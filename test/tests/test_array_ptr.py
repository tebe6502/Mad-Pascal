from testutils import testUtils
test = testUtils()

import pytest

class Test_Structs:
        
    def test_struct1(self):
        
        test.runCode("""

	type

		tboard = array [0..1,0..3] of byte;
 
        var
		x1, x2: byte;
		a: word;
		board: tboard;

		br: ^tboard;
	
        begin
	
	board[0,0]:=3;
	board[0,1]:=17;
	board[0,2]:=25;
	board[0,3]:=39;

	board[1,0]:=7;
	board[1,1]:=19;
	board[1,2]:=2;
	board[1,3]:=16;

	a:=1;

	br:=@board;

	for x1:=0 to 1 do
	 for x2:=0 to 3 do
 	  a := a + br[x1, x2];

        end.

        """)
        
        assert test.varWord('a') == 129


    def test_struct2(self):
        
        test.runCode("""

	type

		tboard = array [0..1,0..3] of byte;
 
        var
		x1, x2: byte;
		a: word;
		board: tboard;

        begin
	
	board[0,0]:=3;
	board[0,1]:=17;
	board[0,2]:=25;
	board[0,3]:=39;

	board[1,0]:=7;
	board[1,1]:=19;
	board[1,2]:=2;
	board[1,3]:=16;

	a:=1;

	for x1:=0 to 1 do
	 for x2:=0 to 3 do
 	  a := a + board[x1, x2];

        end.
        """)
        
        assert test.varWord('a') == 129

