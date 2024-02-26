{The Game of Life written in Sub-Pascal language }

uses crt;

const
  FIELDSIZE = 16;

type
  TField = array [0..FIELDSIZE * FIELDSIZE - 1] of Boolean;

var
  Field: TField;

  scr: array [0..23, 0..39] of char;

procedure Redraw(var Fld: TField);
const
  ORIGINX = 20 - FIELDSIZE shr 1;
  ORIGINY = 12 - FIELDSIZE shr 1;

var
  i, x,y: byte;
  clr: char;

begin

  for i := 0 to FIELDSIZE * FIELDSIZE - 1 do
    begin
      if Fld[i] then clr := 'x' else clr := #0;

      x:=ORIGINX + i shr 4;
      y:=ORIGINY + i and $0f;

      scr[y,x] := clr;

      GotoXY(x,y);
      write(scr[y,x]);
    end;

end;  {Redraw}


procedure Init(var Fld: TField);
var i: byte;
    scr: word;
begin
 Randomize;

 for i := 0 to FIELDSIZE * FIELDSIZE - 1 do
    Fld[i] := (Random(0) > 192);

end;  {Init}


procedure Regenerate(var Fld: TField);
var
  NextFld: TField;
  i, j, ni, nj, n: byte;
  x: byte;
  p: Boolean;
begin

for i := 0 to FIELDSIZE - 1 do
  for j := 0 to FIELDSIZE - 1 do
    begin
    {Count cell neighbors}
    n := 0;
    for ni := i - 1 to i + 1 do
      for nj := j - 1 to j + 1 do begin
        x:=byte(ni shl 4) + nj;

	p:=((ni = i) and (nj = j));

        if Fld[x] and not p then inc(n);
      end;

    {Bear or kill the current cell in the next generation}
    x:=byte(i shl 4) + j;

    if Fld[x] then
     NextFld[x] := ((n > 1) and (n < 4))  {Kill the cell or keep it alive}
    else
     NextFld[x] := (n = 3);               {Bear the cell or keep it dead}

    end;  {for j...}

{Make new generation}

 move(NextFld, Fld, sizeof(Fld));

end;  {Regenerate}


begin

clrscr;
CursorOff;
TextMode(X16_MODE_40x30);

{Create initial population}
Init(Field);

{Run simulation}
repeat

  Redraw(Field);
  Regenerate(Field);
  Delay(3000);
until keypressed;
TextMode(X16_MODE_80x60);
end.

