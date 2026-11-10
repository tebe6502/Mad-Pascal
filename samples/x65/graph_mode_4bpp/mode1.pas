//-----------------------------------------------------------------------------
// MODE1 4bpp demo picture for X65 https://x65.zone/
//-----------------------------------------------------------------------------

{$r res/res.rc}

program mode1_demo;

uses x65;

const
{$i 'inc/const.inc'}

//-----------------------------------------------------------------------------

procedure Init;
begin

  asm
    sei       ; disable IRQ
    cld       ; turn off decimal mode
  end;

  cgia.plane_ctrl := 0; // disable all planes, so CGIA does not go haywire during reconfiguration

  FillByte(@plane0_bckgnd, 10, 0); // clear CGIA plane0 registers

  plane0_bckgnd.flags      := PLANE_BITS_4BPP;
  plane0_bckgnd.row_height := 0;

  plane0_bckgnd.shared_color0 := 4;
  plane0_bckgnd.shared_color1 := 6;
  plane0_bckgnd.color2 := 1;
  plane0_bckgnd.color3 := 46;
  plane0_bckgnd.color4 := 7;
  plane0_bckgnd.color5 := 35;
  plane0_bckgnd.color6 := 3;
  plane0_bckgnd.color7 := 37;

  cgia.offset0 := RES_DISPLAYLIST; // point plane0 to DL

  cgia.plane_ctrl := 1; // activate plane0 (type = background)
end;

//-----------------------------------------------------------------------------

begin
  Init;
  repeat until false;
end.

