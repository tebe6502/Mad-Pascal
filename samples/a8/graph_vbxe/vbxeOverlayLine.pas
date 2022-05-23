
(*

 VGALo: pixel mode 160x192/256 colors (lowres). This is like GR.15 in 256 colors.

VGAMed: pixel mode 320x192/256 colors (stdres). This is like GR.8 in 256 colors.

 VGAHi: pixel mode 640x192/16 colors (hires)

*)


uses crt, vbxe;

begin

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 VBXEMode(VBXE.VGAHi, 0);		// VBXE MODE, OVERLAY PALETTE #0

 vbxe.SetColor($16);

 vbxe.PutPixel(20,20);
 vbxe.PutPixel(21,21);
 vbxe.PutPixel(20,22);
 vbxe.PutPixel(19,21);

 vbxe.Line(10,10,300,120);


 vbxe.SetColor(12);

 vbxe.Line(300,60, 60, 60);


 vbxe.SetColor($86);

 vbxe.Line(160, 240, 160,10);


 repeat until keypressed;

end.