#!/usr/bin/env python
# -*- coding: utf-8 -*-
import math
import functools


class Registers:
    """ An object to hold the CPU registers. """
    def __init__(self, pc=0):
        self.reset(pc)

    def reset(self, pc=0):
        self.a = 0          # Accumulator
        self.x = 0          # General Purpose X
        self.y = 0          # General Purpose Y
        self.s = 0xff       # Stack Pointer
        self.pc = pc        # Program Counter

        self.flagBit = {
            'N': 128,   # N - Negative
            'V': 64,    # V - Overflow
            'B': 16,    # B - Break Command
            'D': 8,     # D - Decimal Mode
            'I': 4,     # I - IRQ Disable
            'Z': 2,     # Z - Zero
            'C': 1      # C - Carry
        }
        self.p = 0b00100100  # Flag Pointer - N|V|1|B|D|I|Z|C

    def getFlag(self, flag):
        return bool(self.p & self.flagBit[flag])

    def setFlag(self, flag, v=True):
        if v:
            self.p = self.p | self.flagBit[flag]
        else:
            self.clearFlag(flag)

    def clearFlag(self, flag):
        self.p = self.p & (255 - self.flagBit[flag])

    def clearFlags(self):
        self.p = 0

    def ZN(self, v):
        """
        The criteria for Z and N flags are standard.  Z gets set if the
        value is zero and N gets set to the same value as bit 7 of the value.
        """
        self.setFlag('Z', v == 0)
        self.setFlag('N', v & 0x80)

    def __repr__(self):
        return "A: %02x X: %02x Y: %02x S: %02x PC: %04x P: %s" % (
            self.a, self.x, self.y, self.s, self.pc, bin(self.p)[2:].zfill(8)
        )


