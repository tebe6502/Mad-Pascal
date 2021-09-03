from testutils import testUtils
test = testUtils()

class Test_Var:

    def test_var1(self):

        test.runCode("""
	var
	    tab:array [0..3] of byte = (3,5,7,9);
	    p: word;

	procedure test(var buffer);
	var tmp: word absolute buffer;
	begin

         p:=tmp;

	end;

	begin

            test(tab);

	end.
	""")

        assert test.varWord('p') == 1283


    def test_var2(self):

        test.runCode("""
	var
	    tab:array [0..7] of byte;
	    a,b: byte;

	procedure test(var buffer);
	var src: PByte;
	begin

	 src:=@buffer;

	 src^:=11;

	 inc(src,7);

	 src^:=78;

	end;

	begin

            test(tab);

	    a:=tab[0];
	    b:=tab[7];

	end.
	""")

        assert test.varByte('a') == 11
        assert test.varByte('b') == 78


    def test_var3(self):

        test.runCode("""
	type

	rc = packed record

        a: cardinal;
	b: word;
	c: byte;

        end;

	var
	p: ^rc;

	v: rc;

	procedure test(var f: word);
	begin
	  inc(f);
	end;

	begin

	 v.b:=111;

	 p:=@v;

	 test(p^.b);

	end.
	""")

        assert test.varWord('v.b') == 112
