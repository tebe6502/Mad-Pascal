// Gif87/89 Viewer (VBXE)
// 27.07.2025 ; 20.08.2025

uses crt, atari, vbxe, gif;

var
   vram: TVBXEMemoryStream;
   
   fnam: TString;

   sts: byte;

begin

 if ParamCount = 0 then begin
  writeln('GIFView v1.1');
  writeln('Usage: GIFVIEW.EXE FILENAME.GIF');
  writeln;
  halt; 
 end;

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 SetHorizontalRes(VBXE.VGAMed);
 ColorMapOff;

 VBXEControl(vc_xdl+vc_xcolor+vc_no_trans);

 vram.position:=VBXE_OVRADR;
 vram.size:=VBXE_OVRADR+336*256;
 vram.Clear;

 sdmctl:=0;

 fnam:=ParamStr(1);
 fnam:=concat('D:',fnam);

 sts := LoadGIF(fnam);


 if sts <> 0 then begin
 
  VBXEOFF;
 
  writeln('Error: ', sts);
  
 end else begin 
 
  repeat until keypressed; 
  readkey;

  VBXEOff;
 
 end;
  
end.

(*
	 geNoError = 0;         { no errors found }
	 geNoFile = 1;          { gif file not found }
	 geNotGIF = 2;          { file is not a gif file }
	 geNoGlobalColor = 3;   { no Global Color table found }
	 geImagePreceded = 4;   { image descriptor preceeded by other unknown data }
	 geEmptyBlock = 5;      { Block has no data }
	 geUnExpectedEOF = 6;   { unexpected EOF }
	 geBadCodeSize = 7;     { bad code size }
	 geBadCode = 8;         { Bad code was found }
	 geBitSizeOverflow = 9; { bit size went beyond 12 bits }
*)