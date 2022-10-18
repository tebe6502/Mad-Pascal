unit vbxeansi;
(*
 @type: unit
 @author: Joseph Zatarski, Tomasz Biela
 @name: terminal emulator that supports ANSI/ECMA-48 control sequences and a 256 character font

 @version: 1.0

 @description:
 <https://forums.atariage.com/topic/225063-full-color-ansi-vbxe-terminal-in-the-works/>

 <https://en.wikipedia.org/wiki/ANSI_escape_code>
*)

{

AnsiChar
ClrScr
NormVideo
SetOverlayAddress
TextOut

}

interface

{$DEFINE A_VBXE}

{$i vbxe_memorystream_type.inc}

const

  VBXE_ANSIADR = $080000 - 24*80*2;	// ..48*160
  VBXE_ANSIFRE = VBXE_ANSIADR + 48*80*2;

  VBXE_ANSIXDL = $000800;

 // text colors

  tcBlack          = 0;
  tcRed            = 1;
  tcGreen          = 2;
  tcYellow         = 3;
  tcBlue           = 4;
  tcMagenta        = 5;
  tcCyan           = 6;
  tcWhite          = 7;
  tcBrightBlack    = 8;
  tcBrightRed      = 9;
  tcBrightGreen    = 10;
  tcBrightYellow   = 11;
  tcBrightBlue     = 12;
  tcBrightMagenta  = 13;
  tcBrightCyan     = 14;
  tcBrightWhite    = 15;

 // background colors

  bcBlack        = $80;
  bcRed          = $90;
  bcGreen        = $a0;
  bcYellow       = $b0;
  bcBlue         = $c0;
  bcMagenta      = $d0;
  bcCyan         = $e0;
  bcWhite        = $f0;


var
	row_slide_status: Boolean;		// status = TRUE -> row #0 was copied to the buffer ($0400..$049F)


	procedure TextOut(a: string); overload;
	procedure TextOut(a: char); overload;
	procedure AnsiChar(a: char); assembler;
	procedure SetOverlayAddress(a: cardinal); assembler;

	procedure ClrScr; assembler;

	procedure NormVideo; assembler;


implementation


{$i vbxe_memorystream.inc}


procedure SetOverlayAddress(a: cardinal); assembler;
(*
@description:
Set Overlay Address (XDLC_OVADR)

*)
asm
	fxs FX_MEMS #$80

	lda a
	sta MAIN.SYSTEM.VBXE_WINDOW+VBXE_ANSIXDL+8
	lda a+1
	sta MAIN.SYSTEM.VBXE_WINDOW+VBXE_ANSIXDL+9
	lda a+2
	sta MAIN.SYSTEM.VBXE_WINDOW+VBXE_ANSIXDL+10

	fxs FX_MEMS #$00
end;


procedure SetCursor; assembler;
(*
@description:
Set Cursor address, colors

*)

asm
	lda colpf2s
	ora colpf1s
	sta fildat

	jsr @ansi.cursor_set
end;


procedure ClrScr; assembler;
(*
@description:
Clears the current window (using the current colors), and sets the cursor in the top left corner of the current window.

*)
asm
	txa:pha

	fxs FX_MEMS #$ff

	jsr @ansi.FF_adr

	fxs FX_MEMS #$00

	pla:tax
end;


procedure AnsiChar(a: char); assembler;
(*
@description:
ANSI character processing

*)
asm
	txa:pha

	fxs FX_MEMS #$ff

	lda a
	sta atachr

	jsr @ansi.process_char

	fxs FX_MEMS #$00

	pla:tax
end;


procedure PutChar(a: char); assembler; inline;
(*
@description:
Put char to screen

*)
asm
	txa:pha

	lda a
	sta atachr

	jsr @ansi.put_byte

	pla:tax
end;


procedure TextOut(a: char); overload;
(*
@description:

*)

begin

 asm
	fxs FX_MEMS #$ff
 end;

 SetCursor;

 PutChar(a);

 asm
	fxs FX_MEMS #$00
 end;

end;


procedure TextOut(a: string); overload;
(*
@description:

*)

var i: byte;
begin

 asm
	fxs FX_MEMS #$ff
 end;

 SetCursor;

 for i:=1 to length(a) do PutChar(a[i]);

 asm
	fxs FX_MEMS #$00
 end;

end;


procedure NormVideo; assembler;
(*
@description:
Disable VBXE, reset E:

*)

asm
  	txa:pha

	sta FX_CORE_RESET

	fxs FX_MEMC #0

        lda     #0
        ldy     #FX_MEMC
        sta     (fxptr),y

	fxsa FX_MEMS

	ldy     #FX_MEMS
        sta     (fxptr),y

	fxsa FX_VIDEO_CONTROL

        ldy     #FX_VIDEO_CONTROL
        sta     (fxptr),y

	@clrscr

	pla:tax
end;


initialization

  asm
   .local @ansi

	icl 'atari\a_vbxe\vbxeansi_main.asm'

   .endl
  end;

end.
