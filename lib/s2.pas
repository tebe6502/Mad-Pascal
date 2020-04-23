unit S2;
(*
 @type: unit
 @author: Drac030, Tomasz Biela (Tebe)
 @name: S2: VBXE handler

 @version: 1.0

 @description:
*)


{

ClearDevice
CloseGraph
InitGraph
SetGraphMode
TextOut

}

interface

const
	fsNormal = 0;
	fsUnderline = 64;
	fsInverse = 128;
	fsProportional = 8;
	fsCondensed = 32;
	

var	Font: Object
			Style: byte;
			Color: byte;

			procedure LoadFromFile(name: TString);
			procedure LoadFromMem(p: pointer);
	end;


	procedure SetGraphMode(mode: byte);
	procedure ClearDevice;
	procedure CloseGraph;
	
//	procedure TextOut(x,y: char; s: PByte);
//	procedure TextOut(x: word; y: byte; s: PByte); overload;
// !!! powinien zglosic niezgodnosc typow parametrow !!!


	procedure TextOut(x: word; y: byte; s: PByte); overload;
	procedure TextOut(a: char); overload;


implementation

uses cio, graph, crt, sysutils;



procedure Font.LoadFromFile(name: PByte);
begin



end;


procedure Font.LoadFromMem(p: pointer);
begin



end;


procedure ClearDevice;
begin

 cls(6);
 opn(6,12,GraphMode,'S2:');

end;


(*
procedure s2_put;
begin

asm
{
	pha
	tya
	pha

	stx @sp

	cmp #eol
	beq skp

	cmp #$7d		; clrscr
	bne skp

	ldx @sp			; restore X !
};

	ClearDevice;
asm
{
skp
	pla
	tay
	pla

	ldx #0
@sp	equ *-1
};

end;
*)


procedure SetGraphMode(mode: byte);
(*
@description:
Init S2:
*)
begin

 cls(6);
 opn(6,12,mode,'S2:');
 
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

	mva #0 766		; execution execution control character

	sta colcrs
	sta colcrs+1
	sta rowcrs

	lda #MAIN.GRAPH.grOK
	sta MAIN.GRAPH.GraphResult

	pla:tax
	
toEnd
	
};
end;



procedure TextOut(x: word; y: byte; s: PByte); overload;
var i: byte;
begin

 GotoXY(x,y);

asm
{
	mva FONT.COLOR fildat
};
  
 for i:=1 to s[0] do xio(105,6,Font.Style,byte(s[i]),'S2:');
 
end;


procedure TextOut(a: char); overload;
begin

asm
{
	mva FONT.COLOR fildat
};
  
 xio(105,6,Font.Style,byte(a),'S2:');
 
end;


procedure CloseGraph;
begin

 cls(6);

 TextMode(0);
 
end;



initialization


SetGraphMode(0);

if GraphResult <> grOK then begin

 xio(40,1,0,0,'D:SDXLD.COM');
 
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

