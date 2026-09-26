/*
 * ARMv5TE interpreter: the ARM and Thumb-1 instruction sets the game engine
 * (built for `armeabi`, soft-float) uses. Where ARMv5 and ARMv7 disagree the
 * ARMv7 behaviour wins, because the engine shipped on ARMv7 phones: unaligned
 * loads and stores are real unaligned accesses, and ARM-state ALU writes to PC
 * interwork.
 */
#include "cpu.h"

uint8_t *zc_mem;
zc_trap_fn zc_trap_handler;
zc_fault_fn zc_fault_handler;
void (*zc_sample_hook)(uint32_t pc);
void (*zc_call_hook)(uint32_t target, uint32_t from);
#define CALL_HOOK(target, from) do { if (zc_call_hook) zc_call_hook((target), (from)); } while (0)

#define R (c->r)

static inline uint32_t sext(uint32_t v, int bits)
{
    uint32_t m = 1u << (bits - 1);
    v &= (1u << bits) - 1;
    return (v ^ m) - m;
}

static inline void set_nz(zc_cpu *c, uint32_t res)
{
    c->n = res >> 31;
    c->z = res == 0;
}

static inline uint32_t adc_flags(zc_cpu *c, uint32_t a, uint32_t b, uint32_t cin)
{
    uint64_t wide = (uint64_t)a + b + cin;
    uint32_t res = (uint32_t)wide;
    c->n = res >> 31;
    c->z = res == 0;
    c->c = (uint32_t)(wide >> 32);
    c->v = (~(a ^ b) & (a ^ res)) >> 31;
    return res;
}

/* a - b - !cin, flags as SUBS/SBCS: C is "no borrow". */
static inline uint32_t sbc_flags(zc_cpu *c, uint32_t a, uint32_t b, uint32_t cin)
{
    return adc_flags(c, a, ~b, cin);
}

static inline int cond_pass(const zc_cpu *c, uint32_t cond)
{
    switch (cond) {
    case 0x0: return c->z;
    case 0x1: return !c->z;
    case 0x2: return c->c;
    case 0x3: return !c->c;
    case 0x4: return c->n;
    case 0x5: return !c->n;
    case 0x6: return c->v;
    case 0x7: return !c->v;
    case 0x8: return c->c && !c->z;
    case 0x9: return !c->c || c->z;
    case 0xA: return c->n == c->v;
    case 0xB: return c->n != c->v;
    case 0xC: return !c->z && c->n == c->v;
    case 0xD: return c->z || c->n != c->v;
    default: return 1;
    }
}

/* Immediate shift as encoded in ARM operand 2 and Thumb shift-by-immediate. */
static inline uint32_t shift_imm(uint32_t v, uint32_t type, uint32_t amt, uint32_t cin, uint32_t *cout)
{
    switch (type) {
    case 0: /* LSL */
        if (amt == 0) { *cout = cin; return v; }
        *cout = (v >> (32 - amt)) & 1;
        return v << amt;
    case 1: /* LSR, #0 means #32 */
        if (amt == 0) { *cout = v >> 31; return 0; }
        *cout = (v >> (amt - 1)) & 1;
        return v >> amt;
    case 2: /* ASR, #0 means #32 */
        if (amt == 0) { *cout = v >> 31; return (uint32_t)((int32_t)v >> 31); }
        *cout = (v >> (amt - 1)) & 1;
        return (uint32_t)((int32_t)v >> amt);
    default: /* ROR, #0 means RRX */
        if (amt == 0) { *cout = v & 1; return (cin << 31) | (v >> 1); }
        *cout = (v >> (amt - 1)) & 1;
        return (v >> amt) | (v << (32 - amt));
    }
}

/* Shift by the bottom byte of a register. */
static inline uint32_t shift_reg(uint32_t v, uint32_t type, uint32_t amt, uint32_t cin, uint32_t *cout)
{
    amt &= 0xff;
    if (amt == 0) { *cout = cin; return v; }
    switch (type) {
    case 0:
        if (amt < 32) { *cout = (v >> (32 - amt)) & 1; return v << amt; }
        *cout = amt == 32 ? (v & 1) : 0;
        return 0;
    case 1:
        if (amt < 32) { *cout = (v >> (amt - 1)) & 1; return v >> amt; }
        *cout = amt == 32 ? (v >> 31) : 0;
        return 0;
    case 2:
        if (amt < 32) { *cout = (v >> (amt - 1)) & 1; return (uint32_t)((int32_t)v >> amt); }
        *cout = v >> 31;
        return (uint32_t)((int32_t)v >> 31);
    default: {
        uint32_t a = amt & 31;
        if (a == 0) { *cout = v >> 31; return v; }
        *cout = (v >> (a - 1)) & 1;
        return (v >> a) | (v << (32 - a));
    }
    }
}

