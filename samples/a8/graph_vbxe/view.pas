// changes: 23.01.2022

uses crt, vbxe, atari, vimage, sysutils;

var	fnam, ext: TString;

	vram: TVBXEMemoryStream;

	status: Boolean;

begin

 if ParamCount > 0 then begin

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 SetHorizontalRes(VBXE.VGAMed);
 ColorMapOff;

 VBXEControl(vc_xdl+vc_xcolor+vc_no_trans);

 vram.position:=VBXE_OVRADR;
 vram.size:=VBXE_OVRADR+320*256;
 vram.Clear;

 sdmctl:=0;

 fnam:=ParamStr(1);

 ext:=AnsiUpperCase(ExtractFileExt(fnam));

 fnam:=concat('D:',fnam);

 if ext='.BMP' then status:=LoadVBMP(fnam, VBXE_OVRADR) else
  if ext='.PCX' then status:=LoadVPCX(fnam, VBXE_OVRADR) else
   if ext='.GIF' then status:=LoadVGIF(fnam, VBXE_OVRADR) else
    status:=false;

 if status=false then begin

  VBXEOff;

  case IMGError of
   1: writeln('File not found');
   2: writeln('Unsupported format');
   3: writeln('Too large');
  end;

 end else begin

  repeat until keypressed;
  VBXEOff;

 end;

 end;

end.

// 9675