unit vbxe;
(*
 @type: unit
 @author: Tomasz Biela (Tebe), Daniel Koźmiński, Joseph Zatarski
 @name: Video Board XE unit

 @version: 1.2

 @description:

   VGA: text mode 80x24 in 2 colors per character. This is like GR.0 in 80 columns and color.

 VGALo: pixel mode 160x192/256 colors (lowres). This is like GR.15 in 256 colors.

VGAMed: pixel mode 320x192/256 colors (stdres). This is like GR.8 in 256 colors.

 VGAHi: pixel mode 640x192/16 colors (hires)

The mode 0 is reserved for text console.

 <https://forums.atariage.com/topic/225063-full-color-ansi-vbxe-terminal-in-the-works/>

 <https://en.wikipedia.org/wiki/ANSI_escape_code>
*)


(*
	$0000	XDLIST
	$00E0	CLR_BLIST
	$0100	BLITTER_CODE_BLOCK
	$1000	COLOR_MAP
	$1000	CHARSET BASE
	$5000	VBXE_OVRADR
*)

{

AnsiChar
BlitterBusy
ClearDevice
ColorMapOff
ColorMapOn
ColorMap
DstBCB
GetXDL
HLine
IniBCB
Line
NormVideo
OverlayOff
Position
PutPixel
SetColor
TextOut
RunBCB
SetColorMapDimensions
SetColorMapEntry
SetCurrentPaletteEntry
SetPaletteEntry
SetHRes
SetHorizontalRes
SetOverlayAddress
SetOverlayPalette
SetPlayfieldPalette
SetRGBPalette
SetTopBorder
SetXDLHeight
SetMapStep
SetXDL
SrcBCB
VBXEControl
VBXEMemoryBank
VBXEMode
VBXEOff
VLine

+ TVBXEMemoryStream : Object

Create
Clear
SetBank
ReadBuffer
WriteBuffer
ReadByte
ReadWord
ReadDWord
WriteByte
WriteWord
WriteDWord

}

interface

uses crt;

type	TUInt24 = record
	(*
	@description:

	*)
	byte0: byte;
	byte1: byte;
	byte2: byte;
	end;

type	TXDL = record
	(*
	@description:

	*)
		xdlc_: word;		// blank
		rptl_: byte;

		xdlc: word;
		rptl: byte;
		ov_adr: TUInt24;
		ov_step: word;
		ov_chbase: byte;
		mp_adr: TUInt24;
		mp_step: word;
		mp_hscrol: byte;
		mp_vscrol: byte;
		mp_width: byte;
		mp_height: byte;
		ov_width: byte;
		ov_prior: byte;
	end;

type	TBCB = record
	(*
	@description:

	*)
		src_adr: TUInt24;
		src_step_y: smallint;
		src_step_x: shortint;
		dst_adr: TUInt24;
		dst_step_y: smallint;
		dst_step_x: shortint;
		blt_width: word;		// 0..511
		blt_height: byte;		// 0..255
		blt_and_mask: byte;
		blt_xor_mask: byte;
		blt_collision_mask: byte;
		blt_zoom: byte;			// blt_zoomy bit 4..6 ; blt_zoomx bit 0..2
		pattern_feature: byte;
		blt_control: byte;		// %1000 = next blit
	end;					// %0000 = copy all
						// %0001 = copy if src <> 0


{$i vbxe_memorystream_type.inc}

const
	VC_XDL		= 1;
	VC_XCOLOR	= 2;
	VC_NO_TRANS	= 4;
	VC_TRANS15	= 8;

// TextColor (ANSI)

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

 // TextBackground (ANSI)

	tbBlack        = $80;
	tbRed          = $90;
	tbGreen        = $a0;
	tbYellow       = $b0;
	tbBlue         = $c0;
	tbMagenta      = $d0;
	tbCyan         = $e0;
	tbWhite        = $f0;

