uses crt;

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


for i:=0 to High(monster) do 
 writeln(monster[i].x,',', monster[i].y);


repeat until keypressed;

end.