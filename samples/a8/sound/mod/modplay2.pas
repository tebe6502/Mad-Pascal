
// 6502 MOD Player 2.3 (VBL, IRQ) 8 kHz (POKEY 1.7 MHz)
// pattern limit = 37
// sample length limit = 16384 bytes , ladowane do koñca banku ($7fff)

// volume $de00 - $feff

// playloop		= $0000
// mainloop		= $0400..$5ff

// changes: 09.10.2018; 21.08.2022


program ModPlay;

uses crt, atari, objects;

//{$define COVOX}
//{$define STATUS}

{$r modplay.rc}

{$info 6502 MOD Player}

type

	TName = array [0..21] of char;

	TSample = packed record
			name		: TName;
			len		: word;
			fine_tune,
			volume		: byte;
			loop_start,
			loop_len	: word;
		end;

	TPSample = ^TSample;


const
	COVOX	= $d700;

	PATTERN_LIMIT = 37;
	SAMPLE_LIMIT = 31;

	VOL6BIT	= $d800;
	ZPAGE	= $db00;		// kopia strony zerowej
	EFFECT	= $dc00;		// dekodowaniu kodu dla efektu sampla
	TADCL	= $dd00;		// mlodsze bajty przyrostu offsetu dla sampla (nuta)
	TADCH	= TADCL + $30;		// starsze bajty przyrostu offsetu dla sampla (nuta)

	VOLUME	= $de00;		// 33 tablice glosnosci (pierwsza tablica zawiera same zera)

	pattern_start = $4000;		// $4000 + $300 * PATTERN_LIMIT
	sample_start = $4000;
	sample_len = $4000;


	KOD : array [0..47] of word = (
	$6b0,$650,$5f4,$5a0,
	$54c,$500,$4b8,$474,
	$434,$3f8,$3c0,$380,
	$358,$328,$2fa,$2d0,
	$2a6,$280,$25c,$23a,
	$21a,$1fc,$1e0,$1c5,
	$1ac,$194,$17d,$168,
	$153,$140,$12e,$11d,
	$10d,$fe,$f0,$e2,
	$d6,$ca,$be,$b4,
	$aa,$a0,$97,$8f,
	$87,$7f,$78,$71
	);

var
	BUF: array [0..255] of byte absolute $0500;

	TIVOL: array [0..31] of byte absolute $0150;	// starszy adres glosnosci tablicy VOLUME = glosnosc SAMPLA

	ORDER: array [0..127] of byte absolute $0600;	// tablica SONG ORDER
	TSTRL: array [0..31] of byte absolute $0680;	// mlodszy bajt adresu poczatkowego sampla
	TSTRH: array [0..31] of byte absolute $06A0;	// starszy bajt adresu poczatkowego sampla
	TREPL: array [0..31] of byte absolute $06C0;	// mlodszy bajt adresu powtorzenia sampla
	TREPH: array [0..31] of byte absolute $06E0;	// starszy bajt adresu powtorzenia sampla

	ModName: array [0..19+1] of char;

	sampl_0, sampl_1, sampl_2, sampl_3, sampl_4,
	sampl_5, sampl_6, sampl_7, sampl_8, sampl_9,
	sampl_10, sampl_11, sampl_12, sampl_13,
	sampl_14, sampl_15, sampl_16, sampl_17,
	sampl_18, sampl_19, sampl_20, sampl_21,
	sampl_22, sampl_23, sampl_24, sampl_25,
	sampl_26, sampl_27, sampl_28, sampl_29, sampl_30: TSample;

	Sample: array [0..30] of pointer = (
	@sampl_0, @sampl_1, @sampl_2, @sampl_3, @sampl_4,
	@sampl_5, @sampl_6, @sampl_7, @sampl_8, @sampl_9,
	@sampl_10, @sampl_11, @sampl_12, @sampl_13,
	@sampl_14, @sampl_15, @sampl_16, @sampl_17,
	@sampl_18, @sampl_19, @sampl_20, @sampl_21,
	@sampl_22, @sampl_23, @sampl_24, @sampl_25,
	@sampl_26, @sampl_27, @sampl_28, @sampl_29, @sampl_30);

	gchar: char;

	SONG_LENGTH,
	SONG_RESTART,
	NUMBER_OF_PATTERNS,
	NUMBER_OF_BANKS,
	NUMBER_OF_SAMPLES	: byte;


