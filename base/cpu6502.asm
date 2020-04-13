	opt l-

/* -----------------------------------------------------------------------
/*                          	 CPU 6502
/*			        19.04.2018
/* -----------------------------------------------------------------------
/* 16.03.2019	poprawka dla @printPCHAR, @printSTRING gdy [YA] = 0
/* 29.02.2020	optymalizacja @printREAL, pozbycie sie 
/*		'jsr mov_BYTE_DX', 'jsr mov_WORD_DX', 'jsr mov_CARD_DX'
/* 07.04.2020	negSHORT, @TRUNC_SHORT, @ROUND_SHORT, @FRAC_SHORT, @INT_SHORT
/* -----------------------------------------------------------------------

@AllocMem
@ClrScr
@CmdLine
@COMMAND
@GRAPHICS
@GetLine
@GetKey

*/

// IORESULT = 106	Invalid numeric format

; wiersz obrazu dla mapy kolorow VBXE = 256 bajtow (40*4 + ...)
; szerokosc linii obrazu dla OVERLAY = 320

FX_VIDEO_CONTROL equ    0x40
FX_VC		equ    FX_VIDEO_CONTROL
VC_XDL_ENABLED	equ     1
VC_XCOLOR	equ     2
VC_NTR		equ     4
VC_NO_TRANS	equ     VC_NTR
VC_TRANS15	equ     8

; Palette registers
FX_CSEL         equ     0x44
FX_PSEL         equ     0x45
FX_CR           equ     0x46
FX_CG           equ     0x47
FX_CB           equ     0x48

; Raster collision detection
FX_COLMASK      equ     0x49
FX_COLCLR       equ     0x4a
FX_COLDETECT    equ     0x4a

; XDL Address
FX_XDL_ADR0     equ     0x41
FX_XDL_ADR1     equ     0x42
FX_XDL_ADR2     equ     0x43
VBXE_MINOR	equ	0x41

; MEMAC-A / MEMAC-B registers
FX_MEMAC_B_CONTROL equ	0x5d
FX_MEMB            equ	FX_MEMAC_B_CONTROL
FX_MEMAC_CONTROL   equ	0x5e
FX_MEMC            equ	FX_MEMAC_CONTROL
FX_MEMAC_BANK_SEL  equ	0x5f
FX_MEMS            equ	FX_MEMAC_BANK_SEL

; Blitter registers
FX_BL_ADR0	equ	0x50
FX_BL_ADR1	equ	0x51
FX_BL_ADR2	equ	0x52
FX_BLITTER_START equ	0x53
FX_BLT_COL_CODE	equ	0x50
FX_BLT_COLLISION_CODE equ FX_BLT_COL_CODE
FX_BLITTER_BUSY	equ	0x53

; Blitter IRQ
FX_IRQ_CONTROL   equ	0x54
FX_IRQ_STATUS    equ	0x54

; Info registers (read only)
FX_CORE_VERSION   equ	0x40
FX_MINOR_REVISION equ	0x41

; Priority registers
FX_P0		 equ	0x55
FX_P1		 equ	0x56
FX_P2		 equ	0x57
FX_P3		 equ	0x58

FX_CORE_RESET   equ	0xD080

; XDLC bits
XDLC_TMON	equ     1
XDLC_GMON	equ     2
XDLC_OVOFF	equ     4
XDLC_MAPON	equ     8
XDLC_MAPOFF	equ     0x10
XDLC_RPTL	equ     0x20
XDLC_OVADR	equ     0x40
XDLC_OVSCRL	equ     0x80
XDLC_CHBASE	equ     0x100
XDLC_MAPADR	equ     0x200
XDLC_MAPPAR	equ     0x400
XDLC_OVATT	equ     0x800
XDLC_ATT	equ     0x800
XDLC_HR		equ     0x1000
XDLC_LR		equ     0x2000
XDLC_END	equ     0x8000

MAXSIZE = 4
EOL	= $9B
@buf	= $0400		; lo addr = 0 !!!

fracpart = eax

/* ----------------------------------------------------------------------- */

.enum	e@xdl
	ovroff, lr, ovron, hr, mapon, mapoff
.ende

.enum	e@file
	eof = 1, open, assign
.ende

.struct	s@file
pfname	.word		; pointer to string with filename
record	.word		; record size
chanel	.byte		; channel *$10
status	.byte		; status bit 0..7
buffer	.word		; load/write buffer
nrecord	.word		; number of records for load/write
numread	.word		; pointer to variable, length of loaded data
.ends

.struct	s@xdl
.word	XDLC_		; puste linie
.byte	RPTL_
.word	XDLC
.byte	RPTL
.long	OVADR
.word	OVSTEP
.long	MAPADR
.word	MAPSTEP
.byte	HSCROL
.byte	VSCROL
.byte	WIDTH
.byte	HEIGHT
.byte	OVWIDTH
.byte	OVPRIOR
.ends

/* ----------------------------------------------------------------------- */

.macro	m@add
	lda %%1
	clc
	adc %%2
	sta %%3
.endm

.macro	m@adc
	lda %%1
	adc %%2
	sta %%3
.endm

.macro	m@sub
	lda %%1
	sec
	sbc %%2
	sta %%3
.endm

.macro	m@sbc
	lda %%1
	sbc %%2
	sta %%3
.endm


.macro	m@index2 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm

.macro	m@index4 (Ofset)
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
	asl :STACKORIGIN-%%Ofset,x
	rol :STACKORIGIN-%%Ofset+STACKWIDTH,x
.endm

; store value in fx register (via accumulator)
fxs     .macro

        lda     :2
        ldy     #:1
        sta     (fxptr),y

        .endm

; store accumulator in fx register
fxsa    .macro

        ldy     #:1
        sta     (fxptr),y

        .endm

; load fx register value to accumulator
fxla    .macro

        ldy     #:1
        lda     (fxptr),y

        .endm

/* ----------------------------------------------------------------------- */

	icl 'atari.hea'

/* ----------------------------------------------------------------------- */


.proc	hiBYTE
	lda :STACKORIGIN,x
	:4 lsr @
	sta :STACKORIGIN,x
	rts
.endp

.proc	hiWORD
	lda :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN,x
	rts
.endp

.proc	hiCARD
	lda :STACKORIGIN+STACKWIDTH*3,x
	sta :STACKORIGIN+STACKWIDTH,x

	lda :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN,x
	rts
.endp


.proc	movaBX_EAX		; mov [BX], EAX
	:MAXSIZE mva eax+# :STACKORIGIN-1+#*STACKWIDTH,x
	rts
.endp

/*
.proc	@pushBYTE
	adc :STACKORIGIN+STACKWIDTH,x
	sta bp+1

	mva (bp),y :STACKORIGIN,x

;	lda #$00
;	sta :STACKORIGIN+STACKWIDTH,x
;	sta :STACKORIGIN+STACKWIDTH*2,x
;	sta :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp


.proc	@pullWORD (.word ya) .reg
	add :STACKORIGIN-1,x
	sta bp2
	tya
	adc :STACKORIGIN-1+STACKWIDTH,x
	sta bp2+1

	ldy #$00

	mva :STACKORIGIN,x (bp2),y
	iny
	mva :STACKORIGIN+STACKWIDTH,x (bp2),y

	rts
.endp


.proc	@pullCARD (.word ya) .reg
	add :STACKORIGIN-1,x
	sta bp2
	tya
	adc :STACKORIGIN-1+STACKWIDTH,x
	sta bp2+1

	ldy #$00

	mva :STACKORIGIN,x (bp2),y
	iny
	mva :STACKORIGIN+STACKWIDTH,x (bp2),y
	iny
	mva :STACKORIGIN+STACKWIDTH*2,x (bp2),y
	iny
	mva :STACKORIGIN+STACKWIDTH*3,x (bp2),y

	rts
.endp


.proc	@pushWORD (.word ya) .reg
	add :STACKORIGIN,x
	sta bp2
	tya
	adc :STACKORIGIN+STACKWIDTH,x
	sta bp2+1

	ldy #$00

	mva (bp2),y :STACKORIGIN,x
	iny
	mva (bp2),y :STACKORIGIN+STACKWIDTH,x

	rts
.endp


.proc	@pushCARD (.word ya) .reg
	add :STACKORIGIN,x
	sta bp2
	tya
	adc :STACKORIGIN+STACKWIDTH,x
	sta bp2+1

	ldy #$00

	mva (bp2),y :STACKORIGIN,x
	iny
	mva (bp2),y :STACKORIGIN+STACKWIDTH,x
	iny
	mva (bp2),y :STACKORIGIN+STACKWIDTH*2,x
	iny
	mva (bp2),y :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp
*/

.proc	shlEAX_CL

;SHORT	jsr @expandToCARD1.SHORT
;	jmp CARD

;SMALL	jsr @expandToCARD1.SMALL
;	jmp CARD

BYTE	lda #0
	sta :STACKORIGIN-1+STACKWIDTH,x

WORD	lda #0
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

