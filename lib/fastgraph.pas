unit fastgraph;
(*
@type: unit
@name: Unit to handle screen graphics, accelerated bitmap modes
@author: Tomasz Biela (Tebe/Madteam)

@description:
<http://www.freepascal.org/docs-html/rtl/graph/index-5.html>

Marcin Żukowski (Eru/TQA): fLine
*)


{

DisplayBuffer
fLine			fast Line
fRectangle		fast Rectangle
GetPixel
HLine
InitGraph		mode: 3, 5, 7, 8, 9, 10, 11, 15
Line
LineTo
MoveTo
PutPixel
Scanline
SetBkColor
SetBuffer
SetColor

}


interface

uses	types, atari;

{$i graphh.inc}

	procedure SetDisplayBuffer(var a: TDisplayBuffer);
	procedure fLine(x0,y0,x1,y1: byte); assembler;
	procedure SetActiveBuffer(a: word); assembler; overload;
	procedure SetActiveBuffer(var a: TDisplayBuffer); overload;
	procedure fRectangle(x1, y1, x2, y2: smallint);
	procedure Hline(x0,x1,y: smallint);
	procedure LineTo(x, y: smallint);
	procedure PutPixel(x,y: smallint); assembler; register;
	function Scanline(y: smallint): PByte;
	function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
	procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);

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
(*
@description:
Sets the background color to Color
*)
asm
	sta colbaks
end;


procedure SetColor(color: byte); assembler;
(*
@description:
Sets the foreground color to Color
*)
asm
	sta GetColor

	jmp gr8
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

colorHi	dta h(adr.color_bits, adr.color_bits+$100, adr.color_bits+$200, adr.color_bits+$300)

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
end;


procedure PutPixel(x,y: smallint); assembler; register;
(*
@description:
Puts a point at (X,Y) using color Color
*)
asm
	stx @sp

	lda y+1
	bmi stop
	cmp hsh:#0	;MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp lsh:#0	;MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp hsw:#0	;MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp lsw:#0	;MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	ldy y
	lda adr.lineLo,y
	add lfb:#0
	sta :bp2

	lda adr.lineHi,y
	adc hfb:#0
	sta :bp2+1

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

	:2 lsr @
	tay

plot	lda (:bp2),y
acol	and adr.color_bits,x
	sta (:bp2),y

stop	ldx #0
@sp	equ *-1

end;


function GetPixel(x,y: smallint): byte; assembler;
(*
@description:
Return color of pixel
*)
asm
{	txa:pha

	lda y+1
	bmi error
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs error

	lda x+1
	bmi error
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs error

	ldy y
	lda adr.lineLo,y
	add lfb:#0
	sta :bp2

	lda adr.lineHi,y
	adc hfb:#0
	sta :bp2+1

	jmp gr15
mode	equ *-2


error	lda #0
	jmp stop


gr8	.local
	lda x
	tax

	lsr x+1
	ror @

	:2 lsr @
	tay

	txa
	and #7
	tax

	lda (:bp2),y
	and msk,x
	bne c1

	jmp stop

c1	lda #1
	jmp stop

msk	dta $80,$40,$20,$10,$08,$04,$02,$01

	.endl



gr15	.local

	ldx x
	ldy adr.div4,x

	txa
	and #3
	beq _0

	cmp #1
	beq _1

	cmp #2
	beq _2

_3	lda (:bp2),y
	and #$03
	jmp stop

_0	lda (:bp2),y
	and #$c0
	:6 lsr @
	jmp stop

_1	lda (:bp2),y
	and #$30
	:4 lsr @
	jmp stop

_2	lda (:bp2),y
	and #$0c
	:2 lsr @
	jmp stop

	.endl


gr9	.local

	lda x
	lsr @
	tay

	lda x
	and #1
	bne _1

_0	lda (:bp2),y
	:4 lsr @
	jmp stop

_1	lda (:bp2),y
	and #$0f
	jmp stop

	.endl

stop	sta Result

	pla:tax
};
end;


procedure Line(x1,y1,x2,y2: smallint);
(*
@description:
Bresenham line
*)
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
    dy := dy + dy;	// dy is now 2*dy
    dx := dx + dx;	// dx is now 2*dx

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


procedure Hline(x0,x1,y: smallint);
(*
@description:
Draw horizintal line, fast as possible
*)
var mode: byte;
    tmp: smallint;
begin

 if x0 > x1 then begin
  tmp:=x1;
  x1:=x0;
  x0:=tmp;
 end;

 mode:=GraphMode and $0f;

 if (mode<>5) and (mode<>7) and (mode<>15) then begin
  Line(x0,y,x1,y);
  exit;
 end;

