from testutils import testUtils
test = testUtils();

import pytest

class Test_Structs:
        
    @pytest.mark.skip(reason="don't know how packed record works, so unable to assert properly (bocianu)")        
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

        """);
        
        monsteradr = mem.readWord(labels['MAIN.MONSTER'])
        for i in range(0,4):
            monster = mem.readWord(monsteradr) + i * 2
            assert mem.read(monster) == i;
            #assert mem.read(monster+6) == i * 2;


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
        """);
        
        monsterArrayAddress = test.varWord('monster')
        monstersArray = test.getArray(monsterArrayAddress, 4, element_size = 2);
        for i in range(0,4):
            assert test.getByte(monstersArray[i]) == i;
            assert test.getByte(monstersArray[i] + 1) == i * 2;


