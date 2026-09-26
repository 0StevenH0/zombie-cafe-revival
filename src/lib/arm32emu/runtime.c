#include "runtime.h"

#include "mem.h"

#define MAX_THUNKS (ZC_THUNK_SIZE / 4)
#define OVERRIDE_SLOTS 1024 /* power of two */

typedef struct {
    const char *name;
    zc_hle_fn fn;
    uint64_t calls;
} thunk_t;

typedef struct {
    uint32_t addr; /* without the Thumb bit; 0 = empty */
    thunk_t t;
} override_t;

static thunk_t thunks[MAX_THUNKS];
static uint32_t nthunks = 1; /* thunk 0 is the return-to-host address */
static override_t overrides[OVERRIDE_SLOTS];

typedef struct {
    const char *name;
    zc_hle_fn fn;
    uint32_t data;
    uint32_t thunk;
} import_t;
static import_t imports[512];
static int nimports;

static pthread_key_t thread_key;
static pthread_mutex_t thread_lock = PTHREAD_MUTEX_INITIALIZER;
static int next_slot;

/* The guest lock is a FIFO ticket lock, so a thread waiting to deliver a touch
   event is served as soon as the render thread yields. */
static pthread_mutex_t lock_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t lock_cond = PTHREAD_COND_INITIALIZER;
static unsigned next_ticket, now_serving;
static volatile pthread_t lock_owner;
static int lock_depth;

/* ------------------------------------------------------------------ logging */

void zc_log(int level, const char *fmt, ...)
{
    char buf[1024];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof buf, fmt, ap);
    va_end(ap);
#ifdef ZC_ANDROID
    __android_log_write(level, "ZCArm32", buf);
#else
    if (level >= ZC_LOG_INFO || getenv("ZC_DEBUG"))
        fprintf(stderr, "[zc] %s\n", buf);
#endif
}

void zc_fatal(const char *fmt, ...)
{
    char buf[1024];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof buf, fmt, ap);
    va_end(ap);
    zc_log(ZC_LOG_ERROR, "FATAL: %s", buf);
    zc_thread *t = pthread_getspecific(thread_key);
    if (t) {
        zc_cpu *c = &t->cpu;
        zc_log(ZC_LOG_ERROR, "guest pc=%08x lr=%08x sp=%08x cpsr=%08x", c->r[15], c->r[14], c->r[13], zc_cpsr_get(c));
        for (int i = 0; i < 13; i += 4)
            zc_log(ZC_LOG_ERROR, "r%-2d %08x %08x %08x %08x", i, c->r[i], c->r[i + 1], c->r[i + 2], i + 3 < 13 ? c->r[i + 3] : 0);
    }
    abort();
}

/* ------------------------------------------------------------------ threads */

static void on_fault(zc_cpu *c, const char *what, uint32_t pc, uint32_t insn)
{
    (void)c;
    zc_fatal("%s at %08x (insn %08x)", what, pc, insn);
}

static void on_signal(int sig)
{
    zc_thread *t = pthread_getspecific(thread_key);
    if (t) {
        zc_cpu *c = &t->cpu;
        zc_log(ZC_LOG_ERROR, "signal %d in guest code: pc=%08x lr=%08x sp=%08x r0=%08x r1=%08x r2=%08x r3=%08x",
               sig, c->r[15], c->r[14], c->r[13], c->r[0], c->r[1], c->r[2], c->r[3]);
    }
    signal(sig, SIG_DFL);
}

static void on_trap(zc_cpu *c, uint32_t imm, uint32_t pc, int thumb);

int zc_runtime_init(void)
{
    if (zc_mem_init())
        return -1;
    pthread_key_create(&thread_key, NULL);
    zc_trap_handler = on_trap;
    zc_fault_handler = on_fault;
    zc_wr32(ZC_THUNK_BASE, 0xE7F000F0u); /* thunk 0: udf #0, return to host */
    signal(SIGSEGV, on_signal);
    signal(SIGBUS, on_signal);
    return 0;
}

