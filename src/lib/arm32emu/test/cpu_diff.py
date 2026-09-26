#!/usr/bin/env python3
"""
Differential test for the interpreter: random ARMv5TE instructions (ARM and
Thumb) run one at a time on both cpu.c (through test/cpu_testlib.c) and
Unicorn emulating a Cortex-A9, the ARMv7 core class the game shipped on.
Registers, NZCVQ/T and the data region must match after every instruction.

    python3 cpu_diff.py <libcputest.so> [iterations] [seed]
"""
import ctypes
import random
import sys

from unicorn import Uc, UC_ARCH_ARM, UC_MODE_ARM, UcError
from unicorn.arm_const import (UC_CPU_ARM_CORTEX_A9, UC_ARM_REG_CPSR, UC_ARM_REG_R0, UC_ARM_REG_R1,
                               UC_ARM_REG_R2, UC_ARM_REG_R3, UC_ARM_REG_R4, UC_ARM_REG_R5, UC_ARM_REG_R6,
                               UC_ARM_REG_R7, UC_ARM_REG_R8, UC_ARM_REG_R9, UC_ARM_REG_R10, UC_ARM_REG_R11,
                               UC_ARM_REG_R12, UC_ARM_REG_SP, UC_ARM_REG_LR, UC_ARM_REG_PC)

REGS = [UC_ARM_REG_R0, UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3, UC_ARM_REG_R4, UC_ARM_REG_R5,
        UC_ARM_REG_R6, UC_ARM_REG_R7, UC_ARM_REG_R8, UC_ARM_REG_R9, UC_ARM_REG_R10, UC_ARM_REG_R11,
        UC_ARM_REG_R12, UC_ARM_REG_SP, UC_ARM_REG_LR, UC_ARM_REG_PC]
CODE, CODE_SIZE = 0x00010000, 0x10000
DATA, DATA_SIZE = 0x00100000, 0x10000
FLAGS_MASK = 0xF8000020  # NZCVQ + T

lib = ctypes.CDLL(sys.argv[1])
lib.zt_ptr.restype = ctypes.c_void_p
lib.zt_ptr.argtypes = [ctypes.c_uint32]
lib.zt_cpu_new.restype = ctypes.c_void_p
lib.zt_get_reg.restype = ctypes.c_uint32
lib.zt_get_reg.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.zt_set_reg.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint32]
lib.zt_get_cpsr.restype = ctypes.c_uint32
lib.zt_get_cpsr.argtypes = [ctypes.c_void_p]
lib.zt_set_cpsr.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
lib.zt_step.argtypes = [ctypes.c_void_p]
lib.zt_last_fault.restype = ctypes.c_char_p
lib.zt_map.argtypes = [ctypes.c_uint32, ctypes.c_uint32]
assert lib.zt_init() == 0
assert lib.zt_map(CODE, CODE_SIZE) == 0 and lib.zt_map(DATA, DATA_SIZE) == 0
cpu = lib.zt_cpu_new()

uc = Uc(UC_ARCH_ARM, UC_MODE_ARM)
uc.ctl_set_cpu_model(UC_CPU_ARM_CORTEX_A9)
uc.mem_map(CODE, CODE_SIZE)
uc.mem_map(DATA, DATA_SIZE)

# Unicorn's count=1 (and emu_stop from a hook) can retire more than one
# instruction, so Unicorn runs until it reaches the PC our interpreter produced.
# If the two disagree about the next PC, Unicorn runs on and the case fails.

EDGE = [0, 1, 2, 31, 32, 33, 0x7f, 0x80, 0xff, 0x100, 0x7fff, 0x8000, 0xffff, 0x10000,
        0x7fffffff, 0x80000000, 0x80000001, 0xfffffffe, 0xffffffff]


def rval(rnd):
    k = rnd.random()
    if k < 0.3:
        return rnd.choice(EDGE)
    if k < 0.5:
        return rnd.randrange(0, 64)
    return rnd.getrandbits(32)


