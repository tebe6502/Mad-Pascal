unit vbxe;
(*
 @type: unit
 @author: Tomasz Biela (Tebe), Daniel KoŸmiñski
 @name: Video Board XE unit

 @version: 1.1

 @description:

1: text mode 80x24 in 2 colors per character. This is like GR.0 in 80 columns and color.

2: pixel mode 160x192/256 colors (lowres). This is like GR.15 in 256 colors.

3: pixel mode 320x192/256 colors (stdres). This is like GR.8 in 256 colors.

4: pixel mode 640x192/16 colors (hires)

The mode 0 is reserved for text console.
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

BlitterBusy
ColorMapOff
ColorMapOn
DstBCB
GetXDL
IniBCB
OverlayOff
RunBCB
SetHorizontalRes
SetXDL
SrcBCB
VBXEMemoryBank
VBXEOff

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
		blt_width: word;
		blt_height: byte;
		blt_and_mask: byte;
		blt_xor_mask: byte;
		blt_collision_mask: byte;
		blt_zoom: byte;
		pattern_feature: byte;
		blt_control: byte;
	end;


type	TVBXEMemoryStream = Object
	(*
	@description:

	*)

	Position: cardinal;
	Size: cardinal;			// 0..Size-1

	procedure Create;

	procedure Clear;
	procedure SetBank;

	procedure ReadBuffer(var Buffer; Count: word);
	procedure WriteBuffer(var Buffer; Count: word);

	function ReadByte: Byte;
	function ReadWord: Word;
	function ReadDWord: Cardinal;

	procedure WriteByte(b: Byte);
	procedure WriteWord(w: Word);
	procedure WriteDWord(d: Cardinal);

	end;

const
	LoRes	= 1;
	MedRes	= 2;
	HiRes	= 3;

	VC_XDL		= 1;
	VC_XCOLOR	= 2;
	VC_NO_TRANS	= 4;
	VC_TRANS15	= 8;

var
	vram: TVBXEMemoryStream;

	function BlitterBusy: Boolean; assembler;
	procedure ColorMapOn; assembler;
	procedure ColorMapOff; assembler;
	procedure ColorMap(a: Boolean); overload;
	procedure ColorMap(w, h: byte); overload;
	procedure DstBCB(var a: TBCB; dst: cardinal);
	procedure GetXDL(var a: txdl); register; assembler;
	procedure IniBCB(var a: TBCB; src,dst: cardinal; w0, w1: smallint; w: word; h: byte; ctrl: byte);
	procedure OverlayOff; assembler;
	procedure RunBCB(var a: TBCB); assembler;
	procedure VBXEMemoryBank(b: byte); assembler;
	procedure SetHorizontalRes(a: byte); overload;
	procedure SetHorizontalRes(a: byte; s: word); overload;
	procedure SetHRes(a: byte); overload;
	procedure SetHRes(a: byte; s: word); overload;
	procedure SrcBCB(var a: TBCB; src: cardinal);
	procedure SetXDL(var a: txdl); register; assembler;
	procedure VBXEControl(a: byte); assembler;
	procedure VBXEOff; assembler;
	procedure VBXEMode(mode, pal: byte);

	procedure ClearDevice;
	procedure TextOut(a: char; c: byte); overload;
	procedure TextOut(s: PByte; c: byte); overload;
	procedure Position(x,y: byte);

	procedure SetColorMapEntry; overload; assembler;
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


	procedure PutPixel(x: word; y: byte);
	procedure SetColor(a: byte);
	procedure HLine(x1, x2: word; y1: byte);
	procedure Line(x1: word; y1: byte; x2: word; y2: byte);
	procedure VLine(x1: word; y1, y2: byte);

implementation

var	fildat: byte absolute $2fd;
	rowcrs: byte absolute $54;		// pionowa pozycja kursora
	colcrs: byte absolute $55;		// (2) pozioma pozycja kursora

	hres: byte;

	mem_vbxe: ^byte;


{$i vbxe.inc}


procedure VBXEMemoryBank(b: byte); assembler;
(*
@description:

*)
asm
{	fxs FX_MEMS b
};
end;


function ReadVBXEMemoryByte(var Position: cardinal): byte;
(*
@description:

*)
var bnk: byte;
    adr: word;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);

	Result:=peek(adr);

	inc(Position);
end;


procedure WriteVBXEMemoryByte(var Position: cardinal; a: byte);
(*
@description:

*)
var bnk: byte;
    adr: word;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);

	poke(adr, a);

	inc(Position);
end;


procedure TVBXEMemoryStream.Create;
(*
@description:

*)
begin

 Position := 0;
 Size:= 512*1024;

end;


procedure TVBXEMemoryStream.SetBank;
(*
@description:

*)
var bnk: byte;
    adr: word;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);
end;