CARD	clc
	ldy :STACKORIGIN,x	; cl
	beq stop
@	asl :STACKORIGIN-1,x	; eax
	rol :STACKORIGIN-1+STACKWIDTH,x
	rol :STACKORIGIN-1+STACKWIDTH*2,x
	rol :STACKORIGIN-1+STACKWIDTH*3,x
	dey
	bne @-

stop	rts
.endp


.proc	shrAL_CL

;SHORT	jsr @expandToCARD1.SHORT
;	jmp shrEAX_CL

BYTE	ldy :STACKORIGIN,x	; cl
	beq stop
@	lsr :STACKORIGIN-1,x
	dey
	bne @-

stop	lda #0
	sta :STACKORIGIN-1+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp

.proc	shrAX_CL

;SMALL	jsr @expandToCARD1.SMALL
;	jmp shrEAX_CL

WORD	ldy :STACKORIGIN,x	; cl
	beq stop
@	lsr :STACKORIGIN-1+STACKWIDTH,x
	ror :STACKORIGIN-1,x
	dey
	bne @-

stop	lda #0
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp

.proc	shrEAX_CL

	ldy :STACKORIGIN,x	; cl
	beq stop
@	lsr :STACKORIGIN-1+STACKWIDTH*3,x
	ror :STACKORIGIN-1+STACKWIDTH*2,x
	ror :STACKORIGIN-1+STACKWIDTH,x
	ror :STACKORIGIN-1,x
	dey
	bne @-

stop	rts
.endp

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; wynik operacji ADD zostanie potraktowany jako INTEGER / CARDINAL
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

.proc	addAL_CL

	ldy #0

	sty :STACKORIGIN-1+STACKWIDTH*2,x
	sty :STACKORIGIN-1+STACKWIDTH*3,x

	lda :STACKORIGIN-1,x
	add :STACKORIGIN,x
	sta :STACKORIGIN-1,x
	scc
	iny

	sty :STACKORIGIN-1+STACKWIDTH,x

	rts
.endp

.proc	addAX_CX

	ldy #0

	sty :STACKORIGIN-1+STACKWIDTH*3,x

	lda :STACKORIGIN-1,x
	add :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	lda :STACKORIGIN-1+STACKWIDTH,x
	adc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x
	scc
	iny

	sty :STACKORIGIN-1+STACKWIDTH*2,x

	rts
.endp


.proc	addEAX_ECX
/*
SHORT	jsr @expandToCARD.SHORT
	jsr @expandToCARD1.SHORT
	jmp CARD

SMALL	jsr @expandToCARD.SMALL
	jsr @expandToCARD1.SMALL
*/
CARD	lda :STACKORIGIN-1,x
	add :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	lda :STACKORIGIN-1+STACKWIDTH,x
	adc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda :STACKORIGIN-1+STACKWIDTH*2,x
	adc :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda :STACKORIGIN-1+STACKWIDTH*3,x
	adc :STACKORIGIN+STACKWIDTH*3,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	subAL_CL

	ldy #0

	lda :STACKORIGIN-1,x
	sub :STACKORIGIN,x
	sta :STACKORIGIN-1,x
	scs
	dey

	sty :STACKORIGIN-1+STACKWIDTH,x
	sty :STACKORIGIN-1+STACKWIDTH*2,x
	sty :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp

.proc	subAX_CX

	ldy #0

	lda :STACKORIGIN-1,x		; ax
	sub :STACKORIGIN,x		; cx
	sta :STACKORIGIN-1,x

	lda :STACKORIGIN-1+STACKWIDTH,x
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x
	scs
	dey

	sty :STACKORIGIN-1+STACKWIDTH*2,x
	sty :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp

.proc	subEAX_ECX

	lda :STACKORIGIN-1,x
	sub :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	lda :STACKORIGIN-1+STACKWIDTH,x
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda :STACKORIGIN-1+STACKWIDTH*2,x
	sbc :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda :STACKORIGIN-1+STACKWIDTH*3,x
	sbc :STACKORIGIN+STACKWIDTH*3,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	@expandSHORT2SMALL
	lda :STACKORIGIN,x
	ora #$7f
	smi
	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x

	rts
.endp

.proc	@expandSHORT2SMALL1
	lda :STACKORIGIN-1,x
	ora #$7f
	smi
	lda #$00
	sta :STACKORIGIN-1+STACKWIDTH,x

	rts
.endp


.proc	@expandToCARD

SMALL	lda :STACKORIGIN+STACKWIDTH,x
	bpl WORD

	lda #$ff
	bne _wo

WORD	lda #$00
	beq _wo

SHORT	lda :STACKORIGIN,x
	bpl BYTE

	lda #$ff
	bne _by

BYTE	lda #$00

_by	sta :STACKORIGIN+STACKWIDTH,x
_wo	sta :STACKORIGIN+STACKWIDTH*2,x
_lo	sta :STACKORIGIN+STACKWIDTH*3,x
	rts
.endp


.proc	@expandToCARD1

SMALL	lda :STACKORIGIN-1+STACKWIDTH,x
	bpl WORD

	lda #$ff
	bne _wo

WORD	lda #$00
	beq _wo

SHORT	lda :STACKORIGIN-1,x
	bpl BYTE

	lda #$ff
	bne _by

BYTE	lda #$00

_by	sta :STACKORIGIN-1+STACKWIDTH,x
_wo	sta :STACKORIGIN-1+STACKWIDTH*2,x
_lo	sta :STACKORIGIN-1+STACKWIDTH*3,x
	rts
.endp


; Piotr Fusik, 15.04.2002
; originally by Ullrich von Bassewitz

.proc	cmpSHORTINT
	lda	:STACKORIGIN-1,x
	sub	:STACKORIGIN,x
	bne     @L4
@L3	rts

@L4:    bvc     @L3
	eor     #$FF		; Fix the N flag if overflow
	ora     #$01		; Clear the Z flag
	rts	
.endp


.proc	cmpSMALLINT
	lda	:STACKORIGIN-1+STACKWIDTH,x
	sub	:STACKORIGIN+STACKWIDTH,x
	bne     @L4

	lda	:STACKORIGIN-1,x
	cmp	:STACKORIGIN,x	; Compare low byte
	beq     @L3

	lda	#$00
	adc     #$FF		; If the C flag is set then clear the N flag
	ora     #$01		; else set the N flag
@L3:    rts

@L4:    bvc     @L3
	eor     #$FF		; Fix the N flag if overflow
	ora     #$01		; Clear the Z flag
	rts	
.endp


.proc	cmpINT
	lda	:STACKORIGIN-1+STACKWIDTH*3,x
	sub	:STACKORIGIN+STACKWIDTH*3,x
	bne	L4

	lda	:STACKORIGIN-1+STACKWIDTH*2,x
	cmp	:STACKORIGIN+STACKWIDTH*2,x
	bne	L1

	lda	:STACKORIGIN-1+STACKWIDTH,x
	cmp	:STACKORIGIN+STACKWIDTH,x
	bne	L1

	lda	:STACKORIGIN-1,x
	cmp	:STACKORIGIN,x

L1	beq	L2
	bcs	L3
	lda	#$FF	; Set the N flag
L2	rts

L3	lda	#$01	; Clear the N flag
	rts

L4	bvc	L5
	eor	#$FF	; Fix the N flag if overflow
	ora	#$01	; Clear the Z flag
L5	rts
.endp


.proc	cmpEAX_ECX
	lda :STACKORIGIN-1+STACKWIDTH*3,x
	cmp :STACKORIGIN+STACKWIDTH*3,x
	bne _done
	lda :STACKORIGIN-1+STACKWIDTH*2,x
	cmp :STACKORIGIN+STACKWIDTH*2,x
	bne _done
AX_CX
	lda :STACKORIGIN-1+STACKWIDTH,x
	cmp :STACKORIGIN+STACKWIDTH,x
	bne _done
	lda :STACKORIGIN-1,x
	cmp :STACKORIGIN,x

_done	rts
.endp


.proc	cmpSTRING2CHAR

	lda :STACKORIGIN-1,x
	sta ztmp8
	lda :STACKORIGIN-1+STACKWIDTH,x
	sta ztmp8+1

	lda :STACKORIGIN,x
	sta ztmp10

	ldy #0

	lda (ztmp8),y		; if length <> 1
	cmp #1
	bne fail

	iny

loop	lda (ztmp8),y
	cmp ztmp10
	bne fail

	lda #0
	seq

fail	lda #$ff

	ldy #1

	cmp #0
	rts
.endp


.proc	cmpCHAR2STRING

	lda :STACKORIGIN-1,x
	sta ztmp8

	lda :STACKORIGIN,x
	sta ztmp10
	lda :STACKORIGIN+STACKWIDTH,x
	sta ztmp10+1

	ldy #0

	lda (ztmp10),y		; if length <> 1
	cmp #1
	bne fail

	iny

loop	lda (ztmp10),y
	cmp ztmp8
	bne fail

	lda #0
	seq

fail	lda #$ff

	ldy #1

	cmp #0
	rts
