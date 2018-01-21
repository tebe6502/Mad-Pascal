unit fastgraph;

{

http://www.freepascal.org/docs-html/rtl/graph/index-5.html


fLine			fast Line
FrameBuffer
fRectangle		fast Rectangle
GetPixel
InitGraph		support mode: 3, 5, 7, 8, 9, 10, 11, 15
Line
MoveTo
LineTo
PutPixel
SetBkColor
SetColor

}


interface

uses	types;

	{$i graphh.inc}

	procedure fLine(x0,y0,x1,y1: byte); assembler;
	procedure FrameBuffer(a: word); assembler;
	procedure fRectangle(x1, y1, x2, y2: Smallint);
	procedure LineTo(x, y: smallint);
	procedure PutPixel(x,y: smallint); assembler; register;


implementation

var
	color_bits: array [0..$3ff] of byte;
	lineLo, lineHi, div4: array [0..255] of byte;

	CurrentX, CurrentY: smallint;


(*
	TheFillSettings : FillSettingsType;


procedure SetFillStyle(pattern, color: byte);
//----------------------------------------------------------------------------------------------
// Set drawing fill style
//----------------------------------------------------------------------------------------------
begin
	TheFillSettings.pattern := pattern;
	TheFillSettings.color	:= color;
end;
*)


procedure SetBkColor(color: byte); assembler;
//----------------------------------------------------------------------------------------------
// Sets the background color to Color
//----------------------------------------------------------------------------------------------
asm
{	mva color colbaks
};
end;


procedure SetColor(color: byte); assembler;
//----------------------------------------------------------------------------------------------
// Sets the foreground color to Color
//----------------------------------------------------------------------------------------------
asm
{	jmp gr8
mode	equ *-2

gr15	lda color
	and #3
	tay

	jmp toend

gr9	txa:pha

	lda color
	and #$0f
	sta c9+1
	:4 asl @
	sta c9

	ldy #0
lp	tya
	and #1
	tax
	lda c9_,x
	sta adr.color_bits,y
	lda c9,x
	sta adr.color_bits+$100,y
	iny
	bne lp

	pla:tax

	ldy color
	beq toend

	ldy #1
	jmp toend

c9	dta 0,0
c9_	dta $0f, $f0

colorHi		dta h(adr.color_bits, adr.color_bits+$100, adr.color_bits+$200, adr.color_bits+$300)

gr8	lda color
	and #1
	tay

toend
	.ifdef fLine
	lda colorHi,y
	sta fLine.urr_color+2
	sta fLine.uur_color+2
	sta fLine.drr_color+2
	sta fLine.ddr_color+2

	lda #$1d		; ora *,x
	cpy #0
	sne
	lda #$3d		; and *,x

	sta fLine.urr_color
	sta fLine.uur_color
	sta fLine.drr_color
	sta fLine.ddr_color
	.endif

	.ifdef PutPixel
	mva colorHi,y PutPixel.acol+2

	lda #$1d		; ora *,x
	cpy #0
	sne
	lda #$3d		; and *,x

	sta PutPixel.acol
	.endif
};
end;


procedure PutPixel(x,y: smallint); assembler; register;
//----------------------------------------------------------------------------------------------
// Puts a point at (X,Y) using color Color
//----------------------------------------------------------------------------------------------
asm
{	stx @sp

	lda y+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	ldy y
	lda adr.lineLo,y
	add #0
lfb	equ *-1
	sta bp2

	lda adr.lineHi,y
;	beq stop
	adc #0
hfb	equ *-1
	sta bp2+1

	jmp gr8
mode	equ *-2

; ----------------------------

gr15	ldx x
	ldy adr.div4,x

	jmp plot

; ----------------------------

gr9	lda x
	lsr @
	tay
	lda x
	and #1
	tax

	jmp plot

; ----------------------------

gr8	lda x
	tax

	lsr x+1
	ror @

	tay
	lda adr.div4,y
	tay

plot	lda (bp2),y
acol	ora adr.color_bits,x
	sta (bp2),y

stop	ldx #0
@sp	equ *-1
};
end;


function GetPixel(x,y: smallint): byte; assembler;
//----------------------------------------------------------------------------------------------
// Return color of pixel
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

	ldy #0

	lda y+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	mwa x colcrs
	mva y rowcrs

	lda #@IDget

	jsr @COMMAND
	tay

stop	sty Result

	pla:tax
};
end;


