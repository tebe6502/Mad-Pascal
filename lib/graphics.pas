unit graphics;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Unit to handle HiRes bitmap graphics, proportional fonts
 @version: 1.0

 @description:
*)

{

Font
FontInitialize
FillRect
TextOut
TextWidth
MoveTo
LineTo

}


interface

type	TBrushBitmap = array [0..7] of byte;

	TPen = record
		dummy:cardinal;
		Color: Byte;
		end;

	TBrush = record
		Bitmap: ^TBrushBitmap;

		Mode,
		Color: Byte;
		end;


	TCanvas = Object

	base: word;

	fdata: array [0..1023] of byte;
	fsize: array [0..127] of byte;

	Pen: TPen;

	Brush: TBrush;

	constructor Create;

	procedure Font(Charset: pointer); overload;
	function Font(const Charset: TString): Boolean; overload;
	procedure FontInitialize; assembler;
	procedure FillRect(R: TRect);
	procedure TextOut(X,Y: smallint; const Txt: string); overload;
	procedure TextOut(X,Y: smallint; const ch: char); overload;
	function TextWidth(const Txt: string): word; assembler; overload;
	function TextWidth(const ch: char): byte; assembler; overload;
	procedure MoveTo(x, y: smallint);
	procedure LineTo(x,y: smallint);

	end;


const
	bmOra = 0;
	bmAnd = 1;
	bmXor = 2;

//	bsSolid = 0;
//	bsClear = 1;
//	bsHorizontal
//	bsVertical
//	bsFDiagonal
//	bsBDiagonal
//	bsCross
//	bsDiagCross


implementation

uses sysutils, graph, types;

const
	tMode: array [0..2] of byte = ($11,$31,$51);	// ora, and, eor


procedure TCanvas.MoveTo(x,y: smallint);
(*
@description:
*)
begin

 SetColor(Pen.Color);

 MoveTo(x,y);

end;


procedure TCanvas.LineTo(x,y: smallint);
(*
@description:
*)
begin

 SetColor(Pen.Color);

 LineTo(x,y);

end;


procedure TCanvas.FillRect(R: TRect);
(*
@description:
*)
var lpos: word;
    i: smallint;

procedure HLine(x0,x1, y: smallint); assembler;
asm
	txa:pha

	mwa brush :bp2
	ldy #brush.mode-DATAORIGIN
	lda (:bp2),y
	tax
	lda adr.tMode,x
	sta mode0
	sta mode1
	sta mode2

	ldy #brush.bitmap-DATAORIGIN
	lda (:bp2),y
	sta _brush
	iny
	lda (:bp2),y
	sta _brush+1

	lda y
	and #7
	tax

	ldy #brush.color-DATAORIGIN
	lda (:bp2),y

	seq
	lda #$ff

	and $ffff,x
_brush	equ *-2

	sta fill

	mwa lpos ztmp

	lda x0		; left edge
	and #7
	tax
	lda lmask,x
	sta lmsk

	lda x0
	lsr x0+1
	ror @
	lsr x0+1
	ror @
	lsr x0+1
	ror @
	tay
	sty lf

	lda x1		; right edge
	and #7
	tax
	lda rmask,x
	sta rmsk

	lda x1
	lsr x1+1
	ror @
	lsr x1+1
	ror @
	lsr x1+1
	ror @
	tay
	sty rg

	ldy #0
lf	equ *-1
	cpy rg
	beq piksel

	lda fill
	and #0
lmsk	equ *-1

mode0	ora (ztmp),y
	sta (ztmp),y

	iny

loop	cpy #0
rg	equ *-1
	bcs stop

	lda #0
fill	equ *-1

mode1	ora (ztmp),y
	sta (ztmp),y

	iny
	bne loop
stop
	lda fill
	and #0
rmsk	equ *-1

	jmp mode2

lmask	dta %11111111
	dta %01111111
	dta %00111111
	dta %00011111
	dta %00001111
	dta %00000111
	dta %00000011
	dta %00000001

rmask	dta %10000000
	dta %11000000
	dta %11100000
	dta %11110000
	dta %11111000
	dta %11111100
	dta %11111110
	dta %11111111

piksel
	lda fill
	and lmsk
	and rmsk

mode2	ora (ztmp),y
	sta (ztmp),y

exit
	pla:tax
end;


begin

 NormalizeRect(r);

 if r.Left < 0 then r.Left:=0;
 if r.Top < 0 then r.Top:=0;
 if r.Right > smallint(319) then r.Right:=319;
 if r.Bottom > 191 then r.Bottom:=191;

 lpos:=r.top*40+base;

 for i:=R.Top to R.Bottom do begin
  HLine(r.Left, r.Right, i);

  inc(lpos, 40);
 end;

end;


procedure TCanvas.TextOut(X,Y: smallint; const Txt: string); overload;
(*
@description:
*)
var lpos: word;
    i, xpos, pix: byte;

const tpix: array [0..7] of byte = ($80,$40,$20,$10,$08,$04,$02,$01);

procedure DrawChar(ch: byte); assembler;
asm
scr	= edx

	txa:pha

	mva #$00 scr

	lda ch

	jsr @ata2int

	tax

	asl @
	rol scr
	asl @
	rol scr
	asl @
	rol scr

	add fdata
	sta fptr
	lda scr
	adc fdata+1
	sta fptr+1

	mwa pen :bp2
	ldy #pen.color-DATAORIGIN
	lda (:bp2),y

	beq color0