.endp


/*
{   CompareText compares S1 and S2, the result is the based on
    substraction of the ascii values of characters in S1 and S2
    comparison is case-insensitive
    case     result
    S1 < S2  < 0
    S1 > S2  > 0
    S1 = S2  = 0     }

function CompareText(const S1, S2: string): Integer; overload;

var
  i, count, count1, count2: sizeint;
  Chr1, Chr2: byte;
  P1, P2: PChar;
begin
  Count1 := Length(S1);
  Count2 := Length(S2);
  if (Count1>Count2) then
    Count := Count2
  else
    Count := Count1;
  i := 0;
  if count>0 then
    begin
      P1 := @S1[1];
      P2 := @S2[1];
      while i < Count do
        begin
          Chr1 := byte(p1^);
          Chr2 := byte(p2^);
          if Chr1 <> Chr2 then
            begin
              if Chr1 in [97..122] then
                dec(Chr1,32);
              if Chr2 in [97..122] then
                dec(Chr2,32);
              if Chr1 <> Chr2 then
                Break;
            end;
          Inc(P1); Inc(P2); Inc(I);
        end;
    end;
  if i < Count then
    result := Chr1-Chr2
  else
    // CAPSIZEINT is no-op if Sizeof(Sizeint)<=SizeOF(Integer)
    result:=CAPSIZEINT(Count1-Count2);
end;
*/

.proc	cmpSTRING

	lda :STACKORIGIN-1,x
	sta ztmp8
	lda :STACKORIGIN-1+STACKWIDTH,x
	sta ztmp8+1

	lda :STACKORIGIN,x
	sta ztmp10
	lda :STACKORIGIN+STACKWIDTH,x
	sta ztmp10+1

	ldy #0
	
	lda (ztmp10),y
	sta count2
	
	lda (ztmp8),y
	sta count1

	cmp count2
	scc
	lda count2
	sta count	

	cmp #0
	beq stop

	inw ztmp8
	inw ztmp10

loop	lda (ztmp8),y
	sub (ztmp10),y
	bne fail

	iny

	cpy #0
count	equ *-1
	bne loop
stop
	ldy #1

	lda #0
count1	equ *-1
	sub #0
count2	equ *-1
	bcc fail

	rts

fail	php

	ldy #1

	plp
	rts
.endp


.proc	notaBX

	.rept MAXSIZE
	lda :STACKORIGIN+#*STACKWIDTH,x
	eor #$ff
	sta :STACKORIGIN+#*STACKWIDTH,x
	.endr

	rts
.endp


.proc	notBOOLEAN
	lda :STACKORIGIN,x
	bne _0

	lda #true
	sne

_0	lda #false
	sta :STACKORIGIN,x

	rts
.endp


.proc	negBYTE
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp

.proc	negWORD
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp

.proc	negCARD
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN+STACKWIDTH*2,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH*3,x
	sta :STACKORIGIN+STACKWIDTH*3,x

	rts
.endp


.proc	negBYTE1
	lda #$00
	sub :STACKORIGIN-1,x
	sta :STACKORIGIN-1,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp

.proc	negWORD1
	lda #$00
	sub :STACKORIGIN-1,x
	sta :STACKORIGIN-1,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda #$00
	sbc #$00
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp

.proc	negCARD1
	lda #$00
	sub :STACKORIGIN-1,x
	sta :STACKORIGIN-1,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda #$00
	sbc :STACKORIGIN-1+STACKWIDTH*3,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	andAL_CL

	lda :STACKORIGIN-1,x
	and :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	rts
.endp

.proc	andAX_CX

	.rept 2
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	and :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp

.proc	andEAX_ECX

	.rept MAXSIZE
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	and :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp


.proc	orAL_CL

	lda :STACKORIGIN-1,x
	ora :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	rts
.endp

.proc	orAX_CX

	.rept 2
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	ora :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp

.proc	orEAX_ECX

	.rept MAXSIZE
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	ora :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp


.proc	xorAL_CL

	lda :STACKORIGIN-1,x
	eor :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	rts
.endp

.proc	xorAX_CX

	.rept 2
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	eor :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp

.proc	xorEAX_ECX

	.rept MAXSIZE
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	eor :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp


/*
.proc	iniEAX_ECX_BYTE

	mva :STACKORIGIN,x ecx
	mva :STACKORIGIN-1,x eax

	rts
.endp
*/


.proc	iniEAX_ECX_WORD

	mva :STACKORIGIN,x ecx
	mva :STACKORIGIN+STACKWIDTH,x ecx+1

	mva :STACKORIGIN-1,x eax
	mva :STACKORIGIN-1+STACKWIDTH,x eax+1

	mva #$00 ecx+2
	sta ecx+3

	sta eax+2
	sta eax+3

	rts
.endp


.proc	iniEAX_ECX_CARD
	mva :STACKORIGIN,x ecx
	mva :STACKORIGIN+STACKWIDTH,x ecx+1
	mva :STACKORIGIN+STACKWIDTH*2,x ecx+2
	mva :STACKORIGIN+STACKWIDTH*3,x ecx+3

	mva :STACKORIGIN-1,x eax
	mva :STACKORIGIN-1+STACKWIDTH,x eax+1
	mva :STACKORIGIN-1+STACKWIDTH*2,x eax+2
	mva :STACKORIGIN-1+STACKWIDTH*3,x eax+3

	rts
.endp

.proc	movZTMP_aBX
	mva ZTMP8 :STACKORIGIN-1,x
	mva ZTMP9 :STACKORIGIN-1+STACKWIDTH,x
	mva ZTMP10 :STACKORIGIN-1+STACKWIDTH*2,x
	mva ZTMP11 :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


	icl '6502\cpu6502_sio.asm'
	icl '6502\cpu6502_cio.asm'

	icl '6502\cpu6502_shortint.asm'		; mul / div -> SHORTINT
	icl '6502\cpu6502_smallint.asm'		; mul / div -> SMALLINT
	icl '6502\cpu6502_integer.asm'		; mul / div -> INTEGER

	icl '6502\cpu6502_byte.asm'		; mul / div -> BYTE
	icl '6502\cpu6502_word.asm'		; mul / div -> WORD
	icl '6502\cpu6502_cardinal.asm'		; mul / div -> CARDINAL

	icl '6502\cpu6502_shortreal.asm'	; mul / div -> SHORTREAL	Q8.8
	icl '6502\cpu6502_real.asm'		; mul / div -> REAL		Q24.8
	icl '6502\cpu6502_single.asm'		; mul / div -> SINGLE		IEEE-754


.proc	@printCHAR
	ldy :STACKORIGIN,x
	jmp @print
.endp


.proc	@printEOL
	ldy #eol
	jmp @print
.endp


.proc	@print (.byte y) .reg
	txa:pha

	tya
	jsr @putchar

	pla:tax
	rts
.endp


.proc	@printPCHAR (.word ya) .reg

	cpy #0
	beq empty

	sta ztmp
	sty ztmp+1

	stx @sp

	lda #0
	sta loop+1

loop	ldy #0
	lda (ztmp),y
	beq stop

	inc loop+1
	sne
	inc ztmp+1

	jsr @putchar

	jmp loop

stop	ldx #0
@sp	equ *-1

empty	rts
.endp


.proc	@printSTRING (.word ya) .reg

	cpy #0
	beq empty

	sta ztmp
	sty ztmp+1

	stx @sp

	ldy #0
	sty loop+1
	lda (ztmp),y
	sta ln

	inw ztmp

loop	ldy #0
	lda (ztmp),y
;	beq stop

	cpy #0
ln	equ *-1
	beq stop

	inc loop+1

	jsr @putchar

	jmp loop

stop	ldx #0
@sp	equ *-1

empty	rts
.endp


.proc	@printBOOLEAN
	lda :STACKORIGIN,x
	beq _0

_1	lda <_true
	ldy >_true
	jmp @printSTRING

_0	lda <_false
	ldy >_false
	jmp @printSTRING

_true	dta 4,c'TRUE'
_false	dta 5,c'FALSE'
.endp


.proc	@printMINUS
	ldy #'-'
	jsr @printVALUE.pout

	jmp negCARD
.endp


.proc	@printSHORTREAL
	jsr @expandToCARD.SMALL
	jmp @printREAL
.endp


.proc	@FTOA

i	= edx
fra	= ecx
hlp	= eax

exp	= ztmp
b	= ztmp+1
sht	= ztmp+2

bit	= @buf+64

	stx @sp

	mva :STACKORIGIN,x I
	sta :STACKORIGIN+9
	mva :STACKORIGIN+STACKWIDTH,x I+1
	sta :STACKORIGIN+STACKWIDTH+9
	mva :STACKORIGIN+STACKWIDTH*2,x I+2
	sta :STACKORIGIN+STACKWIDTH*2+9
	mva :STACKORIGIN+STACKWIDTH*3,x I+3
	sta :STACKORIGIN+STACKWIDTH*3+9	; Sign

	bpl skp

	ldy #'-'
	jsr @printVALUE.pout

