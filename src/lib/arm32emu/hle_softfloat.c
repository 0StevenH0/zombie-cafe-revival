/*
 * The engine is soft-float: every float operation is a call into libgcc's
 * helpers, statically linked into the engine as ARM code. Running those
 * bit-twiddling routines through the interpreter dominates the frame time,
 * so the common ones are replaced with host FPU operations. Results follow
 * IEEE-754 round-to-nearest like the libgcc code they replace; float->int
 * conversions saturate the way libgcc's do.
 */
#include "hle.h"

static inline float F(zc_cpu *c, int i) { return zc_argf(c, i); }
static inline double D(zc_cpu *c, int i) { return zc_argd(c, i); }

static int32_t f2i(double v)
{
    if (v != v) return 0;
    if (v >= 2147483648.0) return INT32_MAX;
    if (v <= -2147483649.0) return INT32_MIN;
    return (int32_t)v;
}

static uint32_t f2u(double v)
{
    if (v != v || v <= -1.0) return 0;
    if (v >= 4294967296.0) return UINT32_MAX;
    return v < 0 ? 0 : (uint32_t)v;
}

static int64_t f2l(double v)
{
    if (v != v) return 0;
    if (v >= 9223372036854775808.0) return INT64_MAX;
    if (v < -9223372036854775808.0) return INT64_MIN;
    return (int64_t)v;
}

static uint64_t f2ul(double v)
{
    if (v != v || v <= -1.0) return 0;
    if (v >= 18446744073709551616.0) return UINT64_MAX;
    return v < 0 ? 0 : (uint64_t)v;
}

static int h_fadd(zc_cpu *c) { zc_retf(c, F(c, 0) + F(c, 1)); return 0; }
static int h_fsub(zc_cpu *c) { zc_retf(c, F(c, 0) - F(c, 1)); return 0; }
static int h_frsub(zc_cpu *c) { zc_retf(c, F(c, 1) - F(c, 0)); return 0; }
static int h_fmul(zc_cpu *c) { zc_retf(c, F(c, 0) * F(c, 1)); return 0; }
static int h_fdiv(zc_cpu *c) { zc_retf(c, F(c, 0) / F(c, 1)); return 0; }
static int h_i2f(zc_cpu *c) { zc_retf(c, (float)(int32_t)zc_arg(c, 0)); return 0; }
static int h_ui2f(zc_cpu *c) { zc_retf(c, (float)zc_arg(c, 0)); return 0; }
static int h_l2f(zc_cpu *c) { zc_retf(c, (float)(int64_t)zc_arg64(c, 0)); return 0; }
static int h_ul2f(zc_cpu *c) { zc_retf(c, (float)zc_arg64(c, 0)); return 0; }
static int h_f2iz(zc_cpu *c) { zc_ret(c, (uint32_t)f2i(F(c, 0))); return 0; }
static int h_f2uiz(zc_cpu *c) { zc_ret(c, f2u(F(c, 0))); return 0; }
static int h_f2lz(zc_cpu *c) { zc_ret64(c, (uint64_t)f2l(F(c, 0))); return 0; }
static int h_f2ulz(zc_cpu *c) { zc_ret64(c, f2ul(F(c, 0))); return 0; }
static int h_f2d(zc_cpu *c) { zc_retd(c, (double)F(c, 0)); return 0; }
static int h_fcmpeq(zc_cpu *c) { zc_ret(c, F(c, 0) == F(c, 1)); return 0; }
static int h_fcmplt(zc_cpu *c) { zc_ret(c, F(c, 0) < F(c, 1)); return 0; }
static int h_fcmple(zc_cpu *c) { zc_ret(c, F(c, 0) <= F(c, 1)); return 0; }
static int h_fcmpge(zc_cpu *c) { zc_ret(c, F(c, 0) >= F(c, 1)); return 0; }
static int h_fcmpgt(zc_cpu *c) { zc_ret(c, F(c, 0) > F(c, 1)); return 0; }
static int h_fcmpun(zc_cpu *c) { float a = F(c, 0), b = F(c, 1); zc_ret(c, a != a || b != b); return 0; }

