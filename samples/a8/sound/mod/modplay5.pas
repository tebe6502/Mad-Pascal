// 65816 MOD Player Rapidus 1.6 (NMI, IRQ) 48 kHz (POKEY 1.7 MHz) 6bit POKEY #1 (2CH) + #2 (2CH)
// pattern limit = 85
// sample length limit = 65536 bytes

// segment $0e -> program + tablice
// segment $0f -> patterny
// segment $10 -> sample

// volume $de00 - $feff

// playloop		= $0400
// mainloop		= $0400..$5ff

// changes
// 02.11.2018
// 21.08.2022
// 28.08.2022	exit to DOS


program ModPlay;

uses crt, atari, highmem;


//{$define status}

{$resource modplay5.rc}

{$info 65816 MOD Player}

{$include resource\modplayh_hmem.inc}


const

	VOL6BIT = $c000;

	play_smp = $d800;
	main_lop = $0400-$20;

	player = $0e0000;
	pattern_start = $0f0000;	// ..$300 * PATTERN_LIMIT
	sample_start = $100000;


procedure Play; assembler;
asm

/****************************************************************************
  MOVE - copy memory block >...
  X = source
  Y = destination
  A = length-1
*****************************************************************************/
.macro move

 ldx.w #[:1]&$00FFFF
 ldy.w #[:2]&$00FFFF
 lda.w #[:3]

 mvn ^[:1],^[:2]

.endm

	opt c+

.zpvar = $d8

.zpvar nr0, nr1, nr2, nr3, patno, patend, cnts, pause, track_pos .byte
.zpvar pat0, pat1, pat2 .long

	jsr wait

	sei

	stx _rx

	stz nmien
	stz irqen

	mva #$fe portb

	ldx #8
lp	stz AUDF1,x
	stz AUDF1+$10,x
	dex
	bpl lp

	ldx #0
	mva:rne 0,x ZPAGE,x+		; copy $00 page
	mva:rne $300,x ZPAGE+$100,x+	; copy $03 page


;	ldx #0
mv1	lda .adr(mainloop),x
	sta mainloop,x
	lda .adr(mainloop)+$100,x
	sta mainloop+$100,x
	inx
	bne mv1

;	ldx #0
mv0	lda .adr(playloop),x
	sta playloop,x
	inx
	cpx #.sizeof(playloop)
	bne mv0

	lda SONG_LENGTH
	sta mainloop.patmax+1

;	lda SONG_RESTART
;	sta mainloop.patres+1

	lda >volume		; silence
	sta playloop.ivol0+1
	sta playloop.ivol1+1
	sta playloop.ivol2+1
	sta playloop.ivol3+1
/*
	lda POKEY
	bne skip

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

	jmp start
*/

skip	lda >VOLUME		; pokey
	sta mvol+2

	ldy #32			; POKEY volume table
	ldx #0
mvol	lsr VOLUME,x
	inx
	bne mvol

	inc mvol+2
	dey
	bpl mvol

start
	stz dmactl

	stz patno
	stz track_pos

	stz pat0
	stz pat1
	stz pat2

	lda #6
	sta pause
	sta cnts

	lda ^pattern_start
	sta pat0+2
	sta pat1+2
	sta pat2+2

	ldy adr.ORDER
	sty pat0+1
	iny
	sty pat1+1
	iny
	sty pat2+1


	clc:xce

	.ia 16

	phb
	move $0000 player $1000-1
	move $c000 player+$c000 $1000-1
	move $d800 player+$d800 $2700-1
	plb

	.ia 8


	mwa	#nmi nmivec16		; custom NMI handler
	mwa	#irq irqvec16		; custom IRQ handler


	;set IRQ position in scanline for consistency and disable keyboard scan

	sta	wsync

	lda	#0
	sta	skctl
	sta	skctl+$10

	sta	audctl+$10


;	mva	#$01	AUDCTL		; 0=POKEY 64KHz, 1=15KHz

	mva #%01000000	AUDCTL

	mva #32	AUDF1			; 48 kHz

	mva #$01	IRQEN

;	lda	#1
	sta	skctl
	sta	skctl+$10
	sta	stimer

	mva	#$40	nmien

	mwa sdlstl dlistl
;	mva sdmctl dmactl

	lda ^player
	pha
	plb

	cli

	jmp player+mainloop.stop


