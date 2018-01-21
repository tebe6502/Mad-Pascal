unit cmc;

{

TCMC.Init
TCMC.Play
TCMC.Stop

}

interface

type
	TCMC = Object

	player: pointer;
	modul: pointer;

	procedure Init; assembler;
	procedure Play; assembler;
	procedure Stop; assembler;

	end;


implementation


procedure TCMC.Init; assembler;
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

	lda #$70
	jsr init

	ldx #0
	txa
	jsr init

	jmp stop

init	jmp $ffff
adr	equ *-2

stop	pla:tax
};
end;


procedure TCMC.Play; assembler;
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


procedure TCMC.Stop; assembler;
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

	lda #$40

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


end.

