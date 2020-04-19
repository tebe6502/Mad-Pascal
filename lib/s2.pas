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
InitGraph

}

interface

	procedure SetGraphMode(mode: byte);
	procedure ClearDevice;
	procedure CloseGraph;
{	procedure Print(a: cardinal); overload;
	procedure Print(a: integer); overload;
	procedure Print(a: char); overload;
	procedure Print(a: PString); overload;
}
implementation

uses cio, graph, crt, sysutils;


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
var p: pointer;
begin

 InitGraph(0);

 cls(6);
 opn(6,12,mode,'S2:');
 
asm
{
	txa:pha

	ldy icax5+$60	; vertical resolution Y
	bne ok

	lda #MAIN.GRAPH.grNotDetected
	bne toEnd

ok	lda icax3+$60	; horizontal resolution X:A
	ldx icax4+$60

	sta MAIN.SYSTEM.ScreenWidth
	stx MAIN.SYSTEM.ScreenWidth+1

	sub #1
	sta MAIN.GRAPH.WIN_RIGHT
	txa
	sbc #0
	sta MAIN.GRAPH.WIN_RIGHT+1

	sty MAIN.SYSTEM.ScreenHeight
	lda #0
	sta MAIN.SYSTEM.ScreenHeight+1

	sta MAIN.GRAPH.WIN_LEFT
	sta MAIN.GRAPH.WIN_LEFT+1
	sta MAIN.GRAPH.WIN_TOP
	sta MAIN.GRAPH.WIN_TOP+1

	sta MAIN.GRAPH.WIN_BOTTOM+1	
	dey
	sty MAIN.GRAPH.WIN_BOTTOM

	lda mode
	sta MAIN.SYSTEM.GraphMode

  	mva #$2c @putchar.vbxe	; bit*
	mva #$60 @putchar.chn	; #6
	mva #0 766		; execution execution control character
	
	lda #MAIN.GRAPH.grOK
toEnd
	sta MAIN.GRAPH.GraphResult

	pla:tax
};
end;


{
procedure Print(a: char); overload;
begin

 put(6, ord(a));

end;


procedure Print(a: PString); overload;
var i: byte;
begin

 for i:=1 to a[0] do put(6, ord(a[i]));

end;


procedure Print(a: cardinal); overload;
begin
 Print( IntToStr(a) );
end;


procedure Print(a: integer); overload;
begin
 Print( IntToStr(a) );
end;
}


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