IRQ	jmp player+playloop	; PLAYLOOP

NMI	jmp player+mainloop	; MAINLOOP


.local	playloop,play_smp

;	phb

	.ia16

	sta regA
	stx regX

	.ia8

	lda #0			; opcode 'inc.l' not exists
	sta.l IRQEN
	lda #1
	sta.l IRQEN


	ldx voice: #0

	lda vol6bit,x
	sta.l audc1+$10

	lda vol6bit+$100,x
	sta.l audc2+$10

	lda vol6bit+$200,x
	sta.l audc3+$10


	ldx voice_: #0

	lda vol6bit,x
	sta.l audc1

	lda vol6bit+$100,x
	sta.l audc2

	lda vol6bit+$200,x
	sta.l audc3


	.ifdef MAIN.@DEFINES.STATUS
	lda #$0f
	sta.l colbak
	.endif

; ---
; ---	AUDC 1
; ---

	clc

ist_0	lda #0
iad0_m	adc #0
	sta ist_0+1
	lda p_0c+1
iad0_s	adc #0
	bcc ext_0

	inc p_0c+2
	bne ext_0

ire0_s	lda #0
	sta p_0c+2
ire0_m	lda #0

ext_0	sta p_0c+1


; ---
; ---	AUDC 2
; ---

	clc

ist_1	lda #0
iad1_m	adc #0
	sta ist_1+1
	lda p_1c+1
iad1_s	adc #0
	bcc ext_1

	inc p_1c+2
	bne ext_1

ire1_s	lda #0
	sta p_1c+2
ire1_m	lda #0

ext_1	sta p_1c+1


; ---
; ---	AUDC 3
; ---

	clc

ist_2	lda #0
iad2_m	adc #0
	sta ist_2+1
	lda p_2c+1
iad2_s	adc #0
	bcc ext_2

	inc p_2c+2
	bne ext_2

ire2_s	lda #0
	sta p_2c+2
ire2_m	lda #0

ext_2	sta p_2c+1


; ---
; ---	AUDC 4
; ---

	clc

ist_3	lda #0
iad3_m	adc #0
	sta ist_3+1
	lda p_3c+1
iad3_s	adc #0
	bcc ext_3

	inc p_3c+2
	bne ext_3

ire3_s	lda #0
	sta p_3c+2
ire3_m	lda #0

ext_3	sta p_3c+1


p_0c	lda.l sample_start+$FFFF	; ch #1
	sta ivol0
p_1c	lda.l sample_start+$FFFF	; ch #2
	sta ivol1
p_2c	lda.l sample_start+$FFFF	; ch #3
	sta ivol2
p_3c	lda.l sample_start+$FFFF	; ch #4
	sta ivol3

	clc
	lda ivol0: volume
	adc ivol3: volume
	sta voice


	clc
	lda ivol1: volume
	adc ivol2: volume
	sta voice_


	.ifdef MAIN.@DEFINES.STATUS
	lda #$00
	sta.l colbak
	.endif


	.ia16

	lda.w regA: #0
	ldx.w regX: #0

;	plb
	rti

	.print 'PLAY_SMP: ',*

.endl


; ----------------------------------------
; copy to HighMem
; ----------------------------------------

.local	mainloop,main_lop

;	phb

	.ai16

	sta regA
	stx regX
	sty regY

	.ai8

	dec cnts
	seq
	jmp nmiExit

	stz patend

	ldy track_pos

*---------------------------
* track  0

i_0	;ldy #1
	lda [pat1],y
	sta i_0c+1
	and #$1f
	beq i_0c
	tax
	sta nr0
	lda adr.tivol-1,x
	sta playloop.ivol0+1

i_0c	ldx EFFECT
	beq i_0f
	cpx #$40
	bne @+
	;ldy #2
	lda [pat2],y
	sta playloop.ivol0+1
@	cpx #$c0
	bne @+
	;ldy #2
	lda [pat2],y
	sta pause
@	cpx #$80
	bne i_0f
	stx patend

i_0f	;ldy #0
	lda [pat0],y
	beq i_1
	tax
	lda tadcl-1,x
	sta playloop.iad0_m+1
	lda tadch-1,x
	sta playloop.iad0_s+1

	stz playloop.ist_0+1

	ldx nr0
	txa
	add ^sample_start-1
	sta playloop.p_0c+3

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
	lda [pat1],y
	sta i_1c+1
	and #$1f
	beq i_1c
	tax
	sta nr1
	lda adr.tivol-1,x
	sta playloop.ivol1+1

