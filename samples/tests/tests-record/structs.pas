program structs;

{ Test: The array MONSTER is filled with pointers to record.

        Expected result:

  0,0
  1,2
  2,4
  3,6

}

uses
  crt;

type
  monsters = packed record
    x: Byte;
    y: Byte;

  end;

var
  monster: array [0..3] of ^monsters;

  i: Byte;
  x: Word;

begin

  for i := 0 to High(monster) do
  begin

    monster[i] := GetMem(sizeof(monsters));

    monster[i].x := i;
    monster[i].y := i * 2;

  end;


  for i := 0 to High(monster) do
    WriteLn(monster[i].x, ',', monster[i].y);


  repeat
  until KeyPressed;

end.