procedure TVBXEMemoryStream.ReadBuffer(var Buffer; Count: word);
(*
@description:

*)
var bnk: byte;
    adr, i: word;
    dst: ^byte;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);

	dst:=Buffer;

	for i:=0 to Count-1 do begin

	 dst^:=peek(adr);

	 inc(adr);
	 inc(dst);

	 if adr>=VBXE_WINDOW+$1000 then begin
	  inc(bnk);
	  VBXEMemoryBank(bnk);
	  adr:=VBXE_WINDOW;
	 end;

	end;

	VBXEMemoryBank(0);

	inc(Position, Count);
end;


procedure TVBXEMemoryStream.WriteBuffer(var Buffer; Count: word);
(*
@description:

*)
var bnk: byte;
    adr, i: word;
    src: ^byte;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);

	src:=Buffer;

	for i:=0 to Count-1 do begin

	 poke(adr, src^);

	 inc(adr);
	 inc(src);

	 if adr>=VBXE_WINDOW+$1000 then begin
	  inc(bnk);
	  VBXEMemoryBank(bnk);
	  adr:=VBXE_WINDOW;
	 end;

	end;

	VBXEMemoryBank(0);

	inc(Position, Count);
end;


function TVBXEMemoryStream.ReadByte: Byte;
(*
@description:

*)
begin
	Result := ReadVBXEMemoryByte(Position);

	VBXEMemoryBank(0);
end;


function TVBXEMemoryStream.ReadWord: Word;
(*
@description:

*)
begin
	Result := ReadVBXEMemoryByte(Position);
	Result := Result + ReadVBXEMemoryByte(Position) shl 8;

	VBXEMemoryBank(0);
end;


function TVBXEMemoryStream.ReadDWord: Cardinal;
(*
@description:

*)
begin
	Result := ReadVBXEMemoryByte(Position);
	Result := Result + ReadVBXEMemoryByte(Position) shl 8;
	Result := Result + ReadVBXEMemoryByte(Position) shl 16;
	Result := Result + ReadVBXEMemoryByte(Position) shl 24;

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.WriteByte(b: Byte);
(*
@description:

*)
begin
	WriteVBXEMemoryByte(Position, b);

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.WriteWord(w: Word);
(*
@description:

*)
begin
	WriteVBXEMemoryByte(Position, w);
	WriteVBXEMemoryByte(Position, w shr 8);

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.WriteDWord(d: Cardinal);
(*
@description:

*)
begin
	WriteVBXEMemoryByte(Position, d);
	WriteVBXEMemoryByte(Position, d shr 8);
	WriteVBXEMemoryByte(Position, d shr 16);
	WriteVBXEMemoryByte(Position, d shr 24);

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.Clear;
(*
@description:

*)
var adr, siz: cardinal;
begin
	adr:=Position;
	siz:=Size;
asm
{	txa:pha

	mva adr _adr
	mva adr+1 _adr+1
	mva adr+2 _adr+2

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

loop	cpw _adr+1 siz+1
	bcs skp

	ldy #20
	mva:rpl bltClr,y MAIN.SYSTEM.VBXE_WINDOW+$e0,y-

	fxs FX_BL_ADR0 #$e0		; program blittera od adresu $0000e0
	fxs FX_BL_ADR1 #$00		; zaraz za programem VBXE Display List
	fxsa FX_BL_ADR2

	fxs FX_BLITTER_START #$01	; !!! start gdy 1 !!!

wait	fxla FX_BLITTER_BUSY
	bne wait

	lda #$00
	sta _adr
	inw _adr+1

	jmp loop

skp	fxs FX_MEMS #$00		; disable VBXE bank

	jmp stop

bltClr	.long 0x00	; source address
	.word 0x00	; source step y
	.byte 0x00	; source step x
_adr	.long 0x00	; destination address
	.word 0x0100	; destination step y
	.byte 0x01	; destination step x
_siz	.word 0xff	; width
	.byte 0x00	; height
	dta 0x00	; and mask (and mask equal to 0, memory will be filled with xor mask)
	dta 0x00	; xor mask
	dta 0x00	; collision and mask
	dta 0x00	; zoom
	dta 0x00	; pattern feature
	dta 0x00	; control

stop	pla:tax
};
	Position:=0;
	Size:=512*1024;
end;



procedure SetColor(a: byte);
(*
@description:

*)
begin
	if hres = 3 then
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

    if hres = 3 then begin

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


procedure WrapCursor;
begin

 inc(colcrs);

 if colcrs >= 80 then begin
  inc(rowcrs);

  inc(mem_vbxe, 2);
  colcrs:=0;
 end;

 if rowcrs > 24 then ;

end;


procedure Position(x,y: byte);
(*
@description:
Set cursor position on screen.

Positions the cursor at (X,Y), X in horizontal, Y in vertical direction.

@param: x - horizontal positions
@param: y - vertical positions
*)
var tmp: word;
begin

 colcrs := x;
 rowcrs := y;

 tmp := y*160 + x shl 1;

 vram.position:=VBXE_OVRADR + tmp;

 mem_vbxe:=pointer(VBXE_WINDOW + tmp);