procedure Line(x1,y1,x2,y2: smallint);
var dx, dy, fraction, stepx, stepy: smallint;
begin
    if x1<0 then x1:=0;
    if y1<0 then y1:=0;

    if x2<0 then x2:=0;
    if y2<0 then y2:=0;

    dy := y2 - y1;
    dx := x2 - x1;

    if (dy < 0) then begin dy := -dy; stepy := -1 end else stepy := 1;
    if (dx < 0) then begin dx := -dx; stepx := -1 end else stepx := 1;
    dy := dy + dy;        // dy is now 2*dy
    dx := dx + dx;        // dx is now 2*dx

    PutPixel(x1,y1);

    if (dx > dy) then begin

        fraction := dy shl 1 - dx;

        while (x1 <> x2) do begin
           if (fraction >= 0) then begin
               inc(y1, stepy);
               dec(fraction,dx);		// same as fraction -= 2*dx
           end;
           inc(x1, stepx);
           inc(fraction, dy);			// same as fraction -= 2*dy

	   PutPixel(x1, y1);
        end;

     end else begin

        fraction := dx shl 1 - dy;

        while (y1 <> y2) do begin
           if (fraction >= 0) then begin
               inc(x1, stepx);
               dec(fraction, dy);
           end;
           inc(y1, stepy);
           inc(fraction, dx);

           PutPixel(x1, y1);
        end;
     end;

end;


procedure fLine(x0,y0,x1,y1: byte); assembler;
// DRAWTO in Graphics 8, 9, 15
// A quick hack by eru
asm
{
dx	= ztmp
dy	= ztmp+1
tmp	= ztmp+2
todo	= ztmp+3

PIXEL	.MACRO
	ldy adr.div4,x
	lda (bp2),y
	.def :1 = *
	ora adr.color_bits,x
	sta (bp2),y
	.ENDM

PREPARE	.MACRO
	sta todo
	inc todo
	lsr @
	sta tmp
	.ENDM

; ==========================================================================
drawto
	txa:pha

; check if going right (x1 <= x0)
	ldx x1
	cpx x0
	bcs right
; going left, swap points
	lda x0
	stx x0
	sta x1
	tax
	ldy y0
	lda y1
	sty y1
	sta y0
right
; compute X delta
	txa
	sec
	sbc x0
	sta dx
; set initial line address
	ldy y0
	lda adr.lineLo,y
	add #0
lfb	equ *-1
	sta bp2
	lda adr.lineHi,y
	adc #0
hfb	equ *-1
	sta bp2+1

; remember x0 in X
	ldx x0
; check if going up or down
	cpy y1
	jcc down

; ----------------------------- UP ----------------------------------
up
; compute Y delta
	lda y0
	sec
	sbc y1
	sta dy
; check if UP UP RIGHT or UP RIGHT RIGHT
	cmp dx
	bcs up_up_right
up_right_right
	lda dx
	PREPARE urr_color
urr_loop
	PIXEL urr_color
	inx			; go 1 pixel right
	lda tmp
	sec
	sbc dy
	sta tmp
	bcs urr_skip
	adc dx
	sta tmp
	lda bp2			; go 1 line up
	sec
	sbc #0
w0	equ *-1
	sta bp2
	bcs *+4
	dec bp2+1
urr_skip
	dec todo
	bne urr_loop

stop_	jmp stop

up_up_right
	lda dy
	PREPARE uur_color
uur_loop
	PIXEL uur_color
	lda bp2	; go 1 line up
	sec
	sbc #0
w1	equ *-1
	sta bp2
	bcs *+4
	dec bp2+1
	lda tmp
	sec
	sbc dx
	bcs uur_skip
	adc dy
	inx			; go 1 pixel right
uur_skip
	sta tmp
	dec todo
	bne uur_loop

	jmp stop

; ----------------------------- DOWN ----------------------------------
down
; compute Y delta
	lda y1
	sec
	sbc y0
	sta dy
; check if DOWN DOWN RIGHT or DOWN RIGHT RIGHT
	cmp dx
	bcs down_down_right
down_right_right
	lda dx
	PREPARE drr_color
drr_loop
	PIXEL drr_color
	inx			; go 1 pixel right
	lda tmp
	sec
	sbc dy
	sta tmp
	bcs drr_skip
	adc dx
	sta tmp
	lda bp2			; go 1 line down
	clc
	adc #0
w2	equ *-1
	sta bp2
	bcc *+4
	inc bp2+1
drr_skip
	dec todo
	bne drr_loop

	jmp stop

down_down_right
	lda dy
	PREPARE ddr_color
ddr_loop
	PIXEL ddr_color
	lda bp2			; go 1 line down
	clc
	adc #0
w3	equ *-1
	sta bp2
	bcc *+4
	inc bp2+1
	lda tmp
	sec
	sbc dx
	bcs ddr_skip
	adc dy
	inx			; go 1 pixel right
ddr_skip
	sta tmp
	dec todo
	bne ddr_loop

stop	pla:tax
};
end;


{$i graph2.inc}


procedure LineTo(x, y: smallint);
//----------------------------------------------------------------------------------------------
// Draw a line starting from current position to a given point
//----------------------------------------------------------------------------------------------
begin