var
	vram: TVBXEMemoryStream;

	scrollback_fill: Boolean absolute $63;				// (LOGCOL = $63) TRUE -> row #0 was copied to the scrollback_buffer

	ColorMapControl: byte external 'vbxe';				// value for the fourth byte of the color map 'lib\vbxe.hea'

        scrollback_buffer: array [0..255] of byte absolute __buffer;	// ROW #0 buffer, filled if 'row_slide_status = true'

	procedure AnsiChar(a: char); assembler;
	procedure AnsiString(s: string); assembler;
	function BlitterBusy: Boolean; assembler;
	procedure ClrScr; assembler;
	procedure ColorMapOn; assembler;
	procedure ColorMapOff; assembler;
	procedure ColorMap(a: Boolean); overload;
	procedure ColorMap(w, h: byte); overload;
	procedure CursorOn; assembler;
	procedure CursorOff; assembler;
	procedure DstBCB(var a: TBCB; dst: cardinal);
	function EnableANSIMode: Boolean;
	procedure GetXDL(var a: txdl); register; assembler;
	procedure IniBCB(var a: TBCB; src,dst: cardinal; w0, w1: smallint; w: word; h: byte; ctrl: byte);
	procedure NormVideo;
	procedure OverlayOff; assembler;
	procedure RunBCB(var a: TBCB); assembler;
	procedure VBXEMemoryBank(b: byte); assembler;
	procedure SetHorizontalRes(a: byte); overload;
	procedure SetHorizontalRes(a: byte; s: word); overload;
	procedure SetHRes(a: byte); overload;
	procedure SetHRes(a: byte; s: word); overload;
	procedure SrcBCB(var a: TBCB; src: cardinal);
	procedure SetOverlayAddress(a: cardinal); assembler;
	procedure SetXDL(var a: txdl); register; assembler;
	procedure VBXEControl(a: byte); assembler;
	procedure VBXEOff; assembler;
	procedure VBXEMode(mode, pal: byte);

	procedure ClearDevice;
	procedure CloseGraph; assembler;
//	procedure TextOut(a: char; c: byte); overload;
//	procedure TextOut(a: char); overload;
//	procedure TextOut(s: PString; c: byte); overload;
//	procedure TextOut(s: PString); overload;
//	procedure Position(x,y: byte); assembler;

	procedure SetColorMapEntry; overload; assembler;
	procedure SetColorMapEntry(a,b,c, i: byte); overload; assembler;
	procedure SetColorMapEntry(a,b,c: byte); overload; register; assembler;
	procedure SetColorMapDimensions(w,h: byte); register; assembler;
	procedure SetCurrentPaletteEntry(nr: word); register;
	procedure SetPaletteEntry(nr: word; r,g,b: byte); register; overload;
	procedure SetPaletteEntry(r,g,b: byte); register; overload;
	procedure SetRGBPalette(pal: byte); assembler; register; overload;
	procedure SetRGBPalette(pal, cnt: byte); assembler; register; overload;
	procedure SetRGBPalette(cnt: byte; r,g,b: byte); assembler; overload;
	procedure SetRGBPalette(r,g,b: byte); assembler; register; overload;
	procedure SetRGBPalette(c: cardinal); assembler; register; overload;
	procedure SetRGBPalette(cnt:byte; c: cardinal); assembler; register; overload;
	procedure SetPlayfieldPalette(a: byte); register; assembler;
	procedure SetOverlayPalette(a: byte); register; assembler;
	procedure SetTopBorder(a: byte); register; assembler;
	procedure SetXDLHeight(a: byte); register; assembler;
	procedure SetMapStep(a: word); register; assembler;

	procedure PutPixel(x: word; y: byte);
	procedure SetColor(a: byte);
	procedure HLine(x1, x2: word; y1: byte);
	procedure Line(x1: word; y1: byte; x2: word; y2: byte);
	procedure VLine(x1: word; y1, y2: byte);

implementation

uses graph;

var	fildat: byte absolute $2fd;
	rowcrs: byte absolute $54;		// pionowa pozycja kursora
	colcrs: byte absolute $55;		// (2) pozioma pozycja kursora

	crsadr: word absolute $68;


{$i vbxe.inc}

{$i vbxe_memorystream.inc}


procedure SetColor(a: byte);
(*
@description:

*)
begin
	if GraphMode = VGAHi then
	 fildat := (a and $0f) or (a shl 4)
	else
	 fildat := a;
end;


procedure PutPixel(x: word; y: byte);
(*
@description:

*)
var a: cardinal;
    v: byte;
begin

    vram.position := VBXE_OVRADR + y*320;

    if GraphMode = VGAHi then begin

	inc(vram.position, x shr 1);

	v := vram.ReadByte;

	dec(vram.position);

	if x and 1 = 0 then
	  v:=v or (fildat and $f0)
	 else
	 v:=v or (fildat and $0f);

	vram.WriteByte(v);

     end else begin

	inc(vram.position, x);
	vram.WriteByte(fildat);

     end;

end;


procedure HLine(x1, x2: word; y1: byte);
(*
@description:

*)
var x: word;
begin

      if x2 >= x1 then
       for x := x1 to x2 do PutPixel(x, y1)
      else
       for x := x2 to x1 do PutPixel(x, y1);