skp
; optimize OK (test_3.pas), line = 32

	lda :STACKORIGIN+STACKWIDTH*3+9
	asl :STACKORIGIN+9
	rol :STACKORIGIN+STACKWIDTH+9
	rol :STACKORIGIN+STACKWIDTH*2+9
	rol @
	sta EXP				; Exponent

; optimize OK (test_3.pas), line = 33

	lda I
	sta FRA
	lda I+1
	sta FRA+1
	lda I+2
	sta FRA+2
	lda I+3
	sta FRA+3
	asl FRA
	rol FRA+1
	rol FRA+2
	rol FRA+3

; optimize OK (test_3.pas), line = 35

	lda EXP
	sub #$7F
	sta SHT

; optimize OK (test_3.pas), line = 37

	ldx #$3f
	lda #0
	sta:rpl bit,x-

; For

; optimize OK (test_3.pas), line = 39

;	sta B
	tax

; optimize OK (test_3.pas), line = 39

l_01D4
;	lda B
;	cmp #$17
	cpx #$17
	bcc *+7
	beq *+5

; ForToDoProlog
	jmp l_01EE

; optimize OK (test_3.pas), line = 40

;	lda #$20
;	add B
;	tax

	lda FRA+2
	sta BIT+$20,x

; optimize OK (test_3.pas), line = 41

	asl FRA
	rol FRA+1
	rol FRA+2
	rol FRA+3

; ForToDoEpilog
c_01D4
;	inc B
	inx

	seq

; WhileDoEpilog
	jmp l_01D4
l_01EE
b_01D4

; optimize OK (test_3.pas), line = 44

	mva #$80 BIT+$1f

; optimize OK (test_3.pas), line = 46

	mva #$00 I
	sta I+1
	sta I+2
	sta I+3

; optimize OK (test_3.pas), line = 47

	sta FRA+1
	sta FRA+2
	sta FRA+3

	mva #$01 FRA

; For

; optimize OK (test_3.pas), line = 49

	lda SHT
	add #$1F
	sta B

; optimize OK (test_3.pas), line = 49

	tay

l_035B
;	lda B
;	cmp #$00
;	bcs *+5

; ForToDoProlog
;	jmp l_0375

; optimize OK (test_3.pas), line = 50

;	ldy B
	lda BIT,y
	bpl l_03D7

; optimize OK (test_3.pas), line = 50

	lda I				; Mantissa
	add FRA
	sta I
	lda I+1
	adc FRA+1
	sta I+1
	lda I+2
	adc FRA+2
	sta I+2
	lda I+3
	adc FRA+3
	sta I+3

; IfThenEpilog
l_03D7

; optimize OK (test_3.pas), line = 52

	asl FRA
	rol FRA+1
	rol FRA+2
	rol FRA+3

; ForToDoEpilog
c_035B
;	dec B
	dey

;	lda B
;	cmp #$ff
	cpy #$ff
	seq

; WhileDoEpilog
	jmp l_035B
l_0375
b_035B

; optimize OK (test_3.pas), line = 55

	mva #$00 FRA
	sta FRA+1
	sta FRA+2
	sta FRA+3

; optimize OK (test_3.pas), line = 56

	sta EXP

	sta hlp
	sta hlp+1

	lda #$80
	sta hlp+2
; For

; optimize OK (test_3.pas), line = 58

	lda SHT
	add #$20
;	sta B

	tay

; optimize OK (test_3.pas), line = 58

	add #23
	sta FORTMP_1273
; To
l_0508

; ForToDoCondition

; optimize OK (test_3.pas), line = 58

;	lda B
;	cmp #0
	cpy #0
FORTMP_1273	equ *-1
	bcc *+7
	beq *+5

; ForToDoProlog
	jmp l_0534

; optimize OK (test_3.pas), line = 59

;	ldy B
	lda BIT,y
	bpl l_0596

; optimize OK (test_3.pas), line = 59

	lda FRA
	add hlp
	sta FRA
	lda FRA+1
	adc hlp+1
	sta FRA+1
	lda FRA+2
	adc hlp+2
	sta FRA+2

; IfThenEpilog
l_0596

	lsr hlp+2
	ror hlp+1
	ror hlp

; ForToDoEpilog
c_0508
;	inc B						; inc ptr byte [CounterAddress]
	iny

	seq

; WhileDoEpilog
	jmp l_0508
l_0534
b_0508
	:3 mva fra+# fracpart+#

	mva #6 @float.afterpoint	; wymagana liczba miejsc po przecinku
	@float #500000

	ldx #0
@sp	equ *-1

	rts
.endp


.proc	@printREAL

	stx @sp

	lda :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr @printMINUS
	
	sta dx+2

	mva :STACKORIGIN,x fracpart+2	; intpart := uvalue shr 8
	mva :STACKORIGIN+STACKWIDTH,x dx; fracpart := uvalue and $FF (dx)
	mva :STACKORIGIN+STACKWIDTH*2,x dx+1
;	mva :STACKORIGIN+STACKWIDTH*3,x dx+2
	mva #$00 dx+3

	sta fracpart
	sta fracpart+1

	mva #4 @float.afterpoint	; wymagana liczba miejsc po przecinku
	@float #5000

	ldx #0
@sp	equ *-1
	rts
.endp


.proc	@float (.long axy) .reg

	sty cx
	stx cx+1
	sta cx+2

	lda @printVALUE.pout		; print integer part
	pha
	jsr @printVALUE
	pla
	sta @printVALUE.pout

	lda #0
	sta dx
	sta dx+1
	sta dx+2
	sta dx+3

loop	lda fracpart+2
	bpl skp

	clc
;	lda cx
;	spl
;	sec

	lda dx
	adc cx
	sta dx
	lda dx+1
	adc cx+1
	sta dx+1
	lda dx+2
	adc cx+2
	sta dx+2
;	lda dx+3
;	adc #0
;	sta dx+3

skp	lsr cx+2
	ror cx+1
	ror cx

	asl fracpart
	rol fracpart+1
	rol fracpart+2

	lda cx
	ora cx+1
	ora cx+2

	bne loop

	ldy #'.'
	jsr @printVALUE.pout

	:4 mva dx+# fracpart+#

	lda @printVALUE.pout
	pha

	lda #{rts}
	sta @printVALUE.pout
	jsr @printVALUE			; floating part length

	sta cnt

	pla
	sta @printVALUE.pout

lp	lda #0
cnt	equ *-1
	cmp #4				; N miejsc po przecinku
afterpoint equ *-1
	bcs ok

	ldy #'0'
	jsr @printVALUE.pout

	inc cnt
	bne lp

ok	:4 mva fracpart+# dx+#
	jmp @printVALUE			; print floating part

.endp


.proc	@printSHORTINT

	lda :STACKORIGIN,x
	spl
	jsr @printMINUS

	jmp @printBYTE
.endp


.proc	@printSMALLINT

	lda :STACKORIGIN+STACKWIDTH,x
	spl
	jsr @printMINUS

	jmp @printWORD
.endp


.proc	@printINT

	lda :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr @printMINUS

	jmp @printCARD
.endp


.proc	@printCARD
	mva :STACKORIGIN,x dx
	mva :STACKORIGIN+STACKWIDTH,x dx+1
	mva :STACKORIGIN+STACKWIDTH*2,x dx+2
	mva :STACKORIGIN+STACKWIDTH*3,x dx+3

	jmp @printVALUE
.endp


.proc	@printWORD
	lda :STACKORIGIN,x
	ldy :STACKORIGIN+STACKWIDTH,x 
_ay
	sta dx
	sty dx+1

	lda #$00
	sta dx+2
	sta dx+3

	jmp @printVALUE._16bit
.endp


.proc	@printBYTE
	lda :STACKORIGIN,x
_a
	sta dx

	lda #$00 
	sta dx+1
	sta dx+2
	sta dx+3

	jmp @printVALUE._8bit
.endp


.proc	@printVALUE

	lda dx+3
	bne _32bit

	lda dx+2
	bne _24bit

	lda dx+1
	bne _16bit

_8bit	lda #3
	bne l3

_16bit	lda #5
	bne l3

_24bit	lda #8
	bne l3

	; prints a 32 bit value to the screen (Graham)

_32bit	lda #10

l3	sta limit

	stx @sp

	ldx #0
	stx cnt

lp	jsr div10

	sta tmp,x
	inx
	cpx #10
limit	equ *-1
	bne lp

	;ldx #9
	dex

l1	lda tmp,x
	bne l2
	dex		; skip leading zeros
	bne l1

l2	lda tmp,x
	ora #$30
	tay

	jsr pout
	inc cnt

	dex
	bpl l2

	mva #{jmp*} pout

	lda #0
cnt	equ *-1

	ldx #0
@sp	equ *-1
	rts

pout	jmp @print

	sty @buf+1
pbuf	equ *-2
	inc pbuf

	rts

tmp	.byte 0,0,0,0,0,0,0,0,0,0

.endp


