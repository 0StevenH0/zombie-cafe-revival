/* Loader for 32-bit ARM ELF shared objects into guest memory. */
#ifndef ZC_LOADER_H
#define ZC_LOADER_H

#include <stddef.h>
#include <stdint.h>

typedef struct zc_lib {
    char name[64];
    uint32_t base;     /* load bias: guest address of vaddr 0 */
    uint32_t lo, hi;   /* guest range covered by PT_LOAD segments */
    uint32_t symtab, strtab, nsyms;
    uint32_t exidx, exidx_count; /* PT_ARM_EXIDX, for __gnu_Unwind_Find_exidx */
    uint32_t init, init_array, init_array_count;
} zc_lib;

/* Resolves an undefined symbol to a guest address (0 = unresolved). */
typedef uint32_t (*zc_resolve_fn)(const char *name, int weak, int is_data);

/* Maps `image` at `base`, applies relocations. Returns 0 on success. */
int zc_elf_load(zc_lib *lib, const char *name, const uint8_t *image, size_t len, uint32_t base,
                zc_resolve_fn resolve);

/* Guest address of an exported symbol (Thumb functions keep bit 0), or 0. */
uint32_t zc_elf_sym(const zc_lib *lib, const char *name);

/* Iterates exported symbols; stops early when fn returns nonzero. */
void zc_elf_each_sym(const zc_lib *lib, int (*fn)(const char *name, uint32_t addr, int is_func, void *ctx), void *ctx);

/* Runs DT_INIT and DT_INIT_ARRAY in the guest (needs the runtime). */
void zc_elf_run_init(const zc_lib *lib);

#endif
