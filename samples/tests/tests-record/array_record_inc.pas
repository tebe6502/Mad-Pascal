{

0,0
1,2
2,4
3,6

Let's move first monster
2,0
4,0

}


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

procedure MoveMonster(p : byte);
begin
  monster[p].x := monster[p].x + 2;
end;

begin
  for i:=0 to High(monster) do begin
    GetMem(monster[i], sizeof(monsters));

    monster[i].x := i;
    monster[i].a := $ffffffff;
    monster[i].y := i * 2;
  end;

  for i:=0 to High(monster) do
    writeln(monster[i].x,',', monster[i].y);

  // Let's move first monster
  writeln('');
  writeln('Let''s move first monster');
//  monster[0].x := 2;
  monster[0].x := monster[0].x + 2;
  writeln(monster[0].x,',', monster[0].y);

  MoveMonster(0);
  writeln(monster[0].x,',', monster[0].y);

  repeat until keypressed;
end.