color1	ldy #$00
	lda #$11	// ora
	bne setPen

color0	ldy #$ff
	lda #$31	// and

setPen	sta mode
	sty pcol


	mwa fsize _fsiz

	lda $ffff,x
_fsiz	equ *-2
	sta fwd

	; Get X/Y pos
	ldy	xpos
	ldx	#0

column:
	lda	lpos
	sta	scr
	lda	lpos+1
	sta	scr+1

	lda	$ffff,x
fptr	equ *-2
	pha

	; Plot 8 pixels
ploop:
	pla
	beq	end_pix
	lsr
	pha
	bcc	no_pix

	lda #$0
pcol	equ *-1
	eor pix

mode	ora	(scr),y
	sta	(scr), y

no_pix:
	lda	scr
	clc
	adc	#40
	sta	scr
	bcc	ploop
	inc	scr+1
	bcs	ploop

end_pix:
	jsr	next_pix
	inx
	cpx #0
fwd	equ *-1
	bne column

	jsr	next_pix
	sty	xpos

	jmp quit

next_pix:

	; Next H pixel
	lsr	pix
	bcc	no_inc
	ror	pix
	iny
	cpy	#40
	bcc	no_inc

	ldy	#0
	lda	lpos
	adc	#<(40 * 8) - 1
	sta	lpos
	lda	lpos+1
	adc	#>(40 * 8)
	sta	lpos+1

no_inc:
	rts
quit
	pla:tax
end;


begin

 if (X >= 0) and (X < ScreenWidth) then
  if (Y >= 0) and (Y < ScreenHeight) then begin

   lpos:=base + byte(y)*40;
   xpos:=word(x) shr 3;
   pix:=tpix[x and 7];

   for i:=1 to length(Txt) do DrawChar(byte(Txt[i]));

  end;

end;


procedure TCanvas.TextOut(X,Y: smallint; const ch: char); overload;
(*
@description:
*)
var s: string[1];
begin

 s:=ch;
 TCanvas.TextOut(X,Y, s);

end;


function TCanvas.TextWidth(const Txt: string): word; assembler; overload;
(*
@description:
*)
asm
	txa:pha

	mwa fsize _fsiz

	ldy #$ff
	sty Result
	sty Result+1

	iny

lp	cpy adr.Txt
	beq stop

	inw Result

	iny
	lda adr.Txt,y

	jsr @ata2int

	tax

	lda $ffff,x
_fsiz	equ *-2

	add Result
	sta Result
	scc
	inc Result+1

	jmp lp

stop	pla:tax
end;


function TCanvas.TextWidth(const ch: char): byte; assembler; overload;
(*
@description:
*)
asm
	mwa fsize ztmp

	lda ch

	jsr @ata2int

	tay

	lda (ztmp),y

	sta Result
end;


procedure TCanvas.FontInitialize; assembler;
(*
@description:
*)
asm
scr	= eax
xpos	= eax+2
lpos	= edx
pix	= edx+2

	txa:pha

	mwa fdata scr
	mwa fsize _fsiz

	lda #0
	sta xpos
loop
	ldx #0
	txa

	ldy #7
	ora:rpl (scr),y-

	sta lpos

	cmp #0
	beq space

	bmi NOshft

lp	inx
	asl @
	bpl lp

	sta lpos

shft	ldy #7
lp_	lda (scr),y
	asl @
	sta (scr),y
	dey
	bpl lp_

	dex
	bne shft
NOshft
	lda #9
	sta size

	lda lpos

slp	dec size
	lsr @
	bcc slp

	dta $2c	; bit

space	lda #3
	sne

skp	lda #0
size	equ *-1

	ldx xpos
	sta $ffff,x
_fsiz	equ *-2

	ldx #7

flp	mwa #shf0 _jmp

	ldy #7
	lda #0
	sta pix

flip	lda (scr),y
	and #$80

	jmp shf0
_jmp	equ *-2

shf7	lsr @
shf6	lsr @
shf5	lsr @
shf4	lsr @
shf3	lsr @
shf2	lsr @
shf1	lsr @
shf0	ora pix
	sta pix
	lda (scr),y
	asl @
	sta (scr),y

	dew _jmp

	dey
	bpl flip

	lda pix

	pha

	dex
	bpl flp


	ldy #7
mv	pla
	sta (scr),y
	dey
	bpl mv

	adw scr #8

	inc xpos
	jpl loop

	pla:tax
end;



constructor TCanvas.Create;
(*
@description:
*)
var br: TBrushBitmap = ($ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff);
begin

 base:=dpeek(88);

 move(pointer(peek(756) shl 8), fdata, 1024);

 brush.bitmap:=@br;

 TCanvas.FontInitialize;

end;


procedure TCanvas.Font(Charset: pointer); overload;
(*
@description:
*)
begin

 move(charset, fdata, 1024);

 TCanvas.FontInitialize;

end;


function TCanvas.Font(const Charset: TString): Boolean; overload;
(*
@description:
*)
var s: TString;
    f: file;
begin

 s:=concat('D:', AnsiUpperCase(Charset));
 s:=concat(s,'.FNT');

 if not FileExists(s) then

  Result := false

 else begin

  assign(f, s); reset(f,1);
  blockread(f, fdata, 1024);
  close(f);

  Result:=(IOResult < 128);

  TCanvas.FontInitialize;
 end;

end;


initialization

  InitGraph(8 + 16);

end.