asm
{	lda y+1
	bpl _0

	lda #0
	sta y
	sta y+1
_0
	lda x+1
	bpl _1

	lda #0
	sta x
	sta x+1
_1
	cpw y main.system.ScreenHeight
	bcc _2

	sbw main.system.ScreenHeight #1 y
_2
	cpw x main.system.ScreenWidth
	bcc _3

	sbw main.system.ScreenWidth #1 x
_3
};
	Line(CurrentX, CurrentY, x,y);

	CurrentX := x;
	CurrentY := y;
end;


procedure fRectangle(x1, y1, x2, y2: Smallint);
//----------------------------------------------------------------------------------------------
// Draws a rectangle with corners at (X1,Y1) and (X2,Y2), using the current color and style
//----------------------------------------------------------------------------------------------
begin

 fLine(x1,y1,x2,y1);
 fLine(x2,y1,x2,y2);
 fLine(x1,y2,x2,y2);
 fLine(x1,y1,x1,y2);

end;


procedure FrameBuffer(a: word); assembler;
asm
{	.ifdef PutPixel
	mva a	PutPixel.lfb
	mva a+1	PutPixel.hfb
	eif

	.ifdef fLine
	mva a	fLine.lfb
	mva a+1	fLine.hfb
	eif
};
end;


procedure InitGraph(mode: byte); overload;
//----------------------------------------------------------------------------------------------
// init graphics mode
//----------------------------------------------------------------------------------------------
var window, i, width: byte;
begin

	if mode and $20<>0 then
	 width := 32
	else
	 width := 40;

	window := mode and $10;

	ScreenMode := mode;

	mode := mode and $0f;

	ScreenHeight := 192;

case mode of

3:
asm
{	mwa #40 MAIN.SYSTEM.ScreenWidth
	mwa #24 MAIN.SYSTEM.ScreenHeight

	mva #10 width

	.ifdef SetColor
	mwa #SetColor.gr15 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr15 PutPixel.mode
	.endif
};

5:
asm
{	mwa #80 MAIN.SYSTEM.ScreenWidth
	mwa #48 MAIN.SYSTEM.ScreenHeight

	mva #20 width

	.ifdef SetColor
	mwa #SetColor.gr15 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr15 PutPixel.mode
	.endif
};

7:
asm
{	mwa #160 MAIN.SYSTEM.ScreenWidth
	mwa #96 MAIN.SYSTEM.ScreenHeight

	.ifdef SetColor
	mwa #SetColor.gr15 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr15 PutPixel.mode
	.endif
};

8:
asm
{	mwa #320 MAIN.SYSTEM.ScreenWidth
;	mwa #192 MAIN.SYSTEM.ScreenHeight

	.ifdef SetColor
	mwa #SetColor.gr8 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr8 PutPixel.mode
	.endif
};

9..11:
asm
{	mwa #80 MAIN.SYSTEM.ScreenWidth
;	mwa #192 MAIN.SYSTEM.ScreenHeight

	.ifdef SetColor
	mwa #SetColor.gr9 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr9 PutPixel.mode
	.endif

	.ifdef fLine
	mva #$ea _nop
	.endif
};

15:
asm
{	mwa #160 MAIN.SYSTEM.ScreenWidth
;	mwa #192 MAIN.SYSTEM.ScreenHeight

	.ifdef SetColor
	mwa #SetColor.gr15 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr15 PutPixel.mode
	.endif
};
end;

asm
{	txa:pha

	.ifdef fLine
	lda width
	sta fLine.w0
	sta fLine.w1
	sta fLine.w2
	sta fLine.w3
	.endif


	ldy mode

	ldx #$60	; 6*16
	lda window	; %00010000 with text window
	eor #$10
	ora #2		; read

	.nowarn @graphics

; ---	init_tabs

	ldy #0
	sty bp2
	sty bp2+1
it1
	lda bp2+1
	sta adr.lineHi,y
	lda bp2
	sta adr.lineLo,y
	clc
	adc width
	sta bp2
	scc
	inc bp2+1

	iny
	bne it1

	mva #$55 _col+1

	ldx #3
	stx _and+1
	txa
l0	sta __oras,x
	asl @
	asl @
	dex
	bpl l0

	lda mode
	cmp #8
	bne it2

	mva #$ff _col+1

	ldx #7
	stx _and+1
	lda #1
l1	sta __oras,x
	asl @
	dex
	bpl l1

it2	tya
_and	and #3
	tax
	lda __oras,x
	eor #$ff
	sta adr.color_bits+$000,y ; color0
	lda __oras,x
_col	and #$55
	sta adr.color_bits+$100,y ; color1
	lda __oras,x
	and #$aa
	sta adr.color_bits+$200,y ; color2
	lda __oras,x
	and #$ff
	sta adr.color_bits+$300,y ; color3
	tya
	lsr @
_nop	lsr @
	sta adr.div4,y
	iny
	bne it2

	jmp stop

__oras	dta $c0,$30,$0c,$03
	dta 0,0,0,0

stop	pla:tax
};
	FrameBuffer(DPeek(88));
end;


{$i vbxe.inc}
{$i graph.inc}

end.
