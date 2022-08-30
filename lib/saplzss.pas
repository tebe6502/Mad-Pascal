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
TLZSSPlay.Play
TLZSSPlay.Stop

}

interface

type	TLZSSPlay = Object
(*
@description:
object for controling SAP-R LZSS Player
*)
	data: pointer;			// SAP-R LZSS data address
	size: word;			// SAP-R LZSS data size
	buffer: byte;			// SAP-R LZSS buffer (hi byte), 9*256 bytes
	pokey: byte;			// POKEY address (low byte), $00 -> $d200, $10 -> $d210

	procedure Init; assembler;	// initializes
	procedure Play; assembler;	// play
	procedure Stop; assembler;	// stops music

	end;


implementation

uses misc;

const
	sap_lzss.zp = $e0;

var	ntsc: byte;


{$link saplzss.obx}


procedure TLZSSPlay.Init; assembler;
(*
@description:
Initialize SAP-R LZSS player
*)
asm
	txa:pha

	lda TLZSSPlay
	ldy TLZSSPlay+1

	jsr sap_lzss.init

	pla:tax
end;


procedure TLZSSPlay.Play; assembler;
(*
@description:
Play music, call this procedure every VBL frame
*)
asm
	asl ntsc		; =0 PAL, =4 NTSC
	bcc skp

	lda #%00000100
	sta ntsc

	bne @exit
skp
	jmp sap_lzss.play
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

if DetectAntic then
 ntsc:=0
else
 ntsc:=4;

end.
