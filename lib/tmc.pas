unit tmc;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Theta Music Player library
 @version: 1.0

 @description:
 <http://atariki.krap.pl/index.php/Chaos_Music_Composer>
*)


{

TTMC.Init
TTMC.Play
TTMC.Stop
TTMC.Pause
TTMC.Cont
TTMC.InitNoSong
TTMC.Song

}

interface

type	TTMC = Object
(*
@description:
object for controling CMC player
*)
	player: pointer;		// memory address of player
	modul: pointer;			// memory address of a module

	procedure Init; assembler;            // initialize player and select song #0
	procedure Play; assembler;            // play
	procedure Sound(ln: byte); assembler; // sound at line LN
	procedure Stop; assembler;            // stops music

	end;


implementation

uses misc;

var	ntsc: byte;
	player_enabled: Boolean;


procedure TTMC.Init; assembler;
(*
@description:
Initialize TMC player and select song #0
*)
asm
	txa:pha

	mwa TTMC :bp2

	ldy #0
	lda (:bp2),y
	add #3		; jsr player+3
	sta adr
	iny
	lda (:bp2),y
	adc #0
	sta adr+1

	ldy #3
	lda (:bp2),y
	tax		; low byte of RMT module to X reg
	dey
	lda (:bp2),y
	tay		; hi byte of RMT module to Y reg

	lda #$70
	jsr init

	ldx #0
	txa
	jsr init

	lda #$10
	ldx #0
	jsr init

	lda #1
	sta player_enabled

	jmp stop

init	jmp $ffff
adr	equ *-2

stop	pla:tax
end;


procedure TTMC.Play; assembler;
(*
@description:
Play music, call this procedure every VBL frame
*)
asm
	txa:pha

	lda player_enabled
	beq quit

	asl ntsc		; =0 PAL, =4 NTSC
	bcc skp

	lda #%00000100
	sta ntsc

	bne quit
skp
	mwa TTMC adr

	ldy #1
mov	lda $ff00,y
adr	equ *-2
	sta ptr,y
	dey
	bpl mov

	clc

	jsr $ff00		; jmp (TCMC)	6502 buggy indirect jump
ptr	equ *-2

quit	pla:tax

end;


procedure TTMC.Stop; assembler;
(*
@description:
Halt TMC player
*)
asm
	lda #0
	sta player_enabled

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


procedure TTMC.Sound(ln: byte); assembler;
(*
@description:
Continue TMC player
*)
asm
	txa:pha

	mwa TTMC adr

	ldy #1
mov	lda $ff00,y
adr	equ *-2
	sta ptr,y
	dey
	bpl mov

wait	lda $d40b
	cmp ln
	bne wait

	sec

	jsr $ff00
ptr	equ *-2

	pla:tax
end;


initialization

if DetectAntic then
 ntsc:=0
else
 ntsc:=4;

end.