; divides a 32 bit value by 10
; remainder is returned in akku

.proc	div10
        ldy #32		; 32 bits
        lda #0
        clc
l4      rol @
        cmp #10
        bcc skip
        sbc #10
skip    rol dx
        rol dx+1
        rol dx+2
        rol dx+3
        dey
        bpl l4

	rts
.endp


.proc	@hexStr

Value	= edx
Digits	= ecx

	ldx Digits
	cpx #32
	scc
	ldx #32

	stx Digits

	lda Value
	jsr hex
	lda Value+1
	jsr hex
	lda Value+2
	jsr hex
	lda Value+3
	jsr hex

	lda Digits
	sta @buf
	rts

hex	pha
	and #$f
	jsr put
	pla
	:4 lsr @
put	tay
	lda thex,y
	sta @buf,x
	dex
	rts

thex	dta c'0123456789ABCDEF'
.endp


.proc	@ValueToStr (.word ya) .reg

	sta adr
	sty adr+1

	mva #{bit*} @printVALUE.pout
	mva <@buf+1 @printVALUE.pbuf

	jsr $ffff
adr	equ *-2

	ldy @printVALUE.pbuf
	dey
	sty @buf

	rts
.endp


;	ecx	isSign
;	edx	Result

.proc	@StrToInt (.word ya) .reg

	sta bp2
	sty bp2+1

	ldy #0
	sty MAIN.SYSTEM.IOResult
	sty edx
	sty edx+1
	sty edx+2
	sty edx+3

	lda (bp2),y
	beq stop
	sta len

	inw bp2

	lda (bp2),y
	cmp #'-'
	sne
	iny

	sty ecx

l1	lda (bp2),y

	CLC
	ADC #$FF-'9'	; make m = $FF
	ADC #'9'-'0'+1	; carry set if in range n to m
	bcs ok

	lda #106	; Invalid numeric format
	sta MAIN.SYSTEM.IOResult
	
	bne stop	; reg Y+1 contains the index of the character in S which prevented the conversion

ok	jsr fmul10

	lda (bp2),y
	sub #$30
	sta ztmp

	lda #$00
	sta ztmp+1
	sta ztmp+2
	sta ztmp+3

	jsr fmul10.add32bit

	iny
	cpy #0
len	equ *-1
	bne l1
	
	ldy #$ff

	lda ecx
	beq stop

	jsr negEDX
	
stop	iny		; reg Y = 0 conversion successful
	rts
.endp


.proc	negEDX
	lda #$00	; minus
	sub edx
	sta edx

	lda #$00
	sbc edx+1
	sta edx+1

	lda #$00
	sbc edx+2
	sta edx+2

	lda #$00
	sbc edx+3
	sta edx+3

	rts
.endp


.proc	fmul10
	asl edx		;multiply by 2
	rol edx+1	;temp store in ZTMP
	rol edx+2
	rol edx+3

	lda edx
	sta ztmp
	lda edx+1
	sta ztmp+1
	lda edx+2
	sta ztmp+2
	lda edx+3
	sta ztmp+3

	asl edx
	rol edx+1
	rol edx+2
	rol edx+3

	asl edx
	rol edx+1
	rol edx+2
	rol edx+3

add32bit
	lda edx
	add ztmp
	sta edx
	lda edx+1
	adc ztmp+1
	sta edx+1
	lda edx+2
	adc ztmp+2
	sta edx+2
	lda edx+3
	adc ztmp+3
	sta edx+3

	rts
.endp


.proc	negSHORT
	lda #$00
	sub :STACKORIGIN,x
	sta :STACKORIGIN,x

	lda #$00
	sbc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH,x

	rts
.endp


.proc	@TRUNC_SHORT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	sta :STACKORIGIN,x
	mva #$00 :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jsr negSHORT

	rts
.endp


.proc	@ROUND_SHORT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	lda :STACKORIGIN,x
//	add #$80
	cmp #$80
	lda :STACKORIGIN+STACKWIDTH,x
	adc #0
	sta :STACKORIGIN,x

	mva #$00 :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jsr negSHORT

	rts
.endp


.proc	@FRAC_SHORT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jsr negSHORT

	rts
.endp


.proc	@INT_SHORT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	lda #$00
	sta :STACKORIGIN,x

	tya
	spl
	jsr negSHORT

	rts
.endp


.proc	@TRUNC

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x
	mva :STACKORIGIN+STACKWIDTH*2,x :STACKORIGIN+STACKWIDTH,x
	mva :STACKORIGIN+STACKWIDTH*3,x :STACKORIGIN+STACKWIDTH*2,x
	mva #$00 :STACKORIGIN+STACKWIDTH*3,x

	tya
	spl
	jsr negCARD

	rts
.endp


.proc	@ROUND

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	lda :STACKORIGIN,x
//	add #$80
	cmp #$80
	lda :STACKORIGIN+STACKWIDTH,x
	adc #0
	sta :STACKORIGIN,x
	lda :STACKORIGIN+STACKWIDTH*2,x
	adc #0
	sta :STACKORIGIN+STACKWIDTH,x
	lda :STACKORIGIN+STACKWIDTH*3,x
	adc #0
	sta :STACKORIGIN+STACKWIDTH*2,x

	mva #$00 :STACKORIGIN+STACKWIDTH*3,x

	tya
	spl
	jsr negCARD

	rts
.endp


.proc	@FRAC

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN+STACKWIDTH*3,x

	tya
	spl
	jsr negCARD

	rts
.endp


.proc	@INT

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	lda #$00
	sta :STACKORIGIN,x

	tya
	spl
	jsr negCARD

	rts
.endp


;----------------------------;
; Biblioteka procedur        ;
; graficznych                ;
;----------------------------;
; Autorzy:                   ;
;  Slawomir 'SERO' Ritter,   ;
;  Jakub Cebula,             ;
;  Winfried Hofacker         ;
;----------------------------;
; Wersja:1.1 DATA:09.01.2008 ;
;----------------------------;

@open	= $03		; Otworz kanal
@close	= $0c		; Zamknij kanal

@IDget	= $07		; Narysuj punkt
@IDput	= $09		; Narysuj punkt
@IDdraw	= $11		; Narysuj linie
@IDfill	= $12		; Wypelnij obszar


;------------------------;
;Wy:.Y-numer bledu (1-OK);
;   f(N)=1-wystapil blad ;
;------------------------;
.proc	@COMMAND

	ldx	#$00
scrchn	equ *-1

	sta	iocom,x

	lda	#$00
colscr	equ *-1
	sta	atachr

	jmp	ciov
.endp

;------------------------;
; Ustaw tryb ekranu      ;
;------------------------;
;We:.X-numer kanalu      ;
;      (normalnie 0)     ;
;   .Y-numer trybu (O.S.);
;   .A-Ustawiony bit nr :;
;     5-Nie kasowanie    ;
;       pamieci ekranu   ;
;     4-Obecnosc okna    ;
;       tekstowego       ;
;     2-Odczyt z ekranu  ;
;------------------------;
;Wy:SCRCHN-numer kanalu  ;
;  .Y-numer bledu (1-OK) ;
;   f(N)=1 wystapil blad ;
;------------------------;
@GRAPHICS .proc (.byte x,y,a) .reg

	sta	byte1
	sty	byte2

	stx	@COMMAND.scrchn

	lda	#@close
	jsr	xcio

	lda	#0		; =opcje
byte1	equ	*-1
	ora	#8		; +zapis na ekranie
	sta	ioaux1,x

	lda	#0
byte2	equ	*-1
	sta	ioaux2,x	;=nr.trybu

	mwa	#sname	ioadr,x

	lda	#@open

xcio	sta iocom,x
	jmp ciov

sname	dta c'S:',$9b

	.endp


.proc	@ata2int
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror
	rts
.endp


/*
  PUT CHAR

  Procedura wyprowadza znak na ekran na pozycji X/Y kursora okreslonej przez zmienne odpowiednio
  COLCRS ($55-$56) i ROWCRS ($54). Zaklada sie, ze obowiazuja przy tym domyslne ustawienia OS-u,
  to jest ekran jest w trybie Graphics 0, a kanal IOCB 0 jest otwarty dla edytora ekranowego.

  Wyprowadzenie znaku polega na zaladowaniu jego kodu ATASCII do akumulatora i wykonaniu rozkazu
  JSR PUTCHR.
*/

.proc	@putchar (.byte a) .reg

vbxe	bit *

	ldx #$00
	.ifdef MAIN.CRT.TextAttr
	ora MAIN.CRT.TextAttr
	.endif
	tay
	lda icputb+1,x
	pha
	lda icputb,x
	pha
	tya

	rts

.endp


/*
  GETLINE

  Program czeka, az uzytkownik wpisze ciag znak�w z klawiatury i nacisnie klawisz RETURN.
  Znaki podczas wpisywania sa wyswietlane na ekranie, dzialaja tez normalne znaki kontrolne
  (odczyt jest robiony z edytora ekranowego).

  Wywolanie funkcji polega na zaladowaniu adresu, pod jaki maja byc wpisane znaki,
  do rejestr�w A/Y (mlodszy/starszy) i wykonaniu rozkazu JSR GETLINE.

*/

