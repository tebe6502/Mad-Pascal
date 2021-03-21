// sample gfx made by Carrion
{$r mgfx.rc}

const
  TRON_TITLE_SCREEN = $5800;

var
  SETBITMAP                          : byte absolute $ff06;
  SETMCOLOR                          : byte absolute $ff07;
  BITMAPADDR                         : byte absolute $ff12;
  VIDEOMATRIX                        : byte absolute $ff14;
  BACKGROUND                         : byte absolute $ff15;
  COLOUR1                            : byte absolute $ff16;
  BORDER                             : byte absolute $ff19;

begin
  SETBITMAP := SETBITMAP or $20;
  SETMCOLOR := (SETMCOLOR and $40) or $18;

  // (01011xxx) $5800 = 11 * $800;
  VIDEOMATRIX := %01011000;
  // (xx011xxx) $6000 = 3 * $2000; bit 2 set to 0 means reading from RAM
  BITMAPADDR := %00011000 or (BITMAPADDR and %00000011);

  BORDER := 0;
  BACKGROUND := 0;
  COLOUR1 := 1;

  repeat until false;
end.
