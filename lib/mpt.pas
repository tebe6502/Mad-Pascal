unit mpt;

{

TMPT.Init
TMPT.Play
TMPT.Stop

}

interface

type
	TMPT = Object

	player: pointer;
	modul: pointer;

	procedure Init; assembler;
	procedure Play; assembler;
	procedure Stop; assembler;

	end;

implementation


procedure TMPT.Init; assembler;
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
	tax		; low byte of MPT module to X reg
	iny
	lda (bp2),y
	tay		; hi byte of MPT module to Y reg

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TMPT.Play; assembler;
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


procedure TMPT.Stop; assembler;
asm
{	lda #0
	sta $d208
	sta $d218
	ldy #3
	sty $d20f
	sty $d21f
	ldy #8
si1	sta $d200,y
	sta $d210,y
	dey
	bpl si1
};
end;


end.