asm
{	txa:pha

	jmp skp

error	jmp exit

skp
	lda y+1
	bmi error
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs error

	lda x0+1
	bmi error
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x0
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcc ok1

	mwa MAIN.SYSTEM.ScreenWidth x0

ok1	lda x1+1
	bmi error
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk2
	lda x1
	cmp MAIN.SYSTEM.ScreenWidth
sk2
	bcc ok2

	mwa MAIN.SYSTEM.ScreenWidth x1

ok2
	ldy y
	lda adr.lineLo,y
	add lfb:#0
	sta :bp2

	lda adr.lineHi,y
	adc hfb:#0
	sta :bp2+1


	lda GetColor
	and #3

	:2 asl @
	sta color
	tay
	lda left,y
	sta fill

	lda x0		; left edge
	and #3
	tax
	lda lmask,x
	sta lmsk
	eor #$ff
	sta _lmsk
	txa
	add #0
color	equ *-1
	tax
	lda left,x
	sta lcol

	lda x0
	:2 lsr @
	tay
	sty lf

	lda x1		; right edge
	and #3
	tax
	lda rmask,x
	sta rmsk
	eor #$ff
	sta _rmsk
	txa
	add color
	tax
	lda right,x
	sta rcol

	lda x1
	:2 lsr @
	tay
	sty rg

	ldy #0
lf	equ *-1
	cpy rg
	beq piksel

	lda (:bp2),y
	and #0
lmsk	equ *-1
	ora #0
lcol	equ *-1
	sta (:bp2),y

	lda #0
rg	equ *-1
	clc
	sbc lf
	beq stop
	tax

	lda #0
fill	equ *-1

loop	iny
	sta (:bp2),y
	dex
	bne loop

stop	iny
	lda (:bp2),y
	and #0
rmsk	equ *-1
	ora #0
rcol	equ *-1
	sta (:bp2),y

	jmp exit

lmask	dta %00000000
	dta %11000000
	dta %11110000
	dta %11111100

left	:4 brk

	dta %01010101
	dta %00010101
	dta %00000101
	dta %00000001

	dta %10101010
	dta %00101010
	dta %00001010
	dta %00000010

	dta %11111111
rmask
	dta %00111111
	dta %00001111
	dta %00000011

right	:4 brk

	dta %01000000
	dta %01010000
	dta %01010100
	dta %01010101

	dta %10000000
	dta %10100000
	dta %10101000
	dta %10101010

	dta %11000000
	dta %11110000
	dta %11111100
	dta %11111111

piksel	lda fill
	and #0
_lmsk	equ *-1
	and #0
_rmsk	equ *-1
	ora (:bp2),y
	sta (:bp2),y

exit
	pla:tax
};
end;


procedure fLine(x0,y0,x1,y1: byte); assembler;
(*
@description:

DRAWTO in Graphics 8, 9, 15
A quick hack by eru
*)

