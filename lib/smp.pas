unit SMP;
(*
 @type: unit
 @author: Chriss Hutt (Sheddy), Tomasz Biela (Tebe)
 @name: Sample player
 @version: 1.0

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
object for controling RMT player
*)
	adr: pointer;		// memory address of sample
	len: byte;		// pages, sample size

	procedure Play; assembler;

	end;


implementation


procedure PlaySample; interrupt; assembler;
asm
	pha				; save A
	lda #0
value	equ *-1
	sta AUDC4			; play sample ASAP to minimise DMA lag
	tya
	pha				; save Y
	lda #0
	sta IRQEN			; reset interrupt

	ldy $ffff
sample	equ *-2

	lda #4
	sta IRQEN			; re-enable only timer 4
	eor #0				; switch between 0 and 1 (right and left nybble)
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
	sta IRQEN			; end of sample - reset interrupt
	beq irq3			; always branch
irq2	ora #$f0			; no polycounters + volume only bit
irq3	sta value			; save sample to play next irq
	pla
	tay
	pla				; restore Y and A

	rti

size	brk

end;


procedure TSMP.Play; assembler;
(*
@description:
Play music, call this procedure every VBL frame
*)
asm
	sei
	mva #0 IRQEN

	mwa	#MAIN.SMP.PlaySample	$fffe		; setup custom IRQ handler

	mva :bp2	l_hlp+1
	mva :bp2+1	h_hlp+1

	mwa TSMP :bp2

	ldy #0
	lda (:bp2),y
	sta PlaySample.sample
	iny
	lda (:bp2),y
	sta PlaySample.sample+1
	iny
	lda (:bp2),y
	sta PlaySample.size

l_hlp	mva #0 :bp2
h_hlp	mva #0 :bp2+1

	lda #1				; 0=POKEY 64KHz, 1=15KHz
	sta AUDCTL
	lda #3				; ~64KHz clock 16 = ~4Khz timer, ~15KHz clock 4 = ~4KHz
	sta AUDF4			; in timer 1
	lda #$f0			; test - no polycounters + volume only
	sta AUDC4

	lda #4
	sta IRQEN			; enable timer 4

	lda #0
	sta PlaySample.nybble		; initialize nybble
	ldx #$f8
	stx PlaySample.value		; an initial sample value (with no polycounters + volume only bit)

	lda #$70
wait3	cmp VCOUNT
	bne wait3			; sync to a scanline

	lda #0
	sta SKCTL
	lda #3
	sta SKCTL			; test - reset pokey and polycounters
	sta STIMER			; start timers
	cli

end;


end.