end;


function ata2int(a: byte): byte; assembler;
asm
{
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror

	sta Result;
};
end;


procedure TextOut(a: char; c: byte); overload;
(*
@description:

*)
begin

 fildat := c;

asm
{
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

};

 mem_vbxe^ := ata2int(ord(a));
 inc(mem_vbxe);

 mem_vbxe^ := c;
 inc(mem_vbxe);

 WrapCursor;

asm
{
 	fxs FX_MEMS #$00		; disable VBXE BANK
};

end;


procedure TextOut(s: PByte; c: byte); overload;
(*
@description:

*)
var i: byte;
begin

 fildat := c;

asm
{
	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

};

 for i:=1 to s[0] do begin

  mem_vbxe^ := ata2int(s[i]);
  inc(mem_vbxe);

  mem_vbxe^ := c;
  inc(mem_vbxe);

  WrapCursor;
 end;

asm
{
 	fxs FX_MEMS #$00		; disable VBXE BANK
};

end;


procedure OverlayOff; assembler;
(*
@description:

*)
asm
{	@setxdl #e@xdl.ovroff
};
end;


procedure ColorMapOn; assembler;
(*
@description:

*)
asm
{	@setxdl #e@xdl.mapon
};
end;

procedure ColorMapOff; assembler;
(*
@description:

*)
asm
{	@setxdl #e@xdl.mapoff
};
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
	ScreenHeight := 192;

	case a of
	 1: ScreenWidth := 160;
	 2: ScreenWidth := 320;
	 3: ScreenWidth := 640;
	else

	 begin
	   ScreenWidth := 80;
	   ScreenHeight := 24;
	   a:=2;
	  end;

	end;

asm
{	txa:pha

	lda MAIN.SYSTEM.ScreenWidth
	ldx MAIN.SYSTEM.ScreenWidth+1

	ldy MAIN.SYSTEM.ScreenHeight

	@SCREENSIZE

	lda a
	and #3
	sta hres

	@setxdl @

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #s@xdl.ovstep

	lda s
	sta MAIN.SYSTEM.VBXE_WINDOW,y

	lda s+1
	sta MAIN.SYSTEM.VBXE_WINDOW+1,y

	fxs FX_MEMS #$00

	pla:tax
};
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
 fillbyte(a, sizeof(a), 0);

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
{	ldy #FX_BLITTER_BUSY
	lda (fxptr),y
	sta Result
};
end;


procedure RunBCB(var a: TBCB); assembler;
(*
@description:

*)
asm
{	fxs	FX_BL_ADR0	a
	lda	a+1
	and	#$0f
	fxsa	FX_BL_ADR1
	fxs	FX_BL_ADR2	#$00

	fxs	FX_BLITTER_START #$01		; !!! start gdy 1 !!!

;wait	fxla	FX_BLITTER_BUSY
;	bne	wait
};
end;


procedure GetXDL(var a: txdl); register; assembler;
(*
@description:

*)
asm
{	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #.sizeof(s@xdl)-1

lp	lda MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW,y
	sta (a),y
	dey
	bpl lp

	fxs FX_MEMS #0
};
end;


procedure SetXDL(var a: txdl); register; assembler;
(*
@description:

*)
asm
{	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

	ldy #.sizeof(s@xdl)-1

lp	lda (a),y
	sta MAIN.SYSTEM.VBXE_XDLADR+MAIN.SYSTEM.VBXE_WINDOW,y
	dey
	bpl lp

	fxs FX_MEMS #0
};
end;


procedure VBXEControl(a: byte); assembler;
(*
@description:

*)
asm
{
	fxs FX_VIDEO_CONTROL a
};
end;


procedure VBXEOff; assembler;
(*
@description:

*)
asm
{	txa:pha

	sta FX_CORE_RESET

	fxs FX_MEMC #0
	fxsa FX_MEMS
	fxsa FX_VIDEO_CONTROL

	@clrscr

	pla:tax
};

end;


procedure ClearDevice;
begin

 vram.position:=VBXE_OVRADR;
 vram.size:=VBXE_OVRADR+320*256;
 vram.Clear;

end;


procedure VBXEMode(mode, pal: byte);
var p: pointer;
begin

 mode:=mode and $0f;

 if mode > 0 then begin

	case mode of
	  1: begin
		SetHorizontalRes($80,160);

		p:=pointer(peek(756)*256);

		vram.position:=VBXE_CHBASE;

		vram.WriteBuffer(p, 2048);

		Position(0,0);

		asm
		{
		@setxdl #e@xdl.tmon
		};

	     end;

	  2: SetHorizontalRes(loRes);
	  3: SetHorizontalRes(medRes);
	  4: SetHorizontalRes(hiRes);

	end;

	ColorMapOff;

	VBXEControl(vc_xdl+vc_xcolor+vc_no_trans);

	SetOverlayPalette(pal);

	ClearDevice;
 end;

end;


end.