i_1c	ldx EFFECT
	beq i_1f
	cpx #$40
	bne @+
	;ldy #5
	lda [pat2],y
	sta playloop.ivol1+1
@	cpx #$c0
	bne @+
	;ldy #5
	lda [pat2],y
	sta pause
@	cpx #$80
	bne i_1f
	stx patend

i_1f	;ldy #3
	lda [pat0],y
	beq i_2
	tax
	lda tadcl-1,x
	sta playloop.iad1_m+1
	lda tadch-1,x
	sta playloop.iad1_s+1

	stz playloop.ist_1+1

	ldx nr1
	txa
	add ^sample_start-1
	sta playloop.p_1c+3

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
	lda [pat1],y
	sta i_2c+1
	and #$1f
	beq i_2c
	tax
	sta nr2
	lda adr.tivol-1,x
	sta playloop.ivol2+1

i_2c	ldx EFFECT
	beq i_2f
	cpx #$40
	bne @+
	;ldy #8
	lda [pat2],y
	sta playloop.ivol2+1
@	cpx #$c0
	bne @+
	;ldy #8
	lda [pat2],y
	sta pause
@	cpx #$80
	bne i_2f
	stx patend

i_2f	;ldy #6
	lda [pat0],y
	beq i_3
	tax
	lda tadcl-1,x
	sta playloop.iad2_m+1
	lda tadch-1,x
	sta playloop.iad2_s+1

	stz playloop.ist_2+1

	ldx nr2
	txa
	add ^sample_start-1
	sta playloop.p_2c+3

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
	lda [pat1],y
	sta i_3c+1
	and #$1f
	beq i_3c
	tax
	sta nr3
	lda adr.tivol-1,x
	sta playloop.ivol3+1

i_3c	ldx EFFECT
	beq i_3f
	cpx #$40
	bne @+
	;ldy #11
	lda [pat2],y
	sta playloop.ivol3+1
@	cpx #$c0
	bne @+
	;ldy #11
	lda [pat2],y
	sta pause
@	cpx #$80
	bne i_3f
	stx patend

i_3f	;ldy #9
	lda [pat0],y
	beq i_e
	tax
	lda tadcl-1,x
	sta playloop.iad3_m+1
	lda tadch-1,x
	sta playloop.iad3_s+1

	stz playloop.ist_3+1

	ldx nr3
	txa
	add ^sample_start-1
	sta playloop.p_3c+3

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

	stz track_pos

i_end
	lda pause
	sta cnts

nmiExit
	lda.l consol
	cmp #$06
	bne skp

	lda #$2c	; bit *
	sta stop

skp

	.ia16

	lda.w regA: #0
	ldx.w regX: #0
	ldy.w regY: #0

;	plb
	rti


stop	jmp *			; do nothing

	.ia8

	lda #0
	pha
	plb

	jml stop2

.endl


; ----------------------------------------
; memory bank #0 (0000..FFFF)
; ----------------------------------------

wait	lda skstat	; wait on keypress
	and #4
	beq wait

	lda:rne vcount
	rts

stop2
	lda:rne vcount

	sei
	stz NMIEN
	stz IRQEN

	stz AUDCTL
	stz AUDCTL+$10

	ldx #0
	mva:rne ZPAGE,x 0,x+		; restore $00 page
	mva:rne ZPAGE+$100,x $300,x+	; restore $03 page

	sec:xce

	lda #$ff
	sta portb

	mva sdmctl dmactl

	lda irqens
	sta IRQEN

	lda	#3
	sta	skctl
	sta	skctl+$10

	ldx _rx: #0

	mva #$40 nmien
	cli

	opt c-

end;


{$include resource\cnvpattern_asm.inc}


{$include resource\loadmod_hmem.inc}


begin

 TextMode(0);		// !!! dziala prawidlowo z VBXE i bez

 writeln('MOD Player Rapidus 1.6 (65816)');
 writeln;


 if ParamCount > 0 then begin

 LoadMOD(ParamStr(1));

// LoadMOD('POPCORN.MOD');

// writeln;
// writeln('Select: P-okey, C-ovox');

// gchar:=UpCase(readkey);

 Play;

 end;

 halt(0);

end.
