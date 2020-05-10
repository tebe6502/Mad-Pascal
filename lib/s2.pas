unit S2;
(*
 @type: unit
 @author: Konrad Kokoszkiewicz, Tomasz Biela
 @name: S2: VBXE handler

 @version: 1.0

 @description:
 1: text mode 80x24 in 2 colors per character. This is like GR.0 in 80 columns and color.

 2: pixel mode 160x192/256 colors (lowres). This is like GR.15 in 256 colors.

 3: pixel mode 320x192/256 colors (stdres). This is like GR.8 in 256 colors.

 4: pixel mode 640x192/16 colors (hires)

 5: text mode 80x25.

 6: text mode 80x30.

 7: text mode 80x32.
*)


{

ClearDevice
ClearLine
CloseGraph
GetPaletteEntries
InitGraph
LoadBitmap
Position
SaveBitmap
ScrollDown
ScrollUp
SetGraphMode
SetPaletteEntries
TextOut

}

interface

const	fsNormal = 0;
	fsUnderline = 64;
	fsInverse = 128;
	fsProportional = 8;
	fsCondensed = 32;


var	Font: Object
			Style: byte;
			Color: byte;
	end;


	procedure SetGraphMode(mode: byte);
	procedure ClearDevice;
	procedure ClearLine(line, cnt: byte);
	procedure CloseGraph;
	procedure GetPaletteEntries(pal: pointer);
	procedure Position(x: word; y: byte); assembler;
	procedure ScrollUp(line, cnt: byte);
	procedure ScrollDown(line, cnt: byte);
	procedure SetPaletteEntries(pal: pointer);
	function LoadBitmap(fnam: PString): Boolean;
	procedure SaveBitmap(fnam: PString);
	procedure TextOut(x: word; y: byte; s: PByte); overload;
	procedure TextOut(a: char); overload;


implementation

uses cio, crt, graph, sysutils;

{$i imageh.inc}

var
	buffer: array [0..0] of byte absolute $0400;
	tmp: array [0..3] of byte;

	Header: TBmpHeader;
	f: file;



procedure ClearDevice;
(*
@description:
Clear whole screen
*)
begin

 cls(6);
 opn(6, 12 + GraphMode and $f0, GraphMode and $0f, 'S2:');

end;


procedure SetGraphMode(mode: byte);
(*
@description:
Init S2:
*)
begin

 cls(6);
 opn(6, 12 + mode and $f0, mode and $0f, 'S2:');

 GraphResult := byte(grNotDetected);

asm
{
	ldy icax5+$60	; vertical resolution Y
	beq toEnd

	txa:pha

	lda icax3+$60	; horizontal resolution X:A
	ldx icax4+$60

; X:A = horizontal resolution
; Y = vertical resolution

	@SCREENSIZE

	lda mode
	sta MAIN.SYSTEM.GraphMode

  	mva #$2c @putchar.vbxe	; bit*

	lda #$60		; #6 * $10
	sta @putchar.chn
	sta @COMMAND.scrchn

;	mva #0 766		; execution control character

	lda #MAIN.GRAPH.grOK
	sta MAIN.GRAPH.GraphResult

	pla:tax

toEnd

};
end;


{
procedure Font.LoadFromFile(fname: PByte);
var buf: PByte;
    f: file;
begin

 if FileExists(fname) then begin

  assign(f, fname); reset(f, 1);
  blockread(f, buf, 2048);
  close(f);

 end;

 xio(103,6,$00,$81,'S2:');

end;
}


procedure Position(x: word; y: byte); assembler;
(*
@description:
Set cursor position on screen.

Positions the cursor at (X,Y), X in horizontal, Y in vertical direction.

@param: x - horizontal positions
@param: y - vertical positions
*)
asm
{
	mwa x colcrs

	mva y rowcrs
};
end;


procedure TextOut(x: word; y: byte; s: PByte); overload;
(*
@description:
*)
var i: byte;
begin

asm
{
	mwa x colcrs

	mva y rowcrs

	mva FONT.COLOR fildat
};

 for i:=1 to s[0] do xio(105,6,Font.Style,byte(s[i]),'S2:');

end;


procedure TextOut(a: char); overload;
(*
@description:
*)
begin

asm
{
	mva FONT.COLOR fildat
};

 xio(105,6,Font.Style,byte(a),'S2:');

end;


procedure ScrollUp(line, cnt: byte);
(*
@description:
*)
begin

 while cnt > 0 do begin
  XIO(97,6,12,line,'S2:');
  dec(cnt);
 end;

end;


procedure ScrollDown(line, cnt: byte);
(*
@description:
*)
begin

 while cnt > 0 do begin
  XIO(98,6,12,line,'S2:');
  dec(cnt);
 end;

