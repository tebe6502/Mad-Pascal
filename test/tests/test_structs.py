from testutils import testUtils
test = testUtils()

import pytest

class Test_Structs:
        
    def test_struct1(self):
        
        test.runCode("""

        type
            monsters = packed record
                x: byte ;
                a: cardinal;
                y: byte;
            end;

        var
            monster: array [0..3] of ^monsters;
            i: byte;

        begin

            for i:=0 to High(monster) do begin

                GetMem(monster[i], sizeof(monsters));

                monster[i].x := i;
                monster[i].a := $ffffffff;
                monster[i].y := i * 2;

            end;
        end.

        """)

        monsterArrayAddress = test.varWord('monster')
        monstersArray = test.getArray(monsterArrayAddress, 4, element_size = 2)
        for i in range(0,3):
            assert test.getByte(monstersArray[i]) == i
            assert test.getByte(monstersArray[i] + 5) == i * 2


    def test_struct2(self):
        
        test.runCode("""
        type
            monsters = record x,y: byte end;
        var
            monster: array [0..3] of ^monsters;
            i: byte;
            a,b,c,d: monsters;
            tmp: ^monsters;
        begin

            monster[0]:=@a;
            monster[1]:=@b;
            monster[2]:=@c;
            monster[3]:=@d;

            for i:=0 to High(monster) do begin
                tmp:=monster[i];
                tmp.x := i;
                tmp.y := i * 2;
            end;

        end.
        """)

        monsterArrayAddress = test.varWord('monster')
        monstersArray = test.getArray(monsterArrayAddress, 4, element_size = 2)
        for i in range(0,3):
            assert test.getByte(monstersArray[i]) == i
            assert test.getByte(monstersArray[i] + 1) == i * 2


    def test_struct3(self):
        
        test.runCode("""
        var
		x,y: smallint;

		w: cardinal;

		s: string;

		temp : record a,b: ^word end;
        begin

	x:=100;
	y:=2000;

	temp.a:=@x;
	temp.b:=@y;

	w:=temp.b^;

        end.
        """)

        assert test.varWord('w') == 2000


