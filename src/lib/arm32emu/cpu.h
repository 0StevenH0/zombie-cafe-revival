/*
 * ARMv5TE interpreter (ARM + Thumb-1) for running the 32-bit game engine on
 * 64-bit-only devices. Guest memory is a flat 4 GB reservation: guest address
 * `a` lives at host address `zc_mem + a`, so guest pointers translate with one
 * add and the host can pass guest buffers straight to GL, zlib and libc.
 */
#ifndef ZC_CPU_H
#define ZC_CPU_H

#include <stdint.h>
#include <string.h>

extern uint8_t *zc_mem;

static inline void *zc_g2h(uint32_t a) { return zc_mem + a; }
static inline uint32_t zc_h2g(const void *p) { return (uint32_t)((const uint8_t *)p - zc_mem); }

static inline uint32_t zc_rd32(uint32_t a) { uint32_t v; memcpy(&v, zc_mem + a, 4); return v; }
static inline uint32_t zc_rd16(uint32_t a) { uint16_t v; memcpy(&v, zc_mem + a, 2); return v; }
static inline uint32_t zc_rd8(uint32_t a) { return zc_mem[a]; }
static inline void zc_wr32(uint32_t a, uint32_t v) { memcpy(zc_mem + a, &v, 4); }
static inline void zc_wr16(uint32_t a, uint32_t v) { uint16_t h = (uint16_t)v; memcpy(zc_mem + a, &h, 2); }
static inline void zc_wr8(uint32_t a, uint32_t v) { zc_mem[a] = (uint8_t)v; }

typedef struct zc_cpu {
    uint32_t r[16];
    /* Flags are kept unpacked (0 or 1) so condition checks stay cheap. */
    uint32_t n, z, c, v, q;
    uint32_t t;      /* 1 while executing Thumb code */
    uint32_t halt;   /* set by a trap handler to leave zc_run() */
    uint64_t icount; /* instructions retired, for profiling */
    void *user;
} zc_cpu;

/*
 * Called for permanently-undefined instructions, which the runtime plants as
 * host-call traps: Thumb `udf #imm8` (0xDExx) and ARM `udf #imm16`
 * (0xE7F...F.). The handler returns to the guest by writing PC (see
 * zc_bx_write), or sets cpu->halt. `pc` is the address of the trapping
 * instruction; cpu->r[15] already points past it.
 */
typedef void (*zc_trap_fn)(zc_cpu *cpu, uint32_t imm, uint32_t pc, int thumb);
extern zc_trap_fn zc_trap_handler;

/* Fatal guest condition (undefined instruction, SWI, BKPT...). Does not return. */
typedef void (*zc_fault_fn)(zc_cpu *cpu, const char *what, uint32_t pc, uint32_t insn);
extern zc_fault_fn zc_fault_handler;

uint32_t zc_cpsr_get(const zc_cpu *cpu);
void zc_cpsr_set(zc_cpu *cpu, uint32_t cpsr);

/* Interworking branch: bit 0 selects Thumb, as BX does. */
static inline void zc_bx_write(zc_cpu *cpu, uint32_t addr)
{
    if (addr & 1) {
        cpu->t = 1;
        cpu->r[15] = addr & ~1u;
    } else {
        cpu->t = 0;
        cpu->r[15] = addr & ~3u;
    }
}

/* Executes until a trap handler sets cpu->halt or `max` instructions retire.
   Returns 1 if halted, 0 if the budget ran out. */
int zc_run(zc_cpu *cpu, uint64_t max);

/* Optional PC sampling (every ~1000 instructions) for profiling. */
extern void (*zc_sample_hook)(uint32_t pc);
/* Optional hook on every BL/BLX (target has bit 0 set for Thumb), for tracing. */
extern void (*zc_call_hook)(uint32_t target, uint32_t from);

/* Executes exactly one instruction (a Thumb BL/BLX pair counts as one). */
void zc_step(zc_cpu *cpu);

#endif