static int h_dadd(zc_cpu *c) { zc_retd(c, D(c, 0) + D(c, 2)); return 0; }
static int h_dsub(zc_cpu *c) { zc_retd(c, D(c, 0) - D(c, 2)); return 0; }
static int h_drsub(zc_cpu *c) { zc_retd(c, D(c, 2) - D(c, 0)); return 0; }
static int h_dmul(zc_cpu *c) { zc_retd(c, D(c, 0) * D(c, 2)); return 0; }
static int h_ddiv(zc_cpu *c) { zc_retd(c, D(c, 0) / D(c, 2)); return 0; }
static int h_i2d(zc_cpu *c) { zc_retd(c, (double)(int32_t)zc_arg(c, 0)); return 0; }
static int h_ui2d(zc_cpu *c) { zc_retd(c, (double)zc_arg(c, 0)); return 0; }
static int h_l2d(zc_cpu *c) { zc_retd(c, (double)(int64_t)zc_arg64(c, 0)); return 0; }
static int h_ul2d(zc_cpu *c) { zc_retd(c, (double)zc_arg64(c, 0)); return 0; }
static int h_d2iz(zc_cpu *c) { zc_ret(c, (uint32_t)f2i(D(c, 0))); return 0; }
static int h_d2uiz(zc_cpu *c) { zc_ret(c, f2u(D(c, 0))); return 0; }
static int h_d2lz(zc_cpu *c) { zc_ret64(c, (uint64_t)f2l(D(c, 0))); return 0; }
static int h_d2ulz(zc_cpu *c) { zc_ret64(c, f2ul(D(c, 0))); return 0; }
static int h_d2f(zc_cpu *c) { zc_retf(c, (float)D(c, 0)); return 0; }
static int h_dcmpeq(zc_cpu *c) { zc_ret(c, D(c, 0) == D(c, 2)); return 0; }
static int h_dcmplt(zc_cpu *c) { zc_ret(c, D(c, 0) < D(c, 2)); return 0; }
static int h_dcmple(zc_cpu *c) { zc_ret(c, D(c, 0) <= D(c, 2)); return 0; }
static int h_dcmpge(zc_cpu *c) { zc_ret(c, D(c, 0) >= D(c, 2)); return 0; }
static int h_dcmpgt(zc_cpu *c) { zc_ret(c, D(c, 0) > D(c, 2)); return 0; }
static int h_dcmpun(zc_cpu *c) { double a = D(c, 0), b = D(c, 2); zc_ret(c, a != a || b != b); return 0; }

/* Integer division helpers (ARMv5 has no divide instruction). */
static int h_idivmod(zc_cpu *c)
{
    int32_t n = (int32_t)zc_arg(c, 0), d = (int32_t)zc_arg(c, 1);
    if (d == 0) {
        /* libgcc calls __aeabi_idiv0, which returns its argument */
        c->r[0] = 0;
        c->r[1] = (uint32_t)n;
        return 0;
    }
    if (n == INT32_MIN && d == -1) {
        c->r[0] = (uint32_t)INT32_MIN;
        c->r[1] = 0;
        return 0;
    }
    c->r[0] = (uint32_t)(n / d);
    c->r[1] = (uint32_t)(n % d);
    return 0;
}

static int h_uidivmod(zc_cpu *c)
{
    uint32_t n = zc_arg(c, 0), d = zc_arg(c, 1);
    if (d == 0) {
        c->r[0] = 0;
        c->r[1] = n;
        return 0;
    }
    c->r[0] = n / d;
    c->r[1] = n % d;
    return 0;
}

typedef struct {
    const char *name;
    zc_hle_fn fn;
} sf_t;

