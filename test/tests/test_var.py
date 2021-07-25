from testutils import testUtils
test = testUtils()

class Test_Var:

    def test_var1(self):

        test.runCode("""
	var
	    tab:array [0..3] of byte = (3,5,7,9);
	    p: word;

	procedure tst(var buffer);
	var tmp: word absolute buffer;
	begin

         p:=tmp;

	end;

	begin

            tst(tab);

	end.
	""")

        assert test.varWord('p') == 1283
