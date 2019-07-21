unit MPT;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Music Pro Tracker library
 @version: 1.0

 @description:
 <http://atariki.krap.pl/index.php/Music_Protracker>
*)


{

TMPT.Init
TMPT.Play
TMPT.Stop

}

interface

type	TMPT = Object
(*
@description:
object for controling MPT player
*)
	player: pointer;		// memory address of player
	modul: pointer;			// memory address of a module

	procedure Init; assembler;	// Initializes
	procedure Play; assembler;
	procedure Stop; assembler;	// Stops Music

	end;

implementation


procedure TMPT.Init; assembler;
(*
@description:
Initialize MPT player
*)
asm
{	txa:pha

	mwa TMPT :bp2

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
	tax		; low byte of MPT module to X reg
	iny
	lda (:bp2),y
	tay		; hi byte of MPT module to Y reg

	jsr $ffff
adr	equ *-2

	pla:tax
};
end;


procedure TMPT.Play; assembler;
(*
@description:
Play music, call this procedure every VBL frame
*)
asm
{	txa:pha

	mwa TMPT ptr

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


procedure TMPT.Stop; assembler;
(*
@description:
Halt MPT player
*)
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

