from testutils import testUtils
test = testUtils()

class Test_Cardinal_shr:

    def test_shr(self):

        test.runCode('''
        procedure breaktest; begin end;

        var a, b: cardinal;

        begin
            b:=$e7813Fa5;

            a:=b shr 1;
            breaktest;

            a:=b shr 2;
            breaktest;

            a:=b shr 3;
            breaktest;

            a:=b shr 4;
            breaktest;

            a:=b shr 5;
	    breaktest;

            a:=b shr 6;
	    breaktest;

            a:=b shr 7;
	    breaktest;

            a:=b shr 8;
            breaktest;

            a:=b shr 9;
            breaktest;

            a:=b shr 10;
            breaktest;

            a:=b shr 11;
            breaktest;

            a:=b shr 12;
	    breaktest;

            a:=b shr 13;
	    breaktest;

            a:=b shr 14;
	    breaktest;

            a:=b shr 15;
	    breaktest;

            a:=b shr 16;
        end.
        ''', ['breaktest'])

        assert test.varCardinal('a') == 0x73C09FD2

        test.resume()
        assert test.varCardinal('a') == 0x39E04FE9

        test.resume()
        assert test.varCardinal('a') == 0x1CF027F4

        test.resume()
        assert test.varCardinal('a') == 0x0E7813FA

        test.resume()
        assert test.varCardinal('a') == 0x073C09FD

        test.resume()
        assert test.varCardinal('a') == 0x039E04FE

        test.resume()
        assert test.varCardinal('a') == 0x01CF027F

        test.resume()
        assert test.varCardinal('a') == 0x00E7813F

        test.resume()
        assert test.varCardinal('a') == 0x0073C09F

        test.resume()
        assert test.varCardinal('a') == 0x0039E04F

        test.resume()
        assert test.varCardinal('a') == 0x001CF027

        test.resume()
        assert test.varCardinal('a') == 0x000E7813

        test.resume()
        assert test.varCardinal('a') == 0x00073C09

        test.resume()
        assert test.varCardinal('a') == 0x00039E04

        test.resume()
        assert test.varCardinal('a') == 0x0001CF02

        test.resume()
        assert test.varCardinal('a') == 0x0000E781
