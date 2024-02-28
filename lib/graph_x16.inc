
procedure SetActiveBuffer(var a: TDisplayBuffer);
(*
@description:

*)
begin

//  VideoRam := pointer(a.bp);
// savmsc := VideoRam;

end;


procedure SetDisplayBuffer(var a: TDisplayBuffer);
(*
@description:
Set video buffer which is displayed
*)
begin
//	sdlstl := a.dl;
//	dlistl := sdlstl;
end;


function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
(*
@description:
Initialize new graphical buffer
*)
begin

// ramtop := bound;

// InitGraph(mode);

// a.dl := sdlstl;
// a.bp := savmsc;

end;


procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);
(*
@description:
Switch graphical buffer between A <> B
*)
var tmp: TDisplayBuffer;
    x, y: pointer;
    l: word;
begin

{
 tmp:=b;

 b:=a;
 a:=tmp;

 SetDisplayBuffer(a);
 SetActiveBuffer(b);

 x:=Scanline(WIN_TOP);

 y:=Scanline(WIN_BOTTOM);
 l:=word(y);
 y:=Scanline(WIN_TOP);

 dec(l, word(y));

 fillchar(x, l, 0);
}

end;


procedure SetColor(color: byte); assembler;
(*
@description:
Sets the foreground color to Color
*)
asm
	lda MAIN.SYSTEM.GraphMode
	cmp #VGAHi
	beq HiRes
	cmp #VGAMed
	beq Multi

	jmp @exit

Multi	lda color
	and #$03
	cmp #1
	beq c1_m
	cmp #2
	beq c2_m
	cmp #3
	beq c3_m

c0_m
	mva #{and#} @putpixel.msk

	.put %11000000^$ff, %00110000^$ff, %00001100^$ff, %00000011^$ff
	:4 mva #.get[#] @putpixel.color+#

	jmp @exit

c1_m
	.put %01000000, %00010000, %00000100, %00000001
	:4 mva #.get[#] @putpixel.color+#

	bne skp

c2_m
	.put %10000000, %00100000, %00001000, %00000010
	:4 mva #.get[#] @putpixel.color+#

	bne skp

c3_m
	.put %11000000, %00110000, %00001100, %00000011
	:4 mva #.get[#] @putpixel.color+#

skp
	mva #{ora#} @putpixel.msk

	jmp @exit

; ------------------------------------

HiRes	lda color
	and #1
	bne c1_h
c0_h
	mva #{and#} @putpixel.msk

	.put $80^$ff,$40^$ff,$20^$ff,$10^$ff,$08^$ff,$04^$ff,$02^$ff,$01^$ff
	:8 mva #.get[#] @putpixel.color+#

	jmp @exit

c1_h
	mva #{ora#} @putpixel.msk

	.put $80,$40,$20,$10,$08,$04,$02,$01
	:8 mva #.get[#] @putpixel.color+#
end;


procedure InitGraph(mode: byte); overload;
(*
@description: Init graphics mode

@param: Mode - Graphics mode to initialize (X16_MODE_320x240)

X16_MODE_320x240
TODO currently only 1 mode is accepted
*)
begin

 asm
 	@ClrScr
	jsr GRAPH_init

 end;
	case mode of
		X16_MODE_320x240: begin
			ScreenWidth:=320;
			ScreenHeight:=240;
		end;
	end;

end;


procedure InitGraph(driver, mode: byte; dev: PString); overload;
(*
@description:
Init graphics mode
*)
begin

 InitGraph(mode);

end;


procedure SetBkColor(color: byte); assembler;
(*
@description:
Sets the background color to Color
*)
asm

//  sta MAIN.C64.Backgroundcolor0

end;


procedure PutPixel(x,y: smallint); assembler; overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
asm
// 	lda y+1
// 	bmi stop
// 	cmp MAIN.SYSTEM.ScreenHeight+1
// 	bne sk0
// 	lda y
// 	cmp MAIN.SYSTEM.ScreenHeight
// sk0
// 	bcs stop

