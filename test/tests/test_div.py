from testutils import testUtils
test = testUtils()

class Test_Divide:

    def test_simple_div(self):

        test.runCode('''
        procedure breaktest; begin end;

        var a:byte;
            b:byte;

        begin
            b:=197;
            a:=b div 3;
            breaktest;

            a:=b div 4;
            breaktest;

            a:=b div 5;
            breaktest;

            a:=b div 6;
            breaktest;

            a:=b div 7;
	    breaktest;

	    a:=b div 8;
	    breaktest;

	    a:=b div 9;
	    breaktest;

	    a:=b div 10;
	    breaktest;

	    a:=b div 12;
	    breaktest;

	    a:=b div 16;
	    breaktest;

	    a:=b div 20;

        end.
        ''', ['breaktest'])

        assert test.varByte('b') == 197;
        assert test.varByte('a') == 197 // 3

        test.resume()
        assert test.varByte('a') == 197 // 4

        test.resume()
        assert test.varByte('a') == 197 // 5

        test.resume()
        assert test.varByte('a') == 197 // 6

        test.resume()
        assert test.varByte('a') == 197 // 7

        test.resume()
        assert test.varByte('a') == 197 // 8

        test.resume()
        assert test.varByte('a') == 197 // 9

        test.resume()
        assert test.varByte('a') == 197 // 10

        test.resume()
        assert test.varByte('a') == 197 // 12

        test.resume()
        assert test.varByte('a') == 197 // 16

        test.resume()
        assert test.varByte('a') == 197 // 20