end;


procedure ClearLine(line, cnt: byte);
(*
@description:
*)
begin

 while cnt > 0 do begin
  XIO(99,6,12,line,'S2:');
  inc(line);
  dec(cnt);
 end;

end;



procedure CloseGraph;
(*
@description:
*)
begin

 cls(6);

 TextMode(0);

end;


procedure GetPaletteEntries(pal: pointer);
begin

 xio(102,6,64+12,hi(word(pal)),'S2:');

end;


procedure SetPaletteEntries(pal: pointer);
begin

 xio(101,6,64+12,hi(word(pal)),'S2:');

end;


procedure SaveBitmap(fnam: PString);
var i: byte;
begin

 Header.bfType := ord('M')*256 + ord('B');
 Header.biSize := 40;
 Header.biWidth := ScreenWidth;
 Header.biHeight := ScreenHeight;
 Header.bfOffbits := 14 + Header.biSize + 1024;
 Header.biSizeImage := Header.biWidth * Header.biHeight;
 Header.bfSize := Header.bfOffbits + Header.biSizeImage;

 Header.biClrUsed := 256;		// liczba kolorow
 Header.biClrImportant:=0;
 Header.biXPelsPerMeter:=0;
 Header.biYPelsPerMeter:=0;
 Header.bfReserved:=0;
 Header.biCompression:=0;
 Header.biPlanes:=1;
 Header.biBitcount:=8;			// liczba bitow na pixel

 assign(f, fnam); rewrite(f, 1);
 blockwrite(f, Header, sizeof(TBMPHeader));

 GetPaletteEntries(Buffer);

 for i:=0 to 255 do begin
  tmp[0]:=Buffer[$200+i];
  tmp[1]:=Buffer[$100+i];
  tmp[2]:=Buffer[i];
  tmp[3]:=0;

  blockwrite(f, tmp, 4);
 end;


 for i:=191 downto 0 do begin
 
  Position(0,i);

  BGet(6, Buffer, 320);
  blockwrite(f, Buffer, 320);

 end;

 close(f);

end;


function LoadBitmap(fnam: PString): Boolean;
(*
@description:
This loads a BMP File (4bit, 8bit)
*)
var x, w, h: word;
    b, v, i: byte;
    a: cardinal;
begin

 if not FileExists(fnam) then begin
//   IMGError:=FileNotFound;
   Result:=false;
   exit;
 end;

 assign(f, fnam); reset(f, 1);

 blockread(f, Header, sizeof(Header));

 w:=Header.biwidth;
 h:=Header.biheight;
 b:=Header.bibitcount;

 {Check to see whether we can display it}
 if (Header.bfType <> 19778)
 or (Header.bfReserved <> 0)
 or (Header.biPlanes <> 1)
 or (Header.biCompression <> 0)
 or (b <> 8) then begin
   Close (f);
//   IMGError := UnsupportedFormat;
   Result := false;
   Exit;
 end;

 if (w>320) or (h>192) then begin
//  IMGError := TooLarge;
  Result := false;
  Exit;
 end;

 if w and 3<>0 then w:=w and $fffc + 4;

 dec(h);

 blockread(f, Buffer, Header.bfOffBits-1024-sizeof(TBMPHeader));	// offset do tablicy pikseli obrazka

 {Set the palette}

 for i:=0 to 255 do begin
  blockread(f, tmp, 4);

  Buffer[i+$200]:= tmp[0];
  Buffer[i+$100]:= tmp[1];
  Buffer[i]	:= tmp[2];
 end;  
  
 SetPaletteEntries(Buffer);


 x:=0;

 Position(0,h);

 while not eof(f) do begin

	blockread(f, Buffer, 256);

	if word(x+256) < w then begin
	
	 BPut(6, Buffer, 256);
	 inc(x, 256);

	end else

	for i:=0 to 255 do begin

	 Put(6, Buffer[i]);

	 inc(x);

	 if x = w then begin
		x:=0;
		dec(h);
		Position(0,h);
	 end;

	end;

 end;

 {Close the file}
 Close (f);

 {Successful}
 Result := true;

end;



initialization


SetGraphMode(0);

if GraphResult <> grOK then begin

 xio(40,1,0,0,'D:SDXLD.COM /X');

 if IoResult >= 128 then begin
  TextMode(0);
  writeln('S_VBXE.SYS not installed');

  repeat until keypressed;
  halt;
 end;

 SetGraphMode(0);

 if GraphResult <> grOK then begin
  TextMode(0);
  writeln('VBXE not present');

  repeat until keypressed;
  halt;
 end;

end;


end.