procedure Play; assembler;
asm
{

.zpvar = $d8

.zpvar nr0, nr1, nr2, nr3, patno, patend, cnts, pause, track_pos .byte
.zpvar pat0, pat1, pat2 .word

	stx _rx

	jsr wait

	sei

	lda #$00
	sta nmien
	sta irqen

	mva #$fe portb

	lda #0

	ldx #8
lp	sta AUDF1,x
	sta AUDF1+$10,x
	dex
	bpl lp

	tax
	mva:rne 0,x ZPAGE,x+

	ldx #0
mv0	lda .adr(playloop),x
	sta playloop,x
	inx
	cpx #.sizeof(playloop)
	bne mv0

	ldx #0
mv1	lda .adr(mainloop),x
	sta mainloop,x
	lda .adr(mainloop)+$100,x
	sta mainloop+$100,x
	inx
	bne mv1

	lda SONG_LENGTH
	sta mainloop.patmax+1

;	lda SONG_RESTART
;	sta mainloop.patres+1

	lda >volume		; silence
	sta playloop.ivol0+2
	sta playloop.ivol1+2
	sta playloop.ivol2+2
	sta playloop.ivol3+2

	.ifdef MAIN.@DEFINES.COVOX

	lda >COVOX		; covox
	sta playloop.ch0+2
	sta playloop.ch1+2
	sta playloop.ch2+2
	sta playloop.ch3+2

	ldy #0
	sty playloop.ch0+1
	iny
	sty playloop.ch1+1
	iny
	sty playloop.ch2+1
	iny
	sty playloop.ch3+1

	.else

	lda >VOLUME		; pokey
	sta av0+1
	sta av1+1

	ldx #32			; POKEY volume table
	ldy #0
mvol	lda VOLUME,y
av0	equ *-2
;	:4 lsr @
;	ora #$10
	:2 lsr @
	sta VOLUME,y
av1	equ *-2
	iny
	bne mvol

	inc av0+1
	inc av1+1
	dex
	bpl mvol

	.endif

start	lda #0

	sta dmactl

	sta patno
	sta track_pos

	sta pat0
	sta pat1
	sta pat2

	lda #6
	sta pause
	sta cnts

	ldy adr.ORDER
	sty pat0+1
	iny
	sty pat1+1
	iny
	sty pat2+1

	mwa	#mainloop nmivec	; custom NMI handler
	mwa	#playloop irqvec	; custom IRQ handler

;	mva	#$01	AUDCTL		; 0=POKEY 64KHz, 1=15KHz

	;set IRQ position in scanline for consistency and disable keyboard scan
	sta	wsync
	lda	#0
	sta	skctl
	sta	skctl+$10

	sta	AUDCTL+$10

	mva #%01000000	AUDCTL

	mva #218	AUDF1		; 8 kHz

	mva	#$01	IRQEN

	lda	#1
	sta	skctl
	sta	stimer

	mva	#$40	nmien

	cli

	jmp stop


.local	playloop,0

	sta regA
	stx regX

	inc IRQEN

	lda v0: #0
	ldx v1: #0
	sta audc1
	lda v2: #0
	stx audc2
	sta audc3

	.ifdef MAIN.@DEFINES.STATUS
	lda #$0f
	sta colbak
	.endif

; ---
; ---	AUDC 1
; ---

ist_0	lda #0
iad0_m	adc #0
	sta ist_0+1
	lda p_0c+1
iad0_s	adc #0
	bcc ext_0

	inc p_0c+2
	bpl ext_0

ire0_s	lda #0
	sta p_0c+2
ire0_m	lda #0

ext_0	sta p_0c+1

; ---
; ---	AUDC 2
; ---

ist_1	lda #0
iad1_m	adc #0
	sta ist_1+1
	lda p_1c+1
iad1_s	adc #0
	bcc ext_1

	inc p_1c+2
	bpl ext_1

ire1_s	lda #0
	sta p_1c+2
ire1_m	lda #0

ext_1	sta p_1c+1

; ---
; ---	AUDC 3
; ---

ist_2	lda #0
iad2_m	adc #0
	sta ist_2+1
	lda p_2c+1
iad2_s	adc #0
	bcc ext_2

	inc p_2c+2
	bpl ext_2

ire2_s	lda #0
	sta p_2c+2
ire2_m	lda #0

ext_2	sta p_2c+1

; ---
; ---	AUDC 4
; ---

ist_3	lda #0
iad3_m	adc #0
	sta ist_3+1
	lda p_3c+1
iad3_s	adc #0
	bcc ext_3

	inc p_3c+2
	bpl ext_3

ire3_s	lda #0
	sta p_3c+2
ire3_m	lda #0

ext_3	sta p_3c+1



bank0	ldx #$fe		; ch #0
	stx portb

p_0c	ldx $ffff
ivol0	lda volume,x
	clc

bank1	ldx #$fe		; ch #1
	stx portb

p_1c	ldx $ffff
ivol1	adc volume,x

bank2	ldx #$fe		; ch #2
	stx portb

p_2c	ldx $ffff
ivol2	adc volume,x

bank3	ldx #$fe		; ch #3
	stx portb

p_3c	ldx $ffff
ivol3	adc volume,x

	tax

	lda vol6bit,x
	sta v0

	lda vol6bit+$100,x
	sta v1

	lda vol6bit+$200,x
	sta v2


	.ifdef MAIN.@DEFINES.STATUS
	lda #$00
	sta colbak
	.endif


	lda regA: #0
	ldx regX: #0

	rti

.endl


.local	mainloop,$0400

	bit nmist
	bpl vbl

exit	rti

vbl	dec cnts
	bne exit

	sta regA
	stx regX
	sty regY

	lda #0
	sta patend

	lda #$fe
	sta portb

	ldy track_pos

*---------------------------
* track  0

i_0	;ldy #1
	lda (pat1),y
	sta i_0c+1
	and #$1f
	beq i_0c
	tax
	sta nr0
	lda adr.tivol-1,x
	sta playloop.ivol0+2

i_0c	ldx EFFECT
	beq i_0f
	cpx #$40
	bne @+
	;ldy #2
	lda (pat2),y
	sta playloop.ivol0+2
@	cpx #$c0
	bne @+
	;ldy #2
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_0f
	stx patend

i_0f	;ldy #0
	lda (pat0),y
	beq i_1
	tax
	lda tadcl-1,x
	sta playloop.iad0_m+1
	lda tadch-1,x
	sta playloop.iad0_s+1

;	lda #0
;	sta playloop.ist_0+1

	ldx nr0
	lda main.misc.adr.banks-1,x
	sta playloop.bank0+1

	lda adr.tstrl-1,x
	sta playloop.p_0c+1
	lda adr.tstrh-1,x
	sta playloop.p_0c+2

	lda adr.trepl-1,x
	sta playloop.ire0_m+1
	lda adr.treph-1,x
	sta playloop.ire0_s+1

* track 1

i_1	iny

	;ldy #4
	lda (pat1),y
	sta i_1c+1
	and #$1f
	beq i_1c
	tax
	sta nr1
	lda adr.tivol-1,x
	sta playloop.ivol1+2

i_1c	ldx EFFECT
	beq i_1f
	cpx #$40
	bne @+
	;ldy #5
	lda (pat2),y
	sta playloop.ivol1+2
@	cpx #$c0
	bne @+
	;ldy #5
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_1f
	stx patend

i_1f	;ldy #3
	lda (pat0),y
	beq i_2
	tax
	lda tadcl-1,x
	sta playloop.iad1_m+1
	lda tadch-1,x
	sta playloop.iad1_s+1

;	lda #0
;	sta playloop.ist_1+1

	ldx nr1
	lda main.misc.adr.banks-1,x
	sta playloop.bank1+1

	lda adr.tstrl-1,x
	sta playloop.p_1c+1
	lda adr.tstrh-1,x
	sta playloop.p_1c+2

	lda adr.trepl-1,x
	sta playloop.ire1_m+1
	lda adr.treph-1,x
	sta playloop.ire1_s+1

* track 2

i_2	iny

	;ldy #7
	lda (pat1),y
	sta i_2c+1
	and #$1f
	beq i_2c
	tax
	sta nr2
	lda adr.tivol-1,x
	sta playloop.ivol2+2

i_2c	ldx EFFECT
	beq i_2f
	cpx #$40
	bne @+
	;ldy #8
	lda (pat2),y
	sta playloop.ivol2+2
@	cpx #$c0
	bne @+
	;ldy #8
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_2f
	stx patend

i_2f	;ldy #6
	lda (pat0),y
	beq i_3
	tax
	lda tadcl-1,x
	sta playloop.iad2_m+1
	lda tadch-1,x
	sta playloop.iad2_s+1

;	lda #0
;	sta playloop.ist_2+1

	ldx nr2
	lda main.misc.adr.banks-1,x
	sta playloop.bank2+1

	lda adr.tstrl-1,x
	sta playloop.p_2c+1
	lda adr.tstrh-1,x
	sta playloop.p_2c+2

	lda adr.trepl-1,x
	sta playloop.ire2_m+1
	lda adr.treph-1,x
	sta playloop.ire2_s+1

* track 3

i_3	iny

	;ldy #10
	lda (pat1),y
	sta i_3c+1
	and #$1f
	beq i_3c
	tax
	sta nr3
	lda adr.tivol-1,x
	sta playloop.ivol3+2

i_3c	ldx EFFECT
	beq i_3f
	cpx #$40
	bne @+
	;ldy #11
	lda (pat2),y
	sta playloop.ivol3+2
@	cpx #$c0
	bne @+
	;ldy #11
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_3f
	stx patend

i_3f	;ldy #9
	lda (pat0),y
	beq i_e
	tax
	lda tadcl-1,x
	sta playloop.iad3_m+1
	lda tadch-1,x
	sta playloop.iad3_s+1

;	lda #0
;	sta playloop.ist_3+1

	ldx nr3
	lda main.misc.adr.banks-1,x
	sta playloop.bank3+1

	lda adr.tstrl-1,x
	sta playloop.p_3c+1
	lda adr.tstrh-1,x
	sta playloop.p_3c+2

	lda adr.trepl-1,x
	sta playloop.ire3_m+1
	lda adr.treph-1,x
	sta playloop.ire3_s+1

i_e
	lda patend
	bne i_en

	iny
	sty track_pos
	bne i_end

i_en	inc patno
	ldx patno
patmax	cpx #0
	bcc i_ens

	lda #6
	sta pause
patres	ldx #0
	stx patno

i_ens	ldy adr.ORDER,x
	sty pat0+1
	iny
	sty pat1+1
	iny
	sty pat2+1

	lda #0
	sta track_pos

i_end
	lda pause
	sta cnts

	lda consol
	cmp #$06
	bne skp

	lda #$2c	; bit *
	sta stop

skp
	lda regA: #0
	ldx regX: #0
	ldy regY: #0

	rti

.endl


wait	lda skstat		; wait on keypress
	and #4
	beq wait

	lda #$70
	cmp:rne vcount
	rts


stop	jmp *

	jsr wait

	sei
	lda #0
	sta AUDCTL
	sta AUDCTL+$10
	sta NMIEN
	sta IRQEN

	tax
	mva:rne ZPAGE,x 0,x+

	lda #$ff
	sta portb

	mva sdmctl dmactl

	lda irqens
	sta IRQEN

	lda	#3
	sta	skctl

	mva #$40 nmien
	cli

	ldx #0
_rx	equ *-1

};
end;


{$i resource\cnvpattern_asm.inc}

{$i resource\loadmod_portb.inc}


begin

 TextMode(0);		// !!! dziala prawidlowo z VBXE i bez

 writeln('MOD Player 2.3 (6502)');
 writeln;

 dmactl := sdmctl;

 if ParamCount > 0 then begin

 LoadMOD(ParamStr(1));

// LoadMOD('XRAY.MOD');

// writeln;
// writeln('Select: P-okey, C-ovox');

// gchar:=UpCase(readkey);

 Play;

 end;

end.
