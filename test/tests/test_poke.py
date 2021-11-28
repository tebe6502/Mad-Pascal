from testutils import testUtils
test = testUtils()


class test_poke:

    def test_poke_opty(self):

        test.runCode("""
        var blob: byte;

        begin

	blob:=35; Poke($a000,(blob+128));  Poke($a001,(blob+128));  Poke($a002,blob);  Poke($a003,blob);  Poke($a004,blob);

        end.
        """)
        assert test.getByte(0xA000) == 163
        assert test.getByte(0xA001) == 163
        assert test.getByte(0xA002) == 35
        assert test.getByte(0xA003) == 35
        assert test.getByte(0xA004) == 35
