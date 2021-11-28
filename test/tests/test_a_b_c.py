

from testutils import testUtils
test = testUtils()

class Test_a_b_c:

    def test_opty_add(self):

        test.runCode("""
var
	i: word;
	a,b,c:byte;

begin

a:=100;

b:=200;

i:=$a0a0;

c:=40;

i := a + b + c;
end.
        """)
        assert test.varWord('i') == 340;
