from testutils import testUtils
test = testUtils()

class Test_DivideXY:

    def test_simple_div(self):

        test.runCode('''
        procedure breaktest; begin end;

        var a:byte;
            i,j:byte;

        begin
            i:=4;
            j:=197;
	    a:=64 div i + j div 3;
            breaktest;

	    a:=64 div i + j div 4;
            breaktest;

	    a:=64 div i + j div 5;
            breaktest;

	    a:=64 div i + j div 6;
            breaktest;

	    a:=64 div i + j div 7;
            breaktest;

	    a:=64 div i + j div 8;
	    breaktest;

	    a:=64 div i + j div 9;
	    breaktest;

	    a:=64 div i + j div 10;
	    breaktest;

	    a:=64 div i + j div 12;
	    breaktest;

	    a:=64 div i + j div 16;
	    breaktest;

	    a:=64 div i + j div 20;

        end.
        ''', ['breaktest'])

        assert test.varByte('a') == 197 // 3+16;

        test.resume()
        assert test.varByte('a') == 197 // 4+16

        test.resume()
        assert test.varByte('a') == 197 // 5+16

        test.resume()
        assert test.varByte('a') == 197 // 6+16

        test.resume()
        assert test.varByte('a') == 197 // 7+16

        test.resume()
        assert test.varByte('a') == 197 // 8+16

        test.resume()
        assert test.varByte('a') == 197 // 9+16

        test.resume()
        assert test.varByte('a') == 197 // 10+16

        test.resume()
        assert test.varByte('a') == 197 // 12+16

        test.resume()
        assert test.varByte('a') == 197 // 16+16

        test.resume()
        assert test.varByte('a') == 197 // 20+16