def dptr(rnd, align=4, span=0x4000):
    return DATA + 0x4000 + rnd.randrange(0, span // align) * align


class Case:
    def __init__(self, rnd, thumb):
        self.thumb = thumb
        self.regs = [rval(rnd) for _ in range(13)] + [DATA + 0xC000, CODE + 0x100 | 1, 0]
        self.flags = rnd.getrandbits(5) << 27
        self.pc = CODE + 0x8000 + (rnd.randrange(0, 0x100) * (2 if thumb else 4))
        self.code = b''
        self.mask_reg = {}  # reg -> mask for results only defined in part (MRS)


# ------------------------------------------------------------------ Thumb

def gen_thumb(rnd):
    c = Case(rnd, True)
    r = c.regs
    lo = lambda: rnd.randrange(8)
    k = rnd.randrange(22)
    if k == 0:
        op = (rnd.randrange(3) << 11) | (rnd.randrange(32) << 6) | (lo() << 3) | lo()
    elif k == 1:
        op = 0x1800 | (rnd.randrange(4) << 9) | (lo() << 6) | (lo() << 3) | lo()
    elif k == 2:
        op = (rnd.randrange(4, 8) << 11) | (lo() << 8) | rnd.randrange(256)
    elif k in (3, 4):
        op = 0x4000 | (rnd.randrange(16) << 6) | (lo() << 3) | lo()
    elif k == 5:  # hi-register ADD/CMP/MOV, never writing PC
        sub = rnd.randrange(3)
        while True:
            rd, rm = rnd.randrange(15), rnd.randrange(16)
            if sub == 1 and rd < 8 and rm < 8:
                continue
            if sub != 1 and rd == 13 and rm == 15:
                continue
            break
        op = 0x4400 | (sub << 8) | ((rd & 8) << 4) | (rm << 3) | (rd & 7)
    elif k == 6:  # BX / BLX register
        rm = rnd.randrange(15)
        op = 0x4700 | (rnd.randrange(2) << 7) | (rm << 3)
        tgt_thumb = rnd.randrange(2)
        r[rm] = CODE + 0x2000 + rnd.randrange(0x100) * 4 + tgt_thumb
    elif k == 7:
        op = 0x4800 | (lo() << 8) | rnd.randrange(256)
    elif k == 8:  # load/store register offset
        sub = rnd.randrange(8)
        size = [4, 2, 1, 1, 4, 2, 1, 2][sub]
        rb, ro, rd = lo(), lo(), lo()
        while ro == rb:
            ro = lo()
        r[rb] = dptr(rnd, size)
        r[ro] = rnd.randrange(0, 64) * size
        op = 0x5000 | (sub << 9) | (ro << 6) | (rb << 3) | rd
    elif k == 9:  # load/store word/byte immediate
        sub = rnd.randrange(4)
        rb = lo()
        r[rb] = dptr(rnd, 4)
        op = (0x6000 + (sub << 11)) | (rnd.randrange(32) << 6) | (rb << 3) | lo()
    elif k == 10:  # halfword immediate
        rb = lo()
        r[rb] = dptr(rnd, 2)
        op = 0x8000 | (rnd.randrange(2) << 11) | (rnd.randrange(32) << 6) | (rb << 3) | lo()
    elif k == 11:
        op = 0x9000 | (rnd.randrange(2) << 11) | (lo() << 8) | rnd.randrange(256)
    elif k == 12:
        op = 0xA000 | (rnd.randrange(2) << 11) | (lo() << 8) | rnd.randrange(256)
    elif k == 13:
        op = 0xB000 | (rnd.randrange(2) << 7) | rnd.randrange(128)
    elif k == 14:  # PUSH
        op = 0xB400 | (rnd.randrange(2) << 8) | rnd.randrange(1, 256)
    elif k == 15:  # POP, optionally PC
        pcbit = rnd.randrange(2)
        op = 0xBC00 | (pcbit << 8) | rnd.randrange(0 if pcbit else 1, 256)
        c.pop_target = CODE + 0x3000 + rnd.randrange(0x100) * 4 + rnd.randrange(2)
    elif k == 16:  # STMIA / LDMIA
        rb = lo()
        r[rb] = dptr(rnd, 4)
        lst = rnd.randrange(1, 256)
        l = rnd.randrange(2)
        if not l and (lst & (1 << rb)) and (lst & ((1 << rb) - 1)):
            lst &= ~(1 << rb)  # base not lowest: UNPREDICTABLE store value
            lst |= 1 if rb else 2
        op = 0xC000 | (l << 11) | (rb << 8) | lst
    elif k == 17:  # conditional branch
        op = 0xD000 | (rnd.randrange(14) << 8) | rnd.randrange(256)
    elif k == 18:
        op = 0xE000 | rnd.randrange(2048)
    elif k in (19, 20):  # BL / BLX pair
        off = (rnd.randrange(-0x800, 0x800)) * 4
        if off == -4:
            off = 4  # a BL to its own address stops Unicorn before it starts
        hi = (off >> 12) & 0x7ff
        lo_ = (off >> 1) & 0x7ff
        blx = k == 20
        if blx:
            lo_ &= ~1
        c.code = bytes([(0xF000 | hi) & 0xff, (0xF000 | hi) >> 8])
        second = (0xE800 if blx else 0xF800) | lo_
        c.code += bytes([second & 0xff, second >> 8])
        return c
    else:  # ADD/SUB with SP as base, or small immediates edge
        op = 0x1C00 | (rnd.randrange(2) << 9) | (rnd.randrange(8) << 6) | (lo() << 3) | lo()
    c.code = bytes([op & 0xff, op >> 8])
    return c


# -------------------------------------------------------------------- ARM

def gen_arm(rnd):
    c = Case(rnd, False)
    r = c.regs
    cond = rnd.randrange(15) if rnd.random() < 0.3 else 14
    reg = lambda: rnd.randrange(13)
    k = rnd.randrange(16)
    if k in (0, 1, 2):  # data processing
        opc = rnd.randrange(16)
        s = 1 if opc in (8, 9, 10, 11) else rnd.randrange(2)
        rd = 0 if opc in (8, 9, 10, 11) else reg()  # compares: Rd is should-be-zero
        rn = 0 if opc in (13, 15) else reg()       # MOV/MVN: Rn is should-be-zero
        form = rnd.randrange(3)
        if form == 0:
            op2 = (1 << 25) | (rnd.randrange(16) << 8) | rnd.randrange(256)
        elif form == 1:
            op2 = (rnd.randrange(32) << 7) | (rnd.randrange(4) << 5) | reg()
        else:
            op2 = (reg() << 8) | (rnd.randrange(4) << 5) | 0x10 | reg()
        op = (cond << 28) | (opc << 21) | (s << 20) | (rn << 16) | (rd << 12) | op2
        if form == 2:
            r[(op >> 8) & 15] = rnd.choice([0, 1, 5, 31, 32, 33, 40, 255, 256 + 3, rval(rnd)])
    elif k == 3:  # MUL / MLA / long multiplies
        sub = rnd.choice([0, 1, 4, 5, 6, 7])
        rdhi, rdlo = reg(), reg()
        while rdlo == rdhi:
            rdlo = reg()
        if sub == 0:
            rdlo = 0  # MUL: accumulator field is should-be-zero
        op = (cond << 28) | (sub << 21) | (rnd.randrange(2) << 20) | (rdhi << 16) | (rdlo << 12) | (reg() << 8) | 0x90 | reg()
    elif k == 4:  # CLZ
        op = (cond << 28) | 0x016F0F10 | (reg() << 12) | reg()
    elif k == 5:  # QADD family / halfword multiplies
        if rnd.randrange(2):
            op = (cond << 28) | 0x01000050 | (rnd.randrange(4) << 21) | (reg() << 16) | (reg() << 12) | reg()
        else:
            sub = rnd.randrange(4)
            op = (cond << 28) | 0x01000080 | (sub << 21) | (reg() << 16) | (reg() << 12) | (reg() << 8) | (rnd.randrange(4) << 5) | reg()
            if sub == 2 and ((op >> 16) & 15) == ((op >> 12) & 15):
                op ^= 1 << 12
            if sub == 3 or (sub == 1 and op & 0x20):  # SMULxy / SMULWy: Rn is should-be-zero
                op &= ~(15 << 12)
    elif k in (6, 7):  # LDR/STR word/byte
        p, u, b, w, l = rnd.randrange(2), rnd.randrange(2), rnd.randrange(2), rnd.randrange(2), rnd.randrange(2)
        rn, rd = reg(), reg()
        while rd == rn:
            rd = reg()
        r[rn] = dptr(rnd, 4)
        if rnd.randrange(2):
            off = (rnd.randrange(0, 256) * (1 if b else 4))
            op2 = off
        else:
            rm = reg()
            while rm in (rn, rd):
                rm = reg()
            sh = rnd.randrange(3)
            r[rm] = rnd.randrange(0, 64) * (1 if b else 4)
            amt = 0 if sh else rnd.randrange(3)
            if sh:  # LSR/ASR by 32 gives 0/-1-ish: keep offsets sane with LSR #32 only for small
                sh, amt = 0, 0
            op2 = (1 << 25) | (amt << 7) | (sh << 5) | rm
            if not b:
                r[rm] = (r[rm] >> amt) << amt
        if not p:
            w = 0
        op = (cond << 28) | (1 << 26) | (p << 24) | (u << 23) | (b << 22) | (w << 21) | (l << 20) | (rn << 16) | (rd << 12) | op2
    elif k == 8:  # LDRH/STRH/LDRSB/LDRSH/LDRD/STRD
        p, u, i, w = rnd.randrange(2), rnd.randrange(2), rnd.randrange(2), rnd.randrange(2)
        form = rnd.randrange(5)
        l, sh = [(1, 1), (0, 1), (1, 2), (1, 3), (0, 2 + rnd.randrange(2))][form]
        rn = reg()
        rd = reg()
        if (l, sh) in ((0, 2), (0, 3)):
            rd = rnd.randrange(6) * 2
            while rn in (rd, rd + 1):
                rn = reg()
        while rd == rn:
            rd = reg()
        size = 8 if (l == 0 and sh in (2, 3)) else (1 if sh == 2 else 2)
        r[rn] = dptr(rnd, max(size, 4) if size == 8 else size)
        if i:
            off = rnd.randrange(0, 32) * (4 if size == 8 else size)
            op2 = (1 << 22) | ((off & 0xf0) << 4) | (off & 0xf)
        else:
            rm = reg()
            while rm in (rn, rd, rd + 1):
                rm = reg()
            r[rm] = rnd.randrange(0, 32) * (4 if size == 8 else size)
            op2 = rm
        if not p:
            w = 0
        op = (cond << 28) | (p << 24) | (u << 23) | (w << 21) | (l << 20) | (rn << 16) | (rd << 12) | 0x90 | (sh << 5) | op2
    elif k == 9:  # LDM/STM
        p, u, w, l = rnd.randrange(2), rnd.randrange(2), rnd.randrange(2), rnd.randrange(2)
        rn = reg()
        lst = rnd.randrange(1, 1 << 13)
        if w or l:
            lst &= ~(1 << rn)
        if lst == 0:
            lst = 1 << ((rn + 1) % 13)
        r[rn] = DATA + 0x6000 + rnd.randrange(0, 0x400) * 4
        op = (cond << 28) | (4 << 25) | (p << 24) | (u << 23) | (w << 21) | (l << 20) | (rn << 16) | lst
    elif k == 10:  # B / BL (never to its own address: Unicorn would stop before starting)
        off = rnd.choice([o for o in (rnd.randrange(-0x800, 0x800),) if o != -2] or [2])
        op = (cond << 28) | (5 << 25) | (rnd.randrange(2) << 24) | (off & 0xffffff)
    elif k == 11:  # BX / BLX reg
        rm = reg()
        r[rm] = CODE + 0x4000 + rnd.randrange(0x100) * 4 + rnd.randrange(2)
        op = (cond << 28) | 0x012FFF10 | (rnd.randrange(2) << 5) | rm
    elif k == 12:  # BLX imm
        off = rnd.choice([o for o in (rnd.randrange(-0x800, 0x800),) if o != -2] or [2])
        op = 0xFA000000 | (rnd.randrange(2) << 24) | (off & 0xffffff)
    elif k == 13:  # MRS / MSR flags
        if rnd.randrange(2):
            rd = reg()
            op = (cond << 28) | 0x010F0000 | (rd << 12)
            c.mask_reg[rd] = FLAGS_MASK & ~0x20
        else:
            if rnd.randrange(2):
                op = (cond << 28) | 0x0328F000 | (rnd.randrange(16) << 8) | rnd.randrange(256)
            else:
                op = (cond << 28) | 0x0128F000 | reg()
    elif k == 14:  # (SWP/SWPB are UNDEFINED on Cortex-A9; test CLZ again instead)
        op = (cond << 28) | 0x016F0F10 | (reg() << 12) | reg()
    else:  # data processing with PC as an operand (reads pc+8)
        opc = rnd.choice([0, 1, 2, 3, 4, 12, 14])
        op = (cond << 28) | (opc << 21) | (15 << 16) | (reg() << 12) | (rnd.randrange(32) << 7) | (rnd.randrange(4) << 5) | rnd.choice([15, reg()])
    c.code = op.to_bytes(4, 'little')
    return c


def run_case(c, rnd, idx):
    code_img = bytes(rnd.getrandbits(8) for _ in range(64))
    data_img = bytes(rnd.getrandbits(8) for _ in range(DATA_SIZE))
    base = c.pc - 32
    ctypes.memmove(lib.zt_ptr(base), code_img, 64)
    ctypes.memmove(lib.zt_ptr(c.pc), c.code, len(c.code))
    ctypes.memmove(lib.zt_ptr(DATA), data_img, DATA_SIZE)
    uc.mem_write(base, code_img)
    uc.mem_write(c.pc, c.code)
    uc.mem_write(DATA, data_img)
    uc.ctl_remove_cache(CODE, CODE + CODE_SIZE)  # Unicorn keeps translated blocks across mem_write
    if hasattr(c, 'pop_target'):
        n = bin(c.code[0] | ((c.code[1] & 1) << 8)).count('1')
        addr = c.regs[13] + 4 * (n - 1)
        ctypes.memmove(lib.zt_ptr(addr), c.pop_target.to_bytes(4, 'little'), 4)
        uc.mem_write(addr, c.pop_target.to_bytes(4, 'little'))

    # CPSR first: entering user mode swaps in the banked SP/LR.
    lib.zt_set_cpsr(cpu, c.flags | (0x20 if c.thumb else 0))
    uc.reg_write(UC_ARM_REG_CPSR, 0x10 | c.flags | (0x20 if c.thumb else 0))
    for i in range(15):
        lib.zt_set_reg(cpu, i, c.regs[i])
        uc.reg_write(REGS[i], c.regs[i])
    lib.zt_set_reg(cpu, 15, c.pc)
    uc.reg_write(UC_ARM_REG_PC, c.pc | (1 if c.thumb else 0))

    lib.zt_clear()
    lib.zt_step(cpu)
    fault = lib.zt_last_fault().decode()
    our_next = lib.zt_get_reg(cpu, 15)
    try:
        uc.emu_start(c.pc | (1 if c.thumb else 0), our_next, count=4)
        ufault = None
    except UcError as e:
        ufault = str(e)

    ours = [lib.zt_get_reg(cpu, i) for i in range(16)]
    theirs = [uc.reg_read(REGS[i]) for i in range(16)]
    ocpsr = lib.zt_get_cpsr(cpu) & FLAGS_MASK
    ucpsr = uc.reg_read(UC_ARM_REG_CPSR) & FLAGS_MASK
    for rr, m in c.mask_reg.items():
        ours[rr] &= m
        theirs[rr] &= m
    odata = ctypes.string_at(lib.zt_ptr(DATA), DATA_SIZE)
    udata = bytes(uc.mem_read(DATA, DATA_SIZE))
    ok = ours == theirs and ocpsr == ucpsr and odata == udata and not fault and not ufault
    if not ok:
        print('MISMATCH #%d %s code=%s pc=%08x flags=%08x' % (idx, 'thumb' if c.thumb else 'arm', c.code.hex(), c.pc, c.flags))
        if fault or ufault:
            print('  fault ours=%r unicorn=%r' % (fault, ufault))
        for i in range(16):
            if ours[i] != theirs[i]:
                print('  r%-2d ours=%08x unicorn=%08x (in=%08x)' % (i, ours[i], theirs[i], c.regs[i] if i < 15 else c.pc))
        if ocpsr != ucpsr:
            print('  cpsr ours=%08x unicorn=%08x' % (ocpsr, ucpsr))
        if odata != udata:
            diffs = [j for j in range(DATA_SIZE) if odata[j] != udata[j]]
            print('  data differs at %d bytes, first %08x' % (len(diffs), DATA + diffs[0]))
    return ok


def main():
    iters = int(sys.argv[2]) if len(sys.argv) > 2 else 20000
    seed = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    rnd = random.Random(seed)
    bad = 0
    for i in range(iters):
        c = gen_thumb(rnd) if i % 2 == 0 else gen_arm(rnd)
        if not run_case(c, rnd, i):
            bad += 1
            if bad >= 25:
                break
    print('%d cases, %d mismatches' % (i + 1, bad))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
