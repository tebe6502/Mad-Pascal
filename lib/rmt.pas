unit rmt;

{

TRMT.Init
TRMT.Play
TRMT.Stop

}

interface

type
	TRMT = Object

	player: pointer;
	modul: pointer;

	procedure Init(a: byte); assembler;
	procedure Play; assembler;
	procedure Sfx(effect, channel, note: byte); assembler;
	procedure Stop; assembler;

	end;



implementation


procedure TRMT.Init(a: byte); assembler;
asm
{	txa:pha

	ldy #0
	lda (bp2),y
	add #3		; jsr player+3
	sta adr
	iny
	lda (bp2),y
	adc #0
	sta adr+1

	iny
	lda (bp2),y
	tax		; low byte of RMT module to X reg
	iny
	lda (bp2),y
	tay		; hi byte of RMT module to Y reg

	lda a		; starting song line 0-255 to A reg
	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TRMT.Sfx(effect, channel, note: byte); assembler;
asm
{	txa:pha

	ldy #0
	lda (bp2),y
	add #15		; jsr player+15
	sta adr
	iny
	lda (bp2),y
	adc #0
	sta adr+1

	lda effect
	asl @
	tay

	ldx channel
	lda note

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TRMT.Play; assembler;
asm
{	txa:pha

	ldy #0
	lda (bp2),y
	sta adr
	iny
	lda (bp2),y
	sta adr+1

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TRMT.Stop; assembler;
asm
{	txa:pha

	ldy #0
	lda (bp2),y
	add #9		; jsr player+9
	sta adr
	iny
	lda (bp2),y
	adc #0
	sta adr+1

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


end.