class CPU:

    def __init__(self, mmu=None, pc=None, stack_page=0x1, magic=0xee):
        """
        Parameters
        ----------
        mmu: An instance of MMU
        pc: The starting address of the pc (program counter)
        stack_page: The index of the page which contains the stack.  The default for
            a 6502 is page 1 (the stack from 0x0100-0x1ff) but in some varients the
            stack page may be elsewhere.
        magic: A value needed for the illegal opcodes, XAA.  This value differs
            between different versions, even of the same CPU.  The default is 0xee.
        """
        self.mmu = mmu
        self.r = Registers()
        self.cc = 0
        # Which page the stack is in.  0x1 means that the stack is from
        # 0x100-0x1ff.  In the 6502 this is always true but it's different
        # for other 65* varients.
        self.stack_page = stack_page
        self.magic = magic

        if pc:
            self.r.pc = pc
        else:
            # if pc is none get the address from $FFFD,$FFFC
            pass

        self._create_ops()

    def reset(self):
        self.r.reset()
        self.mmu.reset()

        self.running = True

    def step(self):
        self.cc = 0
        # pc = self.r.pc
        opcode = self.nextByte()
        self.ops[opcode]()

    def execute(self, instruction):
        """
        Execute a single instruction independent of the program in memory.
        instruction is an array of bytes.
        """
        pass

    def nextByte(self):
        v = self.mmu.read(self.r.pc)
        self.r.pc += 1
        return v

    def nextWord(self):
        low = self.nextByte()
        high = self.nextByte()
        return (high << 8) + low

    def stackPush(self, v):
        self.mmu.write(self.stack_page*0x100 + self.r.s, v)
        self.r.s = (self.r.s - 1) & 0xff

    def stackPushWord(self, v):
        self.stackPush(v >> 8)
        self.stackPush(v & 0xff)

    def stackPop(self):
        v = self.mmu.read(self.stack_page*0x100 + ((self.r.s + 1) & 0xff))
        self.r.s = (self.r.s + 1) & 0xff
        return v

    def stackPopWord(self):
        return self.stackPop() + (self.stackPop() << 8)

    def fromBCD(self, v):
        return (((v & 0xf0) // 0x10) * 10) + (v & 0xf)

    def toBCD(self, v):
        return int(math.floor(v/10))*16 + (v % 10)

    def fromTwosCom(self, v):
        return (v & 0x7f) - (v & 0x80)

    interrupts = {
        "ABORT":    0xfff8,
        "COP":      0xfff4,
        "IRQ":      0xfffe,
        "BRK":      0xfffe,
        "NMI":      0xfffa,
        "RESET":    0xfffc
    }

    def interruptAddress(self, i):
        return self.mmu.readWord(self.interrupts[i])

    # Addressing modes
    def z_a(self):
        return self.nextByte()

    def zx_a(self):
        return (self.nextByte() + self.r.x) & 0xff

    def zy_a(self):
        return (self.nextByte() + self.r.y) & 0xff

    def a_a(self):
        return self.nextWord()

    def ax_a(self):
        o = self.nextWord()
        a = o + self.r.x
        if math.floor(o/0xff) != math.floor(a/0xff):
            self.cc += 1

        return a & 0xffff

    def ay_a(self):
        o = self.nextWord()
        a = o + self.r.y
        if math.floor(o/0xff) != math.floor(a/0xff):
            self.cc += 1

        return a & 0xffff

    def i_a(self):
        """Only used by indirect JMP"""
        i = self.nextWord()
        # Doesn't carry, so if the low byte is in the XXFF position
        # Then the high byte will be XX00 rather than XY00
        if i & 0xff == 0xff:
            j = i - 0xff
        else:
            j = i + 1

        return ((self.mmu.read(j) << 8) + self.mmu.read(i)) & 0xffff

    def ix_a(self):
        i = (self.nextByte() + self.r.x) & 0xff
        return ((self.mmu.read((i + 1) & 0xff) << 8) + self.mmu.read(i)) & 0xffff

    def iy_a(self):
        i = self.nextByte()
        o = (self.mmu.read((i + 1) & 0xff) << 8) + self.mmu.read(i)
        a = o + self.r.y

        if math.floor(o/0xff) != math.floor(a/0xff):
            self.cc += 1

        return a & 0xffff

    # Return values based on the addressing mode
    def im(self):
        return self.nextByte()

    def z(self):
        return self.mmu.read(self.z_a())

    def zx(self):
        return self.mmu.read(self.zx_a())

    def zy(self):
        return self.mmu.read(self.zy_a())

    def a(self):
        return self.mmu.read(self.a_a())

    def ax(self):
        return self.mmu.read(self.ax_a())

    def ay(self):
        return self.mmu.read(self.ay_a())

    def i(self):
        return self.mmu.read(self.i_a())

    def ix(self):
        return self.mmu.read(self.ix_a())

    def iy(self):
        return self.mmu.read(self.iy_a())

    # Operators
    # All the operations.  For each operation have the name of the operation,
    # whether it acts on values, "v" or on addresses, "a" and a list of 4-tuples
    # containing the valid addressing modes for the operation, the
    # base number of cycles it takes, the opcode, and a target register, if valid.
    _ops = [
        ("ADC", "v", [
            ("im", 2, [0x69], None),
            ("z",  3, [0x65], None),
            ("zx", 4, [0x75], None),
            ("a",  4, [0x6d], None),
            ("ax", 4, [0x7d], None),
            ("ay", 4, [0x79], None),
            ("ix", 6, [0x61], None),
            ("iy", 5, [0x71], None)
        ]),
        ("AND", "v", [
            ("im", 2, [0x29], None),
            ("z",  3, [0x25], None),
            ("zx", 4, [0x35], None),
            ("a",  4, [0x2d], None),
            ("ax", 4, [0x3d], None),
            ("ay", 4, [0x39], None),
            ("ix", 6, [0x21], None),
            ("iy", 5, [0x31], None)
        ]),
        ("ASL", "a", [
            ("im", 2, [0x0a], "a"),
            ("z",  5, [0x06], None),
            ("zx", 6, [0x16], None),
            ("a",  6, [0x0e], None),
            ("ax", 7, [0x1e], None)
        ]),
        ("B", "v", [
            ("PL", 2, [0x10], ("N", False)),
            ("MI", 2, [0x30], ("N", True)),
            ("VC", 2, [0x50], ("V", False)),
            ("VC", 2, [0x70], ("V", True)),
            ("CC", 2, [0x90], ("C", False)),
            ("CS", 2, [0xb0], ("C", True)),
            ("NE", 2, [0xd0], ("Z", False)),
            ("EQ", 2, [0xf0], ("Z", True))
        ]),
        ("BIT", "v", [
            ("z",  3, [0x24], None),
            ("a",  4, [0x2c], None)
        ]),
        ("BRK", "v", [
            ("im", 7, [0x00], 1)
        ]),
        ("CMP", "v", [
            ("im", 2, [0xc9], None),
            ("z",  3, [0xc5], None),
            ("zx", 4, [0xd5], None),
            ("a",  4, [0xcd], None),
            ("ax", 4, [0xdd], None),
            ("ay", 4, [0xd9], None),
            ("ix", 6, [0xc1], None),
            ("iy", 5, [0xd1], None)
        ]),
        ("CPX", "v", [
            ("im", 2, [0xe0], None),
            ("z",  3, [0xe4], None),
            ("a",  4, [0xec], None)
        ]),
        ("CPY", "v", [
            ("im", 2, [0xc0], None),
            ("z",  3, [0xc4], None),
            ("a",  4, [0xcc], None)
        ]),
        ("DEC", "a", [
            ("z",  5, [0xc6], None),
            ("zx", 6, [0xd6], None),
            ("a",  6, [0xce], None),
            ("ax", 7, [0xde], None)
        ]),
        ("DEX", "a", [
            ("im", 2, [0xca], 1)
        ]),
        ("DEY", "a", [
            ("im", 2, [0x88], 1)
        ]),
        ("EOR", "v", [
            ("im", 2, [0x49], None),
            ("z",  3, [0x45], None),
            ("zx", 4, [0x55], None),
            ("a",  4, [0x4d], None),
            ("ax", 4, [0x5d], None),
            ("ay", 4, [0x59], None),
            ("ix", 6, [0x41], None),
            ("iy", 5, [0x51], None)
        ]),
        ("CL", "v", [
            ("C", 2, [0x18], "C"),
            ("I", 2, [0x58], "I"),
            ("V", 2, [0xb8], "V"),
            ("D", 2, [0xd8], "D")
        ]),
        ("SE", "v", [
            ("C", 2, [0x38], "C"),
            ("I", 2, [0x78], "I"),
            ("D", 2, [0xf8], "D")
        ]),
        ("INC", "a", [
            ("z",  5, [0xe6], None),
            ("zx", 6, [0xf6], None),
            ("a",  6, [0xee], None),
            ("ax", 7, [0xfe], None)
        ]),
        ("INX", "a", [
            ("im", 2, [0xe8], 1)
        ]),
        ("INY", "a", [
            ("im", 2, [0xc8], 1)
        ]),
        ("JMP", "a", [
            ("a", 3, [0x4c], None),
            ("i", 5, [0x6c], None)
        ]),
        ("JSR", "a", [
            ("a", 6, [0x20], None)
        ]),
        ("LDA", "v", [
            ("im", 2, [0xa9], None),
            ("z",  3, [0xa5], None),
            ("zx", 4, [0xb5], None),
            ("a",  4, [0xad], None),
            ("ax", 4, [0xbd], None),
            ("ay", 4, [0xb9], None),
            ("ix", 6, [0xa1], None),
            ("iy", 5, [0xb1], None)
        ]),
        ("LDX", "v", [
            ("im", 2, [0xa2], None),
            ("z",  3, [0xa6], None),
            ("zy", 4, [0xb6], None),
            ("a",  4, [0xae], None),
            ("ay", 4, [0xbe], None)
        ]),
        ("LDY", "v", [
            ("im", 2, [0xa0], None),
            ("z",  3, [0xa4], None),
            ("zx", 4, [0xb4], None),
            ("a",  4, [0xac], None),
            ("ax", 4, [0xbc], None)
        ]),
        ("LSR", "a", [
            ("im", 2, [0x4a], "a"),
            ("z",  5, [0x46], None),
            ("zx", 6, [0x56], None),
            ("a",  6, [0x4e], None),
            ("ax", 7, [0x5e], None)
        ]),
        ("NOP", "v", [
            # (imp)lied mode with opcode 0xea is the only documented
            # NOP, the rest are illegal opcodes.
            ("ip", 2, [0x1a, 0x3a, 0x5a, 0x7a, 0xda, 0xea, 0xfa], 1),
            ("im", 2, [0x80, 0x82, 0x89, 0xc2, 0xe2], None),
            ("z",  3, [0x04, 0x44, 0x64, ], None),
            ("zx", 4, [0x14, 0x34, 0x54, 0x74, 0xd4, 0xf4], None),
            ("a",  4, [0x0c], None),
            ("ax", 4, [0x1c, 0x3c, 0x5c, 0x7c, 0xdc, 0xfc], None)
        ]),
        ("ORA", "v", [
            ("im", 2, [0x09], None),
            ("z",  3, [0x05], None),
            ("zx", 4, [0x15], None),
            ("a",  4, [0x0d], None),
            ("ax", 4, [0x1d], None),
            ("ay", 4, [0x19], None),
            ("ix", 6, [0x01], None),
            ("iy", 5, [0x11], None)
        ]),
        ("P", "a", [
            ("PHA", 3, [0x48], ("PH", "a")),
            ("PLA", 4, [0x68], ("PL", "a")),
            ("PHP", 3, [0x08], ("PH", "p")),
            ("PLP", 4, [0x28], ("PL", "p")),
        ]),
        ("T", "a", [
            ("AX", 2, [0xaa], ('a', 'x')),
            ("XA", 2, [0x8a], ('x', 'a')),
            ("AY", 2, [0xa8], ('a', 'y')),
            ("YA", 2, [0x98], ('y', 'a')),
            ("XS", 2, [0x9a], ('x', 's')),
            ("SX", 2, [0xba], ('s', 'x'))
        ]),
        ("ROL", "a", [
            ("im", 2, [0x2a], "a"),
            ("z",  5, [0x26], None),
            ("zx", 6, [0x36], None),
            ("a",  6, [0x2e], None),
            ("ax", 7, [0x3e], None)
        ]),
        ("ROR", "a", [
            ("im", 2, [0x6a], "a"),
            ("z",  5, [0x66], None),
            ("zx", 6, [0x76], None),
            ("a",  6, [0x6e], None),
            ("ax", 7, [0x7e], None)
        ]),
        ("RTI", "a", [
            ("im", 6, [0x40], 1)
        ]),
        ("RTS", "a", [
            ("im", 6, [0x60], 1)
        ]),
        ("SBC", "v", [
            ("im", 2, [0xe9, 0xeb], None),
            ("z",  3, [0xe5], None),
            ("zx", 4, [0xf5], None),
            ("a",  4, [0xed], None),
            ("ax", 4, [0xfd], None),
            ("ay", 4, [0xf9], None),
            ("ix", 6, [0xe1], None),
            ("iy", 5, [0xf1], None)
        ]),
        ("STA", "a", [
            ("z",  3, [0x85], None),
            ("zx", 4, [0x95], None),
            ("a",  4, [0x8d], None),
            ("ax", 5, [0x9d], None),
            ("ay", 5, [0x99], None),
            ("ix", 6, [0x81], None),
            ("iy", 6, [0x91], None)
        ]),
        ("STX", "a", [
            ("z",  3, [0x86], None),
            ("zy", 4, [0x96], None),
            ("a",  4, [0x8e], None),
        ]),
        ("STY", "a", [
            ("z",  3, [0x84], None),
            ("zx", 4, [0x94], None),
            ("a",  4, [0x8c], None)
        ]),
        # ***Ilegal Opcodes***
        ("AAC", "v", [
            ("im", 2, [0x0b, 0x2b], None)
        ]),
        ("AAX", "a", [
            ("z",  3, [0x87], None),
            ("zy", 4, [0x97], None),
            ("a",  4, [0x8f], None),
            ("ix", 6, [0x83], None),
        ]),
        ("ARR", "v", [
            ("im", 2, [0x6b], None)
        ]),
        ("ASR", "v", [
            ("im", 2, [0x4b], None)
        ]),
        ("ATX", "v", [
            ("im", 2, [0xab], None)
        ]),
        ("AXA", "a", [
            ("ay", 5, [0x9f], None),
            ("iy", 6, [0x93], None)
        ]),
        ("AXS", "v", [
            ("im", 2, [0xcb], None)
        ]),
        ("DCP", "a", [
            ("z",  5, [0xc7], None),
            ("zx", 6, [0xd7], None),
            ("a",  6, [0xcf], None),
            ("ax", 7, [0xdf], None),
            ("ay", 7, [0xdb], None),
            ("ix", 8, [0xc3], None),
            ("iy", 8, [0xd3], None)
        ]),
        ("ISC", "a", [
            ("z",  5, [0xe7], None),
            ("zx", 6, [0xf7], None),
            ("a",  6, [0xef], None),
            ("ax", 7, [0xff], None),
            ("ay", 7, [0xfb], None),
            ("ix", 8, [0xe3], None),
            ("iy", 8, [0xf3], None)
        ]),
        ("KIL", "v", [
            ("im", 0, [0x02, 0x12, 0x22, 0x32, 0x42, 0x52,
                       0x62, 0x72, 0x92, 0xb2, 0xd2, 0xf2], 1)
        ]),
        ("LAR", "v", [
            ("ay", 4, [0xbb], None)
        ]),
        ("LAX", "v", [
            ("z",  3, [0xa7], None),
            ("zy", 4, [0xb7], None),
            ("a",  4, [0xaf], None),
            ("ay", 4, [0xbf], None),
            ("ix", 6, [0xa3], None),
            ("iy", 5, [0xb3], None)
        ]),
        ("RLA", "a", [
            ("z",  5, [0x27], None),
            ("zx", 6, [0x37], None),
            ("a",  6, [0x2f], None),
            ("ax", 7, [0x3f], None),
            ("ay", 7, [0x3b], None),
            ("ix", 8, [0x23], None),
            ("iy", 8, [0x33], None)
        ]),
        ("RRA", "a", [
            ("z",  5, [0x67], None),
            ("zx", 6, [0x77], None),
            ("a",  6, [0x6f], None),
            ("ax", 7, [0x7f], None),
            ("ay", 7, [0x7b], None),
            ("ix", 8, [0x63], None),
            ("iy", 8, [0x73], None)
        ]),
        ("SLO", "a", [
            ("z",  5, [0x07], None),
            ("zx", 6, [0x17], None),
            ("a",  6, [0x0f], None),
            ("ax", 7, [0x1f], None),
            ("ay", 7, [0x1b], None),
            ("ix", 8, [0x03], None),
            ("iy", 8, [0x13], None)
        ]),
        ("SRE", "a", [
            ("z",  5, [0x47], None),
            ("zx", 6, [0x57], None),
            ("a",  6, [0x4f], None),
            ("ax", 7, [0x5f], None),
            ("ay", 7, [0x5b], None),
            ("ix", 8, [0x43], None),
            ("iy", 8, [0x53], None)
        ]),
        ("SXA", "a", [
            ("ay", 5, [0x9e], None)
        ]),
        ("SYA", "a", [
            ("ax", 5, [0x9c], None)
        ]),
        ("XAA", "v", [
            ("im", 2, [0x8b], None)
        ]),
        ("XAS", "a", [
            ("ay", 5, [0x9b], None)
        ])
    ]

    def _create_ops(self):

        def f(self, op_f, a_f, cc):
            op_f(a_f())
            self.cc += cc

        def f_target(target):
            return target

        self.ops = [None]*0x100

        for op, atype, addrs in self._ops:
            op_f = getattr(self, op)
            for a, cc, opcode, target in addrs:
                if target:
                    a_f = functools.partial(f_target, target)
                elif atype == 'v':
                    a_f = getattr(self, a)
                else:
                    a_f = getattr(self, "%s_a" % a)

                fp = functools.partial(f, self, op_f, a_f, cc)
                for o in opcode:
                    if self.ops[o]:
                        raise Exception("Opcode %s already defined" % hex(o))
                    self.ops[o] = fp

    def ADC(self, v2):
        v1 = self.r.a

        if self.r.getFlag('D'):  # decimal mode
            d1 = self.fromBCD(v1)
            d2 = self.fromBCD(v2)
            r = d1 + d2 + self.r.getFlag('C')
            self.r.a = self.toBCD(r % 100)

            self.r.setFlag('C', r > 99)
        else:
            r = v1 + v2 + self.r.getFlag('C')
            self.r.a = r & 0xff

            self.r.setFlag('C', r > 0xff)

        self.r.ZN(self.r.a)
        self.r.setFlag('V', ((~(v1 ^ v2)) & (v1 ^ r) & 0x80))

    def AND(self, v):
        self.r.a = (self.r.a & v) & 0xff
        self.r.ZN(self.r.a)

    def ASL(self, a):
        if a == 'a':
            v = self.r.a << 1
            self.r.a = v & 0xff
        else:
            v = self.mmu.read(a) << 1
            self.mmu.write(a, v)

        self.r.setFlag('C', v > 0xff)
        self.r.ZN(v & 0xff)

    def BIT(self, v):
        self.r.setFlag('Z', self.r.a & v == 0)
        self.r.setFlag('N', v & 0x80)
        self.r.setFlag('V', v & 0x40)

    def B(self, v):
        """
        v is a tuple of (flag, boolean).  For instance, BCC (Branch Carry Clear)
        will call B(('C', False)).
        """
        d = self.im()
        if self.r.getFlag(v[0]) is v[1]:
            o = self.r.pc
            self.r.pc += self.fromTwosCom(d)
            if math.floor(o/0xff) == math.floor(self.r.pc/0xff):
                self.cc += 1
            else:
                self.cc += 2

    def BRK(self, _):
        self.r.setFlag('B')
        self.stackPushWord(self.r.pc+1)
        self.stackPush(self.r.p)
        self.r.setFlag('I')
        self.r.pc = self.interruptAddress('BRK')

    def CP(self, r, v):
        o = (r-v) & 0xff
        self.r.setFlag('Z', o == 0)
        self.r.setFlag('C', v <= r)
        self.r.setFlag('N', o & 0x80)

    def CMP(self, v):
        self.CP(self.r.a, v)

    def CPX(self, v):
        self.CP(self.r.x, v)

    def CPY(self, v):
        self.CP(self.r.y, v)

    def DEC(self, a):
        v = (self.mmu.read(a)-1) & 0xff
        self.mmu.write(a, v)
        self.r.ZN(v)

    def DEX(self, _):
        self.r.x = (self.r.x-1) & 0xff
        self.r.ZN(self.r.x)

    def DEY(self, _):
        self.r.y = (self.r.y-1) & 0xff
        self.r.ZN(self.r.y)

    def EOR(self, v):
        self.r.a = self.r.a ^ v
        self.r.ZN(self.r.a)

    """Flag Instructions."""
    def SE(self, v):
        """Set the flag to True."""
        self.r.setFlag(v)

    def CL(self, v):
        """Clear the flag to False."""
        self.r.clearFlag(v)

    def INC(self, a):
        v = (self.mmu.read(a)+1) & 0xff
        self.mmu.write(a, v)
        self.r.ZN(v)

    def INX(self, _):
        self.r.x = (self.r.x+1) & 0xff
        self.r.ZN(self.r.x)

    def INY(self, _):
        self.r.y = (self.r.y+1) & 0xff
        self.r.ZN(self.r.y)

    def JMP(self, a):
        self.r.pc = a

    def JSR(self, a):
        self.stackPushWord(self.r.pc-1)
        self.r.pc = a

    def LDA(self, v):
        self.r.a = v
        self.r.ZN(self.r.a)

    def LDX(self, v):
        self.r.x = v
        self.r.ZN(self.r.x)

    def LDY(self, v):
        self.r.y = v
        self.r.ZN(self.r.y)

    def LSR(self, a):
        if a == 'a':
            self.r.setFlag('C', self.r.a & 0x01)
            self.r.a = v = self.r.a >> 1
        else:
            v = self.mmu.read(a)
            self.r.setFlag('C', v & 0x01)
            v = v >> 1
            self.mmu.write(a, v)

        self.r.ZN(v)

    def NOP(self, _):
        pass

    def ORA(self, v):
        self.r.a = self.r.a | v
        self.r.ZN(self.r.a)

    def P(self, v):
        """
        Stack operations, PusH and PulL.  v is a tuple where the
        first value is either PH or PL, specifying the action and
        the second is the source or target register, either A or P,
        meaning the Accumulator or the Processor status flag.
        """
        a, r = v

        if a == "PH":
            self.stackPush(getattr(self.r, r))
        else:
            setattr(self.r, r, self.stackPop())

            if r == "a":
                self.r.ZN(self.r.a)
            elif r == "p":
                self.r.p = self.r.p | 0b00100000

    def ROL(self, a):
        if a == "a":
            v_old = self.r.a
            self.r.a = v_new = ((v_old << 1) + self.r.getFlag('C')) & 0xff
        else:
            v_old = self.mmu.read(a)
            v_new = ((v_old << 1) + self.r.getFlag('C')) & 0xff
            self.mmu.write(a, v_new)

        self.r.setFlag('C', v_old & 0x80)
        self.r.ZN(v_new)

    def ROR(self, a):
        if a == "a":
            v_old = self.r.a
            self.r.a = v_new = ((v_old >> 1) + self.r.getFlag('C')*0x80) & 0xff
        else:
            v_old = self.mmu.read(a)
            v_new = ((v_old >> 1) + self.r.getFlag('C')*0x80) & 0xff
            self.mmu.write(a, v_new)

        self.r.setFlag('C', v_old & 0x01)
        self.r.ZN(v_new)

    def RTI(self, _):
        self.r.p = self.stackPop()
        self.r.pc = self.stackPopWord()

    def RTS(self, _):
        self.r.pc = (self.stackPopWord() + 1) & 0xffff

    def SBC(self, v2):
        v1 = self.r.a
        if self.r.getFlag('D'):
            d1 = self.fromBCD(v1)
            d2 = self.fromBCD(v2)
            r = d1 - d2 - (not self.r.getFlag('C'))
            self.r.a = self.toBCD(r % 100)
        else:
            r = v1 - v2 - (not self.r.getFlag('C'))
            self.r.a = r & 0xff

        self.r.setFlag('C', r >= 0)
        self.r.setFlag('V', ((v1 ^ v2) & (v1 ^ r) & 0x80))
        self.r.ZN(self.r.a)

    def STA(self, a):
        self.mmu.write(a, self.r.a)

    def STX(self, a):
        self.mmu.write(a, self.r.x)

    def STY(self, a):
        self.mmu.write(a, self.r.y)

    def T(self, a):
        """
        Transfer registers
        a is a tuple with (source, destination) so TAX
        would be T(('a', 'x'))self.
        """
        s, d = a
        setattr(self.r, d, getattr(self.r, s))
        if d != 's':
            self.r.ZN(getattr(self.r, d))

    """
    Illegal Opcodes
    ---------------

    Opcodes which were not officially documented but still have
    and effect.  The behavior for each of these is based on the following:

    -http://www.ataripreservation.org/websites/freddy.offenga/illopc31.txt
    -http://wiki.nesdev.com/w/index.php/Programming_with_unofficial_opcodes
    -www.ffd2.com/fridge/docs/6502-NMOS.extra.opcodes

    The behavior is not consistent across the various resources so I don't
    promise 100% hardware accuracy here.

    Other names for the opcode are in comments on the function defintion
    line.
    """

    def AAC(self, v):  # ANC
        self.AND(v)
        self.r.setFlag('C', self.r.getFlag('N'))

    def AAX(self, a):  # SAX, AXS
        r = self.r.a & self.r.x
        self.mmu.write(a, r)
        # self.r.ZN(r) # There is conflicting information whether this effects P.

    def ARR(self, v):
        self.AND(v)
        self.ROR('a')
        self.r.setFlag('C', self.r.a & 0x40)
        self.r.setFlag('V', bool(self.r.a & 0x40) ^ bool(self.r.a & 0x20))

    def ASR(self, v):  # ALR
        self.AND(v)
        self.LSR('a')

    def ATX(self, v):  # LXA, OAL
        self.AND(v)
        self.T(('a', 'x'))

    def AXA(self, a):  # SHA
        """
        There are a few illegal opcodes which and the high
        bit of the address with registers and write the values
        back into that address.  These operations are
        particularly screwy.  These posts are used as reference
        but I am unsure whether they are correct.
        - forums.nesdev.com/viewtopic.php?f=3&t=3831&start=30#p113343
        - forums.nesdev.com/viewtopic.php?f=3&t=10698
        """
        o = (a - self.r.y) & 0xffff
        low = o & 0xff
        high = o >> 8
        if low + self.r.y > 0xff:  # crossed page
            a = ((high & self.r.x) << 8) + low + self.r.y
        else:
            a = (high << 8) + low + self.r.y

        v = self.r.a & self.r.x & (high + 1)
        self.mmu.write(a, v)

    def AXS(self, v):  # SBX, SAX
        o = self.r.a & self.r.x
        self.r.x = (o - v) & 0xff

        self.r.setFlag('C', v <= o)
        self.r.ZN(self.r.x)

    def DCP(self, a):  # DCM
        self.DEC(a)
        self.CMP(self.mmu.read(a))

    def ISC(self, a):  # ISB, INS
        self.INC(a)
        self.SBC(self.mmu.read(a))

    def KIL(self, _):  # JAM, HLT
        self.running = False

    def LAR(self, v):  # LAE, LAS
        self.r.a = self.r.x = self.r.s = self.r.s & v
        self.r.ZN(self.r.a)

    def LAX(self, v):
        self.r.a = self.r.x = v
        self.r.ZN(self.r.a)

    def RLA(self, a):
        self.ROL(a)
        self.AND(self.mmu.read(a))

    def RRA(self, a):
        self.ROR(a)
        self.ADC(self.mmu.read(a))

    def SLO(self, a):  # ASO
        self.ASL(a)
        self.ORA(self.mmu.read(a))

    def SRE(self, a):  # LSE
        self.LSR(a)
        self.EOR(self.mmu.read(a))

    def SXA(self, a):  # SHX, XAS
        # See AXA
        o = (a - self.r.y) & 0xffff
        low = o & 0xff
        high = o >> 8
        if low + self.r.y > 0xff:  # crossed page
            a = ((high & self.r.x) << 8) + low + self.r.y
        else:
            a = (high << 8) + low + self.r.y

        v = self.r.x & (high + 1)
        self.mmu.write(a, v)

    def SYA(self, a):  # SHY, SAY
        # See AXA
        o = (a - self.r.x) & 0xffff
        low = o & 0xff
        high = o >> 8
        if low + self.r.x > 0xff:  # crossed page
            a = ((high & self.r.y) << 8) + low + self.r.x
        else:
            a = (high << 8) + low + self.r.x

        v = self.r.y & (high + 1)
        self.mmu.write(a, v)

    def XAA(self, v):  # ANE
        """
        Another very wonky operation.  It's fully described here:
        http://visual6502.org/wiki/index.php?title=6502_Opcode_8B_%28XAA,_ANE%29
        "magic" varies by version of the processor.  0xee seems to be common.
        The formula is: A = (A | magic) & X & imm
        """
        self.r.a = (self.r.a | self.magic) & self.r.x & v
        self.r.ZN(self.r.a)

    def XAS(self, a):  # SHS, TAS
        # First set the stack pointer's value
        self.r.s = self.r.a & self.r.x

        # Then write to memory using the new value of the stack pointer
        o = (a - self.r.y) & 0xffff
        low = o & 0xff
        high = o >> 8
        if low + self.r.y > 0xff:  # crossed page
            a = ((high & self.r.s) << 8) + low + self.r.y
        else:
            a = (high << 8) + low + self.r.y

        v = self.r.s & (high + 1)
        self.mmu.write(a, v)
