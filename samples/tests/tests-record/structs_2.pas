{ Test:

        Expected result:

	0,0
	1,2
	2,4
	3,6
}

uses crt;

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


for i:=0 to High(monster) do begin

 writeln(monster[i].x,',', monster[i].y);

end;



repeat until keypressed;

end.