unit md1;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Music Pro Tracker sample MD1 (D15, D8)
 @version: 1.0 (2025-08-18)

 @description:
 <http://atariki.krap.pl/index.php/Music_Protracker>
*)


{

TMD1.Init
TMD1.Play
TMD1.Digi
TMD1.Stop

}

interface

type	TMD1 = Object
(*
@description:
object for controling TMD1 player
*)
	jmp: byte;			// $4c

	player: pointer;		// memory address of player
	modul: pointer;			// memory address of a module
	sample: pointer;

	procedure Init;					// Initializes
	procedure Play; assembler;			// play music
	procedure Digi(kHz15: Boolean); assembler;	// play digi sample
	procedure Stop; assembler;			// Stops Music

	end;

implementation

uses misc;

var	ntsc: byte;
        player_enabled: Boolean;


procedure TMD1.Init;
(*
@description:
Initialize TMD1 player
*)
var i, a: byte;
    s0: PByte register;
    s1: PByte register;
begin


 s0:=sample;
 s1:=sample + 16;
 
 a:=hi(word(sample)) - s0[0];	// [new sample address] - [sample ORIGIN address]
 
 for i:=15 downto 0 do
  if s0[i] <> 0 then begin
  
    s0[i]:=s0[i] + a;
    s1[i]:=s1[i] + a;
 
  end;
	

asm
	txa:pha

	lda TMD1
	sta :bp2
	sta adr
	lda TMD1+1
	sta :bp2+1
	sta adr+1

	ldy #0
	lda #$4c	; jmp
	sta (:bp2),y

	ldy #4
	lda (:bp2),y
	tax		; hi byte of TMD1 module to X reg
	dey
	lda (:bp2),y
	tay		; low byte of TMD1 module to Y reg

	lda #$00
	jsr ini

	ldx #0
	lda #2
	jsr ini

	ldy #6
	lda (:bp2),y
	tax		; hi byte of TMD1 sample to X reg
	dey
	lda (:bp2),y
	tay		; low byte of TMD1 sample to Y reg
	lda #3
	jsr ini

	lda #1
	sta player_enabled

	jmp quit

ini	sec		; C = 1
	jsr $ffff
adr	equ *-2

	rts

quit
	pla:tax
end;

end;


procedure TMD1.Digi(kHz15: Boolean); assembler;
(*
@description:
Play music, call this procedure every VBL frame
*)
asm
	txa:pha

	mwa TMD1 ptr

	lda #5			; sample
	ldx kHz15		; 1 - 15kHz ; 0 - 8kHz
	sec			; C = 1

	jsr $ff00		; jmp (TMD1)	6502 buggy indirect jump
ptr	equ *-2

quit	pla:tax
end;


procedure TMD1.Play; assembler;
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
	mwa TMD1 ptr		; C = 0

	jsr $ff00		; jmp (TMD1)	6502 buggy indirect jump
ptr	equ *-2

quit	pla:tax
end;


procedure TMD1.Stop; assembler;
(*
@description:
Halt TMD1 player
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


initialization

if DetectAntic then
 ntsc:=0
else
 ntsc:=4;

end.
