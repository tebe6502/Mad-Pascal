var
  COLORRAM       : array [0..0] of byte absolute $0800;
  SCREEN         : array [0..0] of byte absolute $0c00;
  BORDERCOLOR    : byte absolute $ff15;
  BGCOLOR        : byte absolute $ff19;

var
  w0i, row       : word;
  b0i, b1i, x, c : byte;

begin
  BORDERCOLOR := 0; BGCOLOR := 0;
  FillByte(@SCREEN, 40 * 25, $a0);

  for b0i := 0 to 7 do begin
    row := 40 * b0i * 2; c := b0i shl 4;
    for b1i := 0 to 15 do begin
      x := b1i * 2; Inc(c,b1i);

      COLORRAM[row + x] := c;
      COLORRAM[row + x + 1] := c;

      COLORRAM[row + 40 + x] := c;
      COLORRAM[row + 40 + x + 1] := c;

    end;
  end;

end.
