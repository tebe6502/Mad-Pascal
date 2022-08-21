const
  ATTRIBUTE_ADDR = $0800; SCREEN_ADDR = $0c00; OFFSET = SCREEN_ADDR - ATTRIBUTE_ADDR;
  CHARSET = $d000; EMPTY = $20;

var
  BACKGROUND                         : byte absolute $ff15;
  BOREDER                            : byte absolute $ff19;

//-----------------------------------------------------------------------------

procedure printBigCharXY(x, y, ch, c: byte);
var
  curPoint, charRow     : word;
  tmp, i0b, i1b         : byte;
begin
  curPoint := SCREEN_ADDR + x + (y * 40);
  charRow := CHARSET + (8 * ch);

  for i0b := 0 to 7 do begin
    tmp := Peek(charRow + i0b);
    for i1b := 7 downto 0 do begin
      if (tmp and 1) = 1 then begin
        poke(curPoint + i1b, $a0);
        poke(curPoint - OFFSET + i1b, c);
      end;
      tmp := tmp shr 1;
    end;
    Inc(curPoint,40);
  end;
end;

//-----------------------------------------------------------------------------

procedure printBigXY(x, y, c: byte; s: string);
var
  i0b : byte;
begin
  for i0b := 1 to length(s) do printBigCharXY(x + (8 * (i0b - 1)), y, ord(s[i0b]), c);
end;

//-----------------------------------------------------------------------------

begin

  FillChar(pointer(SCREEN_ADDR), 24 * 40, EMPTY);
  FillChar(pointer(ATTRIBUTE_ADDR), 24 * 40, 0);

  printBigXY(3, 3, $11, 'tron'~);
  printBigXY(11, 12, $11, '+4'~);

  repeat until false;

end.
