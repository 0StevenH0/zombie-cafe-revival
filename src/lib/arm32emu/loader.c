#include "loader.h"

#include "cpu.h"
#include "hle.h"
#include "mem.h"
#include "platform.h"
#include "runtime.h"

#define PT_LOAD 1
#define PT_DYNAMIC 2
#define PT_ARM_EXIDX 0x70000001
#define DT_NULL 0
#define DT_HASH 4
#define DT_STRTAB 5
#define DT_SYMTAB 6
#define DT_REL 17
#define DT_RELSZ 18
#define DT_JMPREL 23
#define DT_PLTRELSZ 2
#define DT_INIT 12
#define DT_INIT_ARRAY 25
#define DT_INIT_ARRAYSZ 27
#define DT_GNU_HASH 0x6ffffef5
#define R_ARM_NONE 0
#define R_ARM_ABS32 2
#define R_ARM_REL32 3
#define R_ARM_GLOB_DAT 21
#define R_ARM_JUMP_SLOT 22
#define R_ARM_RELATIVE 23
#define STT_OBJECT 1
#define STT_FUNC 2
#define STB_WEAK 2

typedef struct {
    uint8_t ident[16];
    uint16_t type, machine;
    uint32_t version, entry, phoff, shoff, flags;
    uint16_t ehsize, phentsize, phnum, shentsize, shnum, shstrndx;
} Ehdr;
typedef struct { uint32_t type, offset, vaddr, paddr, filesz, memsz, flags, align; } Phdr;
typedef struct { uint32_t name, value, size; uint8_t info, other; uint16_t shndx; } Sym;

static uint32_t gnu_hash_nsyms(uint32_t gh)
{
    uint32_t nbuckets = zc_rd32(gh), symoffset = zc_rd32(gh + 4), bloom_size = zc_rd32(gh + 8);
    uint32_t buckets = gh + 16 + bloom_size * 4, chains = buckets + nbuckets * 4;
    uint32_t last = 0;
    for (uint32_t i = 0; i < nbuckets; i++)
        if (zc_rd32(buckets + 4 * i) > last)
            last = zc_rd32(buckets + 4 * i);
    if (last < symoffset)
        return symoffset;
    while (!(zc_rd32(chains + 4 * (last - symoffset)) & 1))
        last++;
    return last + 1;
}

static Sym read_sym(const zc_lib *lib, uint32_t i)
{
    Sym s;
    memcpy(&s, zc_g2h(lib->symtab + 16 * i), sizeof s);
    return s;
}

static int relocate(zc_lib *lib, uint32_t rel, uint32_t size, zc_resolve_fn resolve)
{
    for (uint32_t off = 0; off + 8 <= size; off += 8) {
        uint32_t where = lib->base + zc_rd32(rel + off);
        uint32_t info = zc_rd32(rel + off + 4);
        uint32_t type = info & 0xff, symi = info >> 8;
        uint32_t s = 0;
        if (symi) {
            Sym sym = read_sym(lib, symi);
            const char *name = zc_g2h(lib->strtab + sym.name);
            if (sym.shndx != 0) {
                s = lib->base + sym.value;
            } else {
                s = resolve(name, (sym.info >> 4) == STB_WEAK, (sym.info & 15) == STT_OBJECT);
                if (!s && (sym.info >> 4) != STB_WEAK) {
                    zc_log(ZC_LOG_ERROR, "%s: unresolved symbol %s", lib->name, name);
                    return -1;
                }
            }
        }
        switch (type) {
        case R_ARM_NONE: break;
        case R_ARM_ABS32: zc_wr32(where, zc_rd32(where) + s); break;
        case R_ARM_REL32: zc_wr32(where, zc_rd32(where) + s - where); break;
        case R_ARM_GLOB_DAT:
        case R_ARM_JUMP_SLOT: zc_wr32(where, s); break;
        case R_ARM_RELATIVE: zc_wr32(where, zc_rd32(where) + lib->base); break;
        default:
            zc_log(ZC_LOG_ERROR, "%s: unsupported relocation type %u at %08x", lib->name, type, where);
            return -1;
        }
    }
    return 0;
}

