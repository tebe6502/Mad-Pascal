#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
test_cpu
----------------------------------

Tests for `py65emu` module.
"""

import os
import unittest

from py65emu.cpu import CPU
from py65emu.mmu import MMU


class TestCPU(unittest.TestCase):

    def _cpu(self, ram=(0, 0x200, False), rom=(0x1000, 0x100), romInit=None, pc=0x1000):
        return CPU(
            MMU([
                ram,
                rom + (True, romInit)
            ]),
            pc
        )

    def setUp(self):
        pass

    def test_fromBCD(self):
        c = self._cpu()
        self.assertEqual(c.fromBCD(0), 0)
        self.assertEqual(c.fromBCD(0x05), 5)
        self.assertEqual(c.fromBCD(0x11), 11)
        self.assertEqual(c.fromBCD(0x99), 99)

    def test_toBCD(self):
        c = self._cpu()
        self.assertEqual(c.toBCD(0), 0)
        self.assertEqual(c.toBCD(5), 0x05)
        self.assertEqual(c.toBCD(11), 0x11)
        self.assertEqual(c.toBCD(99), 0x99)

    def test_fromTwosCom(self):
        c = self._cpu()
        self.assertEqual(c.fromTwosCom(0x00), 0)
        self.assertEqual(c.fromTwosCom(0x01), 1)
        self.assertEqual(c.fromTwosCom(0x7f), 127)
        self.assertEqual(c.fromTwosCom(0xff), -1)
        self.assertEqual(c.fromTwosCom(0x80), -128)

    def test_nextByte(self):
        c = self._cpu(romInit=[1, 2, 3])
        self.assertEqual(c.nextByte(), 1)
        self.assertEqual(c.nextByte(), 2)
        self.assertEqual(c.nextByte(), 3)
        self.assertEqual(c.nextByte(), 0)

    def test_nextWord(self):
        c = self._cpu(romInit=[1, 2, 3, 4, 5, 9, 10])
        self.assertEqual(c.nextWord(), 0x0201)
        c.nextByte()
        self.assertEqual(c.nextWord(), 0x0504)
        self.assertEqual(c.nextWord(), 0x0a09)

    def test_zeropage_addressing(self):
        c = self._cpu(romInit=[1, 2, 3, 4, 5])
        self.assertEqual(c.z_a(), 1)
        c.r.x = 0
        self.assertEqual(c.zx_a(), 2)
        c.r.x = 1
        self.assertEqual(c.zx_a(), 4)
        c.r.y = 0
        self.assertEqual(c.zy_a(), 4)
        c.r.y = 1
        self.assertEqual(c.zy_a(), 6)

    def test_absolute_addressing(self):
        c = self._cpu(romInit=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        self.assertEqual(c.a_a(), 0x0201)

        c.r.x = 0
        c.cc = 0
        self.assertEqual(c.ax_a(), 0x0403)
        self.assertEqual(c.cc, 0)
        c.r.x = 0xff
        c.cc = 0
        self.assertEqual(c.ax_a(), 0x0605+0xff)
        self.assertEqual(c.cc, 1)

        c.r.y = 0
        c.cc = 0
        self.assertEqual(c.ay_a(), 0x0807)
        self.assertEqual(c.cc, 0)
        c.r.y = 0xff
        c.cc = 0
        self.assertEqual(c.ay_a(), 0x0a09+0xff)
        self.assertEqual(c.cc, 1)

    def test_indirect_addressing(self):
        c = self._cpu(romInit=[
            0x06, 0x10,
            0xff, 0x10,
            0x00,
            0x00,

            0xf0, 0x00,
        ])

        self.assertEqual(c.i_a(), 0x00f0)
        self.assertEqual(c.i_a(), 0x0600)

        c.r.y = 0x05
        c.mmu.write(0x00, 0x21)
        c.mmu.write(0x01, 0x43)
        self.assertEqual(c.iy_a(), 0x4326)

        c.r.x = 0x02
        c.mmu.write(0x02, 0x34)
        c.mmu.write(0x03, 0x12)
        self.assertEqual(c.ix_a(), 0x1234)

    def test_stack(self):
        c = self._cpu()
        c.stackPush(0x10)
        self.assertEqual(c.stackPop(), 0x10)
        c.stackPushWord(0x0510)
        self.assertEqual(c.stackPopWord(), 0x0510)
        self.assertEqual(c.stackPop(), 0x00)
        c.stackPush(0x00)
        c.stackPushWord(0x0510)
        self.assertEqual(c.stackPop(), 0x10)
        self.assertEqual(c.stackPop(), 0x05)

    def test_adc(self):
        c = self._cpu(romInit=[1, 2, 250, 3, 100, 100])
        # immediate
        c.ops[0x69]()
        self.assertEqual(c.r.a, 1)
        c.ops[0x69]()
        self.assertEqual(c.r.a, 3)
        c.ops[0x69]()
        self.assertEqual(c.r.a, 253)
        self.assertTrue(c.r.getFlag('N'))
        c.r.clearFlags()
        c.ops[0x69]()
        self.assertTrue(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('Z'))
        c.r.clearFlags()
        c.ops[0x69]()
        c.ops[0x69]()
        self.assertTrue(c.r.getFlag('V'))

    def test_adc_decimal(self):
        c = self._cpu(romInit=[0x01, 0x55, 0x50])
        c.r.setFlag('D')

        c.ops[0x69]()
        self.assertEqual(c.r.a, 0x01)
        c.ops[0x69]()
        self.assertEqual(c.r.a, 0x56)
        c.ops[0x69]()
        self.assertEqual(c.r.a, 0x06)
        self.assertTrue(c.r.getFlag('C'))

    def test_and(self):
        c = self._cpu(romInit=[0xff, 0xff, 0x01, 0x2])

        c.r.a = 0x00
        c.ops[0x29]()
        self.assertEqual(c.r.a, 0)

        c.r.a = 0xff
        c.ops[0x29]()
        self.assertEqual(c.r.a, 0xff)

        c.r.a = 0x01
        c.ops[0x29]()
        self.assertEqual(c.r.a, 0x01)

        c.r.a = 0x01
        c.ops[0x29]()
        self.assertEqual(c.r.a, 0x00)

    def test_asl(self):
        c = self._cpu(romInit=[0x00])

        c.r.a = 1
        c.ops[0x0a]()
        self.assertEqual(c.r.a, 2)

        c.mmu.write(0, 4)
        c.ops[0x06]()
        self.assertEqual(c.mmu.read(0), 8)

    def test_bit(self):
        c = self._cpu(romInit=[0x00, 0x00, 0x10])
        c.mmu.write(0, 0xff)
        c.r.a = 1

        c.ops[0x24]()  # Zero page
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('N'))
        self.assertTrue(c.r.getFlag('V'))

        c.ops[0x2c]()  # Absolute
        self.assertTrue(c.r.getFlag('Z'))
        self.assertFalse(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('V'))

    def test_brk(self):
        c = self._cpu()
        c.mmu.addBlock(0xfffe, 0x2, True, [0x34, 0x12])
        c.r.p = 239
        c.ops[0x00]()
        self.assertTrue(c.r.getFlag('B'))
        self.assertTrue(c.r.getFlag('I'))
        self.assertEqual(c.r.pc, 0x1234)
        self.assertEqual(c.stackPop(), 255)
        self.assertEqual(c.stackPopWord(), 0x1001)

    def test_branching(self):
        c = self._cpu(romInit=[0x01, 0x00, 0x00, 0xfc])
        c.ops[0x10]()
        self.assertEqual(c.r.pc, 0x1002)
        c.ops[0x70]()
        self.assertEqual(c.r.pc, 0x1003)
        c.r.setFlag('C')
        c.ops[0xb0]()
        self.assertEqual(c.r.pc, 0x1000)
        c.ops[0xd0]()
        self.assertEqual(c.r.pc, 0x1002)

    def test_cmp(self):
        c = self._cpu(romInit=[0x0f, 0x10, 0x11, 0xfe, 0xff, 0x00, 0x7f])

        c.r.a = 0x10
        c.ops[0xc9]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xc9]()
        self.assertTrue(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xc9]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertFalse(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('N'))

        c.r.a = 0xff
        c.ops[0xc9]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xc9]()
        self.assertTrue(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xc9]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('N'))
        c.ops[0xc9]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('N'))

    def test_cpx(self):
        c = self._cpu(romInit=[0x0f, 0x10, 0x11])

        c.r.x = 0x10
        c.ops[0xe0]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xe0]()
        self.assertTrue(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xe0]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertFalse(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('N'))

    def test_cpy(self):
        c = self._cpu(romInit=[0x0f, 0x10, 0x11])

        c.r.y = 0x10
        c.ops[0xc0]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xc0]()
        self.assertTrue(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('N'))
        c.ops[0xc0]()
        self.assertFalse(c.r.getFlag('Z'))
        self.assertFalse(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('N'))

    def test_dec(self):
        c = self._cpu(romInit=[0x00])
        c.ops[0xc6]()
        self.assertEqual(c.mmu.read(0x00), 0xff)

    def test_dex(self):
        c = self._cpu()
        c.ops[0xca]()
        self.assertEqual(c.r.x, 0xff)

    def test_dey(self):
        c = self._cpu()
        c.ops[0x88]()
        self.assertEqual(c.r.y, 0xff)

    def test_eor(self):
        c = self._cpu(romInit=[0x0f, 0xf0, 0xff])

        c.ops[0x49]()
        self.assertEqual(c.r.a, 0x0f)
        c.ops[0x49]()
        self.assertEqual(c.r.a, 0xff)
        c.ops[0x49]()
        self.assertEqual(c.r.a, 0x00)

    def test_flag_ops(self):
        c = self._cpu()

        c.ops[0x38]()
        self.assertTrue(c.r.getFlag('C'))
        c.ops[0x78]()
        self.assertTrue(c.r.getFlag('I'))
        c.ops[0xf8]()
        self.assertTrue(c.r.getFlag('D'))

        c.r.setFlag('V')

        c.ops[0x18]()
        self.assertFalse(c.r.getFlag('C'))
        c.ops[0x58]()
        self.assertFalse(c.r.getFlag('I'))
        c.ops[0xb8]()
        self.assertFalse(c.r.getFlag('V'))
        c.ops[0xd8]()
        self.assertFalse(c.r.getFlag('D'))

    def test_inc(self):
        c = self._cpu(romInit=[0x00])
        c.ops[0xe6]()
        self.assertEqual(c.mmu.read(0x00), 0x01)

    def test_inx(self):
        c = self._cpu()
        c.ops[0xe8]()
        self.assertEqual(c.r.x, 0x01)

    def test_iny(self):
        c = self._cpu()
        c.ops[0xc8]()
        self.assertEqual(c.r.y, 0x01)

    def test_jmp(self):
        c = self._cpu(romInit=[0x00, 0x10])

        c.ops[0x4c]()
        self.assertEqual(c.r.pc, 0x1000)

        c.ops[0x6c]()
        self.assertEqual(c.r.pc, 0x1000)

    def test_jsr(self):
        c = self._cpu(romInit=[0x00, 0x10])

        c.ops[0x20]()
        self.assertEqual(c.r.pc, 0x1000)
        self.assertEqual(c.stackPopWord(), 0x1001)

    def test_lda(self):
        c = self._cpu(romInit=[0x01])
        c.ops[0xa9]()
        self.assertEqual(c.r.a, 0x01)

    def test_ldx(self):
        c = self._cpu(romInit=[0x01])
        c.ops[0xa2]()
        self.assertEqual(c.r.x, 0x01)

    def test_ldy(self):
        c = self._cpu(romInit=[0x01])
        c.ops[0xa0]()
        self.assertEqual(c.r.y, 0x01)

    def test_lsr(self):
        c = self._cpu(romInit=[0x00])

        c.r.a = 0x02

        c.ops[0x4a]()
        self.assertEqual(c.r.a, 0x01)
        self.assertFalse(c.r.getFlag('C'))

        c.ops[0x4a]()
        self.assertEqual(c.r.a, 0x00)
        self.assertTrue(c.r.getFlag('C'))

        c.mmu.write(0x00, 0x02)
        c.ops[0x46]()
        self.assertEqual(c.mmu.read(0x00), 0x01)

    def test_ora(self):
        c = self._cpu(romInit=[0x0f, 0xf0, 0xff])
        c.ops[0x09]()
        self.assertEqual(c.r.a, 0x0f)
        c.ops[0x09]()
        self.assertEqual(c.r.a, 0xff)
        c.ops[0x09]()
        self.assertEqual(c.r.a, 0xff)

    def test_p(self):
        c = self._cpu()

        c.r.a = 0xcc
        c.ops[0x48]()
        self.assertEqual(c.stackPop(), 0xcc)

        c.r.p = 0xff
        c.ops[0x08]()
        self.assertEqual(c.stackPop(), 0xff)

        c.r.a = 0x00
        c.stackPush(0xdd)
        c.ops[0x68]()
        self.assertEqual(c.r.a, 0xdd)

        c.r.p = 0x20
        c.stackPush(0xfd)
        c.ops[0x28]()
        self.assertEqual(c.r.p, 0xfd)

    def test_rol(self):
        c = self._cpu(romInit=[0x00])

        c.r.a = 0xff
        c.ops[0x2a]()
        self.assertEqual(c.r.a, 0xfe)
        self.assertTrue(c.r.getFlag('C'))
        c.ops[0x2a]()
        self.assertEqual(c.r.a, 0xfd)
        self.assertTrue(c.r.getFlag('C'))

        c.ops[0x26]()
        self.assertEqual(c.mmu.read(0x00), 0x01)
        self.assertFalse(c.r.getFlag('C'))

    def test_ror(self):
        c = self._cpu(romInit=[0x00])

        c.r.a = 0xff
        c.ops[0x6a]()
        self.assertEqual(c.r.a, 0x7f)
        self.assertTrue(c.r.getFlag('C'))
        c.ops[0x6a]()
        self.assertEqual(c.r.a, 0xbf)
        self.assertTrue(c.r.getFlag('C'))

        c.ops[0x66]()
        self.assertEqual(c.mmu.read(0x00), 0x80)
        self.assertFalse(c.r.getFlag('C'))

    def test_rti(self):
        c = self._cpu()

        c.stackPushWord(0x1234)
        c.stackPush(0xfd)

        c.ops[0x40]()
        self.assertEqual(c.r.pc, 0x1234)
        self.assertTrue(c.r.getFlag('N'))
        self.assertTrue(c.r.getFlag('V'))
        self.assertTrue(c.r.getFlag('B'))
        self.assertTrue(c.r.getFlag('D'))
        self.assertTrue(c.r.getFlag('I'))
        self.assertFalse(c.r.getFlag('Z'))
        self.assertTrue(c.r.getFlag('C'))

    def test_rts(self):
        c = self._cpu()
        c.stackPushWord(0x1234)
        c.ops[0x60]()
        self.assertEqual(c.r.pc, 0x1235)

    def test_sbc(self):
        c = self._cpu(romInit=[
            0x10, 0x01, 0x51, 0x80,
            0x12, 0x13, 0x02, 0x21
        ])

        c.r.a = 0x15
        c.r.setFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0x05)
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('V'))
        self.assertFalse(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

        c.r.a = 0xff
        c.r.setFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0xfe)
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('V'))
        self.assertTrue(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

        c.r.a = 0x50
        c.r.setFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0xff)
        self.assertFalse(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('V'))
        self.assertTrue(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

        c.r.a = 0x01
        c.r.setFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0x81)
        self.assertFalse(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('V'))
        self.assertTrue(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

        # decimal mode test
        c.r.setFlag('D')

        c.r.a = 0x46
        c.r.setFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0x34)
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('V'))
        self.assertFalse(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

        c.r.a = 0x40
        c.r.setFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0x27)
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('V'))
        self.assertFalse(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

        c.r.a = 0x32
        c.r.clearFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0x29)
        self.assertTrue(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('V'))
        self.assertFalse(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

        c.r.a = 0x12
        c.r.setFlag('C')
        c.ops[0xe9]()
        self.assertEqual(c.r.a, 0x91)
        self.assertFalse(c.r.getFlag('C'))
        self.assertFalse(c.r.getFlag('V'))
        self.assertTrue(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('Z'))

    def test_sta(self):
        c = self._cpu(romInit=[0x00])
        c.r.a = 0xf0
        c.ops[0x85]()
        self.assertEqual(c.mmu.read(0x00), 0xf0)

    def test_stx(self):
        c = self._cpu(romInit=[0x00])
        c.r.x = 0xf0
        c.ops[0x86]()
        self.assertEqual(c.mmu.read(0x00), 0xf0)

    def test_sty(self):
        c = self._cpu(romInit=[0x00])
        c.r.y = 0xf0
        c.ops[0x84]()
        self.assertEqual(c.mmu.read(0x00), 0xf0)

    def test_t(self):
        c = self._cpu()

        c.r.a = 0xf0
        c.ops[0xaa]()
        self.assertEqual(c.r.x, 0xf0)

        c.r.x = 0x0f
        c.ops[0x8a]()
        self.assertEqual(c.r.a, 0x0f)

        c.r.a = 0xff
        c.ops[0xa8]()
        self.assertEqual(c.r.y, 0xff)

        c.r.y = 0x00
        c.ops[0x98]()
        self.assertEqual(c.r.a, 0x00)

        c.r.x = 0xff
        c.ops[0x9a]()
        self.assertEqual(c.r.s, 0xff)

        c.r.s = 0xf0
        c.ops[0xba]()
        self.assertEqual(c.r.x, 0xf0)

    def test_aac(self):
        c = self._cpu(romInit=[0xff, 0xff, 0x01, 0x2])

        c.r.a = 0x00
        c.ops[0x0b]()
        self.assertEqual(c.r.a, 0)
        self.assertFalse(c.r.getFlag('N'))
        self.assertFalse(c.r.getFlag('C'))

        c.r.a = 0xff
        c.ops[0x2b]()
        self.assertEqual(c.r.a, 0xff)
        self.assertTrue(c.r.getFlag('N'))
        self.assertTrue(c.r.getFlag('C'))

    def test_aax(self):
        c = self._cpu(romInit=[0x00, 0x00])

        c.r.a = 0xf0
        c.r.x = 0xf0
        c.ops[0x87]()
        self.assertEqual(c.mmu.read(0x00), 0xf0)

    def test_arr(self):
        c = self._cpu(romInit=[0x80])

        c.r.a = 0xff
        c.r.setFlag('C')
        c.ops[0x6b]()
        self.assertEqual(c.r.a, 0xc0)
        self.assertTrue(c.r.getFlag('C'))
        self.assertTrue(c.r.getFlag('V'))

    def test_asr(self):
        c = self._cpu(romInit=[0x80])

        c.r.a = 0xff
        c.r.setFlag('C')
        c.ops[0x4b]()
        self.assertEqual(c.r.a, 0x40)

    def test_atx(self):
        c = self._cpu(romInit=[0xf8])

        c.r.a = 0x1f
        c.ops[0xab]()
        self.assertEqual(c.r.x, 0x18)

    def test_axa(self):
        c = self._cpu(ram=(0, 0x400, False), romInit=[0xff, 0x01])

        c.r.a = c.r.x = 0xff
        c.r.y = 0x01
        c.ops[0x9f]()

        self.assertEqual(c.mmu.read(0x200), 0x02)

    def test_axs(self):
        c = self._cpu(romInit=[0x02])

        c.r.a = 0xf0
        c.r.x = 0x0f
        c.ops[0xcb]()
        self.assertEqual(c.r.x, 0xfe)

    def test_dcp(self):
        c = self._cpu(romInit=[0x01])
        c.r.a = 0xff
        c.ops[0xc7]()
        self.assertEqual(c.mmu.read(0x01), 0xff)
        self.assertTrue(c.r.getFlag('Z'))

    def test_isc(self):
        c = self._cpu(romInit=[0x01])
        c.r.a = 0xff
        c.r.setFlag('C')
        c.ops[0xe7]()
        self.assertEqual(c.mmu.read(0x01), 0x01)
        self.assertEqual(c.r.a, 0xfe)

    def test_kil(self):
        c = self._cpu()
        c.ops[0x02]()
        self.assertFalse(c.running)

    def test_lar(self):
        c = self._cpu(romInit=[0x01, 0x00])
        c.r.y = 0x01
        c.mmu.write(0x02, 0xf0)

        c.ops[0xbb]()
        self.assertEqual(c.r.a, 0xf0)
        self.assertEqual(c.r.x, 0xf0)
        self.assertEqual(c.r.s, 0xf0)

    def test_lax(self):
        c = self._cpu(romInit=[0x01])
        c.mmu.write(0x01, 0xf0)
        c.ops[0xa7]()
        self.assertEqual(c.r.a, 0xf0)
        self.assertEqual(c.r.x, 0xf0)

    def test_rla(self):
        c = self._cpu(romInit=[0x01])
        c.mmu.write(0x01, 0x01)
        c.r.a = 0x06
        c.r.setFlag('C')
        c.ops[0x27]()
        self.assertEqual(c.mmu.read(0x01), 0x03)
        self.assertEqual(c.r.a, 0x02)

    def test_rra(self):
        c = self._cpu(romInit=[0x01])
        c.mmu.write(0x01, 0x01)
        c.r.a = 0x06
        c.r.setFlag('C')
        c.ops[0x67]()
        self.assertEqual(c.mmu.read(0x01), 0x80)
        self.assertEqual(c.r.a, 0x87)

    def test_rra2(self):
        c = self._cpu(romInit=[0x01])
        c.mmu.write(0x01, 0x02)
        c.r.a = 0x06
        c.r.setFlag('C')
        c.ops[0x47]()
        self.assertEqual(c.mmu.read(0x01), 0x01)
        self.assertEqual(c.r.a, 0x07)

    def test_slo(self):
        c = self._cpu(romInit=[0x01])
        c.mmu.write(0x01, 0x01)
        c.r.a = 0x06
        c.r.setFlag('C')
        c.ops[0x07]()
        self.assertEqual(c.mmu.read(0x01), 0x02)
        self.assertEqual(c.r.a, 0x06)

    def test_sxa(self):
        c = self._cpu(ram=(0, 0x400, False), romInit=[0xff, 0x01])
        c.r.x = 0xff
        c.r.y = 0x01
        c.ops[0x9e]()

        self.assertEqual(c.mmu.read(0x200), 0x02)

    def test_sya(self):
        c = self._cpu(ram=(0, 0x400, False), romInit=[0xff, 0x01])

        c.r.y = 0xff
        c.r.x = 0x01
        c.ops[0x9c]()

        self.assertEqual(c.mmu.read(0x200), 0x02)

    def test_xaa(self):
        c = self._cpu(romInit=[0xff])

        c.r.a = 0b11111110
        c.r.x = 0b11101111

        c.ops[0x8b]()

        self.assertEqual(c.r.a, 0b11101110)

    def test_xas(self):
        c = self._cpu(ram=(0, 0x400, False), romInit=[0xff, 0x01])

        c.r.x = 0xfe
        c.r.a = 0x7f

        c.r.y = 0x01
        c.ops[0x9b]()

        self.assertEqual(c.r.s, 0x7e)
        self.assertEqual(c.mmu.read(0x100), 0x02)

    def test_step(self):
        c = self._cpu(romInit=[0xa9, 0x55, 0x69, 0x22])
        c.step()
        self.assertEqual(c.r.a, 0x55)
        c.step()
        self.assertEqual(c.r.a, 0x77)

    def test_run_rom(self):
        path = os.path.join(
            os.path.dirname(os.path.realpath(__file__)),
            "files", "test_load_file.bin"
        )

        with open(path, "rb") as f:
            c = self._cpu(romInit=f)

        c.step()
        self.assertEqual(c.r.a, 0x55)

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()
