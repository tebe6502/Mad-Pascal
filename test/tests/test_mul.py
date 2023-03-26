from testutils import testUtils
test = testUtils()

class Test_Multiplications:

    def test_simple_multiplication(self):

        test.runCode('''
        procedure breaktest; begin end;

        var a:word;
            b:byte;

        begin
            b:=27;
	    
            a:=b*1;
            breaktest;
	    
            a:=b*3;
            breaktest;

            a:=b*5;
            breaktest;

            a:=b*6;
            breaktest;

            a:=b*7;
            breaktest;

            a:=b*9;
	    breaktest;

            a:=b*10;
	    breaktest;

	    a:=b*128;
	    breaktest;

	    a:=b*256;
	    breaktest;

	    a:=$78 + b*2;

        end.
        ''', ['breaktest'])

        assert test.varByte('b') == 27;
        assert test.varWord('a') == 27 * 1

        test.resume()
        assert test.varWord('a') == 27 * 3

        test.resume()
        assert test.varWord('a') == 27 * 5

        test.resume()
        assert test.varWord('a') == 27 * 6

        test.resume()
        assert test.varWord('a') == 27 * 7

        test.resume()
        assert test.varWord('a') == 27 * 9

        test.resume()
        assert test.varWord('a') == 27 * 10

        test.resume()
        assert test.varWord('a') == 27 * 128

        test.resume()
        assert test.varWord('a') == 27 * 256

        test.resume()
        assert test.varWord('a') == 0x78 + 27 * 2

    def test_another_multiplication_inline(self):

        test.runCode("""
        var a:word;
            b:byte;
            w:word;
        begin
            b := 23;
            a := 45 * b;
            w := a * 10;
        end.
        """)

        assert test.varWord('w') == 23 * 45 * 10


    def test_mul256(self):

        test.runCode("""
        var b:byte;
            w, a:word;
        begin
            b := 184;
            w := b * 256;

	    a := 184;
	    a := a * 256;
        end.
        """)

        assert test.varWord('w') == 47104
        assert test.varWord('a') == 47104
