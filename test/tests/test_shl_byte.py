from testutils import testUtils
test = testUtils()

class Test_byte_shl:

    def test_shl(self):

        test.runCode('''
        procedure breaktest; begin end;

        var b: byte;
	    a: cardinal;

        begin
            b:=1;
            a:=b shl 0;
            breaktest;

            b:=1;
            a:=b shl 1;
            breaktest;

            b:=1;
            a:=b shl 2;
            breaktest;

            b:=1;
            a:=b shl 3;
            breaktest;

            b:=1;
            a:=b shl 4;
            breaktest;

            b:=1;
            a:=b shl 5;
            breaktest;

            b:=1;
            a:=b shl 6;
            breaktest;

            b:=1;
            a:=b shl 7;
            breaktest;

            b:=1;
            a:=b shl 8;
            breaktest;

            b:=1;
            a:=b shl 9;
            breaktest;

            b:=1;
            a:=b shl 10;
            breaktest;

            b:=1;
            a:=b shl 11;
            breaktest;

            b:=1;
            a:=b shl 12;
            breaktest;

            b:=1;
            a:=b shl 13;
            breaktest;

            b:=1;
            a:=b shl 14;
            breaktest;

            b:=1;
            a:=b shl 15;
            breaktest;

            b:=1;
            a:=b shl 16;
            breaktest;

            b:=1;
            a:=b shl 17;
            breaktest;

            b:=1;
            a:=b shl 18;
            breaktest;

            b:=1;
            a:=b shl 19;
            breaktest;

            b:=1;
            a:=b shl 20;
            breaktest;

            b:=1;
            a:=b shl 21;
            breaktest;

            b:=1;
            a:=b shl 22;
            breaktest;

            b:=1;
            a:=b shl 23;
            breaktest;

            b:=1;
            a:=b shl 24;
            breaktest;

            b:=1;
            a:=b shl 25;
            breaktest;

            b:=1;
            a:=b shl 26;
            breaktest;

            b:=1;
            a:=b shl 27;
            breaktest;

            b:=1;
            a:=b shl 28;
            breaktest;

            b:=1;
            a:=b shl 29;
            breaktest;

            b:=1;
            a:=b shl 30;
            breaktest;

            b:=1;
            a:=b shl 31;

        end.
        ''', ['breaktest'])

        assert test.varCardinal('a') == 1

        test.resume()
        assert test.varCardinal('a') == 2

        test.resume()
        assert test.varCardinal('a') == 4

        test.resume()
        assert test.varCardinal('a') == 8

        test.resume()
        assert test.varCardinal('a') == 16

        test.resume()
        assert test.varCardinal('a') == 32

        test.resume()
        assert test.varCardinal('a') == 64

        test.resume()
        assert test.varCardinal('a') == 128

        test.resume()
        assert test.varCardinal('a') == 256

        test.resume()
        assert test.varCardinal('a') == 512

        test.resume()
        assert test.varCardinal('a') == 1024

        test.resume()
        assert test.varCardinal('a') == 2048

        test.resume()
        assert test.varCardinal('a') == 4096

        test.resume()
        assert test.varCardinal('a') == 8192

        test.resume()
        assert test.varCardinal('a') == 16384

        test.resume()
        assert test.varCardinal('a') == 32768

        test.resume()
        assert test.varCardinal('a') == 0x10000
	
        test.resume()
        assert test.varCardinal('a') == 0x20000
	
        test.resume()
        assert test.varCardinal('a') == 0x40000

        test.resume()
        assert test.varCardinal('a') == 0x80000

        test.resume()
        assert test.varCardinal('a') == 0x100000

        test.resume()
        assert test.varCardinal('a') == 0x200000

        test.resume()
        assert test.varCardinal('a') == 0x400000

        test.resume()
        assert test.varCardinal('a') == 0x800000

        test.resume()
        assert test.varCardinal('a') == 0x1000000

        test.resume()
        assert test.varCardinal('a') == 0x2000000

        test.resume()
        assert test.varCardinal('a') == 0x4000000

        test.resume()
        assert test.varCardinal('a') == 0x8000000

        test.resume()
        assert test.varCardinal('a') == 0x10000000

        test.resume()
        assert test.varCardinal('a') == 0x20000000

        test.resume()
        assert test.varCardinal('a') == 0x40000000

        test.resume()
        assert test.varCardinal('a') == 0x80000000
