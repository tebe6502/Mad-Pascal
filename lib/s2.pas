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
	procedure Print(a: char); overload;
	procedure Print(a: PString); overload;

implementation

uses cio, graph, crt;


procedure SetGraphMode(mode: byte);
(*
@description:
Init S2:
*)
begin

 InitGraph(0);

 cls(6);
 opn(6,12,mode,'S2:');
 
 GraphResult:=IOResult;
 
 GraphMode := mode;
 
asm
{
	txa:pha

	ldx #$60

	ldy icax5,x	; vertical resolution Y

	lda icax3,x	; horizontal resolution X:A
	pha
	lda icax4,x
	tax

	pla

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
	
	pla:tax
};
end;


procedure Print(a: char); overload;
begin

 put(6, ord(a));

end;


procedure Print(a: PString); overload;
var i: byte;
begin

 for i:=1 to a[0] do put(6, ord(a[i]));

end;


procedure ClearDevice;
begin

 cls(6);
 opn(6,12,GraphMode,'S2:');

end;


procedure CloseGraph;
begin

 cls(6);

 TextMode(0);
end;


end.

