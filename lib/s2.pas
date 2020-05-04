unit S2;
(*
 @type: unit
 @author: Drac030, Tomasz Biela (Tebe)
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
CloseGraph
InitGraph
Position
SetGraphMode
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

			procedure LoadFromFile(name: PByte);
			procedure LoadFromMem(p: pointer);
	end;


	procedure SetGraphMode(mode: byte);
	procedure ClearDevice;
	procedure CloseGraph;
	procedure Position(x: word; y: byte); assembler;
	procedure TextOut(x: word; y: byte; s: PByte); overload;
	procedure TextOut(a: char); overload;


implementation

uses cio, crt, graph, sysutils;


procedure Font.LoadFromFile(name: PByte);
(*
@description:
*)
begin



end;


procedure Font.LoadFromMem(p: pointer);
(*
@description:
*)
begin



end;


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
 
// xio(111,6,0,0,'S2:');

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

	mva #0 766		; execution control character

	lda #MAIN.GRAPH.grOK
	sta MAIN.GRAPH.GraphResult

	pla:tax
	
toEnd
	
};
end;


procedure Position(x: word; y: byte); assembler;
(*
@description:
Set cursor position on screen.

GotoXY positions the cursor at (X,Y), X in horizontal, Y in vertical direction.

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


procedure CloseGraph;
(*
@description:
*)
begin

 cls(6);

 TextMode(0);
 
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

