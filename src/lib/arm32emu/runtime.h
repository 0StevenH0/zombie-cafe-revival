/*
 * Runtime core: guest threads, the big guest lock, host<->guest calls and the
 * host-call thunks that stand in for the engine's imports.
 */
#ifndef ZC_RUNTIME_H
#define ZC_RUNTIME_H

#include "cpu.h"
#include "platform.h"

typedef struct zc_jni_thread zc_jni_thread;

typedef struct zc_thread {
    zc_cpu cpu;
    int slot;
    void *host_env;        /* JNIEnv* of this host thread, when known */
    zc_jni_thread *jni;    /* local reference frames (jni_bridge.c) */
} zc_thread;

int zc_runtime_init(void);
zc_thread *zc_thread_current(void);

/*
 * One lock serialises guest execution, as on a single core. It is released
 * around calls back into Java so another Java thread can enter the guest
 * while this one waits (the same interleaving points the original had).
 */
void zc_lock(void);
void zc_unlock(void);
int zc_release_all(void);      /* returns the depth to restore */
void zc_reacquire(int depth);

/*
 * Calls guest function `fn` (bit 0 = Thumb) with `words` laid out as the
 * AAPCS argument words (r0-r3 then the stack). Returns r0 | r1 << 32.
 */
uint64_t zc_call(zc_cpu *cpu, uint32_t fn, const uint32_t *words, int nwords);

/* ---- host-call thunks ------------------------------------------------- */

/* Returns 0 to return to the guest caller through LR, 1 if the handler set PC. */
typedef int (*zc_hle_fn)(zc_cpu *c);

void zc_hle_register(const char *name, zc_hle_fn fn);
void zc_hle_register_data(const char *name, uint32_t guest_addr);
/* Loader callback: guest address for an import. */
uint32_t zc_hle_resolve(const char *name, int weak, int is_data);
/* A fresh thunk (for JNI function tables and the like). */
uint32_t zc_hle_thunk(const char *name, zc_hle_fn fn);
/* Replaces the guest function at `addr` (bit 0 = Thumb) with a host handler. */
void zc_hle_override(uint32_t addr, const char *name, zc_hle_fn fn);
void zc_hle_dump_stats(void);

/* ---- argument helpers (AAPCS, soft-float) ----------------------------- */

static inline uint32_t zc_arg(zc_cpu *c, int i)
{
    return i < 4 ? c->r[i] : zc_rd32(c->r[13] + 4u * (uint32_t)(i - 4));
}
static inline float zc_argf(zc_cpu *c, int i)
{
    uint32_t v = zc_arg(c, i);
    float f;
    memcpy(&f, &v, 4);
    return f;
}
/* 64-bit argument whose first word is argument word i (already aligned by caller). */
static inline uint64_t zc_arg64(zc_cpu *c, int i)
{
    return (uint64_t)zc_arg(c, i) | ((uint64_t)zc_arg(c, i + 1) << 32);
}
static inline double zc_argd(zc_cpu *c, int i)
{
    uint64_t v = zc_arg64(c, i);
    double d;
    memcpy(&d, &v, 8);
    return d;
}
static inline void zc_ret(zc_cpu *c, uint32_t v) { c->r[0] = v; }
static inline void zc_ret64(zc_cpu *c, uint64_t v)
{
    c->r[0] = (uint32_t)v;
    c->r[1] = (uint32_t)(v >> 32);
}
static inline void zc_retf(zc_cpu *c, float f)
{
    uint32_t v;
    memcpy(&v, &f, 4);
    c->r[0] = v;
}
static inline void zc_retd(zc_cpu *c, double d)
{
    uint64_t v;
    memcpy(&v, &d, 8);
    zc_ret64(c, v);
}
static inline const char *zc_str(uint32_t p) { return p ? (const char *)zc_g2h(p) : NULL; }
static inline void *zc_ptr(uint32_t p) { return p ? zc_g2h(p) : NULL; }

/*
 * Variadic argument cursor. For "..." arguments start at register `first`;
 * for a va_list start from memory (zc_va_mem). 64-bit values are 8-byte
 * aligned: in registers they take an even pair, on the stack an aligned slot.
 */
typedef struct {
    zc_cpu *c;
    int reg;       /* next core register, 4 = spilled to memory */
    uint32_t mem;  /* next memory address */
} zc_va;

static inline zc_va zc_va_regs(zc_cpu *c, int first)
{
    zc_va v = { c, first, c->r[13] };
    return v;
}
static inline zc_va zc_va_mem(uint32_t addr)
{
    zc_va v = { NULL, 4, addr };
    return v;
}
static inline uint32_t zc_va_u32(zc_va *v)
{
    if (v->reg < 4)
        return v->c->r[v->reg++];
    uint32_t x = zc_rd32(v->mem);
    v->mem += 4;
    return x;
}
static inline uint64_t zc_va_u64(zc_va *v)
{
    if (v->reg < 4) {
        if (v->reg & 1)
            v->reg++;
        if (v->reg < 4) {
            uint64_t x = (uint64_t)v->c->r[v->reg] | ((uint64_t)v->c->r[v->reg + 1] << 32);
            v->reg += 2;
            return x;
        }
    }
    v->mem = (v->mem + 7u) & ~7u;
    uint64_t x = (uint64_t)zc_rd32(v->mem) | ((uint64_t)zc_rd32(v->mem + 4) << 32);
    v->mem += 8;
    return x;
}
static inline double zc_va_double(zc_va *v)
{
    uint64_t x = zc_va_u64(v);
    double d;
    memcpy(&d, &x, 8);
    return d;
}

#endif
