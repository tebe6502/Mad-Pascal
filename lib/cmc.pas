unit CMC;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Chaos Music Player library
 @version: 1.0

 @description:
 <http://atariki.krap.pl/index.php/Chaos_Music_Composer>
*)


{

TCMC.Init
TCMC.Play
TCMC.Stop

}

interface

type	TCMC = Object
(*
@description:
object for controling CMC player
*)
	player: pointer;		// memory address of player
	modul: pointer;			// memory address of a module

	procedure Init; assembler;	// initializes
	procedure Play; assembler;	// play
	procedure Pause; assembler;	// pause
	procedure Cont; assembler;	// continue
	procedure Stop; assembler;	// stops music

	end;


implementation


procedure TCMC.Init; assembler;
(*
@description:
Initialize CMC player
*)
asm
{	txa:pha

	mwa TCMC :bp2

	ldy #0
	lda (:bp2),y
	add #3		; jsr player+3
	sta adr
	iny
	lda (:bp2),y
	adc #0
	sta adr+1

	iny
	lda (:bp2),y
	tax		; low byte of RMT module to X reg
	iny
	lda (:bp2),y
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
(*
@description:
Play music, call this procedure every VBL frame
*)
asm
{	txa:pha

	mwa TCMC ptr

	ldy #1
cptr	lda $ffff,y
ptr	equ *-2
	sta adr,y
	dey
	bpl cptr

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TCMC.Stop; assembler;
(*
@description:
Halt CMC player
*)
asm
{	txa:pha

	mwa TCMC :bp2

	ldy #0
	lda (:bp2),y
	add #3		; jsr player+3
	sta adr
	iny
	lda (:bp2),y
	adc #0
	sta adr+1

	lda #$40

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TCMC.Pause; assembler;
(*
@description:
Interrupt CMC player
*)
asm
{	txa:pha

	mwa TCMC :bp2

	ldy #0
	lda (:bp2),y
	add #3		; jsr player+3
	sta adr
	iny
	lda (:bp2),y
	adc #0
	sta adr+1

	lda #$50

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TCMC.Cont; assembler;
(*
@description:
Continue CMC player
*)
asm
{	txa:pha

	mwa TCMC :bp2

	ldy #0
	lda (:bp2),y
	add #3		; jsr player+3
	sta adr
	iny
	lda (:bp2),y
	adc #0
	sta adr+1

	lda #$60

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;

end.