.proc	@GetLine

	stx @sp

	ldx #0

	stx MAIN.SYSTEM.EoLn

	mwa	#@buf+1	icbufa,x

	mwa	#$ff	icbufl,x	; maks. wielkosc tekstu

	mva	#$05	iccmd,x

	jsr	ciov

	dew icbufl
	mva icbufl @buf			; length

	ldx @buf+1
	cpx #EOL
	bne skp

	ldx #TRUE
	stx MAIN.SYSTEM.EoLn
skp
	ldx #0
@sp	equ *-1

	rts
.endp


.proc	@GetKey

getk	lda kbcodes	; odczytaj kbcodes
	cmp #255		; czy jest znak?
	beq getk	; nie: czekaj
	ldy #255		; daj zna�, �e klawisz
	sty kbcodes	; zosta� odebrany
	tay		; kod klawisza jako indeks
	lda (keydef),y	; do tablicy w ROM-ie

	rts
.endp


.proc	@moveSTRING (.word ya) .reg

	sta @move.dst
	sty @move.dst+1

	mva :STACKORIGIN,x @move.src
	mva :STACKORIGIN+STACKWIDTH,x @move.src+1

	ldy #$00
	lda (@move.src),y
	add #1
	sta @move.cnt
	scc
	iny
	sty @move.cnt+1

	jmp @move
.endp


.proc	@moveSTRING_1 (.word ya) .reg

	sta @move.dst
	sty @move.dst+1

	mva :STACKORIGIN,x @move.src
	mva :STACKORIGIN+STACKWIDTH,x @move.src+1

	ldy #$00
	lda (@move.src),y
;	add #1
	sta @move.cnt
	sty @move.cnt+1

	inw @move.src

	jmp @move
.endp


; Ullrich von Bassewitz, 2003-08-20
; Performance increase (about 20%) by
; Christian Krueger, 2009-09-13

.proc	@moveu			; assert Y = 0

ptr1	= edx
ptr2	= ecx
ptr3	= eax

	stx @sp

	ldy	#0

	ldx     ptr3+1		; Get high byte of n
	beq     L2		; Jump if zero

L1:     .rept 2			; Unroll this a bit to make it faster...
	lda     (ptr1),Y	; copy a byte
	sta     (ptr2),Y
	iny
	.endr

	bne     L1
	inc     ptr1+1
	inc     ptr2+1
	dex			; Next 256 byte block
	bne	L1		; Repeat if any

	; the following section could be 10% faster if we were able to copy
	; back to front - unfortunately we are forced to copy strict from
	; low to high since this function is also used for
	; memmove and blocks could be overlapping!
	; {
L2:				; assert Y = 0
	ldx     ptr3		; Get the low byte of n
	beq     done		; something to copy

L3:     lda     (ptr1),Y	; copy a byte
	sta     (ptr2),Y
	iny
	dex
	bne     L3

	; }

done	ldx #0
@sp	equ *-1
	rts
.endp


@move	.proc (.word ptr1, ptr2, ptr3) .var

ptr1	= edx
ptr2	= ecx
ptr3	= eax

src	= ptr1
dst	= ptr2
cnt	= ptr3

	cpw ptr2 ptr1
	scs
	jmp @moveu

	stx @sp

; Copy downwards. Adjust the pointers to the end of the memory regions.

	lda     ptr1+1
	add     ptr3+1
	sta     ptr1+1

	lda     ptr2+1
	add     ptr3+1
	sta     ptr2+1

; handle fractions of a page size first

	ldy     ptr3		; count, low byte
	bne     @entry		; something to copy?
	beq     PageSizeCopy	; here like bra...

@copyByte:
	lda     (ptr1),y
	sta     (ptr2),y
@entry:
	dey
	bne     @copyByte
	lda     (ptr1),y	; copy remaining byte
	sta     (ptr2),y

PageSizeCopy:			; assert Y = 0
	ldx     ptr3+1		; number of pages
	beq     done		; none? -> done

@initBase:
	dec     ptr1+1		; adjust base...
	dec     ptr2+1
	dey			; in entry case: 0 -> FF
	lda     (ptr1),y	; need to copy this 'intro byte'
	sta     (ptr2),y	; to 'land' later on Y=0! (as a result of the '.repeat'-block!)
	dey			; FF ->FE
@copyBytes:
	.rept 2			; Unroll this a bit to make it faster...
	lda     (ptr1),y
	sta     (ptr2),y
	dey
	.endr
@copyEntry:			; in entry case: 0 -> FF
	bne     @copyBytes
	lda     (ptr1),y	; Y = 0, copy last byte
	sta     (ptr2),y
	dex			; one page to copy less
	bne     @initBase	; still a page to copy?

done	ldx #0
@sp	equ *-1
	rts
.endp


; Ullrich von Bassewitz, 29.05.1998
; Performance increase (about 20%) by
; Christian Krueger, 12.09.2009, slightly improved 12.01.2011

.proc	@fill (.word ptr1, ptr3 .byte ptr2) .var

ptr1 = edx
ptr3 = ecx
ptr2 = eax

	txa:pha

	ldx ptr2

	ldy #0

        lsr	ptr3+1          ; divide number of
        ror	ptr3            ; bytes by two to increase
        bcc	evenCount       ; speed (ptr3 = ptr3/2)
oddCount:
				; y is still 0 here
        txa			; restore fill value
        sta	(ptr1),y	; save value and increase
        inc	ptr1		; dest. pointer
        bne	evenCount
        inc	ptr1+1
evenCount:
	lda	ptr1		; build second pointer section
	clc
	adc	ptr3		; ptr2 = ptr1 + (length/2) <- ptr3
	sta     ptr2
	lda     ptr1+1
	adc     ptr3+1
	sta     ptr2+1

        txa			; restore fill value
        ldx	ptr3+1		; Get high byte of n
        beq	L2		; Jump if zero

; Set 256/512 byte blocks
				; y is still 0 here
L1:	.rept 2			; Unroll this a bit to make it faster
	sta	(ptr1),y	; Set byte in lower section
	sta	(ptr2),y	; Set byte in upper section
	iny
	.endr
        bne	L1
        inc	ptr1+1
        inc	ptr2+1
        dex                     ; Next 256 byte block
        bne	L1              ; Repeat if any

; Set the remaining bytes if any

L2:	ldy	ptr3            ; Get the low byte of n
	beq	leave           ; something to set? No -> leave

L3:	dey
	sta	(ptr1),y	; set bytes in low
	sta	(ptr2),y	; and high section
	bne     L3		; flags still up to date from dey!

leave	pla:tax
	rts			; return
.endp


/*
 add strings
 result -> @buf
*/
.proc	@addString(.word ya) .reg

	sta ztmp
	sty ztmp+1

	stx @sp

	ldx @buf
	inx
	beq stop

	ldy #0
	lda (ztmp),y
	sta ile
	beq stop

	iny

load	lda (ztmp),y
	sta @buf,x

	iny
	inx
	beq stop
	dec ile
	bne load

stop	dex
	stx @buf

	ldx #0
@sp	equ *-1
	rts

ile	brk
.endp


/* ----------------------------------------------------------------------- */


.proc	@AllocMem	;(.word ztmp .byte ztmp+2) .var

	sty ztmp+2

loop	lda (psptr),y
	sta ztmp+3

	lda (ztmp),y
	sta (psptr),y

	lda ztmp+3
	sta (ztmp),y

	dey
	bne loop

	lda psptr
	add ztmp+2
	sta psptr
	scc
	inc psptr+1

	rts
.endp


.proc	@FreeMem	;(.word ztmp .byte ztmp+2) .var

	sty ztmp+2

	lda psptr
	sub ztmp+2
	sta psptr
	scs
	dec psptr+1

loop	lda (psptr),y
	sta ztmp+3

	lda (ztmp),y
	sta (psptr),y

	lda ztmp+3
	sta (ztmp),y

	dey
	bne loop

	rts
.endp


/* ----------------------------------------------------------------------- */


.proc	@vbxe_detect

	ldy #.sizeof(detect)-1
	mva:rpl copy,y detect,y-

	jmp detect

copy
	.local	detect,@buf
;
; 2009 by KMK/DLT
;
	lda #0
	sta fxptr

        lda #$d6
        sta fxptr+1
        ldy #FX_MEMB
        jsr ?clr

        jsr ?try
        bcc ok

        inc fxptr+1

	jsr ?try
	bcc ok

	lda #0
	sta fxptr+1
	rts

?try    ldx $4000
        jsr ?chk
        bcc ?ret
        inx
        stx $4000
        jsr ?chk
        dec $4000
?ret    rts

ok	ldy	#VBXE_MINOR		; get core minor version
	lda	(fxptr),y
	rts

?chk    lda #$80
        jsr _vbxe_write
        cpx $4000
        bne ?fnd
        sec
        .byte $24
