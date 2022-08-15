from testutils import testUtils
test = testUtils()

class Test_conditions:

    def test_if_complex_order1(self):

        test.runCode("""
        function gettru:boolean; begin result:=true; end;
        function getfalse:boolean; begin result:=false; end;
        var a:byte;
            c:char;
            r1,r2,r3:boolean;
        begin
            r1 := false;
            r2 := false;
            r3 := false;
            a := 75;
            c := 'B';
            if (a = 75) and (c = 'B') and gettru then r1 := true;
            if gettru and (a = 75) and (c = 'B') then r2 := true;
            if (c = 'B') and gettru and (a = 75) then r3 := true;
        end.
        """)
    
        assert test.isVarTrue('r1')
        assert test.isVarTrue('r2')
        assert test.isVarTrue('r3')


    def test_if_complex_order2(self):

        test.runCode("""
        function gettru:boolean; begin result:=true; end;
        function getfalse:boolean; begin result:=false; end;
        var a:byte;
            c:char;
            r1,r2,r3:boolean;
        begin
            r1 := true;
            r2 := true;
            r3 := true;
            a := 75;
            c := 'B';
            if (a = 12) or (c = 'A') or getfalse then r1 := false;
            if getfalse and (a = 12) and (c = 'A') then r2 := false;
            if (c = 'A') and getfalse and (a = 12) then r3 := false;
        end.
        """)
    
        assert test.isVarTrue('r1')
        assert test.isVarTrue('r2')
        assert test.isVarTrue('r3')


    def test_3(self):

        test.runCode("""
        var a, b: shortint;
	    r: Boolean;
        begin
	 a:=100;
	 b:=-120;       	 
	
	 if (a+b) < 0 then
	  r:=true
	 else
	  r:=false;
	 
        end.
        """)
    
        assert test.isVarTrue('r')