static const sf_t helpers[] = {
    { "__aeabi_fadd", h_fadd }, { "__addsf3", h_fadd }, { "__aeabi_fsub", h_fsub }, { "__subsf3", h_fsub },
    { "__aeabi_frsub", h_frsub }, { "__aeabi_fmul", h_fmul }, { "__mulsf3", h_fmul }, { "__aeabi_fdiv", h_fdiv },
    { "__divsf3", h_fdiv }, { "__aeabi_i2f", h_i2f }, { "__floatsisf", h_i2f }, { "__aeabi_ui2f", h_ui2f },
    { "__floatunsisf", h_ui2f }, { "__aeabi_l2f", h_l2f }, { "__floatdisf", h_l2f }, { "__aeabi_ul2f", h_ul2f },
    { "__floatundisf", h_ul2f }, { "__aeabi_f2iz", h_f2iz }, { "__fixsfsi", h_f2iz }, { "__aeabi_f2uiz", h_f2uiz },
    { "__fixunssfsi", h_f2uiz }, { "__aeabi_f2lz", h_f2lz }, { "__fixsfdi", h_f2lz }, { "__aeabi_f2ulz", h_f2ulz },
    { "__fixunssfdi", h_f2ulz }, { "__aeabi_f2d", h_f2d }, { "__extendsfdf2", h_f2d },
    { "__aeabi_fcmpeq", h_fcmpeq }, { "__aeabi_fcmplt", h_fcmplt }, { "__aeabi_fcmple", h_fcmple },
    { "__aeabi_fcmpge", h_fcmpge }, { "__aeabi_fcmpgt", h_fcmpgt }, { "__aeabi_fcmpun", h_fcmpun },
    { "__aeabi_dadd", h_dadd }, { "__adddf3", h_dadd }, { "__aeabi_dsub", h_dsub }, { "__subdf3", h_dsub },
    { "__aeabi_drsub", h_drsub }, { "__aeabi_dmul", h_dmul }, { "__muldf3", h_dmul }, { "__aeabi_ddiv", h_ddiv },
    { "__divdf3", h_ddiv }, { "__aeabi_i2d", h_i2d }, { "__floatsidf", h_i2d }, { "__aeabi_ui2d", h_ui2d },
    { "__floatunsidf", h_ui2d }, { "__aeabi_l2d", h_l2d }, { "__floatdidf", h_l2d }, { "__aeabi_ul2d", h_ul2d },
    { "__floatundidf", h_ul2d }, { "__aeabi_d2iz", h_d2iz }, { "__fixdfsi", h_d2iz }, { "__aeabi_d2uiz", h_d2uiz },
    { "__fixunsdfsi", h_d2uiz }, { "__aeabi_d2lz", h_d2lz }, { "__fixdfdi", h_d2lz }, { "__aeabi_d2ulz", h_d2ulz },
    { "__fixunsdfdi", h_d2ulz }, { "__aeabi_d2f", h_d2f }, { "__truncdfsf2", h_d2f },
    { "__aeabi_dcmpeq", h_dcmpeq }, { "__aeabi_dcmplt", h_dcmplt }, { "__aeabi_dcmple", h_dcmple },
    { "__aeabi_dcmpge", h_dcmpge }, { "__aeabi_dcmpgt", h_dcmpgt }, { "__aeabi_dcmpun", h_dcmpun },
    { "__aeabi_idiv", h_idivmod }, { "__aeabi_idivmod", h_idivmod }, { "__divsi3", h_idivmod },
    { "__aeabi_uidiv", h_uidivmod }, { "__aeabi_uidivmod", h_uidivmod }, { "__udivsi3", h_uidivmod },
};

void zc_hle_softfloat_init(const zc_lib *lib)
{
    if (getenv("ZC_NO_SOFTFLOAT_HLE"))
        return;
    int n = 0;
    uint32_t done[sizeof helpers / sizeof helpers[0]];
    for (size_t i = 0; i < sizeof helpers / sizeof helpers[0]; i++) {
        uint32_t addr = zc_elf_sym(lib, helpers[i].name);
        if (!addr)
            continue;
        int dup = 0;
        for (int k = 0; k < n; k++)
            if (done[k] == addr)
                dup = 1;
        if (dup)
            continue;
        zc_hle_override(addr, helpers[i].name, helpers[i].fn);
        done[n++] = addr;
    }
    zc_log(ZC_LOG_INFO, "replaced %d soft-float/division helpers in %s", n, lib->name);
}