uint32_t zc_cpsr_get(const zc_cpu *c)
{
    return (c->n << 31) | (c->z << 30) | (c->c << 29) | (c->v << 28) | (c->q << 27) | (c->t << 5) | 0x10;
}

void zc_cpsr_set(zc_cpu *c, uint32_t v)
{
    c->n = (v >> 31) & 1;
    c->z = (v >> 30) & 1;
    c->c = (v >> 29) & 1;
    c->v = (v >> 28) & 1;
    c->q = (v >> 27) & 1;
    c->t = (v >> 5) & 1;
}

static void fault(zc_cpu *c, const char *what, uint32_t pc, uint32_t insn)
{
    if (zc_fault_handler)
        zc_fault_handler(c, what, pc, insn);
    c->halt = 1;
}

static inline void trap(zc_cpu *c, uint32_t imm, uint32_t pc, int thumb)
{
    if (zc_trap_handler)
        zc_trap_handler(c, imm, pc, thumb);
    else
        fault(c, "trap without handler", pc, imm);
}

/* ------------------------------------------------------------------ ARM */

static inline uint32_t arm_reg(zc_cpu *c, uint32_t r, uint32_t pc)
{
    return r == 15 ? pc + 8 : R[r];
}

/* ALU result written to PC: ARMv7 ALUWritePC interworks in ARM state. */
static inline void arm_alu_write_pc(zc_cpu *c, uint32_t v)
{
    zc_bx_write(c, v);
}

static void arm_dp(zc_cpu *c, uint32_t op, uint32_t pc)
{
    uint32_t imm = (op >> 25) & 1, opc = (op >> 21) & 15, s = (op >> 20) & 1;
    uint32_t rn = (op >> 16) & 15, rd = (op >> 12) & 15;
    uint32_t op2, sc, vn;

    if (imm) {
        uint32_t v = op & 0xff, rot = ((op >> 8) & 15) * 2;
        op2 = rot ? (v >> rot) | (v << (32 - rot)) : v;
        sc = rot ? op2 >> 31 : c->c;
        vn = arm_reg(c, rn, pc);
    } else if (op & 0x10) {
        uint32_t rm = op & 15, rs = (op >> 8) & 15;
        uint32_t vm = rm == 15 ? pc + 12 : R[rm];
        op2 = shift_reg(vm, (op >> 5) & 3, R[rs], c->c, &sc);
        vn = rn == 15 ? pc + 12 : R[rn];
    } else {
        op2 = shift_imm(arm_reg(c, op & 15, pc), (op >> 5) & 3, (op >> 7) & 31, c->c, &sc);
        vn = arm_reg(c, rn, pc);
    }

    uint32_t res;
    switch (opc) {
    case 0x0: res = vn & op2; break;
    case 0x1: res = vn ^ op2; break;
    case 0x2: res = s ? sbc_flags(c, vn, op2, 1) : vn - op2; goto arith;
    case 0x3: res = s ? sbc_flags(c, op2, vn, 1) : op2 - vn; goto arith;
    case 0x4: res = s ? adc_flags(c, vn, op2, 0) : vn + op2; goto arith;
    case 0x5: res = s ? adc_flags(c, vn, op2, c->c) : vn + op2 + c->c; goto arith;
    case 0x6: res = s ? sbc_flags(c, vn, op2, c->c) : vn - op2 - !c->c; goto arith;
    case 0x7: res = s ? sbc_flags(c, op2, vn, c->c) : op2 - vn - !c->c; goto arith;
    case 0x8: res = vn & op2; set_nz(c, res); c->c = sc; return;          /* TST */
    case 0x9: res = vn ^ op2; set_nz(c, res); c->c = sc; return;          /* TEQ */
    case 0xA: sbc_flags(c, vn, op2, 1); return;                           /* CMP */
    case 0xB: adc_flags(c, vn, op2, 0); return;                           /* CMN */
    case 0xC: res = vn | op2; break;
    case 0xD: res = op2; break;
    case 0xE: res = vn & ~op2; break;
    default: res = ~op2; break;
    }
    /* logical */
    if (s) {
        set_nz(c, res);
        c->c = sc;
    }
arith:
    if (rd == 15) {
        if (s) {
            fault(c, "exception return (S with Rd=PC)", pc, op);
            return;
        }
        arm_alu_write_pc(c, res);
    } else {
        R[rd] = res;
    }
}

