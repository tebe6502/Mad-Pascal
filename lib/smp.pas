unit smp;
(*
 @type: unit
 @author: Chriss Hutt (Sheddy), Tomasz Biela (Tebe)
 @name: Sample player
 @version: 1.1 (2025-08-19)

 @description:
 
*)

{

TSMP.Play

}

{$define romoff}


interface

type	TSMP = Object
(*
@description:
*)
	adr: pointer;		// memory address of sample
	len: byte;		// pages, sample size

	procedure Play; assembler;

	end;


implementation


procedure PlaySample; interrupt; assembler;
(*
@description:
*)
asm
	sta regA			; save A

	lda #0
value	equ *-1
	sta AUDC4			; play sample ASAP to minimise DMA lag

	sty regY			; save Y

	lda #0
	sta IRQEN			; reset interrupt

	ldy $ffff
sample	equ *-2

	lda #4
	sta IRQEN			; re-enable only timer 4
	eor #0				; switch between 0 and 4 (right and left nybble)
nybble	equ *-1
	sta nybble
	beq irq1

	tya
	lsr @
	lsr @
	lsr @
	lsr @				; left nybble of sample
	bpl irq2			; always branch

irq1	tya
	and #$0f			; right nybble of sample

	inc sample			; next lo byte of sample
	bne irq2
	inc sample+1			; next hi byte of sample

	dec size			; check if at end of sample
	bne irq2			; branch if not

	lda #0
IRQ_l	equ *-1
	sta irqvec

	lda #0
IRQ_h	equ *-1
	sta irqvec+1

	lda #0
IRQ_s	equ *-1
	sta IRQEN

	lda #0
size	equ *-1				; = 0
//	sta IRQEN			; end of sample - restore OLD IRQ interrupt
	beq irq3			; always branch

irq2	ora #$f0			; no polycounters + volume only bit
irq3	sta value			; save sample to play next irq

	lda regA: #$00			; restore Y and A
	ldy regY: #$00
end;


procedure TSMP.Play; assembler;
(*
@description:

*)
asm
	sei
	mvy #0 IRQEN

	mwa #MAIN.SMP.PlaySample irqvec	; setup custom IRQ handler

	lda :bp2
	pha
	lda :bp2+1
	pha

	mwa TSMP :bp2

	lda (:bp2),y			; Y = 0
	sta PlaySample.sample
	iny
	lda (:bp2),y
	sta PlaySample.sample+1
	iny
	lda (:bp2),y
	sta PlaySample.size

	pla
	sta :bp2+1
	pla
	sta :bp2

	lda #1				; 0=POKEY 64KHz, 1=15KHz
	sta AUDCTL
	lda #3				; ~64KHz clock 16 = ~4Khz timer, ~15KHz clock 4 = ~4KHz
	sta AUDF4			; in timer 1
	lda #$f0			; test - no polycounters + volume only
	sta AUDC4

	lda #4
	sta IRQEN			; enable timer 4
	sta irqens			; !!! NTSC NEED

	lda #$f8
	sta PlaySample.value		; an initial sample value (with no polycounters + volume only bit)
	lda #0
	sta PlaySample.nybble		; initialize nybble

	ldy #$70
wait3	cpy VCOUNT
	bne wait3			; sync to a scanline

	sta SKCTL			; A = 0
	lda #3
	sta SKCTL			; test - reset pokey and polycounters
	sta STIMER			; start timers

	cli
end;


initialization

asm
	lda irqens
	sta MAIN.SMP.PlaySample.IRQ_s

	lda irqvec
	sta MAIN.SMP.PlaySample.IRQ_l
	lda irqvec+1
	sta MAIN.SMP.PlaySample.IRQ_h
end;

end.
