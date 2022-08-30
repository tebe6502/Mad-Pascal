unit LZSSPLAY;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: LZSS Player
 @version: 1.0

 @description:

*)


{

TLZSSPlay.Init
TLZSSPlay.Play

}

interface

type	TLZSSPlay = Object
(*
@description:
object for controling LZSS Player
*)
	data: pointer;			// memory address of lzss_data
	size: word;			// size of data

	procedure Init; assembler;	// initializes
	procedure Play; assembler;	// play

	end;


implementation

uses misc;

var	ntsc: byte;


{$codealign link = $100}

{$link playlzss.obx}

{$codealign link = 0}



procedure TLZSSPlay.Init; assembler;
(*
@description:
Initialize LZSS Player
*)
asm
	txa:pha

	lda TLZSSPlay
	ldy TLZSSPlay+1

	jsr lzss_init

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
	jmp lzss_play
end;


initialization

if DetectAntic then
 ntsc:=0
else
 ntsc:=4;

end.
