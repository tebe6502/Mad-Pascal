var
  COLORRAM    : array [0..0] of byte absolute $0800;
  SCREEN      : array [0..0] of byte absolute $0c00;
  BORDERCOLOR : byte absolute $ff15;
  BGCOLOR     : byte absolute $ff19;

var
  w0i, row    : word;
  b0i, b1i    : byte;

begin
  BORDERCOLOR := 0; BGCOLOR := 0;
  FillByte(@SCREEN, 40 * 25, $a0);

  for b0i := 0 to 7 do begin
    row := 40 * b0i;
    for b1i := 0 to 15 do COLORRAM[row+b1i] := (b0i shl 4) + b1i;
  end;
end.
