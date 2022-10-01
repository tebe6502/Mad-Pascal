 // by Signum Temporis 2022

program RotatingSierpinskiCarpet;


uses atari, crt, fastgraph, math, sysutils;

type
  IntVector = record x, y: SmallInt end;
  IntVectorPtr = ^IntVector;

  Vector = record x, y: Float16 end;
  VectorPtr = ^Vector;
  Square = record
    v: Vector;    // top left vertex
    d: Vector;    // delta to top right vertex
  end;
  SquarePtr = ^Square;
  CarpetPtr = Pointer;

const
  maxX: Word = 320;
  maxY: Byte = 192;
  midX: Byte = Round(maxX / 2);
  midY: Byte = Round(maxY / 2);
  onScreenSize: Float16 = maxY / 1.5;
  rank: Byte = 2;   // rank -> sN | 0 -> 1 | 1 -> 2 |2 -> 11 | 3 -> 74 | 4 -> 586
  sN: Byte = 11;    // number of squares in carpet sN := 1 + 1/7 * (8^rank - 1)
  cN: Byte = 36;    // number of carpet snapshots in 90-degree rotation (rotation steps)

var
  data: array [0 .. cN - 1, 0 .. sN * SizeOf(Square) - 1] of Byte;
  carpets: array [0 .. cN - 1] of CarpetPtr;
  currentSquare: ^Square;
  sinA, cosA: Float16;
  ticksAnim: Word;
  buf1, buf2: TDisplayBuffer;

procedure AssignCarpetsPointers();
var i: Byte;
begin
  for i := 0 to cN - 1 do begin
    carpets[i] := Pointer(@data[i,0]);
  end;
end;

function GetSquare(c, s: Byte): ^Square;
begin
  Result := carpets[c] + s * SizeOf(Square);
end;

procedure AddSquare(x, y, size: Float16);
begin
  currentSquare^.v.x := x;
  currentSquare^.v.y := y;
  currentSquare^.d.x := size;
  currentSquare^.d.y := 0;

  Inc(currentSquare);
end;

procedure MakeCarpet0Interior(x, y, size: Float16; rank: Byte);
var i, j: Byte;
begin
  if rank > 0 then begin
    size := size / 3;
    AddSquare(x + size, y + size, size);
    if rank > 1 then begin
      rank := rank - 1;
      for i := 0 to 2 do begin
        for j := 0 to 2 do begin
          if (i <> 1) or (j <> 1) then begin
            MakeCarpet0Interior(x + i * size, y + j * size, size, rank);
          end;
        end;
      end;
    end;
  end;
end;

procedure MakeCarpet0();
var x: Float16;
begin
  x := -onScreenSize / 2;
  currentSquare := GetSquare(0, 0);
  AddSquare(x, x, onScreenSize);
  MakeCarpet0Interior(x, x, onScreenSize, rank);
end;

procedure RotateVector(var src: Vector; var result: Vector);
begin
  result.x := src.x * cosA - src.y * sinA;
  result.y := src.x * sinA + src.y * cosA;
end;

procedure MakeRotatedCarpet(c: Byte);
var
  s: Byte;
  s0, sc: ^Square;
begin
  for s := 0 to sN - 1 do begin
    s0 := GetSquare(0, s);
    sc := GetSquare(c, s);

    RotateVector(s0.v, sc.v);
    RotateVector(s0.d, sc.d);
  end;
end;

procedure MakeRotatedCarpets();
var
  alphaStep: Float16 = 90.0 / cN * (pi / 180);
  alpha: Float16;
  c: Byte;
begin
  for c := 0 to cN - 1 do begin
    alpha := c * alphaStep;
    sinA := Sin(alpha);
    cosA := Cos(alpha);
    MakeRotatedCarpet(c);
  end;
end;

procedure CenterVector(var v: Vector);
begin
  v.x := v.x + midX;
  v.y := v.y + midY;
end;

procedure IntegerizeVector(vf: VectorPtr);
var  vi: IntVectorPtr;
begin
  vi := Pointer(vf);

  vi^.x := Round(vf^.x);
  vi^.y := Round(vf^.y);

end;

procedure PreprocessCarpet(c: Byte);
var s: Byte;
begin
  currentSquare := GetSquare(c, 0);
  for s := 0 to sN - 1 do begin
    CenterVector(currentSquare^.v);

    IntegerizeVector(@currentSquare.v);
    IntegerizeVector(@currentSquare.d);

    Inc(currentSquare);
  end;
end;

procedure PreprocessCarpets();
var c: Byte;
begin
  for c := 0 to cN - 1 do begin
    PreprocessCarpet(c);
  end;
end;

procedure DrawCurrentSquare();
var
  v, d: ^IntVector;
  x, y: SmallInt;
begin
  v := Pointer(@currentSquare.v);
  d := Pointer(@currentSquare.d);

  x := v.x;
  y := v.y;
  MoveTo(x, y);

  x := x + d.x;
  y := y + d.y;
  LineTo(x, y);

  x := x - d.y;
  y := y + d.x;
  LineTo(x, y);

  x := x - d.x;
  y := y - d.y;
  LineTo(x, y);

  LineTo(v.x, v.y);
end;

procedure DrawCarpet(c: CarpetPtr);
var s: Byte;
begin
  currentSquare := Pointer(c);
  for s := 0 to sN - 1 do begin
    DrawCurrentSquare();
    Inc(currentSquare);
  end;
end;

procedure AnimateCarpet();
var i, c: Byte;
begin
  i := 100;   // number of iterations
  c := 0;
  ticksAnim := 0;
  while i > 0 do begin
    Pause();
    SwitchDisplayBuffer(buf1, buf2);
    DrawCarpet(carpets[c]);

    if KeyPressed() then break;

    Inc(c);
    if c >= cN then c := 0;
    Dec(i);
  end;
  ticksAnim := Word(GetTickCount()) - ticksAnim;
end;

begin
  AssignCarpetsPointers();

  MakeCarpet0();
  MakeRotatedCarpets();
  PreprocessCarpets();

  NewDisplayBuffer(buf1, 8 + 16, $c0);    // ramtop = $c0
  NewDisplayBuffer(buf2, 8 + 16, $a0);    // ramtop = $a0
  SetColor(1);

  AnimateCarpet();

  ReadKey();
  WriteLn(ticksAnim);
  ReadKey();
end.

// 1598