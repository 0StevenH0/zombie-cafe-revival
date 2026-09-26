/*
 * The dynamic-linker view the guest gets: its own libraries only. This is what
 * lets the unmodified ZombieCafeExtension (built for ARMv5TE) find the engine
 * with dlopen/dlsym/dladdr and patch it in place.
 */
#include "hle.h"

#include "mem.h"

static int h_dlopen(zc_cpu *c)
{
    const char *name = zc_str(zc_arg(c, 0));
    const zc_lib *lib = name ? zc_find_lib_by_name(name) : NULL;
    zc_ret(c, lib ? (uint32_t)zc_lib_index(lib) + 1 : 0);
    if (!lib)
        zc_log(ZC_LOG_WARN, "guest dlopen(%s): not a guest library", name ? name : "(null)");
    return 0;
}

static int h_dlsym(zc_cpu *c)
{
    const zc_lib *lib = zc_lib_at((int)zc_arg(c, 0) - 1);
    const char *name = zc_str(zc_arg(c, 1));
    zc_ret(c, lib && name ? zc_elf_sym(lib, name) : 0);
    return 0;
}

static int h_dladdr(zc_cpu *c)
{
    const zc_lib *lib = zc_find_lib(zc_arg(c, 0) & ~1u);
    uint32_t info = zc_arg(c, 1);
    if (!lib || !info) {
        zc_ret(c, 0);
        return 0;
    }
    static uint32_t names[8];
    int i = zc_lib_index(lib);
    if (i >= 0 && i < 8 && !names[i])
        names[i] = zc_sys_strdup(lib->name);
    zc_wr32(info, i >= 0 && i < 8 ? names[i] : 0);
    zc_wr32(info + 4, lib->base);
    zc_wr32(info + 8, 0);
    zc_wr32(info + 12, 0);
    zc_ret(c, 1);
    return 0;
}

/* Guest memory has no page protections to change. */
static int h_mprotect(zc_cpu *c) { zc_ret(c, 0); return 0; }

static int h_sysconf(zc_cpu *c)
{
    uint32_t name = zc_arg(c, 0);
    zc_ret(c, (name == 0x27 || name == 0x28) ? 4096 : 0); /* _SC_PAGESIZE / _SC_PAGE_SIZE */
    return 0;
}

static int h_aeabi_memcpy(zc_cpu *c)
{
    if (zc_arg(c, 2))
        memmove(zc_g2h(zc_arg(c, 0)), zc_g2h(zc_arg(c, 1)), zc_arg(c, 2));
    return 0;
}

static int h_aeabi_memset(zc_cpu *c) /* (dest, n, c): note the argument order */
{
    if (zc_arg(c, 1))
        memset(zc_g2h(zc_arg(c, 0)), (int)zc_arg(c, 2), zc_arg(c, 1));
    return 0;
}

static int h_aeabi_memclr(zc_cpu *c)
{
    if (zc_arg(c, 1))
        memset(zc_g2h(zc_arg(c, 0)), 0, zc_arg(c, 1));
    return 0;
}

static int h_aeabi_idivmod(zc_cpu *c)
{
    int32_t n = (int32_t)zc_arg(c, 0), d = (int32_t)zc_arg(c, 1);
    if (d == 0) { c->r[0] = n ? (n > 0 ? 0x7fffffffu : 0x80000000u) : 0; c->r[1] = 0; return 0; }
    if (n == INT32_MIN && d == -1) { c->r[0] = (uint32_t)INT32_MIN; c->r[1] = 0; return 0; }
    c->r[0] = (uint32_t)(n / d);
    c->r[1] = (uint32_t)(n % d);
    return 0;
}

static int h_aeabi_uidivmod(zc_cpu *c)
{
    uint32_t n = zc_arg(c, 0), d = zc_arg(c, 1);
    if (d == 0) { c->r[0] = n ? 0xffffffffu : 0; c->r[1] = 0; return 0; }
    c->r[0] = n / d;
    c->r[1] = n % d;
    return 0;
}

void zc_hle_dl_init(void)
{
    zc_hle_register("dlopen", h_dlopen);
    zc_hle_register("dlsym", h_dlsym);
    zc_hle_register("dladdr", h_dladdr);
    zc_hle_register("mprotect", h_mprotect);
    zc_hle_register("sysconf", h_sysconf);
    zc_hle_register("__aeabi_memcpy", h_aeabi_memcpy);
    zc_hle_register("__aeabi_memcpy4", h_aeabi_memcpy);
    zc_hle_register("__aeabi_memcpy8", h_aeabi_memcpy);
    zc_hle_register("__aeabi_memmove", h_aeabi_memcpy);
    zc_hle_register("__aeabi_memset", h_aeabi_memset);
    zc_hle_register("__aeabi_memclr", h_aeabi_memclr);
    zc_hle_register("__aeabi_memclr4", h_aeabi_memclr);
    zc_hle_register("__aeabi_memclr8", h_aeabi_memclr);
    zc_hle_register("__aeabi_idiv", h_aeabi_idivmod);
    zc_hle_register("__aeabi_idivmod", h_aeabi_idivmod);
    zc_hle_register("__aeabi_uidiv", h_aeabi_uidivmod);
    zc_hle_register("__aeabi_uidivmod", h_aeabi_uidivmod);
}
