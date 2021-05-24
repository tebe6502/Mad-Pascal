#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
test_suites
----------------------------------

Tests for `py65emu` module.
"""


import os
import unittest
import traceback

from py65emu.cpu import CPU
from py65emu.mmu import MMU


class TestPy65emu(unittest.TestCase):

    def setUp(self):
        pass

    def test_nestest(self):
        path = os.path.join(
            os.path.dirname(os.path.realpath(__file__)),
            "files", "nestest_mod.nes"
        )

        with open(path, "rb") as f:
            mmu = MMU([
                (0x0000, 0x800),  # RAM
                (0x2000, 0x8),  # PPU
                (0x4000, 0x18),
                (0x8000, 0xc000, True, f, 0x3ff0)  # ROM
            ])

        c = CPU(mmu, 0xc000)
        c.r.s = 0xfd  # Not sure why the stack starts here.

        while c.r.pc != 0xc66e:
            try:
                c.step()
            except Exception as e:
                print(c.r)
                print(traceback.format_exc())
                raise e

            self.assertEqual(c.mmu.read(0x2), 0x00, hex(c.mmu.read(0x2)))
            self.assertEqual(c.mmu.read(0x3), 0x00, hex(c.mmu.read(0x3)))

    def tearDown(self):
        pass


if __name__ == '__main__':
    unittest.main()
