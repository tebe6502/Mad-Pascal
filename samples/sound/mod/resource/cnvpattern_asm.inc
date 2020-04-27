

function CnvPattern: cardinal; assembler;
asm
{
	lda #0
	sta Result
	sta Result+1
	sta Result+2
	sta Result+3

	lda adr.BUF
	and #$f
	ora adr.BUF+1
	beq _sil

	ldy #0
_tst	lda adr.KOD,y
	cmp adr.BUF+1
	bne pls
	lda adr.BUF		;kod dzwieku
	and #$f
	cmp adr.KOD+1,y
	bne pls
	iny
	iny
	tya
	lsr @
; ldy #0
	sta Result		;czestotliwosc

	lda adr.BUF+2		;oblicz nr instr
	lsr @
	lsr @
	lsr @
	lsr @
	sta or_+1
	lda adr.BUF
	and #$f0
or_	ora #0
	and #$1f
; ldy #1
_con	sta Result+1		;numer instrumentu

; ldy #2
	lda #0
	sta Result+2
; dey
	lda adr.BUF+2
	and #$f
	cmp #$c
	beq _vol		; Effect Cxy (Set Volume)
	cmp #$f
	beq _tmp		; Effect Fxy (Set Speed)
	cmp #$d
	beq _break		; Effect Dxy (Pattern Break)
	jmp stop

_sil	sta Result
	beq _con

_break	lda #$80
	ora Result+1
	sta Result+1
	bne stop

_vol	lda #$40
	ora Result+1
	sta Result+1

	lda adr.BUF+3		;parametr komendy

	lsr @
	clc
	adc >VOLUME
	sta Result+2
	bne stop

_tmp	lda adr.BUF+3
	cmp #$20
	bcs _tq
	lda #$c0
	ora Result+1
	sta Result+1
; ldy #2
	lda adr.BUF+3		;parametr komendy
	and #$1f
	sta Result+2
_tq
	jmp stop

pls	iny
	iny
	cpy #96

	jne _tst

stop
};
end;
