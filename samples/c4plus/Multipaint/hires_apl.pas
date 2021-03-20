//Mad Pascal logo by @bocianu
{$r hgfx_apl.rc}

uses aplib;

const
  APLBIN = $3000;
  LOGO   = $5800;

var
  SETBITMAP                          : byte absolute $ff06;
  SETMCOLOR                          : byte absolute $ff07;
  BITMAPADDR                         : byte absolute $ff12;
  VIDEOMATRIX                        : byte absolute $ff14;
  BORDER                             : byte absolute $ff19;

begin

  unapl(pointer(APLBIN), pointer(LOGO));

  SETBITMAP := SETBITMAP or $20;
  SETMCOLOR := (SETMCOLOR and $40) or $8;

  // (01011xxx) $5800 = 11 * $800;
  VIDEOMATRIX := %01011000;
  // (xx011xxx) $6000 = 3 * $2000; bit 2 set to 0 means reading from RAM
  BITMAPADDR := %00011000 or (BITMAPADDR and %00000011);

  BORDER := $3d;

  repeat until false;
end.