?fnd    clc
?clr    lda #$00
_vbxe_write
        sta (fxptr),y
        rts

/*
	lda	#0
	ldx	#0xd6
	sta	0xd640			; make sure it isn't coincidence
	lda	0xd640
	cmp	#0x10			; do we have major version here?
	beq	VBXE_Detected		; if so, then VBXE is detected
	lda	#0
	inx
	sta	0xd740			; no such luck, try other location
	lda	0xd740
	cmp	#0x10
	beq	VBXE_Detected
	ldx 	#0  			; not here, so not present or FX core version too low
	stx	fxptr+1
	stx	fxptr

	sec
	rts

VBXE_Detected
	stx	fxptr+1
	lda	#0
	sta	fxptr

	ldy	#VBXE_MINOR		; get core minor version
	lda	(fxptr),y

	clc
	rts	 			; x - page of vbxe
*/

	.endl

.endp


.proc	@setxdl(.byte a) .reg

	asl @
	sta idx

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #0
idx	equ *-1

	lda MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc
	and msk,y
	ora val,y
	sta MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc

	lda MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc+1
	and msk+1,y
	ora val+1,y
	sta MAIN.SYSTEM.VBXE_WINDOW+s@xdl.xdlc+1

	fxs FX_MEMS #0
	rts

msk	.array [6] .word
	[e@xdl.mapon]  = [XDLC_MAPON|XDLC_MAPOFF]^$FFFF
	[e@xdl.mapoff] = [XDLC_MAPON|XDLC_MAPOFF]^$FFFF
	[e@xdl.ovron]  = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	[e@xdl.ovroff] = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	[e@xdl.hr]     = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	[e@xdl.lr]     = [XDLC_GMON|XDLC_OVOFF|XDLC_LR|XDLC_HR]^$FFFF
	.enda

val	.array [6] .word
	[e@xdl.mapon]  = XDLC_MAPON
	[e@xdl.mapoff] = XDLC_MAPOFF
	[e@xdl.ovron]  = XDLC_GMON
	[e@xdl.ovroff] = XDLC_OVOFF
	[e@xdl.hr]     = XDLC_GMON|XDLC_HR
	[e@xdl.lr]     = XDLC_GMON|XDLC_LR
	.enda

.endp


.proc	@vbxe_init

	fxs FX_MEMC #%1000+>MAIN.SYSTEM.VBXE_WINDOW	; $b000..$bfff (4K window), cpu on, antic off
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000	; enable VBXE BANK #0

	ldx #.sizeof(s@xdl)-1
	mva:rpl xdlist,x MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW,x-

	jsr cmapini		; init color map

	fxsa FX_P1		; A = 0
	fxsa FX_P2
	fxsa FX_P3

	fxsa FX_IRQ_CONTROL
	fxsa FX_BLITTER_START

	fxsa FX_XDL_ADR0	; XDLIST PROGRAM ADDRES (VBXE_XDLADR = $0000) = bank #0
	fxsa FX_XDL_ADR1
	fxsa FX_XDL_ADR2

	sta colpf0s

	fxs FX_P0 #$ff

	mwa #@vbxe_cmap @putchar.vbxe+1
	mva #{jsr*} @putchar.vbxe

	fxs FX_VIDEO_CONTROL #VC_XDL_ENABLED|VC_XCOLOR	;|VC_NO_TRANS

	rts

cmapini	lda colpf1s
	and #$0f
	sta colpf1s

	lda #$80+MAIN.SYSTEM.VBXE_MAPADR/$1000
	sta ztmp

	mva #4 ztmp+1

loop	fxs FX_MEMS ztmp

	lda >MAIN.SYSTEM.VBXE_WINDOW
	sta bp+1

	ldx #16
	ldy #0

lop	mva #$00	(bp),y+
	mva colpf1s	(bp),y+
	mva colpf2s	(bp),y+
	mva #%00010000	(bp),y+		; overlay palette #1
	bne lop

	inc bp+1
	dex
	bne lop

	inc ztmp

	dec ztmp+1
	bne loop

	fxs FX_MEMS #$00		; disable VBXE BANK
	rts

xdlist	dta s@xdl [0] (XDLC_RPTL, 24-1,\
	XDLC_END|XDLC_RPTL|XDLC_MAPON|XDLC_MAPADR|XDLC_OVADR|XDLC_MAPPAR|XDLC_OVATT,\	;|XDLC_GMON,\
	192-1, MAIN.SYSTEM.VBXE_OVRADR, 320,\
	MAIN.SYSTEM.VBXE_MAPADR, $100,\
	0, 0, 7, 7, %00010001, $ff)
.endp


.proc	@vbxe_cmap

	pha

	cmp #eol
	beq stop

	cmp #$7d		; clrscr
	bne skp

	jsr @vbxe_init.cmapini
	jmp stop

skp	lda rowcrs
	pha
	:4 lsr @
	add #$80+MAIN.SYSTEM.VBXE_MAPADR/$1000
	fxsa FX_MEMS

	pla
	and #$0f
	add >MAIN.SYSTEM.VBXE_WINDOW
	sta bp+1

	lda colcrs
	asl @
	asl @
	tay
	mva colpf0s (bp),y
	iny
	mva colpf1s (bp),y
	iny
	mva colpf2s (bp),y

	fxs FX_MEMS #$00

stop	pla

	rts
.endp


/* ----------------------------------------------------------------------- */


/*
.proc	@cmdline (.byte a) .reg

	stx @sp

	sta idpar

	lda #0
	sta parno

	lda boot?		; sprawdzamy, czy DOS w ogole jest w pamieci
	lsr
	bcc _no_command_line

	lda dosvec+1		; a jesli tak, czy DOSVEC nie wskazuje ROM-u
	cmp #$c0
	bcs _no_command_line

	ldy #$03
	lda (dosvec),y
	cmp #{jmp}
	bne _no_command_line

	ldy #$0a		; COMTAB+$0A (BUFOFF)
	lda (dosvec),y
	sta lbuf
	iny
	lda (dosvec),y
	sta hbuf

	adw dosvec #3 zcr

loop	lda #0
	sta @buf

	jsr $ffff
zcr	equ *-2
	beq stop

	lda idpar
	bne skp

	ldy #33			; ParamStr(0)
_par0	lda (dosvec),y
	sta @buf-33+1,y
	iny
	cpy #36
	bne _par0

	lda #3
	sta @buf
	bne stop

skp	ldy #36
_cp	lda (dosvec),y
	sta @buf-36+1,y
	iny
	cmp #$9b
	bne _cp

	tya
	sub #37
	sta @buf

	inc parno
	lda #0
parno	equ *-1
	cmp #0
idpar	equ *-1

	bne loop

stop	ldy #$0a		; przywracamy poprzednia wartosc BUFOFF
	lda #0
lbuf	equ *-1
	sta (dosvec),y
	iny
	lda #0
hbuf	equ *-1
	sta (dosvec),y

_no_command_line		; przeskok tutaj oznacza brak dostepnosci wiersza polecen

	lda parno

	ldx #0
@sp	equ *-1
	rts
.endp
*/


.proc	@CmdLine (.byte a) .reg

	stx @sp

	sta idpar

	lda #0
	sta parno
	sta loop+1

	lda	#{jsr*}
	sta	res

; Get filename from SpartaDOS...
get_param
	lda boot?		; sprawdzamy, czy DOS w ogole jest w pamieci
	lsr
	bcc no_sparta

	lda dosvec+1		; a jesli tak, czy DOSVEC nie wskazuje ROM-u
	cmp #$c0
	bcs no_sparta

	ldy #$03
	lda (dosvec),y
	cmp #{jmp}
	bne no_sparta

	ldy #$0a		; COMTAB+$0A (BUFOFF)
	lda (dosvec),y
	sta lbuf
	iny
	lda (dosvec),y
	sta hbuf

	adw dosvec #33 tmp

	ldy #0
fnm	lda (tmp),y
	iny
	cmp #$9b
	bne fnm

	tya			; remove .COM
	sub #5
	tay
	lda #0
	sta (tmp),y
	tay

	lda	#3
	sta	loop+1
	add	dosvec
	sta	get_adr
	lda	#0
	adc	dosvec+1
	sta	get_adr+1

	jmp	_ok

no_sparta
	mwa #next get_adr

	lda	#{bit*}
	sta	res

; ... or channel #0
	lda	MAIN.IOCB@COPY+2	; command
	cmp	#5			; read line
	bne	_no_command_line
	lda	MAIN.IOCB@COPY+3	; status
	bmi	_no_command_line
; don't assume the line is EOL-terminated
; DOS II+/D overwrites the EOL with ".COM"
; that's why we rely on the length
	lda	MAIN.IOCB@COPY+9	; length hi
	bne	_no_command_line
	ldx	MAIN.IOCB@COPY+8	; length lo
	beq	_no_command_line
	inx:inx
	stx	arg_len
