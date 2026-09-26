/*
 * Guest address space and a boundary-tag heap living inside it.
 *
 * Chunks follow the dlmalloc layout: an 8-byte header (prev_size, size|flags)
 * and 8-byte aligned payloads, so guest code sees the same alignment bionic's
 * allocator gave it. Free chunks carry fd/bk links (guest addresses) and are
 * kept in exact-size bins up to 1 KB and power-of-two bins above that. The
 * heap grows by committing more of the reservation.
 */
#include "mem.h"

#include "cpu.h"
#include "platform.h"

#define HDR 8u
#define MIN_CHUNK 16u
#define INUSE 1u
#define PREV_INUSE 2u
#define NSMALL 130u /* chunk sizes 0..1039 by 8 */
#define NLARGE 22u  /* 1 KB .. 4 GB by power of two */
#define NBINS (NSMALL + NLARGE)
#define GROW_STEP (4u << 20)

static uint32_t page_mask;
static pthread_mutex_t heap_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t sys_lock = PTHREAD_MUTEX_INITIALIZER;
static uint32_t bins[NBINS];
static uint32_t binmap[(NBINS + 31) / 32];
static uint32_t top, heap_end;
static uint64_t in_use;
static uint32_t sys_next = ZC_SYS_BASE;
static unsigned bad_frees;

int zc_mem_commit(uint32_t addr, uint32_t size)
{
    uint64_t start = addr & ~(uint64_t)page_mask;
    uint64_t end = ((uint64_t)addr + size + page_mask) & ~(uint64_t)page_mask;
    if (end > (1ull << 32))
        return -1;
    return mprotect(zc_mem + start, (size_t)(end - start), PROT_READ | PROT_WRITE);
}

int zc_mem_init(void)
{
    long ps = sysconf(_SC_PAGESIZE);
    page_mask = (uint32_t)((ps > 0 ? ps : 4096) - 1);
    void *p = mmap(NULL, (size_t)1 << 32, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, -1, 0);
    if (p == MAP_FAILED)
        return -1;
    zc_mem = p;
    if (zc_mem_commit(ZC_SYS_BASE, ZC_SYS_SIZE) || zc_mem_commit(ZC_THUNK_BASE, ZC_THUNK_SIZE))
        return -1;
    if (zc_mem_commit(ZC_HEAP_BASE, GROW_STEP))
        return -1;
    heap_end = ZC_HEAP_BASE + GROW_STEP;
    top = ZC_HEAP_BASE;
    zc_wr32(top, 0);
    zc_wr32(top + 4, (heap_end - top) | PREV_INUSE);
    return 0;
}

static inline uint32_t head(uint32_t c) { return zc_rd32(c + 4); }
static inline uint32_t csize(uint32_t c) { return zc_rd32(c + 4) & ~7u; }
static inline void set_head(uint32_t c, uint32_t v) { zc_wr32(c + 4, v); }
static inline void set_foot(uint32_t c, uint32_t size) { zc_wr32(c + size, size); }
static inline uint32_t fd(uint32_t c) { return zc_rd32(c + 8); }
static inline uint32_t bk(uint32_t c) { return zc_rd32(c + 12); }

static inline uint32_t bin_index(uint32_t size)
{
    if (size < NSMALL * 8)
        return size >> 3;
    uint32_t b = 31u - (uint32_t)__builtin_clz(size); /* >= 10 */
    uint32_t i = NSMALL + (b - 10);
    return i < NBINS ? i : NBINS - 1;
}

static void bin_insert(uint32_t c, uint32_t size)
{
    uint32_t i = bin_index(size), h = bins[i];
    zc_wr32(c + 8, h);
    zc_wr32(c + 12, 0);
    if (h)
        zc_wr32(h + 12, c);
    bins[i] = c;
    binmap[i >> 5] |= 1u << (i & 31);
}