end;


procedure VLine(x1: word; y1, y2: byte);
(*
@description:

*)
var y: word;
begin

      if y2 >= y1 then
       for y := y1 to y2 do PutPixel(x1, y)
      else
       for y := y2 to y1 do PutPixel(x1, y);

end;


procedure Line(x1: word; y1: byte; x2: word; y2: byte);
(*
@description:

*)
var
     d, ai, bi: smallint;
     dx, dy: smallint;
     xi, yi: smallint;
     x, y: word;
begin

     if y1 = y2 then begin
      HLine(x1,x2, y1);

      exit;
     end;


     if x1 = x2 then begin
      VLine(x1, y1,y2);

      exit;
     end;


     x := x1;
     y := y1;

     if x1 < x2 then begin
         xi := 1;
         dx := x2 - x1;
     end else begin
         xi := -1;
         dx := x1 - x2;
     end;

     if y1 < y2 then begin
         yi := 1;
         dy := y2 - y1;
     end else begin
         yi := -1;
         dy := y1 - y2;
     end;

     PutPixel(x, y);

     if dx > dy then begin

          ai := (dy - dx) * 2;
          bi := dy * 2;
          d := bi - dx;

          while x <> x2 do begin

               if d >= 0 then begin

                   x := x + xi;
                   y := y + yi;
                   d := d + ai;

               end else begin
                   d := d + bi;
                   x := x + xi;
               end;

               PutPixel(x, y);

          end;

     end else begin

         ai := ( dx - dy ) * 2;
         bi := dx * 2;
         d := bi - dy;

          while (y <> y2) do begin

               if d >= 0 then begin
                    x := x + xi;
                    y := y + yi;
                    d := d + ai;
               end else begin
                    d := d + bi;
                    y := y + yi;
               end;

               PutPixel(x, y);

          end;
     end;

end;


procedure Position(x, y: byte); assembler;
(*
@description:
Set cursor position on screen.

Positions the cursor at (X,Y), X in horizontal, Y in vertical direction.

@param: x - horizontal positions
@param: y - vertical positions
*)
asm
	jsr @vbxe_Cursor.off

	ldy x
	beq @+

	dey

@	sty colcrs
	mvy #$00 colcrs+1

	ldy y
	beq @+

	dey

@	sty rowcrs

	jmp @vbxe_SetCursor
end;


procedure TextOut(a: char; c: byte); overload;
(*
@description:

*)
begin

 fildat := c;

 asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	lda a
	jsr @putchar_80

 	fxs FX_MEMS #$00		; disable VBXE BANK
 end;

end;


procedure TextOut(a: char); overload;
(*
@description:

*)
begin

 asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	lda a
	jsr @putchar_80

 	fxs FX_MEMS #$00		; disable VBXE BANK
 end;

end;


procedure TextOut(s: PString; c: byte); overload;
(*
@description:

*)
var i: byte;
    a: char;
begin

 fildat := c;

 for i:=1 to s[0] do begin

  a := s[i];

  asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	lda a
	jsr @putchar_80

	fxs FX_MEMS #$00		; disable VBXE BANK
  end;

end;

end;


procedure TextOut(s: PString); overload;
(*
@description:

*)
var i: byte;
    a: char;
begin

asm
	lda colpf2s	; TextBackground
	ora colpf1s	; TextColor
	sta fildat
end;

 for i:=1 to s[0] do begin

  a := s[i];

  asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	lda a
	jsr @putchar_80

	fxs FX_MEMS #$00		; disable VBXE BANK
  end;

 end;

end;


procedure OverlayOff; assembler;
(*
@description:

*)
asm
	@setxdl #e@xdl.ovroff
end;


procedure ColorMapOn; assembler;
(*
@description:

*)
asm
	@setxdl #e@xdl.mapon
end;

procedure ColorMapOff; assembler;
(*
@description:

*)
asm
	@setxdl #e@xdl.mapoff
end;


procedure ColorMap(a: Boolean); overload;
begin

 if a then
  ColorMapOn
 else
  ColorMapOff;

end;


procedure ColorMap(w, h: byte); overload;
begin

 ColorMapOn;
 SetColorMapDimensions(w,h);

end;


procedure SetHorizontalRes(a: byte; s: word); overload;
(*
@description:

*)
begin
	GraphMode := a;

	ScreenHeight := 192;

	case a of
	  VGALo: begin ScreenWidth := 160; a := 1 end;
	 VGAMed: begin ScreenWidth := 320; a := 2 end;
	  VGAHi: begin ScreenWidth := 640; a := 3 end;
	else

	 begin
	   ScreenWidth := 80;
	   ScreenHeight := 24;
	   a := 2;
	  end;

	end;

