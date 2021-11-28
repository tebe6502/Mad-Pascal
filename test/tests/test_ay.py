

from testutils import testUtils
test = testUtils()

class Test_opty:

    def test_opty_ay(self):

        test.runCode("""
var
	l,c,d:byte;

begin
	l := 11;
	c:=1;
	d:=1;
	repeat
		Inc(d,4);
		Inc(c,3);
	until c > l;

	l := d - 1;
end.
        """)
        assert test.varByte('l') == 16;