zc_thread *zc_thread_current(void)
{
    zc_thread *t = pthread_getspecific(thread_key);
    if (t)
        return t;
    t = calloc(1, sizeof *t);
    pthread_mutex_lock(&thread_lock);
    t->slot = next_slot++;
    pthread_mutex_unlock(&thread_lock);
    if (t->slot >= ZC_MAX_THREADS)
        zc_fatal("too many guest threads");
    t->cpu.r[13] = zc_stack_top(t->slot);
    t->cpu.user = t;
    pthread_setspecific(thread_key, t);
    return t;
}

static void take_turn(void)
{
    pthread_mutex_lock(&lock_mutex);
    unsigned mine = next_ticket++;
    while (mine != now_serving)
        pthread_cond_wait(&lock_cond, &lock_mutex);
    pthread_mutex_unlock(&lock_mutex);
}

static void end_turn(void)
{
    pthread_mutex_lock(&lock_mutex);
    now_serving++;
    pthread_cond_broadcast(&lock_cond);
    pthread_mutex_unlock(&lock_mutex);
}

void zc_lock(void)
{
    pthread_t self = pthread_self();
    if (lock_depth > 0 && lock_owner == self) {
        lock_depth++;
        return;
    }
    take_turn();
    lock_owner = self;
    lock_depth = 1;
}

void zc_unlock(void)
{
    if (--lock_depth == 0) {
        lock_owner = 0;
        end_turn();
    }
}

int zc_release_all(void)
{
    int d = lock_depth;
    if (d == 0 || lock_owner != pthread_self())
        return 0;
    lock_depth = 0;
    lock_owner = 0;
    end_turn();
    return d;
}

void zc_reacquire(int depth)
{
    if (!depth)
        return;
    take_turn();
    lock_owner = pthread_self();
    lock_depth = depth;
}

/* Lets waiting threads (touch input on the UI thread) run between slices of a
   long guest call, the way they ran in parallel on the original hardware. */
static void maybe_yield(void)
{
    pthread_mutex_lock(&lock_mutex);
    int waiting = next_ticket != now_serving + 1;
    pthread_mutex_unlock(&lock_mutex);
    if (waiting && lock_owner == pthread_self())
        zc_reacquire(zc_release_all());
}

/* -------------------------------------------------------------------- calls */

uint64_t zc_call(zc_cpu *c, uint32_t fn, const uint32_t *words, int nwords)
{
    zc_cpu saved = *c;
    uint32_t sp = c->r[13];
    int nstack = nwords > 4 ? nwords - 4 : 0;
    sp = (sp - 16u - 4u * (uint32_t)nstack) & ~7u;
    for (int i = 0; i < nstack; i++)
        zc_wr32(sp + 4u * (uint32_t)i, words[4 + i]);
    for (int i = 0; i < 4; i++)
        c->r[i] = i < nwords ? words[i] : 0;
    c->r[13] = sp;
    c->r[14] = ZC_THUNK_BASE;
    zc_bx_write(c, fn);
    c->halt = 0;
    while (!zc_run(c, 4000000))
        maybe_yield();
    uint64_t ret = (uint64_t)c->r[0] | ((uint64_t)c->r[1] << 32);
    uint64_t icount = c->icount;
    *c = saved;
    c->icount = icount;
    return ret;
}

/* ------------------------------------------------------------------- thunks */

static uint32_t new_thunk(const char *name, zc_hle_fn fn)
{
    if (nthunks >= MAX_THUNKS)
        zc_fatal("out of thunks");
    uint32_t i = nthunks++;
    thunks[i].name = name;
    thunks[i].fn = fn;
    uint32_t addr = ZC_THUNK_BASE + 4 * i;
    zc_wr32(addr, 0xE7F000F0u | ((i & 0xFFF0u) << 4) | (i & 0xFu));
    return addr;
}

uint32_t zc_hle_thunk(const char *name, zc_hle_fn fn) { return new_thunk(name, fn); }

void zc_hle_register(const char *name, zc_hle_fn fn)
{
    if (nimports >= (int)(sizeof imports / sizeof imports[0]))
        zc_fatal("too many imports");
    imports[nimports].name = name;
    imports[nimports].fn = fn;
    nimports++;
}

