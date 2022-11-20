from testutils import testUtils
test = testUtils()

import pytest

class Test_Structs:
        
    def test_struct1(self):
        
        test.runCode("""

        var
            tb: array [0..3000] of byte;
            i,j: word;
            a: word;

        begin
            i:=578;
            j:=570;

            tb[578]:=100;

            inc(tb[i], 30);

            inc(tb[j+8], 7);

            tb[i]:=tb[578] + 3;

            dec(tb[i], 11);

            tb[i]:=tb[i]+75;

            a:=tb[i];

        end.

        """)
        
        assert test.varWord('a') == 204


    def test_struct2(self):
        
        test.runCode("""

        var
            tb: array [0..3000] of word;
            i,j: word;
            a: word;

        begin
            i:=578; 
            j:=570;

            tb[578]:=100;

            inc(tb[i], 30);

            inc(tb[j+8], 7);

            tb[i]:=tb[578] + 3;

            dec(tb[i], 11);

            tb[i]:=tb[i]+75;

            a:=tb[i];

        end.
        """)
        
        assert test.varWord('a') == 204


    def test_struct3(self):
        
        test.runCode("""

        var
            tb: array [0..3000] of cardinal;
            i,j: word;
            a: word;

        begin
            i:=578; 
            j:=570;

            tb[578]:=100;

            inc(tb[i], 30);

            inc(tb[j+8], 7);

            tb[i]:=tb[578] + 3;

            dec(tb[i], 11);

            tb[i]:=tb[i]+75;

            a:=tb[i];

        end.
        """)
        
        assert test.varWord('a') == 204
