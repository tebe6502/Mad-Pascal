
uses crt, graph, vbxe;

var
	vram: TVBXEMemoryStream;


procedure initVBXE;
var a: word;
begin

 InitGraph(mVBXE, 0, '');

 if GraphResult <> grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 SetHorizontalRes(MedRes);
 ColorMapOff;

 VBXEControl(vc_xdl+vc_xcolor+vc_no_trans);

 SetOverlayPalette(0);

 vram.position:=VBXE_OVRADR;
 vram.size:=VBXE_OVRADR+320*256;
 vram.Clear;

end;


begin

 initVBXE;

 vbxe.SetColor($16);

 vbxe.PutPixel(20,20);
 vbxe.PutPixel(21,21);
 vbxe.PutPixel(20,22);
 vbxe.PutPixel(19,21);

 vbxe.Line(10,10,300,120);


 vbxe.SetColor(15);

 vbxe.Line(300,60, 60, 60);


 vbxe.SetColor($86);

 vbxe.Line(160, 240, 160,10);


 repeat until keypressed;

end.