void zc_hle_register_data(const char *name, uint32_t addr)
{
    if (nimports >= (int)(sizeof imports / sizeof imports[0]))
        zc_fatal("too many imports");
    imports[nimports].name = name;
    imports[nimports].data = addr;
    nimports++;
}

static int unresolved_call(zc_cpu *c)
{
    uint32_t idx = (c->r[15] - ZC_THUNK_BASE) / 4;
    (void)idx;
    zc_fatal("guest called an import with no host implementation");
    return 0;
}

uint32_t zc_hle_resolve(const char *name, int weak, int is_data)
{
    for (int i = 0; i < nimports; i++) {
        if (strcmp(imports[i].name, name))
            continue;
        if (imports[i].data)
            return imports[i].data;
        if (!imports[i].thunk)
            imports[i].thunk = new_thunk(imports[i].name, imports[i].fn);
        return imports[i].thunk;
    }
    if (weak)
        return 0;
    zc_log(ZC_LOG_WARN, "import %s has no host implementation", name);
    if (is_data)
        return zc_sys_alloc(64, 8);
    char *copy = strdup(name);
    return new_thunk(copy, unresolved_call);
}

void zc_hle_override(uint32_t addr, const char *name, zc_hle_fn fn)
{
    uint32_t a = addr & ~1u;
    uint32_t h = (a >> 1) * 2654435761u;
    for (uint32_t i = 0; i < OVERRIDE_SLOTS; i++) {
        override_t *o = &overrides[(h + i) & (OVERRIDE_SLOTS - 1)];
        if (!o->addr || o->addr == a) {
            o->addr = a;
            o->t.name = name;
            o->t.fn = fn;
            if (addr & 1)
                zc_wr16(a, 0xDEFE); /* udf #0xfe */
            else
                zc_wr32(a, 0xE7FFFFFEu); /* udf #0xfffe */
            return;
        }
    }
    zc_fatal("override table full");
}

static thunk_t *find_override(uint32_t pc)
{
    uint32_t h = (pc >> 1) * 2654435761u;
    for (uint32_t i = 0; i < OVERRIDE_SLOTS; i++) {
        override_t *o = &overrides[(h + i) & (OVERRIDE_SLOTS - 1)];
        if (o->addr == pc)
            return &o->t;
        if (!o->addr)
            return NULL;
    }
    return NULL;
}

static void on_trap(zc_cpu *c, uint32_t imm, uint32_t pc, int thumb)
{
    thunk_t *t;
    if (!thumb && pc >= ZC_THUNK_BASE && pc < ZC_THUNK_BASE + ZC_THUNK_SIZE) {
        uint32_t idx = (pc - ZC_THUNK_BASE) / 4;
        if (idx == 0) {
            c->halt = 1;
            return;
        }
        if (idx >= nthunks)
            zc_fatal("jump into unused thunk %08x", pc);
        t = &thunks[idx];
    } else {
        t = find_override(pc);
        if (!t)
            zc_fatal("undefined instruction (udf #%u) at %08x", imm, pc);
    }
    t->calls++;
    c->r[15] = pc; /* handlers that report the PC see the call site */
    if (!t->fn(c))
        zc_bx_write(c, c->r[14]);
}

static int cmp_calls(const void *a, const void *b)
{
    const thunk_t *x = *(thunk_t *const *)a, *y = *(thunk_t *const *)b;
    return x->calls < y->calls ? 1 : x->calls > y->calls ? -1 : 0;
}

void zc_hle_dump_stats(void)
{
    static thunk_t *list[MAX_THUNKS + OVERRIDE_SLOTS];
    int n = 0;
    for (uint32_t i = 1; i < nthunks; i++)
        if (thunks[i].calls)
            list[n++] = &thunks[i];
    for (int i = 0; i < OVERRIDE_SLOTS; i++)
        if (overrides[i].addr && overrides[i].t.calls)
            list[n++] = &overrides[i].t;
    qsort(list, (size_t)n, sizeof list[0], cmp_calls);
    for (int i = 0; i < n && i < 40; i++)
        zc_log(ZC_LOG_INFO, "  %10llu  %s", (unsigned long long)list[i]->calls, list[i]->name);
}