static void arm_multiply(zc_cpu *c, uint32_t op, uint32_t pc)
{
    uint32_t s = (op >> 20) & 1;
    uint32_t rdhi = (op >> 16) & 15, rdlo = (op >> 12) & 15, rs = (op >> 8) & 15, rm = op & 15;
    switch ((op >> 21) & 7) {
    case 0: /* MUL Rd(19:16) = Rm * Rs */
    case 1: { /* MLA Rd = Rm * Rs + Rn(15:12) */
        uint32_t res = R[rm] * R[rs];
        if (op & (1u << 21))
            res += R[rdlo];
        R[rdhi] = res;
        if (s) set_nz(c, res);
        return;
    }
    case 4: case 5: { /* UMULL / UMLAL */
        uint64_t res = (uint64_t)R[rm] * R[rs];
        if (op & (1u << 21))
            res += ((uint64_t)R[rdhi] << 32) | R[rdlo];
        R[rdlo] = (uint32_t)res;
        R[rdhi] = (uint32_t)(res >> 32);
        if (s) { c->n = (uint32_t)(res >> 63); c->z = res == 0; }
        return;
    }
    case 6: case 7: { /* SMULL / SMLAL */
        int64_t res = (int64_t)(int32_t)R[rm] * (int32_t)R[rs];
        if (op & (1u << 21))
            res += (int64_t)(((uint64_t)R[rdhi] << 32) | R[rdlo]);
        R[rdlo] = (uint32_t)res;
        R[rdhi] = (uint32_t)((uint64_t)res >> 32);
        if (s) { c->n = (uint32_t)((uint64_t)res >> 63); c->z = res == 0; }
        return;
    }
    default:
        fault(c, "undefined multiply", pc, op);
    }
}

static inline uint32_t sat_add(zc_cpu *c, int32_t a, int32_t b)
{
    int64_t r = (int64_t)a + b;
    if (r > INT32_MAX) { c->q = 1; return INT32_MAX; }
    if (r < INT32_MIN) { c->q = 1; return (uint32_t)INT32_MIN; }
    return (uint32_t)r;
}

static inline uint32_t sat_sub(zc_cpu *c, int32_t a, int32_t b)
{
    int64_t r = (int64_t)a - b;
    if (r > INT32_MAX) { c->q = 1; return INT32_MAX; }
    if (r < INT32_MIN) { c->q = 1; return (uint32_t)INT32_MIN; }
    return (uint32_t)r;
}

/* opcode 10xx with S=0 in the register data-processing space */
static void arm_misc(zc_cpu *c, uint32_t op, uint32_t pc)
{
    if ((op & 0x0FBF0FFF) == 0x010F0000) { /* MRS */
        R[(op >> 12) & 15] = zc_cpsr_get(c);
        return;
    }
    if ((op & 0x0FB0FFF0) == 0x0120F000) { /* MSR CPSR, Rm */
        if (op & (1u << 22)) { fault(c, "MSR SPSR", pc, op); return; }
        if (op & (1u << 19)) {
            uint32_t v = R[op & 15];
            c->n = (v >> 31) & 1; c->z = (v >> 30) & 1; c->c = (v >> 29) & 1; c->v = (v >> 28) & 1; c->q = (v >> 27) & 1;
        }
        return;
    }
    if ((op & 0x0FFFFFF0) == 0x012FFF10) { /* BX */
        zc_bx_write(c, arm_reg(c, op & 15, pc));
        return;
    }
    if ((op & 0x0FFFFFF0) == 0x012FFF30) { /* BLX Rm */
        uint32_t target = arm_reg(c, op & 15, pc);
        R[14] = pc + 4;
        zc_bx_write(c, target);
        CALL_HOOK(target, pc);
        return;
    }
    if ((op & 0x0FFF0FF0) == 0x016F0F10) { /* CLZ */
        uint32_t v = R[op & 15];
        R[(op >> 12) & 15] = v ? (uint32_t)__builtin_clz(v) : 32;
        return;
    }
    if ((op & 0x0F900FF0) == 0x01000050) { /* QADD, QSUB, QDADD, QDSUB */
        int32_t m = (int32_t)R[op & 15], n = (int32_t)R[(op >> 16) & 15];
        uint32_t rd = (op >> 12) & 15;
        switch ((op >> 21) & 3) {
        case 0: R[rd] = sat_add(c, m, n); break;
        case 1: R[rd] = sat_sub(c, m, n); break;
        case 2: R[rd] = sat_add(c, m, (int32_t)sat_add(c, n, n)); break;
        default: R[rd] = sat_sub(c, m, (int32_t)sat_add(c, n, n)); break;
        }
        return;
    }
    if ((op & 0x0F900090) == 0x01000080) { /* signed halfword multiplies */
        uint32_t rd = (op >> 16) & 15, rn = (op >> 12) & 15, rs = (op >> 8) & 15, rm = op & 15;
        int32_t x = (op & 0x20) ? (int32_t)R[rm] >> 16 : (int16_t)R[rm];
        int32_t y = (op & 0x40) ? (int32_t)R[rs] >> 16 : (int16_t)R[rs];
        switch ((op >> 21) & 3) {
        case 0: { /* SMLAxy */
            int64_t wide = (int64_t)(x * y) + (int32_t)R[rn];
            if (wide != (int32_t)wide) c->q = 1;
            R[rd] = (uint32_t)wide;
            return;
        }
        case 1: { /* SMLAWy / SMULWy: 32 x 16 >> 16 */
            int32_t yy = (op & 0x40) ? (int32_t)R[rs] >> 16 : (int16_t)R[rs];
            int32_t prod = (int32_t)(((int64_t)(int32_t)R[rm] * yy) >> 16);
            if (op & 0x20) { /* SMULWy */
                R[rd] = (uint32_t)prod;
            } else {
                int64_t wide = (int64_t)prod + (int32_t)R[rn];
                if (wide != (int32_t)wide) c->q = 1;
                R[rd] = (uint32_t)wide;
            }
            return;
        }
        case 2: { /* SMLALxy: RdHi=rd(19:16), RdLo=rn(15:12) */
            int64_t acc = (int64_t)(((uint64_t)R[rd] << 32) | R[rn]);
            acc += (int64_t)x * y;
            R[rn] = (uint32_t)acc;
            R[rd] = (uint32_t)((uint64_t)acc >> 32);
            return;
        }
        default: /* SMULxy */
            R[rd] = (uint32_t)(x * y);
            return;
        }
    }
    if ((op & 0xFFF000F0) == 0xE1200070) {
        fault(c, "BKPT", pc, op);
        return;
    }
    fault(c, "undefined ARM misc instruction", pc, op);
}