asm
	txa:pha

	lda MAIN.SYSTEM.ScreenWidth
	ldx MAIN.SYSTEM.ScreenWidth+1

	ldy MAIN.SYSTEM.ScreenHeight

	@SCREENSIZE

	@setxdl a

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #s@xdl.ovstep

	lda s
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	lda s+1
	sta MAIN.SYSTEM.VBXE_WINDOW+1,y

	fxs FX_MEMS #$00

	pla:tax
end;

end;


procedure SetHorizontalRes(a: byte); overload;
(*
@description:

*)
begin

  SetHorizontalRes(a, 320);

end;


procedure SetHRes(a: byte); overload;
(*
@description:

*)
begin

  SetHorizontalRes(a, 320);

end;


procedure SetHRes(a: byte; s: word); overload;
(*
@description:

*)
begin
  SetHorizontalRes(a, s);
end;


procedure IniBCB(var a: TBCB; src,dst: cardinal; w0, w1: smallint; w: word; h: byte; ctrl: byte);
(*
@description:

*)
begin
 fillbyte(@a, sizeof(a), 0);

 a.src_adr.byte2:=src shr 16;
 a.src_adr.byte1:=src shr 8;
 a.src_adr.byte0:=src;

 a.dst_adr.byte2:=dst shr 16;
 a.dst_adr.byte1:=dst shr 8;
 a.dst_adr.byte0:=dst;

 a.src_step_x:=1;
 a.src_step_y:=w0;

 a.dst_step_x:=1;
 a.dst_step_y:=w1;

 a.blt_width:=w;
 a.blt_height:=h;

 a.blt_and_mask := $ff;

 a.blt_control:=ctrl;
end;


procedure SrcBCB(var a: TBCB; src: cardinal);
(*
@description:

*)
begin

 a.src_adr.byte2 := src shr 16;
 a.src_adr.byte1 := src shr 8;
 a.src_adr.byte0 := src;

end;


procedure DstBCB(var a: TBCB; dst: cardinal);
(*
@description:

*)
begin

 a.dst_adr.byte2 := dst shr 16;
 a.dst_adr.byte1 := dst shr 8;
 a.dst_adr.byte0 := dst;

end;


function BlitterBusy: Boolean; assembler;
(*
@description:

*)
asm
	ldy #FX_BLITTER_BUSY
	lda (fxptr),y
	sta Result
end;


procedure RunBCB(var a: TBCB); assembler;
(*
@description:

*)
asm
	fxs	FX_BL_ADR0	a
	lda	a+1
	and	#$0f
	fxsa	FX_BL_ADR1
	fxs	FX_BL_ADR2	#$00

	fxs	FX_BLITTER_START #$01		; !!! start gdy 1 !!!

;wait	fxla	FX_BLITTER_BUSY
;	bne	wait
end;


procedure GetXDL(var a: txdl); register; assembler;
(*
@description:

*)
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #.sizeof(s@xdl)-1

lp	lda MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW,y
	sta (a),y
	dey
	bpl lp

	fxs FX_MEMS #0
end;


procedure SetXDL(var a: txdl); register; assembler;
(*
@description:

*)
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #.sizeof(s@xdl)-1

lp	lda (a),y
	sta MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW,y
	dey
	bpl lp

	fxs FX_MEMS #0
end;


procedure SetOverlayAddress(a: cardinal); assembler;
(*
@description:
Set Overlay Address (XDLC_OVADR)

*)
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	lda a
	sta MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW+6
	lda a+1
	sta MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW+7
	lda a+2
	sta MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW+8

	fxs FX_MEMS #$00
end;


procedure VBXEControl(a: byte); assembler;
(*
@description:

*)
asm
	fxs FX_VIDEO_CONTROL a
end;


procedure VBXEOff; assembler;
(*
@description:
Disable VBXE, reset E:

*)
asm
	txa:pha

	sta FX_CORE_RESET

	fxs FX_MEMC #0
	fxsa FX_MEMS
	fxsa FX_VIDEO_CONTROL

	@clrscr

	pla:tax
end;


procedure NormVideo;
(*
@description:
Disable VBXE, reset E:

*)
begin

 VBXEOff;

end;


procedure ClearDevice;
(*
@description:


*)
begin

 vram.position:=VBXE_OVRADR;
 vram.size:=VBXE_OVRADR+320*256;
 vram.Clear;

