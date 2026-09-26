/* PC-sampling profiler (ZC_PROFILE=1): which guest functions the time goes to. */
#include "hle.h"

#define SLOTS (1u << 16)
static uint32_t keys[SLOTS], counts[SLOTS];
static uint64_t total;

static void sample(uint32_t pc)
{
    uint32_t h = (pc >> 1) * 2654435761u;
    for (uint32_t i = 0; i < SLOTS; i++) {
        uint32_t k = (h + i) & (SLOTS - 1);
        if (keys[k] == pc || !keys[k]) {
            keys[k] = pc;
            counts[k]++;
            total++;
            return;
        }
    }
}

void zc_profile_init(void)
{
    if (getenv("ZC_PROFILE"))
        zc_sample_hook = sample;
}

typedef struct { uint32_t addr; const char *name; uint64_t hits; } fn_t;
static fn_t *fns;
static size_t nfns, capfns;

static int collect(const char *name, uint32_t addr, int is_func, void *ctx)
{
    (void)ctx;
    if (!is_func)
        return 0;
    if (nfns == capfns) {
        capfns = capfns ? capfns * 2 : 4096;
        fns = realloc(fns, capfns * sizeof *fns);
    }
    fns[nfns].addr = addr & ~1u;
    fns[nfns].name = name;
    fns[nfns].hits = 0;
    nfns++;
    return 0;
}

static int by_addr(const void *a, const void *b)
{
    const fn_t *x = a, *y = b;
    return x->addr < y->addr ? -1 : x->addr > y->addr;
}

static int by_hits(const void *a, const void *b)
{
    const fn_t *x = a, *y = b;
    return x->hits < y->hits ? 1 : x->hits > y->hits ? -1 : 0;
}

void zc_profile_dump(const zc_lib *lib, int top)
{
    if (!zc_sample_hook || !total)
        return;
    nfns = 0;
    zc_elf_each_sym(lib, collect, NULL);
    qsort(fns, nfns, sizeof *fns, by_addr);
    uint64_t outside = 0;
    for (uint32_t k = 0; k < SLOTS; k++) {
        if (!keys[k])
            continue;
        size_t lo = 0, hi = nfns;
        while (lo < hi) {
            size_t mid = (lo + hi) / 2;
            if (fns[mid].addr <= keys[k]) lo = mid + 1; else hi = mid;
        }
        if (lo == 0 || keys[k] < lib->lo || keys[k] >= lib->hi)
            outside += counts[k];
        else
            fns[lo - 1].hits += counts[k];
    }
    qsort(fns, nfns, sizeof *fns, by_hits);
    zc_log(ZC_LOG_INFO, "profile: %llu samples (%llu outside %s)", (unsigned long long)total,
           (unsigned long long)outside, lib->name);
    for (int i = 0; i < top && (size_t)i < nfns && fns[i].hits; i++)
        zc_log(ZC_LOG_INFO, "  %5.1f%%  %s", 100.0 * (double)fns[i].hits / (double)total, fns[i].name);
    memset(keys, 0, sizeof keys);
    memset(counts, 0, sizeof counts);
    total = 0;
}

/* ---- first-call tracing: logs each guest function the first time it is
   called after tracing starts (ZC_TRACE_NEW or zc_trace_new_calls(1)). */

#define SEEN_SLOTS (1u << 18)
static uint32_t *seen;
static const zc_lib *trace_lib;
static size_t traced;
static int trace_logging;

static const char *symbol_for(uint32_t addr)
{
    if (!nfns) {
        zc_elf_each_sym(trace_lib, collect, NULL);
        qsort(fns, nfns, sizeof *fns, by_addr);
    }
    size_t lo = 0, hi = nfns;
    uint32_t a = addr & ~1u;
    while (lo < hi) {
        size_t mid = (lo + hi) / 2;
        if (fns[mid].addr <= a) lo = mid + 1; else hi = mid;
    }
    return lo ? fns[lo - 1].name : "?";
}

static void on_call(uint32_t target, uint32_t from)
{
    uint32_t h = (target >> 1) * 2654435761u;
    for (uint32_t i = 0; i < SEEN_SLOTS; i++) {
        uint32_t k = (h + i) & (SEEN_SLOTS - 1);
        if (seen[k] == target)
            return;
        if (!seen[k]) {
            seen[k] = target;
            if (trace_logging && traced++ < 4000 && target >= trace_lib->lo && target < trace_lib->hi)
                zc_log(ZC_LOG_INFO, "first call %08x %s (from %s)", target, symbol_for(target), symbol_for(from));
            return;
        }
    }
}

/* mode 0: off, 1: record calls silently, 2: log functions not seen before. */
void zc_trace_new_calls(const zc_lib *lib, int mode)
{
    trace_lib = lib;
    if (mode && !seen)
        seen = calloc(SEEN_SLOTS, sizeof *seen);
    trace_logging = mode == 2;
    zc_call_hook = mode ? on_call : NULL;
}