static void bin_unlink(uint32_t c, uint32_t size)
{
    uint32_t i = bin_index(size), f = fd(c), b = bk(c);
    if (b)
        zc_wr32(b + 8, f);
    else
        bins[i] = f;
    if (f)
        zc_wr32(f + 12, b);
    if (!bins[i])
        binmap[i >> 5] &= ~(1u << (i & 31));
}

static int grow(uint32_t need)
{
    uint64_t want = (uint64_t)top + need + MIN_CHUNK;
    if (want <= heap_end)
        return 0;
    uint64_t new_end = ((want - ZC_HEAP_BASE + GROW_STEP - 1) / GROW_STEP) * GROW_STEP + ZC_HEAP_BASE;
    if (new_end > ZC_HEAP_LIMIT)
        return -1;
    if (zc_mem_commit(heap_end, (uint32_t)(new_end - heap_end)))
        return -1;
    heap_end = (uint32_t)new_end;
    set_head(top, (heap_end - top) | (head(top) & PREV_INUSE));
    return 0;
}

/* Carves `need` bytes off the front of free chunk c (already unlinked). */
static uint32_t take(uint32_t c, uint32_t need)
{
    uint32_t size = csize(c), prev = head(c) & PREV_INUSE;
    if (size - need >= MIN_CHUNK) {
        uint32_t r = c + need, rem = size - need;
        set_head(r, rem | PREV_INUSE);
        set_foot(r, rem);
        bin_insert(r, rem);
        set_head(c, need | INUSE | prev);
    } else {
        need = size;
        set_head(c, size | INUSE | prev);
        uint32_t n = c + size;
        set_head(n, head(n) | PREV_INUSE);
    }
    in_use += need;
    return c + HDR;
}

static uint32_t malloc_locked(uint32_t n)
{
    if (n > 0x7ffff000u)
        return 0;
    uint32_t need = (n + HDR + 7u) & ~7u;
    if (need < MIN_CHUNK)
        need = MIN_CHUNK;

    uint32_t i = bin_index(need);
    if (i < NSMALL && bins[i]) {
        uint32_t c = bins[i];
        bin_unlink(c, need);
        return take(c, need);
    }
    for (; i < NBINS; i++) {
        if (!(binmap[i >> 5] >> (i & 31) & 1)) {
            if ((binmap[i >> 5] >> (i & 31)) == 0)
                i |= 31; /* skip the rest of this word */
            continue;
        }
        for (uint32_t c = bins[i]; c; c = fd(c)) {
            uint32_t size = csize(c);
            if (size >= need) {
                bin_unlink(c, size);
                return take(c, need);
            }
        }
    }
    if (grow(need))
        return 0;
    uint32_t c = top, prev = head(top) & PREV_INUSE;
    top += need;
    set_head(top, (heap_end - top) | PREV_INUSE);
    set_head(c, need | INUSE | prev);
    in_use += need;
    return c + HDR;
}

static int valid_chunk(uint32_t p)
{
    if (p < ZC_HEAP_BASE + HDR || p >= top || (p & 7u))
        return 0;
    uint32_t c = p - HDR, h = head(c);
    return (h & INUSE) && (h & ~7u) >= MIN_CHUNK && c + (h & ~7u) <= top;
}

static void free_locked(uint32_t p)
{
    if (!valid_chunk(p)) {
        if (bad_frees++ < 16)
            zc_log(ZC_LOG_WARN, "ignoring free of %08x (not a live heap block)", p);
        return;
    }
    uint32_t c = p - HDR, size = csize(c);
    in_use -= size;
    if (!(head(c) & PREV_INUSE)) {
        uint32_t psz = zc_rd32(c);
        c -= psz;
        bin_unlink(c, psz);
        size += psz;
    }
    uint32_t n = c + size;
    if (n == top) {
        top = c;
        set_head(top, (heap_end - top) | PREV_INUSE);
        return;
    }
    uint32_t nh = head(n);
    if (!(nh & INUSE)) {
        uint32_t nsz = nh & ~7u;
        bin_unlink(n, nsz);
        size += nsz;
    }
    set_head(c, size | PREV_INUSE);
    set_foot(c, size); /* prev_size of the following chunk (or top) */
    n = c + size;
    set_head(n, head(n) & ~PREV_INUSE);
    bin_insert(c, size);
}

