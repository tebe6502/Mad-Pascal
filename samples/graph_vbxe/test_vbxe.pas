uses crt, graph, vbxe, atari, sysutils;

var vram: TVBXEMemoryStream;


procedure InitVBXE();
begin
 InitGraph(mVBXE, 0, '');

 if GraphResult <> grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 SetHorizontalRes(MedRes);
 ColorMapOff;
 

 SetRGBPalette(4);

 SetRGBPalette(0,0,0);
 SetRGBPalette(100,100,100);


 VBXEControl(vc_xdl+vc_xcolor+vc_no_trans);

 vram.position:=VBXE_OVRADR;
 vram.size:=VBXE_OVRADR+320*256;
 vram.Clear;
end;


procedure DrawPixel;
var i: byte;
begin
  vram.position := VBXE_OVRADR + 320 * 25;
  for i := 0 to 255 do begin
    vram.WriteByte(1);
  end;
end;


begin
  InitVBXE;
  DrawPixel;
  repeat until keypressed;
  VBXEOff;
end.