asm
{
dx	= ztmp
dy	= ztmp+1
tmp	= ztmp+2
todo	= ztmp+3

PIXEL	.MACRO
	ldy adr.div4,x
	lda (:bp2),y
	.def :1 = *
	ora adr.color_bits,x
	sta (:bp2),y
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
	add lfb:#0
	sta :bp2
	lda adr.lineHi,y
	adc hfb:#0
	sta :bp2+1

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
	lda :bp2		; go 1 line up
	sec
	sbc #0
w0	equ *-1
	sta :bp2
	bcs *+4
	dec :bp2+1
urr_skip
	dec todo
	bne urr_loop

stop_	jmp stop

up_up_right
	lda dy
	PREPARE uur_color
uur_loop
	PIXEL uur_color
	lda :bp2		; go 1 line up
	sec
	sbc #0
w1	equ *-1
	sta :bp2
	bcs *+4
	dec :bp2+1
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
	lda :bp2		; go 1 line down
	clc
	adc #0
w2	equ *-1
	sta :bp2
	bcc *+4
	inc :bp2+1
drr_skip
	dec todo
	bne drr_loop

	jmp stop

down_down_right
	lda dy
	PREPARE ddr_color
ddr_loop
	PIXEL ddr_color
	lda :bp2		; go 1 line down
	clc
	adc #0
w3	equ *-1
	sta :bp2
	bcc *+4
	inc :bp2+1
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


function Scanline(y: smallint): PByte;
(*
@description:

*)
var i: byte;
begin

 i:=y;

 if y < 0 then i:=0 else
  if y >= ScreenHeight then i:=ScreenHeight-1;

 Result:=pointer(VideoRam + lineLo[i] + lineHi[i] shl 8);

end;



procedure LineTo(x, y: smallint);
(*
@description:
Draw a line starting from current position to a given point
*)
begin

asm
	lda y+1
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
end;

	Line(CurrentX, CurrentY, x,y);

	CurrentX := x;
	CurrentY := y;
end;


procedure fRectangle(x1, y1, x2, y2: Smallint);
(*
@description:
Draws a rectangle with corners at (X1,Y1) and (X2,Y2), using the current color and style
*)
begin

 fLine(x1,y1,x2,y1);
 fLine(x2,y1,x2,y2);
 fLine(x1,y2,x2,y2);
 fLine(x1,y1,x1,y2);

end;


procedure SetActiveBuffer(a: word); assembler; overload;
(*
@description:

*)
asm
	lda a
	ldy a+1

	sta VideoRam
	sty VideoRam+1

	.ifdef PutPixel
	 sta PutPixel.lfb
	 sty PutPixel.hfb
	eif

	.ifdef GetPixel
	 sta GetPixel.lfb
	 sty GetPixel.hfb
	eif

	.ifdef HLine
	 sta HLine.lfb
	 sty HLine.hfb
	eif

	.ifdef fLine
	 sta fLine.lfb
	 sty fLine.hfb
	eif

	.ifdef PutPixel
	 lda WIN_RIGHT
	 sta PutPixel.lsw
	 lda WIN_RIGHT+1
	 sta PutPixel.hsw

	 lda WIN_BOTTOM
	 sta PutPixel.lsh
	 lda WIN_BOTTOM+1
	 sta PutPixel.hsh
	eif

end;


procedure SetActiveBuffer(var a: TDisplayBuffer); overload;
(*
@description:

*)
begin

 SetActiveBuffer(a.bp);

end;


procedure InitGraph(mode: byte); overload;
(*
@description:
Init graphics mode
*)

const
	tlshc: array [0..15] of byte = ($03,$02,$02,$01,$01,$02,$02,$03,$03,$03,$03,$03,$03,$03,$02,$03);	// $EE6D: Table Left SHift Columns
	tmccn: array [0..15] of byte = ($28,$14,$14,$28,$50,$50,$A0,$A0,$40,$50,$50,$50,$28,$28,$A0,$A0);	// $EE7D: Table Mode Column CouNts
	tmrcn: array [0..15] of byte = ($18,$18,$0C,$18,$30,$30,$60,$60,$C0,$C0,$C0,$C0,$18,$0C,$C0,$C0);	// $EE8D: Table Mode Row CouNts

var width: byte;

begin
	GraphMode := mode;

	width := mode and $0f;

case width of

6,8:
 asm
	.ifdef SetColor
	mwa #SetColor.gr8 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr8 PutPixel.mode
	.endif

	.ifdef GetPixel
	mwa #GetPixel.gr8 GetPixel.mode
	.endif
 end;

9..11:
 asm
	.ifdef SetColor
	mwa #SetColor.gr9 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr9 PutPixel.mode
	.endif

	.ifdef GetPixel
	mwa #GetPixel.gr9 GetPixel.mode
	.endif

	.ifdef fLine
	mva #$ea _nop
	.endif
 end;

else

 asm
	.ifdef SetColor
	mwa #SetColor.gr15 SetColor.mode
	.endif

	.ifdef PutPixel
	mwa #PutPixel.gr15 PutPixel.mode
	.endif

	.ifdef GetPixel
	mwa #GetPixel.gr15 GetPixel.mode
	.endif
 end;

end;


asm
	txa:pha

	lda mode
	and #$0f
	tay

	ldx #$60	; 6*16
	lda mode	; %00010000 with text window
	and #$10
	eor #$10
	ora #2		; read

	.nowarn @GRAPHICS

	sty GraphResult


	.ifdef MAIN.@DEFINES.ROMOFF
	inc portb
	.endif

; Fox/TQA

dindex	equ $57

	ldx dindex
	lda adr.tmccn,x
	ldy adr.tmrcn,x
	ldx #0
	cmp #<320
	sne:inx

; X:A = horizontal resolution
; Y = vertical resolution

	sta MAIN.SYSTEM.ScreenWidth
	stx MAIN.SYSTEM.ScreenWidth+1

	sub #1
	sta WIN_RIGHT
	txa
	sbc #0
	sta WIN_RIGHT+1

	sty MAIN.SYSTEM.ScreenHeight
	lda #0
	sta MAIN.SYSTEM.ScreenHeight+1

	sta WIN_LEFT
	sta WIN_LEFT+1
	sta WIN_TOP
	sta WIN_TOP+1

	sta WIN_BOTTOM+1
	dey
	sty WIN_BOTTOM


	ldx dindex
	ldy adr.tlshc,x
	lda #5
shift	asl @
	dey
	bne shift

	sta width
;	sta SCANLINE_WIDTH

	.ifdef fLine
;	lda width
	sta fLine.w0
	sta fLine.w1
	sta fLine.w2
	sta fLine.w3
	.endif

	.ifdef MAIN.@DEFINES.ROMOFF
	dec portb
	.endif


; ---	init_tabs

	ldy #0
	sty :bp2
	sty :bp2+1
it1
	lda :bp2+1
	sta adr.lineHi,y
	lda :bp2
	sta adr.lineLo,y
	clc
	adc width
	sta :bp2
	scc
	inc :bp2+1

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
	and #$0f
	cmp #8
	beq x8
	cmp #6
	beq x8

	jmp it2
x8
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
end;

	SetActiveBuffer(savmsc);
end;


procedure InitGraph(driver, mode: byte; dev: PByte); overload;
begin

InitGraph(mode);

asm
	lda driver
	bpl stop

	txa:pha

	jsr @vbxe_detect
	bcc ok

	ldx #grNoInitGraph
	bne status

ok	jsr @vbxe_init

	ldx #grOK
status	stx GraphResult

	pla:tax
stop

end;

end;


{$i graph3.inc}

{$i vbxe.inc}
{$i graph.inc}

end.