; give access to three bytes before the input buffer
; in DOS II+/D the device prompt ("D1:") is there
	lda	MAIN.IOCB@COPY+4
	sub	#3
	sta	tmp
	lda	MAIN.IOCB@COPY+5
	sbc	#0
	sta	tmp+1

	lda	#0
	ldy	#0
arg_len	equ *-1
	sta	(tmp),y


loop	ldy	#0

_ok	ldx	#0

lprea	lda	(tmp),y
	sta	@buf+1,x

	beq	stop

	cmp	#$9b
	beq	stop
	cmp	#' '
	beq	stop

	iny
	inx
	cpx #32
	bne lprea

stop	lda #0
parno	equ *-1
	cmp #0
idpar	equ *-1
	beq found

	jsr $ffff		; sty loop+1
get_adr	equ *-2
	beq found

	inc parno
	bne loop

found	lda #0	;+$9b
	sta @buf+1,x
	stx @buf

res	jsr sdxres

_no_command_line		; przeskok tutaj oznacza brak dostepnosci wiersza polecen

	lda parno

	ldx #0
@sp	equ *-1
	rts


sdxres	ldy #$0a		; przywracamy poprzednia wartosc BUFOFF
	lda #0
lbuf	equ *-1
	sta (dosvec),y
	iny
	lda #0
hbuf	equ *-1
	sta (dosvec),y
	rts


_next	iny
next	lda (tmp),y
	beq _eol
	cmp #' '
	beq _next

	cmp #$9b
	beq _eol

	sty loop+1
	rts

_eol	lda #0
	rts

.endp


/* ----------------------------------------------------------------------- */

/*
.proc	@rstsnd
	lda #0
	sta $d208
	sta $d218

	ldy #3
	sty $d20f
	sty $d21f
	rts
.endp
*/

;	ert (*>$3fff) .and (*<$8000)


/* ----------------------------------------------------------------------- */


.proc	@xmsBank

ptr3 = eax			; position	(4)

	mva ptr3+3 ztmp+1	; position shr 14
	mva ptr3+2 ztmp
	lda ptr3+1

	.rept 6
	lsr ztmp+1
	ror ztmp
	ror @
	.endr

	tax			; index to bank

	lda portb
	and #1
	ora main.misc.adr.banks,x
	sta portb

	lda ptr3 		; offset
	sta ztmp
	lda ptr3+1
	and #$3f
	ora #$40
	sta ztmp+1

	rts
.endp


.proc	@xmsReadBuf (.word ptr1, ptr2) .var

ptr1 = dx	; buffer	(2)

ptr2 = cx	; count		(2)
pos = cx+2	; position	(2) pointer

ptr3 = eax	; position	(4)

	txa:pha

	ldy #0
	lda (pos),y
	sta ptr3
	iny
	lda (pos),y
	sta ptr3+1
	iny
	lda (pos),y
	sta ptr3+2
	iny
	lda (pos),y
	sta ptr3+3

	lda ptr2+1
	beq lp2

lp1	jsr @xmsBank

	lda ztmp+1
	cmp #$7f
	bne skp
	lda ztmp
	beq skp

	lda #0
	jsr nextBank
	jmp skp2

skp	ldy #0
	mva:rne (ztmp),y @buf,y+

skp2	lda portb
	and #1
	ora #$fe
	sta portb

	ldy #0
	mva:rne @buf,y (dx),y+

	inc dx+1	// inc(dx, $100)

	inl ptr3+1	// inc(position, $100)

	dec ptr2+1
	bne lp1

lp2	jsr @xmsBank

	lda ztmp+1		; zakonczenie kopiowania
	cmp #$7f		; jesli przekraczamy granice banku $7FFF
	bne skp_

	lda ztmp
	add ptr2
	bcc skp_

	lda ptr2		; to realizuj wyjatek NEXTBANK, kopiuj PTR2 bajtow
	jsr nextBank
	jmp skp3

skp_	ldy #0
mv	lda (ztmp),y
	sta @buf,y
	iny
	cpy ptr2
	bne mv

skp3	lda portb
	and #1
	ora #$fe
	sta portb

	ldy #0
lp3	lda @buf,y
	sta (dx),y
	iny
	cpy ptr2
	bne lp3

	jmp @xmsUpdatePosition

.local	nextBank

	sta max

	mwa ztmp src

	ldy #0
mv0	lda $ffff,y
src	equ *-2
	sta @buf,y
	iny
	inc ztmp
	bne mv0

	lda portb
	and #1
	ora main.misc.adr.banks+1,x
	sta portb

	ldx #0
mv1	cpy #0
max	equ *-1
	beq stp
	lda $4000,x
	sta @buf,y
	inx
	iny
	bne mv1
stp	rts
.endl

.endp


.proc	@xmsWriteBuf (.word ptr1, ptr2) .var

ptr1 = dx	; buffer	(2)

ptr2 = cx	; count		(2)
pos = cx+2	; position	(2) pointer

ptr3 = eax	; position	(4)

	txa:pha

	ldy #0			; przepisz POSITION spod wskaznika
	lda (pos),y
	sta ptr3
	iny
	lda (pos),y
	sta ptr3+1
	iny
	lda (pos),y
	sta ptr3+2
	iny
	lda (pos),y
	sta ptr3+3

lp1	lda portb		; wylacz dodatkowe banki
	and #1
	ora #$fe
	sta portb

	ldy #0			; przepisz 256b z BUFFER do @BUF
	mva:rne (dx),y @buf,y+

	jsr @xmsBank		; wlacz dodatkowy bank

	lda ptr2+1
	beq lp2

	lda ztmp+1		; jesli przekraczamy granice banku $7FFF
	cmp #$7f
	bne skp
	lda ztmp
	beq skp

	lda #0			; to realizuj wyjatek NEXTBANK, kopiuj 256b
	jsr nextBank
	jmp skp2

skp	mva:rne @buf,y (ztmp),y+

skp2	inc dx+1		// inc(dx, $100)

	inl ptr3+1		// inc(position, $100)

	dec ptr2+1
	bne lp1

lp2	lda ztmp+1		; zakonczenie kopiowania
	cmp #$7f		; jesli przekraczamy granice banku $7FFF
	bne skp_

	lda ztmp
	add ptr2
	bcc skp_

	lda ptr2		; to realizuj wyjatek NEXTBANK, kopiuj PTR2 bajtow
	jsr nextBank
	jmp quit

skp_	ldy #0
lp3	lda @buf,y
	sta (ztmp),y

	iny
	cpy ptr2
	bne lp3

quit	lda portb
	and #1
	ora #$fe
	sta portb

	jmp @xmsUpdatePosition

.local	nextBank

	sta max

	mwa ztmp dst

	ldy #0
mv0	lda @buf,y
	sta $ffff,y
dst	equ *-2
	iny
	inc ztmp
	bne mv0

	lda portb
	and #1
	ora main.misc.adr.banks+1,x
	sta portb

	ldx #0
mv1	cpy #0
max	equ *-1
	beq stp
	lda @buf,y
	sta $4000,x
	inx
	iny
	bne mv1
stp	rts
.endl

.endp


.proc	@xmsAddPosition

	.use @xmsReadBuf

	add ptr3
	sta ptr3
	lda #$00
	adc ptr3+1
	sta ptr3+1
	lda #$00
	adc ptr3+2
	sta ptr3+2
	lda #$00
	adc ptr3+3
	sta ptr3+3

	rts
.endp


.proc	@xmsUpdatePosition

	.use @xmsReadBuf

	tya
	jsr @xmsAddPosition

	ldy #0
	lda ptr3
	sta (pos),y
	iny
	lda ptr3+1
	sta (pos),y
	iny
	lda ptr3+2
	sta (pos),y
	iny
	lda ptr3+3
	sta (pos),y

	pla:tax
	rts
.endp


/* ----------------------------------------------------------------------- */


.proc	@ClrScr

	ldx #$00
	lda #$0c
	jsr xcio

	mwa #ename ioadr,x

	mva #$0c ioaux1,x
	mva #$00 ioaux2,x

	lda #$03

xcio	sta iocom,x
	jmp ciov

ename	.byte 'E:',$9b

.endp


/* ----------------------------------------------------------------------- */

.proc   @mul40			; = 33 bytes, 48/53 cycles

        sta     eax+1		; remember value for later addition...
        ldy     #0              ; clear high-byte
        asl     @		; * 2
        bcc     mul4            ; high-byte affected?
        ldy     #2              ; this will be the 1st high-bit soon...

mul4:   asl     @               ; * 4
        bcc     mul5            ; high-byte affected?
        iny                     ; => yes, apply to 0 high-bit
        clc                     ; prepare addition

mul5:   adc     eax+1		; * 5
        bcc     mul10		; high-byte affected?
        iny			; yes, correct...

mul10:  sty     eax+1		; continue with classic shifting...
        
        asl     @		; * 10
        rol     eax+1

        asl     @		; * 20
        rol     eax+1

        asl     @		; * 40
        rol     eax+1
	
	sta eax

        rts

.endp	

/* ----------------------------------------------------------------------- */


	opt l+
