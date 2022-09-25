unit SAPLZSS;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: SAP-R LZSS Player
 @version: 1.0

 @description:
 <https://github.com/dmsc/lzss-sap>
*)


{

TLZSSPlay.Init
TLZSSPlay.Decode
TLZSSPlay.Play
TLZSSPlay.Stop

}

interface

type	TLZSSPlay = Object
(*
@description:
object for controling SAP-R LZSS Player
*)
	jmp: byte;			// dta $4c

	player: pointer;		// memory address of a player
	modul: pointer;			// memory address of a module

	// A = POKEY address (low byte), $00 -> $d200, $10 -> $d210

	procedure Init(a: byte); assembler;	// initializes
	procedure Decode; assembler; 		// decode stream
	procedure Play; assembler;		// play
	procedure Stop; assembler;		// stops music

	end;


implementation



procedure TLZSSPlay.Init(a: byte); assembler;
(*
@description:
Initialize SAP-R LZSS player
*)
asm
	txa:pha

	mwa TLZSSPlay :bp2

	ldy #0
	lda #$4c	; JMP
	sta (:bp2),y

	iny
	lda (:bp2),y
	add #6		; jsr player+6
	sta adr
	iny
	lda (:bp2),y
	adc #0
	sta adr+1

	ldy #4
	lda (:bp2),y
	tax		; hi byte of MPT module to Y reg
	dey
	lda (:bp2),y	; low byte of MPT module to X reg

	ldy a		; POKEY: $00 | $10 | ...

	jsr $ffff
adr	equ *-2

	pla:tax
end;


procedure TLZSSPlay.Decode; assembler;
(*
@description:
Decode stream music
*)
asm
	mwa TLZSSPlay ptr

	clc

	jsr $ff00		; jmp (TLZSSPlay)	6502 buggy indirect jump
ptr	equ *-2

end;


procedure TLZSSPlay.Play; assembler;
(*
@description:
Play music
*)
asm
	mwa TLZSSPlay ptr

	sec

	jsr $ff00		; jmp (TLZSSPlay)	6502 buggy indirect jump
ptr	equ *-2
end;


procedure TLZSSPlay.Stop; assembler;
(*
@description:
Halt SAP-R LZSS player
*)
asm
	lda #0
	sta $d208
	sta $d218
	ldy #3
	sty $d20f
	sty $d21f
	ldy #8
clr	sta $d200,y
	sta $d210,y
	dey
	bpl clr
end;


initialization


end.