int zc_elf_load(zc_lib *lib, const char *name, const uint8_t *image, size_t len, uint32_t base,
                zc_resolve_fn resolve)
{
    memset(lib, 0, sizeof *lib);
    snprintf(lib->name, sizeof lib->name, "%s", name);
    lib->base = base;
    Ehdr eh;
    if (len < sizeof eh)
        return -1;
    memcpy(&eh, image, sizeof eh);
    if (memcmp(eh.ident, "\177ELF", 4) || eh.ident[4] != 1 || eh.machine != 40) {
        zc_log(ZC_LOG_ERROR, "%s: not a 32-bit ARM ELF", name);
        return -1;
    }
    uint32_t lo = 0xffffffffu, hi = 0, dyn = 0;
    for (int i = 0; i < eh.phnum; i++) {
        Phdr ph;
        memcpy(&ph, image + eh.phoff + (size_t)i * eh.phentsize, sizeof ph);
        if (ph.type == PT_LOAD) {
            if (ph.vaddr < lo) lo = ph.vaddr;
            if (ph.vaddr + ph.memsz > hi) hi = ph.vaddr + ph.memsz;
        }
    }
    if (hi <= lo)
        return -1;
    lib->lo = base + lo;
    lib->hi = base + hi;
    if (zc_mem_commit(lib->lo, hi - lo))
        return -1;
    for (int i = 0; i < eh.phnum; i++) {
        Phdr ph;
        memcpy(&ph, image + eh.phoff + (size_t)i * eh.phentsize, sizeof ph);
        if (ph.type == PT_LOAD) {
            if ((size_t)ph.offset + ph.filesz > len)
                return -1;
            memcpy(zc_g2h(base + ph.vaddr), image + ph.offset, ph.filesz);
            memset(zc_g2h(base + ph.vaddr + ph.filesz), 0, ph.memsz - ph.filesz);
        } else if (ph.type == PT_DYNAMIC) {
            dyn = base + ph.vaddr;
        } else if (ph.type == PT_ARM_EXIDX) {
            lib->exidx = base + ph.vaddr;
            lib->exidx_count = ph.memsz / 8;
        }
    }
    if (!dyn)
        return -1;

    uint32_t rel = 0, relsz = 0, jmprel = 0, pltrelsz = 0, hash = 0, gnuhash = 0;
    for (uint32_t d = dyn;; d += 8) {
        uint32_t tag = zc_rd32(d), val = zc_rd32(d + 4);
        if (tag == DT_NULL) break;
        switch (tag) {
        case DT_HASH: hash = base + val; break;
        case DT_GNU_HASH: gnuhash = base + val; break;
        case DT_STRTAB: lib->strtab = base + val; break;
        case DT_SYMTAB: lib->symtab = base + val; break;
        case DT_REL: rel = base + val; break;
        case DT_RELSZ: relsz = val; break;
        case DT_JMPREL: jmprel = base + val; break;
        case DT_PLTRELSZ: pltrelsz = val; break;
        case DT_INIT: lib->init = base + val; break;
        case DT_INIT_ARRAY: lib->init_array = base + val; break;
        case DT_INIT_ARRAYSZ: lib->init_array_count = val / 4; break;
        }
    }
    if (hash)
        lib->nsyms = zc_rd32(hash + 4);
    else if (gnuhash)
        lib->nsyms = gnu_hash_nsyms(gnuhash);
    if (!lib->symtab || !lib->strtab || !lib->nsyms)
        return -1;
    if (rel && relocate(lib, rel, relsz, resolve))
        return -1;
    if (jmprel && relocate(lib, jmprel, pltrelsz, resolve))
        return -1;
    zc_log(ZC_LOG_INFO, "loaded %s at %08x-%08x (%u symbols)", name, lib->lo, lib->hi, lib->nsyms);
    return 0;
}

uint32_t zc_elf_sym(const zc_lib *lib, const char *name)
{
    for (uint32_t i = 1; i < lib->nsyms; i++) {
        Sym s = read_sym(lib, i);
        if (s.shndx != 0 && !strcmp(zc_g2h(lib->strtab + s.name), name))
            return lib->base + s.value;
    }
    return 0;
}

void zc_elf_each_sym(const zc_lib *lib, int (*fn)(const char *, uint32_t, int, void *), void *ctx)
{
    for (uint32_t i = 1; i < lib->nsyms; i++) {
        Sym s = read_sym(lib, i);
        if (s.shndx == 0)
            continue;
        if (fn(zc_g2h(lib->strtab + s.name), lib->base + s.value, (s.info & 15) == STT_FUNC, ctx))
            return;
    }
}

void zc_elf_run_init(const zc_lib *lib)
{
    zc_thread *t = zc_thread_current();
    if (lib->init)
        zc_call(&t->cpu, lib->init, NULL, 0);
    for (uint32_t i = 0; i < lib->init_array_count; i++) {
        uint32_t fn = zc_rd32(lib->init_array + 4 * i);
        if (fn && fn != 0xffffffffu)
            zc_call(&t->cpu, fn, NULL, 0);
    }
}

static const zc_lib *libs[8];
static int nlibs;

void zc_register_lib(const zc_lib *lib)
{
    if (nlibs < 8)
        libs[nlibs++] = lib;
}

const zc_lib *zc_find_lib(uint32_t addr)
{
    for (int i = 0; i < nlibs; i++)
        if (addr >= libs[i]->lo && addr < libs[i]->hi)
            return libs[i];
    return NULL;
}

const zc_lib *zc_find_lib_by_name(const char *name)
{
    const char *base = strrchr(name, '/');
    base = base ? base + 1 : name;
    for (int i = 0; i < nlibs; i++)
        if (!strcmp(libs[i]->name, base))
            return libs[i];
    return NULL;
}

int zc_lib_index(const zc_lib *lib)
{
    for (int i = 0; i < nlibs; i++)
        if (libs[i] == lib)
            return i;
    return -1;
}

const zc_lib *zc_lib_at(int i)
{
    return i >= 0 && i < nlibs ? libs[i] : NULL;
}