/* LDRH/STRH/LDRSB/LDRSH/LDRD/STRD */
static void arm_extra_ls(zc_cpu *c, uint32_t op, uint32_t pc)
{
    uint32_t p = (op >> 24) & 1, u = (op >> 23) & 1, i = (op >> 22) & 1, w = (op >> 21) & 1, l = (op >> 20) & 1;
    uint32_t rn = (op >> 16) & 15, rd = (op >> 12) & 15, sh = (op >> 5) & 3;
    uint32_t off = i ? (((op >> 4) & 0xf0) | (op & 0xf)) : R[op & 15];
    uint32_t base = arm_reg(c, rn, pc);
    uint32_t addr = p ? (u ? base + off : base - off) : base;
    uint32_t wb = u ? base + off : base - off;
    int writeback = !p || w;

    if (sh == 1) {
        if (l) {
            uint32_t v = zc_rd16(addr);
            if (writeback) R[rn] = wb;
            R[rd] = v;
        } else {
            zc_wr16(addr, rd == 15 ? pc + 8 : R[rd]);
            if (writeback) R[rn] = wb;
        }
        return;
    }
    if (l) {
        uint32_t v = sh == 2 ? (uint32_t)(int32_t)(int8_t)zc_rd8(addr) : (uint32_t)(int32_t)(int16_t)zc_rd16(addr);
        if (writeback) R[rn] = wb;
        if (rd == 15) zc_bx_write(c, v); else R[rd] = v;
        return;
    }
    /* L=0 with sh=2/3: LDRD / STRD on the even/odd pair Rd, Rd+1 */
    if (rd & 1) { fault(c, "LDRD/STRD with odd Rd", pc, op); return; }
    if (sh == 2) {
        uint32_t lo = zc_rd32(addr), hi = zc_rd32(addr + 4);
        if (writeback) R[rn] = wb;
        R[rd] = lo;
        if (rd + 1 == 15) zc_bx_write(c, hi); else R[rd + 1] = hi;
    } else {
        zc_wr32(addr, R[rd]);
        zc_wr32(addr + 4, rd + 1 == 15 ? pc + 8 : R[rd + 1]);
        if (writeback) R[rn] = wb;
    }
}