// 	lda x+1
// 	bmi stop
// 	cmp MAIN.SYSTEM.ScreenWidth+1
// 	bne sk1
// 	lda x
// 	cmp MAIN.SYSTEM.ScreenWidth
// sk1
// 	bcs stop

// ; -----------------------------------------

// 	lda MAIN.SYSTEM.GraphMode
// 	cmp #VGAHi
// 	beq HiRes

// MedRes
// 	lda X
// 	and #3
// 	tay
// 	lda @putpixel.color,y
// 	sta @putpixel.msk+1

// 	ldy Y

// 	lda X
// 	and #%11111100

// 	asl @
// 	rol X+1

// 	add @putpixel.ladr,y
// 	sta :bp2
// 	lda X+1
// 	adc @putpixel.hadr,y
// 	adc VideoRam+1
// 	sta :bp2+1

// 	jmp @putpixel

// stop	rts

// ; -----------------------------------------

// HiRes
// 	lda X
// 	and #7
// 	tay
// 	lda @putpixel.color,y
// 	sta @putpixel.msk+1

// 	ldy Y

// 	lda X
// 	and #%11111000
// 	add @putpixel.ladr,y
// 	sta :bp2
// 	lda X+1
// 	adc @putpixel.hadr,y
// 	adc VideoRam+1
// 	sta :bp2+1

// 	jmp @putpixel

end;


procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin

//  SetColor(color);

//  PutPixel(x,y);

end;


function GetPixel(x,y: smallint): byte; assembler;
(*
@description:
Return color of pixel
*)
asm

end;


procedure LineTo(x, y: smallint);
(*
@description:
Draw a line starting from current position to a given point
*)
var x1, y1, dx, dy, fraction, stepx, stepy: smallint;

begin
//     x1 := CurrentX;
//     y1 := CurrentY;

//     if x1<0 then x1:=0;
//     if y1<0 then y1:=0;

//     if x<0 then x:=0;
//     if y<0 then y:=0;

//     dy := y - y1;
//     dx := x - x1;

//     if (dy < 0) then begin dy := -dy; stepy := -1 end else stepy := 1;
//     if (dx < 0) then begin dx := -dx; stepx := -1 end else stepx := 1;
//     dy := dy + dy;	// dy is now 2*dy
//     dx := dx + dx;	// dx is now 2*dx

//     PutPixel(x1,y1);

//     if (dx > dy) then begin

//         fraction := dy shl 1 - dx;

//         while (x1 <> x) do begin
//            if (fraction >= 0) then begin
//                inc(y1, stepy);
//                dec(fraction,dx);		// same as fraction -= 2*dx
//            end;
//            inc(x1, stepx);
//            inc(fraction, dy);			// same as fraction -= 2*dy

// 	   PutPixel(x1, y1);
//         end;

//      end else begin

//         fraction := dx shl 1 - dy;

//         while (y1 <> y) do begin
//            if (fraction >= 0) then begin
//                inc(x1, stepx);
//                dec(fraction, dy);
//            end;
//            inc(y1, stepy);
//            inc(fraction, dx);

//            PutPixel(x1, y1);
//         end;
//      end;

//  CurrentX := x;
//  CurrentY := y;

end;


procedure CloseGraph; assembler;
(*
@description:

*)
asm

end;

procedure ClearDevice; assembler;
(*
@description:  Clear the current window with the current background color.

*)
asm
	jsr GRAPH_clear
end;


procedure DrawImage(x, y: word; ptr: pointer; width, height: word); assembler;
(*
@description:   Draw a rectangular image from data in memory

*)
asm
	phx
	lda x
	sta r0L
	lda x+1
	sta r0H

	lda y
	sta r1L
	lda y+1
	sta r1H

	lda ptr
	sta r2L
	lda ptr+1
	sta r2H

	lda width
	sta r3L
	lda width+1
	sta r3H

	lda height
	sta r4L
	lda height+1
	sta r4H
	
	jsr GRAPH_draw_image
	plx
end;