uint32_t zc_malloc(uint32_t n)
{
    pthread_mutex_lock(&heap_lock);
    uint32_t p = malloc_locked(n);
    pthread_mutex_unlock(&heap_lock);
    if (!p)
        zc_log(ZC_LOG_ERROR, "guest heap exhausted (request %u, in use %llu)", n, (unsigned long long)in_use);
    return p;
}

uint32_t zc_calloc(uint32_t n, uint32_t size)
{
    uint64_t total = (uint64_t)n * size;
    if (total > 0x7ffff000u)
        return 0;
    uint32_t p = zc_malloc((uint32_t)total);
    if (p)
        memset(zc_g2h(p), 0, (size_t)total);
    return p;
}

void zc_free(uint32_t p)
{
    if (!p)
        return;
    pthread_mutex_lock(&heap_lock);
    free_locked(p);
    pthread_mutex_unlock(&heap_lock);
}

uint32_t zc_malloc_usable(uint32_t p)
{
    return p ? csize(p - HDR) - HDR : 0;
}

uint32_t zc_realloc(uint32_t p, uint32_t n)
{
    if (!p)
        return zc_malloc(n);
    if (!n) {
        zc_free(p);
        return 0;
    }
    pthread_mutex_lock(&heap_lock);
    if (!valid_chunk(p)) {
        pthread_mutex_unlock(&heap_lock);
        zc_log(ZC_LOG_ERROR, "realloc of %08x (not a live heap block)", p);
        return 0;
    }
    uint32_t c = p - HDR, size = csize(c);
    uint32_t need = (n + HDR + 7u) & ~7u;
    if (need < MIN_CHUNK)
        need = MIN_CHUNK;
    if (need <= size) {
        pthread_mutex_unlock(&heap_lock);
        return p;
    }
    uint32_t nx = c + size;
    if (nx == top && grow(need - size) == 0) {
        uint32_t extra = need - size;
        top += extra;
        set_head(top, (heap_end - top) | PREV_INUSE);
        set_head(c, need | INUSE | (head(c) & PREV_INUSE));
        in_use += extra;
        pthread_mutex_unlock(&heap_lock);
        return p;
    }
    uint32_t q = malloc_locked(n);
    if (q) {
        memcpy(zc_g2h(q), zc_g2h(p), size - HDR);
        free_locked(p);
    }
    pthread_mutex_unlock(&heap_lock);
    return q;
}

uint64_t zc_heap_in_use(void) { return in_use; }

uint32_t zc_sys_alloc(uint32_t size, uint32_t align)
{
    pthread_mutex_lock(&sys_lock);
    uint32_t p = (sys_next + align - 1) & ~(align - 1);
    if ((uint64_t)p + size > (uint64_t)ZC_SYS_BASE + ZC_SYS_SIZE)
        zc_fatal("runtime data region exhausted");
    sys_next = p + size;
    pthread_mutex_unlock(&sys_lock);
    memset(zc_g2h(p), 0, size);
    return p;
}

uint32_t zc_strdup_to_guest(const char *s)
{
    size_t n = strlen(s) + 1;
    uint32_t p = zc_malloc((uint32_t)n);
    if (p)
        memcpy(zc_g2h(p), s, n);
    return p;
}

uint32_t zc_sys_strdup(const char *s)
{
    size_t n = strlen(s) + 1;
    uint32_t p = zc_sys_alloc((uint32_t)n, 4);
    memcpy(zc_g2h(p), s, n);
    return p;
}

uint32_t zc_stack_top(int slot)
{
    uint32_t lo = ZC_STACK_BASE + (uint32_t)slot * ZC_STACK_SLOT;
    if (zc_mem_commit(lo + ZC_STACK_GUARD, ZC_STACK_SLOT - ZC_STACK_GUARD))
        zc_fatal("cannot commit guest stack %d", slot);
    return lo + ZC_STACK_SLOT - 64;
}
