from testutils import testUtils
test = testUtils()

class Test_misc:

    def test_misc1(self):

        test.runCode("""
	var
	    s: string;
	    a: word;


	begin

	s:='fsdfksdlkflsdgfjsdlfgjdlfks';
	a:=$aa00 + 512 + 64 - byte(length(s) * 5);

	end.
	""")

        assert test.varWord('a') == 43961


    def test_misc2(self):

        test.runCode("""
	var
	    i,k: byte;

	begin
	
	k:=237;

	i := ((k shr 2) and %11110000) or 6;

	end.
	""")

        assert test.varByte('i') == 54


    def test_misc3(self):

        test.runCode("""
	var
	    i: word;
	    k: byte;
	    bf: array [0..31] of byte;

	begin
	
	bf[23] := 217;
	k:=23;

	i := $c048 + (3 * bf[k]);

	end.
	""")

        assert test.varWord('i') == 49875


    def test_misc4(self):

        test.runCode("""
	var
	    i,k: byte;

	begin
	
	k:=2;
	
	i := 3 shl (k * 3);

	end.
	""")

        assert test.varByte('i') == 192


    def test_misc5(self):

        test.runCode("""
	var
	  i,k:byte;
	  a:word;

	begin

	 a:=11;
	 i:=157;
	 k:=3;

	 a := a or (word(i) shl (8 - k));

	end.
	""")

        assert test.varWord('a') == 5035


    def test_misc6(self):

        test.runCode("""
	var
	  i:byte;
	  a:word;
	  bf:array [0..31] of byte;

	begin

	 bf[11]:=179;
	 i:=11;

	 a := word(bf[i]) shl 6;

	end.
	""")

        assert test.varWord('a') == 11456


    def test_misc7(self):

        test.runCode("""
	var
	  i: smallint;
	  a: word;

	begin

	 i:=-1;
	 a := ord(i < 0);

	end.
	""")

        assert test.varWord('a') == 1


    def test_misc8(self):

        test.runCode("""
	var
	  p: PByte;
	  ptr: pointer;
	  i: byte;
	  
	  tb, bf: array [0..31] of byte;
	  
	begin
	 ptr:=pointer($3043);
	 i:=3;
	 tb[3] := $a3;
	 bf[3] := $9a;

	 p:=pointer(ptr + tb[i] + bf[i] shl 8);

	end.
	""")

        assert test.varWord('p') == 51942

