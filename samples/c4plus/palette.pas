var
  COLORRAM       : ^word;
  SCREEN         : pointer;
  BORDERCOLOR    : byte absolute $ff15;
  BGCOLOR        : byte absolute $ff19;

var
  row, wc        : word;
  b0i, b1i, c    : byte;

begin
  BORDERCOLOR := 0; BGCOLOR := 0;
  COLORRAM := pointer($0800);
  SCREEN := pointer($0c00);
  FillByte(SCREEN, 40 * 25, $a0);

  for b0i := 0 to 7 do begin
    row := 20 * b0i * 2; c := b0i shl 4;
    for b1i := 0 to 15 do begin
      wc := (c + b1i) shl 8 + (c + b1i);
      COLORRAM[row + b1i] := wc;
      COLORRAM[row + 20 + b1i] := wc;
    end;
  end;

  repeat until false;
end.