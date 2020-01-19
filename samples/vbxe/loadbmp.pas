// changes: 24.09.2017

uses crt, graph, vbxe, atari, vimage, sysutils;

var	fnam, ext: TString;

	vram: TVBXEMemoryStream;

	dma: byte;

	status: Boolean;

begin

 InitGraph(mVBXE, 0, '');

 if GraphResult <> grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 dma:=sdmctl;

 SetHorizontalRes(MedRes);
 ColorMapOff;

 repeat

 vram.position:=VBXE_OVRADR;
 vram.size:=VBXE_OVRADR+320*256;
 vram.Clear;

 write('Load image >');
 readln(fnam);

 sdmctl:=0;

 ext:=AnsiUpperCase(ExtractFileExt(fnam));

 if ext='.BMP' then status:=LoadVBMP(fnam, VBXE_OVRADR) else
  if ext='.PCX' then status:=LoadVPCX(fnam, VBXE_OVRADR) else
   if ext='.GIF' then status:=LoadVGIF(fnam, VBXE_OVRADR) else
    status:=false;


 if status=false then begin

  case IMGError of
   1: writeln('File not found');
   2: writeln('Unsupported format');
   3: writeln('Too large');
  end;

 end else
  repeat until keypressed;

 sdmctl:=dma;

 until false;


 VBXEOff;

end.

