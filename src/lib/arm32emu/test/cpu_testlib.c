/* Host-only shim exposing the interpreter to test/cpu_diff.py through ctypes. */
#include "../cpu.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

static char last_fault[128];
static uint32_t last_trap = 0xffffffffu;

static void on_fault(zc_cpu *cpu, const char *what, uint32_t pc, uint32_t insn)
{
    snprintf(last_fault, sizeof last_fault, "%s at %08x (%08x)", what, pc, insn);
    cpu->halt = 1;
}

static void on_trap(zc_cpu *cpu, uint32_t imm, uint32_t pc, int thumb)
{
    (void)pc;
    (void)thumb;
    last_trap = imm;
    zc_bx_write(cpu, cpu->r[14]);
}

int zt_init(void)
{
    void *p = mmap(NULL, 1ull << 32, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, -1, 0);
    if (p == MAP_FAILED)
        return -1;
    zc_mem = p;
    zc_fault_handler = on_fault;
    zc_trap_handler = on_trap;
    return 0;
}

int zt_map(uint32_t addr, uint32_t size)
{
    return mprotect(zc_mem + addr, size, PROT_READ | PROT_WRITE);
}

void *zt_ptr(uint32_t addr) { return zc_mem + addr; }

zc_cpu *zt_cpu_new(void) { return calloc(1, sizeof(zc_cpu)); }

void zt_set_reg(zc_cpu *c, int i, uint32_t v) { c->r[i] = v; }
uint32_t zt_get_reg(zc_cpu *c, int i) { return c->r[i]; }
void zt_set_cpsr(zc_cpu *c, uint32_t v) { zc_cpsr_set(c, v); }
uint32_t zt_get_cpsr(zc_cpu *c) { return zc_cpsr_get(c); }
void zt_step(zc_cpu *c) { c->halt = 0; zc_step(c); }
int zt_run(zc_cpu *c, uint64_t max) { c->halt = 0; return zc_run(c, max); }
uint64_t zt_icount(zc_cpu *c) { return c->icount; }
const char *zt_last_fault(void) { return last_fault; }
void zt_clear(void) { last_fault[0] = 0; last_trap = 0xffffffffu; }
uint32_t zt_last_trap(void) { return last_trap; }
