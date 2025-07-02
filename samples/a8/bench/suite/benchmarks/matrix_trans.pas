unit matrix_trans;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

{$codealign proc = $100}

procedure benchmark;
const
  size = 63;
var
  x         : byte absolute $e0;
  y         : byte absolute $e1;
  A         : array[0..size, 0..size] of byte absolute $a000;
  B         : array[0..size, 0..size] of byte absolute $b000;

begin
  for y := 0 to size do
    for x := 0 to size do A[y][x] := rnd;
  for y := 0 to size do
    for x := 0 to size do B[x][y] := A[y][x];
end;

{$codealign proc = 0}

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Matrix 64x64 Trans'~;
end.