end;


procedure AnsiChar(a: char); assembler;
(*
@description:
ANSI character processing

*)
asm
	txa:pha

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	lda a
	sta atachr

	jsr @ansi.process_char

	fxs FX_MEMS #$00

	pla:tax
end;


procedure AnsiString(s: string); assembler;
(*
@description:
ANSI character processing

*)
asm
	txa:pha

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	lda #0
	sta cnt

loop	ldy cnt: #0
	cpy adr.s
	beq toExit

	lda adr.s+1,y
	sta atachr

	jsr @ansi.process_char

	inc cnt
	bne loop
toExit
	fxs FX_MEMS #$00

	pla:tax
end;


procedure ClrScr; assembler;
(*
@description:
Clear Screen

*)
asm
	txa:pha

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	jsr @FF_adr

	lda savadr		; fill
	sta adr
	lda savadr+1
	sta adr+1

	ldx #$0e		; 15 * 256 = 3840 -> 24 * 160
	ldy #$00

	lda fildat
fil
	iny
	sta adr: $1000,y
	iny

	bne fil

	inc adr+1

	dex
	bpl fil

	fxs FX_MEMS #$00

	pla:tax
end;


procedure CursorOn; assembler;
(*
@description:
Cursor ON

*)
asm
	lda #$00
	sta crsinh

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	jsr @vbxe_cursor.on

	fxs FX_MEMS #$00
end;


procedure CursorOff; assembler;
(*
@description:
Cursor OFF

*)
asm
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	jsr @vbxe_cursor.off

	fxs FX_MEMS #$00

	lda #$ff
	sta crsinh
end;


procedure VBXEMode(mode, pal: byte);
var p: pointer;
begin

// mode:=mode and $0f;

 if mode > 0 then begin

	case mode of

	   VGALo, VGAMed, VGAHi: SetHorizontalRes(mode);

	else

	  begin
		SetHorizontalRes($80,160);

		p:=pointer(peek(756)*256);
		vram.position:=VBXE_CHBASE;
		vram.WriteBuffer(p^, 2048);

		asm
			lda	<MAIN.SYSTEM.VBXE_WINDOW
			sta	savadr
			lda	>MAIN.SYSTEM.VBXE_WINDOW
			sta	savadr + 1

			lda #$00
			sta rowcrs
			sta colcrs
			sta colcrs+1
			sta crsinh			; cursor_flg
			sta oldchr			; ctrl_seq_flg
			sta scrollback_fill

			lda #7
			sta colpf1s

			lda #$80
			sta colpf2s

			lda #$87
			sta fildat			; $87 is white on black (ANSI MODE)

			@setxdl #e@xdl.tmon

			m@putchar {jmp*}, @putchar_80
		end;

	  end;

	end;

	ColorMapOff;

	VBXEControl(vc_xdl+vc_xcolor+vc_no_trans);

	SetOverlayPalette(pal);

	ClearDevice;
 end;

end;


function EnableANSIMode: Boolean;
var a, b: byte;

const
    vgaPal: array [0..15] of cardinal = (
    $000000,	// black
    $AA0000,	// red
    $00AA00,	// green
    $AA5500,	// yellow
    $0000AA,	// blue
    $AA00AA,	// magenta
    $00AAAA,	// cyan
    $AAAAAA,	// white
    $555555,	// bright black
    $FF5555,	// bright red
    $55FF55,	// bright green
    $FFFF55,	// bright yellow
    $5555FF,	// bright blue
    $FF55FF,	// bright magenta
    $55FFFF,	// bright cyan
    $FFFFFF	// bright white
    );

begin

 Result:=false;

 if VBXE.GraphResult <> VBXE.grOK then exit;

 SetRGBPalette(1);					// create Palette #1

 for a:=0 to 127 do SetRGBPalette(vgaPal[a and $0f]);

 for b:=0 to 7 do
  for a:=0 to 15 do SetRGBPalette(vgaPal[b]);

 SetRGBPalette(128, 16,16,16);				// background color

 VBXEMode(VBXE.VGA, 1);					// VBXE MODE, OVERLAY PALETTE #1

 vbxe.ClrScr;

end;



initialization

asm
	txa:pha

	jsr @vbxe_detect
	bcc ok

	ldx #MAIN.GRAPH.grNoInitGraph
	bne status

ok	jsr @vbxe_init

	ldx #MAIN.GRAPH.grOK
status	stx MAIN.GRAPH.GraphResult

	pla:tax
end;

end.
