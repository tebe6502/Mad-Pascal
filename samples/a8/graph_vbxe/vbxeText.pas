
(*

   VGA: text mode 80x24 in 2 colors per character. This is like GR.0 in 80 columns and color.

 VGALo: pixel mode 160x192/256 colors (lowres). This is like GR.15 in 256 colors.

VGAMed: pixel mode 320x192/256 colors (stdres). This is like GR.8 in 256 colors.

 VGAHi: pixel mode 640x192/16 colors (hires)

*)


uses crt, vbxe;

var i: byte;


begin

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 VBXEMode(VBXE.VGA, 0);		// VBXE MODE, OVERLAY PALETTE #0

 Position(0,0);
 for i:=0 to 127 do TextOut(chr(i), i);

 Position(0,3);
 for i:=0 to 127 do TextOut(chr(i), ($80 or i) and $f0);

 Position(0,6);
 TextOut('Atari is back', 12);

 TextOut('a', 28);
 TextOut('A', 28);


 repeat until keypressed;

end.