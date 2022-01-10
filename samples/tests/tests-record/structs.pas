{ Test: The array MONSTER is filled with pointers to record.

        Expected result:

	0,0
	1,2
	2,4
	3,6

}

uses crt;

type
	monsters = packed record
   	x: byte ;
	y: byte;

	end;

var
	monster: array [0..3] of ^monsters;

	i: byte;
	x: word;

begin

for i:=0 to High(monster) do begin

 GetMem(monster[i], sizeof(monsters));

 monster[i].x := i;
 monster[i].y := i * 2;

end;


for i:=0 to High(monster) do
 writeln(monster[i].x,',', monster[i].y);


repeat until keypressed;

end.