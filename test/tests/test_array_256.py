from testutils import testUtils
test = testUtils()

import pytest

class Test_Structs:
        
    def test_struct1(self):
        
        test.runCode("""

        var
            tb: array [0..255] of byte;
            i: word;
            a: word;

        begin
            i:=78;

            tb[78]:=100;

            inc(tb[i], 37);

            tb[i]:=tb[78] + 3;

            dec(tb[i], 11);

            tb[i]:=tb[i]+75;

            a:=tb[i];

        end.

        """)
        
        assert test.varWord('a') == 204


    def test_struct2(self):
        
        test.runCode("""

        var
            tb: array [0..127] of word;
            i: word;
            a: word;

        begin
            i:=78;

            tb[78]:=100;

            inc(tb[i], 37);

            tb[i]:=tb[78] + 3;

            dec(tb[i], 11);

            tb[i]:=tb[i]+75;

            a:=tb[i];

        end.
        """)
        
        assert test.varWord('a') == 204


    def test_struct3(self):
        
        test.runCode("""

        var
            tb: array [0..63] of cardinal;
            i: word;
            a: word;

        begin
            i:=57; 

            tb[57]:=100;

            inc(tb[i], 37);

            tb[i]:=tb[57] + 3;

            dec(tb[i], 11);

            tb[i]:=tb[i]+75;

            a:=tb[i];

        end.
        """)
        
        assert test.varWord('a') == 204
