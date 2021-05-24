from testutils import testUtils
test = testUtils();

class Test_for_loops:

    def test_for_loops1(self):

        test.runCode("""
        var i:byte;
            a:array [0..0] of byte absolute $2000;
        begin
            for i:=0 to 255 do a[i]:=i;
        end.
        """);
    
        for i in range(256):
            assert test.getByte(0x2000 + i) == i;


    def test_for_loops2(self):

        test.runCode("""
        var i:word;
            a:array [0..0] of word absolute $2000;
        begin
            for i:=0 to 256 do a[i] := i;
        end.
        """);
    
        for i in range(257):
            assert test.getWord(0x2000 + i*2) == i;


    def test_for_loops3(self):

        test.runCode("""
        var i:word;
            a:array [0..0] of word absolute $2000;
        begin
            for i:=300 downto 0 do a[i] := i;
        end.
        """);
    
        for i in range(301):
            assert test.getWord(0x2000 + i*2) == i;

    def test_for_loops4(self):

        test.runCode("""
        var i:byte;
            a:array [0..0] of byte absolute $2000;
        begin
            for i:=255 downto 0 do a[i]:=i;
        end.
        """);
    
        for i in range(256):
            assert test.getByte(0x2000 + i) == i;


