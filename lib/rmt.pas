unit rmt;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Raster Music Player library
 @version: 1.1

 @description:
 <http://atariki.krap.pl/index.php/Rmt>
*)

{

TRMT.Init
TRMT.Play
TRMT.Sfx
TRMT.Stop

}

interface

type	TRMT = Object
(*
@description:
object for controling RMT player
*)
	player: pointer;	// memory address of player
	modul: pointer;		// memory address of a module

	procedure Init(a: byte); assembler;	// Initializes
	procedure Play; assembler;
	procedure Sfx(effect, channel, note: byte); assembler;
	procedure Stop; assembler;		// Stops Music

	end;


implementation

uses misc;

var	ntsc: byte;
	player_enabled: Boolean;


procedure TRMT.Init(a: byte); assembler;
(*
@description:
Initialize RMT player

@param: a - song number

player: lsb = $00 ; msb = $xx
*)
asm
	txa:pha

	mwa TRMT :bp2

	ldy #1
	lda (:bp2),y
	sta adr+2

	iny
	lda (:bp2),y
	tax		; low byte of RMT module to X reg
	iny
	lda (:bp2),y
	tay		; hi byte of RMT module to Y reg

	sty player_enabled

	lda a		; starting song line 0-255 to A reg
adr	jsr $ff03	; jsr player+3

	pla:tax
end;


procedure TRMT.Sfx(effect, channel, note: byte); assembler;
(*
@description:
Play sound effect

@param: effect - sound effect number
@param: channel
@param: note
*)
asm
	txa:pha

	mwa TRMT adr+1

	ldy #1
adr	lda $ffff,y
	sta ptr+2

	lda effect
	asl @
	tay

	ldx channel
	lda note

ptr	jsr $ff0f	; jsr player+15

	pla:tax
end;


procedure TRMT.Play; assembler;
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
	mwa TRMT adr+1

	ldy #1
adr	lda $ffff,y
	sta ptr+2

ptr	jsr $ff00		; jmp (TRMT)	6502 buggy indirect jump

quit	pla:tax
end;


procedure TRMT.Stop; assembler;
(*
@description:
Halt RMT player
*)
asm
	txa:pha

	mwa TRMT :bp2

	ldy #1
	lda (:bp2),y
	sta adr+2

adr	jsr $ff09	; jsr player+9

	lda #$00
	sta player_enabled

	pla:tax
end;


initialization

if DetectAntic then
 ntsc:=0
else
 ntsc:=4;

end.

