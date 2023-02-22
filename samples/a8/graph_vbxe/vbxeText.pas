
(*

   VGA: text mode 80x24 in 2 colors per character. This is like GR.0 in 80 columns and color.

 VGALo: pixel mode 160x192/256 colors (lowres). This is like GR.15 in 256 colors.

VGAMed: pixel mode 320x192/256 colors (stdres). This is like GR.8 in 256 colors.

 VGAHi: pixel mode 640x192/16 colors (hires)

*)


uses crt, vbxe;

var i: byte;

    fildat: byte absolute $02FD;

begin

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 VBXEMode(VBXE.VGA, 0);		// VBXE MODE, OVERLAY PALETTE #0


 GotoXY(0,0);
 for i:=0 to 127 do begin fildat:=i; write(chr(i)) end;

 GotoXY(0,3);
 for i:=0 to 127 do begin fildat:=($80 or i) and $f0; write(chr(i)) end;

 TextBackground(0);

 GotoXY(0,24);
 TextColor(12);
 write('Atari is back');

 TextColor(28);
 write('a');
 write('A');

 repeat until keypressed;

end.