static void arm_ls(zc_cpu *c, uint32_t op, uint32_t pc)
{
    uint32_t p = (op >> 24) & 1, u = (op >> 23) & 1, b = (op >> 22) & 1, w = (op >> 21) & 1, l = (op >> 20) & 1;
    uint32_t rn = (op >> 16) & 15, rd = (op >> 12) & 15;
    uint32_t off;
    if (op & (1u << 25)) {
        uint32_t sc;
        off = shift_imm(arm_reg(c, op & 15, pc), (op >> 5) & 3, (op >> 7) & 31, c->c, &sc);
    } else {
        off = op & 0xfff;
    }
    uint32_t base = arm_reg(c, rn, pc);
    uint32_t wbv = u ? base + off : base - off;
    uint32_t addr = p ? wbv : base;
    int writeback = !p || w;

    if (l) {
        uint32_t v = b ? zc_rd8(addr) : zc_rd32(addr);
        if (writeback) R[rn] = wbv;
        if (rd == 15) zc_bx_write(c, v); else R[rd] = v;
    } else {
        uint32_t v = rd == 15 ? pc + 8 : R[rd];
        if (b) zc_wr8(addr, v); else zc_wr32(addr, v);
        if (writeback) R[rn] = wbv;
    }
}

static void arm_ldm_stm(zc_cpu *c, uint32_t op, uint32_t pc)
{
    uint32_t p = (op >> 24) & 1, u = (op >> 23) & 1, s = (op >> 22) & 1, w = (op >> 21) & 1, l = (op >> 20) & 1;
    uint32_t rn = (op >> 16) & 15, list = op & 0xffff;
    uint32_t n = (uint32_t)__builtin_popcount(list);
    uint32_t base = R[rn];
    uint32_t addr, wb;

    if (n == 0) { fault(c, "LDM/STM with empty list", pc, op); return; }
    if (s && (!l || !(list & 0x8000))) { /* user-bank transfer: same registers in user mode */ }
    if (s && l && (list & 0x8000)) { fault(c, "LDM exception return", pc, op); return; }

    if (u) { addr = p ? base + 4 : base; wb = base + 4 * n; }
    else { addr = p ? base - 4 * n : base - 4 * n + 4; wb = base - 4 * n; }

    if (l) {
        uint32_t newpc = 0;
        for (int i = 0; i < 16; i++) {
            if (!(list & (1u << i))) continue;
            uint32_t v = zc_rd32(addr);
            addr += 4;
            if (i == 15) newpc = v; else R[i] = v;
        }
        if (w && !(list & (1u << rn))) R[rn] = wb;
        if (list & 0x8000) zc_bx_write(c, newpc);
    } else {
        for (int i = 0; i < 16; i++) {
            if (!(list & (1u << i))) continue;
            zc_wr32(addr, i == 15 ? pc + 8 : (i == (int)rn ? base : R[i]));
            addr += 4;
        }
        if (w) R[rn] = wb;
    }
}

static void arm_step(zc_cpu *c)
{
    uint32_t pc = R[15];
    uint32_t op = zc_rd32(pc);
    R[15] = pc + 4;

    uint32_t cond = op >> 28;
    if (cond == 0xF) {
        if ((op & 0xFE000000) == 0xFA000000) { /* BLX imm */
            uint32_t target = pc + 8 + (sext(op, 24) << 2) + ((op >> 23) & 2);
            R[14] = pc + 4;
            c->t = 1;
            R[15] = target;
            CALL_HOOK(target | 1, pc);
            return;
        }
        if ((op & 0x0D70F000) == 0x0550F000) /* PLD */
            return;
        fault(c, "undefined unconditional ARM instruction", pc, op);
        return;
    }
    if (cond != 0xE && !cond_pass(c, cond))
        return;

    switch ((op >> 25) & 7) {
    case 0:
        if ((op & 0x90) == 0x90) {
            if ((op & 0x60) == 0) {
                if ((op & 0x0FB00FF0) == 0x01000090) { /* SWP / SWPB */
                    uint32_t addr = R[(op >> 16) & 15], rm = R[op & 15], rd = (op >> 12) & 15;
                    if (op & (1u << 22)) { uint32_t v = zc_rd8(addr); zc_wr8(addr, rm); R[rd] = v; }
                    else { uint32_t v = zc_rd32(addr); zc_wr32(addr, rm); R[rd] = v; }
                    return;
                }
                if ((op & 0x0F000000) == 0) { arm_multiply(c, op, pc); return; }
                fault(c, "undefined ARM instruction", pc, op);
                return;
            }
            arm_extra_ls(c, op, pc);
            return;
        }
        if ((op & 0x01900000) == 0x01000000) { arm_misc(c, op, pc); return; }
        arm_dp(c, op, pc);
        return;
    case 1:
        if ((op & 0x01900000) == 0x01000000) {
            if ((op & 0x0FB0F000) == 0x0320F000) { /* MSR CPSR_f, #imm (or a hint) */
                if (op & (1u << 22)) { fault(c, "MSR SPSR", pc, op); return; }
                if (op & (1u << 19)) {
                    uint32_t v = op & 0xff, rot = ((op >> 8) & 15) * 2;
                    v = rot ? (v >> rot) | (v << (32 - rot)) : v;
                    c->n = (v >> 31) & 1; c->z = (v >> 30) & 1; c->c = (v >> 29) & 1; c->v = (v >> 28) & 1; c->q = (v >> 27) & 1;
                }
                return;
            }
            fault(c, "undefined ARM instruction", pc, op);
            return;
        }
        arm_dp(c, op, pc);
        return;
    case 2:
        arm_ls(c, op, pc);
        return;
    case 3:
        if (op & 0x10) {
            if ((op & 0x0FF000F0) == 0x07F000F0) { /* UDF #imm16: host call */
                trap(c, ((op >> 4) & 0xFFF0) | (op & 0xF), pc, 0);
                return;
            }
            fault(c, "undefined ARM media instruction", pc, op);
            return;
        }
        arm_ls(c, op, pc);
        return;
    case 4:
        arm_ldm_stm(c, op, pc);
        return;
    case 5: {
        uint32_t target = pc + 8 + (sext(op, 24) << 2);
        if (op & (1u << 24)) {
            R[14] = pc + 4;
            CALL_HOOK(target, pc);
        }
        R[15] = target;
        return;
    }
    case 6:
        fault(c, "coprocessor load/store", pc, op);
        return;
    default:
        if (op & (1u << 24)) fault(c, "SWI", pc, op);
        else fault(c, "coprocessor instruction", pc, op);
        return;
    }
}

