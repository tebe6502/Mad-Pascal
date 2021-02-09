unit vbxe;
(*
 @type: unit
 @author: Tomasz Biela (Tebe), Daniel KoŸmiñski
 @name: Video Board XE unit

 @version: 1.1

 @description:
*)


(*
	$0000	XDLIST
	$00E0	CLR_BLIST
	$0100	BLITTER_CODE_BLOCK
	$1000	COLOR_MAP
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


	function BlitterBusy: Boolean; assembler;
	procedure ColorMapOn; assembler;
	procedure ColorMapOff; assembler;
	procedure DstBCB(var a: TBCB; dst: cardinal);
	procedure GetXDL(var a: txdl); register; assembler;
	procedure IniBCB(var a: TBCB; src,dst: cardinal; w0, w1: smallint; w: word; h: byte; ctrl: byte);
	procedure OverlayOff; assembler;
	procedure RunBCB(var a: TBCB); assembler;
	procedure VBXEMemoryBank(b: byte); assembler;
	procedure SetHorizontalRes(a: byte); assembler;
	procedure SetHRes(a: byte); assembler;
	procedure SrcBCB(var a: TBCB; src: cardinal);
	procedure SetXDL(var a: txdl); register; assembler;
	procedure VBXEControl(a: byte); assembler;
	procedure VBXEOff; assembler;

	procedure SetColor(a: byte);
	procedure HLine(x1, x2: word; y1: byte);
	procedure Line(x1: word; y1: byte; x2: word; y2: byte);
	procedure VLine(x1: word; y1, y2: byte);

implementation

var	fildat: byte absolute $2fd;
	hres: byte;

	vram: TVBXEMemoryStream;


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

	dst:=@Buffer;

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

	src:=@Buffer;

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
begin
	fildat := a;
end;


procedure PutPixel(x: word; y: byte);
var a: cardinal;
begin

    case hres of
     1: a := y*160;
     2: a := y*320;
     3: a := y*640;
    else
     a:=0
    end;

    vram.position := VBXE_OVRADR + x + a;
    vram.WriteByte(fildat);
end;


procedure HLine(x1, x2: word; y1: byte);
var x: word;
begin

      if x2 >= x1 then
       for x := x1 to x2 do PutPixel(x, y1)
      else
       for x := x2 to x1 do PutPixel(x, y1);

end;


procedure VLine(x1: word; y1, y2: byte);
var y: word;
begin

      if y2 >= y1 then
       for y := y1 to y2 do PutPixel(x1, y)
      else
       for y := y2 to y1 do PutPixel(x1, y);

end;


procedure Line(x1: word; y1: byte; x2: word; y2: byte);
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


procedure SetHorizontalRes(a: byte); assembler;
(*
@description:

*)
asm
{	lda a
	sta hres
	@setxdl @
};
end;


procedure SetHRes(a: byte); assembler;
(*
@description:

*)
asm
{	lda a
	sta hres
	@setxdl @
};
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


end.