/* ---------------------------------------------------------------- Thumb */

static inline void thumb_alu(zc_cpu *c, uint32_t op)
{
    uint32_t rd = op & 7, rs = (op >> 3) & 7;
    uint32_t a = R[rd], b = R[rs], res, sc;
    switch ((op >> 6) & 15) {
    case 0x0: res = a & b; set_nz(c, res); R[rd] = res; return;
    case 0x1: res = a ^ b; set_nz(c, res); R[rd] = res; return;
    case 0x2: res = shift_reg(a, 0, b, c->c, &sc); set_nz(c, res); c->c = sc; R[rd] = res; return;
    case 0x3: res = shift_reg(a, 1, b, c->c, &sc); set_nz(c, res); c->c = sc; R[rd] = res; return;
    case 0x4: res = shift_reg(a, 2, b, c->c, &sc); set_nz(c, res); c->c = sc; R[rd] = res; return;
    case 0x5: R[rd] = adc_flags(c, a, b, c->c); return;
    case 0x6: R[rd] = sbc_flags(c, a, b, c->c); return;
    case 0x7: res = shift_reg(a, 3, b, c->c, &sc); set_nz(c, res); c->c = sc; R[rd] = res; return;
    case 0x8: set_nz(c, a & b); return;
    case 0x9: R[rd] = sbc_flags(c, 0, b, 1); return;
    case 0xA: sbc_flags(c, a, b, 1); return;
    case 0xB: adc_flags(c, a, b, 0); return;
    case 0xC: res = a | b; set_nz(c, res); R[rd] = res; return;
    case 0xD: res = a * b; set_nz(c, res); R[rd] = res; return;
    case 0xE: res = a & ~b; set_nz(c, res); R[rd] = res; return;
    default: res = ~b; set_nz(c, res); R[rd] = res; return;
    }
}

static inline void thumb_hireg(zc_cpu *c, uint32_t op, uint32_t pc)
{
    uint32_t rd = ((op >> 4) & 8) | (op & 7), rm = (op >> 3) & 15;
    uint32_t vm = rm == 15 ? pc + 4 : R[rm];
    switch ((op >> 8) & 3) {
    case 0: { /* ADD */
        uint32_t vd = rd == 15 ? pc + 4 : R[rd];
        uint32_t res = vd + vm;
        if (rd == 15) R[15] = res & ~1u; else R[rd] = res;
        return;
    }
    case 1: /* CMP */
        sbc_flags(c, rd == 15 ? pc + 4 : R[rd], vm, 1);
        return;
    case 2: /* MOV */
        if (rd == 15) R[15] = vm & ~1u; else R[rd] = vm;
        return;
    default: /* BX / BLX */
        if (op & 0x80) {
            R[14] = (pc + 2) | 1;
            CALL_HOOK(vm, pc);
        }
        zc_bx_write(c, vm);
        return;
    }
}

static void thumb_step(zc_cpu *c)
{
    uint32_t pc = R[15];
    uint32_t op = zc_rd16(pc);
    R[15] = pc + 2;

    switch (op >> 11) {
    case 0x00: case 0x01: case 0x02: { /* LSL/LSR/ASR #imm */
        uint32_t sc, res = shift_imm(R[(op >> 3) & 7], op >> 11, (op >> 6) & 31, c->c, &sc);
        R[op & 7] = res;
        set_nz(c, res);
        c->c = sc;
        return;
    }
    case 0x03: { /* ADD/SUB register or imm3 */
        uint32_t a = R[(op >> 3) & 7];
        uint32_t b = (op & 0x400) ? (op >> 6) & 7 : R[(op >> 6) & 7];
        R[op & 7] = (op & 0x200) ? sbc_flags(c, a, b, 1) : adc_flags(c, a, b, 0);
        return;
    }
    case 0x04: { uint32_t v = op & 0xff; R[(op >> 8) & 7] = v; set_nz(c, v); return; }        /* MOV */
    case 0x05: sbc_flags(c, R[(op >> 8) & 7], op & 0xff, 1); return;                            /* CMP */
    case 0x06: { uint32_t rd = (op >> 8) & 7; R[rd] = adc_flags(c, R[rd], op & 0xff, 0); return; } /* ADD */
    case 0x07: { uint32_t rd = (op >> 8) & 7; R[rd] = sbc_flags(c, R[rd], op & 0xff, 1); return; } /* SUB */
    case 0x08:
        if (op & 0x400) thumb_hireg(c, op, pc); else thumb_alu(c, op);
        return;
    case 0x09: /* LDR Rd, [PC, #imm8*4] */
        R[(op >> 8) & 7] = zc_rd32(((pc + 4) & ~3u) + ((op & 0xff) << 2));
        return;
    case 0x0A: case 0x0B: { /* load/store register offset */
        uint32_t addr = R[(op >> 3) & 7] + R[(op >> 6) & 7], rd = op & 7;
        switch ((op >> 9) & 7) {
        case 0: zc_wr32(addr, R[rd]); return;
        case 1: zc_wr16(addr, R[rd]); return;
        case 2: zc_wr8(addr, R[rd]); return;
        case 3: R[rd] = (uint32_t)(int32_t)(int8_t)zc_rd8(addr); return;
        case 4: R[rd] = zc_rd32(addr); return;
        case 5: R[rd] = zc_rd16(addr); return;
        case 6: R[rd] = zc_rd8(addr); return;
        default: R[rd] = (uint32_t)(int32_t)(int16_t)zc_rd16(addr); return;
        }
    }
    case 0x0C: zc_wr32(R[(op >> 3) & 7] + ((op >> 4) & 0x7c), R[op & 7]); return;       /* STR imm */
    case 0x0D: R[op & 7] = zc_rd32(R[(op >> 3) & 7] + ((op >> 4) & 0x7c)); return;       /* LDR imm */
    case 0x0E: zc_wr8(R[(op >> 3) & 7] + ((op >> 6) & 31), R[op & 7]); return;          /* STRB imm */
    case 0x0F: R[op & 7] = zc_rd8(R[(op >> 3) & 7] + ((op >> 6) & 31)); return;          /* LDRB imm */
    case 0x10: zc_wr16(R[(op >> 3) & 7] + ((op >> 5) & 0x3e), R[op & 7]); return;       /* STRH imm */
    case 0x11: R[op & 7] = zc_rd16(R[(op >> 3) & 7] + ((op >> 5) & 0x3e)); return;       /* LDRH imm */
    case 0x12: zc_wr32(R[13] + ((op & 0xff) << 2), R[(op >> 8) & 7]); return;           /* STR [SP] */
    case 0x13: R[(op >> 8) & 7] = zc_rd32(R[13] + ((op & 0xff) << 2)); return;           /* LDR [SP] */
    case 0x14: R[(op >> 8) & 7] = ((pc + 4) & ~3u) + ((op & 0xff) << 2); return;         /* ADD Rd, PC */
    case 0x15: R[(op >> 8) & 7] = R[13] + ((op & 0xff) << 2); return;                    /* ADD Rd, SP */
    case 0x16: case 0x17:
        switch ((op >> 8) & 0xf) {
        case 0x0: /* ADD/SUB SP, #imm7*4 */
            if (op & 0x80) R[13] -= (op & 0x7f) << 2; else R[13] += (op & 0x7f) << 2;
            return;
        case 0x4: case 0x5: { /* PUSH */
            uint32_t list = (op & 0xff) | ((op & 0x100) << 6); /* bit 8 -> LR (bit 14) */
            uint32_t n = (uint32_t)__builtin_popcount(list);
            uint32_t addr = R[13] - 4 * n;
            R[13] = addr;
            for (int i = 0; i < 15; i++)
                if (list & (1u << i)) { zc_wr32(addr, R[i]); addr += 4; }
            return;
        }
        case 0xC: case 0xD: { /* POP */
            uint32_t addr = R[13];
            for (int i = 0; i < 8; i++)
                if (op & (1u << i)) { R[i] = zc_rd32(addr); addr += 4; }
            if (op & 0x100) {
                uint32_t v = zc_rd32(addr);
                addr += 4;
                R[13] = addr;
                zc_bx_write(c, v);
            } else {
                R[13] = addr;
            }
            return;
        }
        case 0xE:
            fault(c, "BKPT", pc, op);
            return;
        case 0xF:
            /* ARMv6T2 hints (NOP, YIELD, WFE, WFI, SEV). ZombieCafeExtension's
               setNop() writes NOP (0xBF00), which the ARMv7 phones ran. */
            if ((op & 0xF) == 0)
                return;
            fault(c, "IT block (Thumb-2) not supported", pc, op);
            return;
        default:
            fault(c, "undefined Thumb instruction", pc, op);
            return;
        }
    case 0x18: { /* STMIA Rb!, {list} */
        uint32_t rb = (op >> 8) & 7, base = R[rb], addr = base;
        for (int i = 0; i < 8; i++)
            if (op & (1u << i)) { zc_wr32(addr, R[i]); addr += 4; }
        R[rb] = addr;
        return;
    }
    case 0x19: { /* LDMIA Rb!, {list} */
        uint32_t rb = (op >> 8) & 7, addr = R[rb];
        for (int i = 0; i < 8; i++)
            if (op & (1u << i)) { R[i] = zc_rd32(addr); addr += 4; }
        if (!(op & (1u << rb))) R[rb] = addr;
        return;
    }
    case 0x1A: case 0x1B: { /* B<cond>, UDF, SWI */
        uint32_t cond = (op >> 8) & 15;
        if (cond == 0xE) { trap(c, op & 0xff, pc, 1); return; }
        if (cond == 0xF) { fault(c, "SWI", pc, op); return; }
        if (cond_pass(c, cond)) R[15] = pc + 4 + (sext(op, 8) << 1);
        return;
    }
    case 0x1C: /* B */
        R[15] = pc + 4 + (sext(op, 11) << 1);
        return;
    case 0x1D: /* BLX suffix on its own (prefix executed separately) */
        if (op & 1) { fault(c, "undefined BLX suffix", pc, op); return; }
        {
            uint32_t target = (R[14] + ((op & 0x7ff) << 1)) & ~3u;
            R[14] = (pc + 2) | 1;
            c->t = 0;
            R[15] = target;
        }
        return;
    case 0x1E: { /* BL/BLX prefix */
        uint32_t lr = pc + 4 + (sext(op, 11) << 12);
        uint32_t next = zc_rd16(pc + 2);
        if ((next >> 11) == 0x1F) { /* BL pair */
            R[14] = (pc + 4) | 1;
            R[15] = lr + ((next & 0x7ff) << 1);
            CALL_HOOK(R[15] | 1, pc);
            return;
        }
        if ((next >> 11) == 0x1D && !(next & 1)) { /* BLX pair */
            R[14] = (pc + 4) | 1;
            c->t = 0;
            R[15] = (lr + ((next & 0x7ff) << 1)) & ~3u;
            CALL_HOOK(R[15], pc);
            return;
        }
        R[14] = lr;
        return;
    }
    default: /* 0x1F: BL suffix on its own */
        {
            uint32_t target = R[14] + ((op & 0x7ff) << 1);
            R[14] = (pc + 2) | 1;
            R[15] = target;
        }
        return;
    }
}

void zc_step(zc_cpu *c)
{
    if (c->t) thumb_step(c); else arm_step(c);
    c->icount++;
}

int zc_run(zc_cpu *c, uint64_t max)
{
    uint64_t n = 0;
    if (zc_sample_hook) {
        while (!c->halt && n < max) {
            if (c->t) thumb_step(c); else arm_step(c);
            if ((++n & 1023) == 0)
                zc_sample_hook(c->r[15]);
        }
        c->icount += n;
        return c->halt != 0;
    }
    while (!c->halt && n < max) {
        if (c->t) {
            do {
                thumb_step(c);
                n++;
            } while (c->t && !c->halt && n < max);
        } else {
            arm_step(c);
            n++;
        }
    }
    c->icount += n;
    return c->halt != 0;
}
