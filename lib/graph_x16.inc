
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
Sets the foreground color used by draw procedures
*)
asm
	pha
	phx
	phy
	lda color
	ldx MAIN.GRAPH.DRAW_FILL_COLOR
	ldy MAIN.GRAPH.DRAW_BACK_COLOR

	jsr GRAPH_set_colors

	ply
	plx
	pla
end;

procedure SetBkColor(color: byte); assembler;
(*
@description:
Sets the background color used by draw procedures
*)
asm

	pha
	phx
	phy
	lda MAIN.GRAPH.DRAW_COLOR
	ldx MAIN.GRAPH.DRAW_FILL_COLOR
	ldy color

	jsr GRPAH_set_colors

	ply
	plx
	pla

end;

procedure SetFillColor(color: byte); assembler;
(*
@description:
Sets the fill color used by draw procedures
*)
asm
	pha
	phx
	phy
	lda MAIN.GRAPH.DRAW_COLOR
	ldx color
	ldy MAIN.GRAPH.DRAW_BACK_COLOR

	jsr GRAPH_set_colors

	ply
	plx
	pla
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
	lda mode
	// jsr GRAPH_init //does not work as expected
	jsr screen_mode

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





procedure PutPixel(x,y: smallint); assembler; overload;
// (*
// @description:
// Puts a point at (X,Y) using white Color
// *)
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

// // ; -----------------------------------------

// // 	lda MAIN.SYSTEM.GraphMode
// // 	cmp #VGAHi
// // 	beq HiRes

// 	lda x
// 	sta r0L
// 	lda x+1
// 	sta r0H

// 	lda y
// 	sta r1L
// 	lda y+1
// 	sta r1H

// 	jsr FB_cursor_position

// 	lda #00
// 	jsr FB_set_pixel

end;


procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin
	asm
		txa:pha
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

		lda x
		sta r0L
		lda x+1
		sta r0H

		lda y
		sta r1L
		lda y+1
		sta r1H

		jsr FB_cursor_position

		lda color
		jsr FB_set_pixel
		pla:tax
	end;
end;

function GetPixel(x,y: smallint): byte; assembler;
(*
@description:
Return color of pixel
*)
asm
	txa:pha
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

	lda x
	sta r0L
	lda x+1
	sta r0H

	lda y
	sta r1L
	lda y+1
	sta r1H

	jsr FB_cursor_position

	jsr FB_get_pixel

stop	sta Result
	pla:tax

end;


procedure LineTo(x, y: smallint);
(*
@description:
Draw a line starting from current position to a given point
*)
var x1, y1, dx, dy, fraction, stepx, stepy: smallint;

begin
    x1 := CurrentX;
    y1 := CurrentY;

    if x1<0 then x1:=0;
    if y1<0 then y1:=0;

    if x<0 then x:=0;
    if y<0 then y:=0;

    dy := y - y1;
    dx := x - x1;

    if (dy < 0) then begin dy := -dy; stepy := -1 end else stepy := 1;
    if (dx < 0) then begin dx := -dx; stepx := -1 end else stepx := 1;
    dy := dy + dy;	// dy is now 2*dy
    dx := dx + dx;	// dx is now 2*dx

    PutPixel(x1,y1);

    if (dx > dy) then begin

        fraction := dy shl 1 - dx;

        while (x1 <> x) do begin
           if (fraction >= 0) then begin
               inc(y1, stepy);
               dec(fraction,dx);		// same as fraction -= 2*dx
           end;
           inc(x1, stepx);
           inc(fraction, dy);			// same as fraction -= 2*dy

	   PutPixel(x1, y1);
        end;

     end else begin

        fraction := dx shl 1 - dy;

        while (y1 <> y) do begin
           if (fraction >= 0) then begin
               inc(x1, stepx);
               dec(fraction, dy);
           end;
           inc(y1, stepy);
           inc(fraction, dx);

           PutPixel(x1, y1);
        end;
     end;

 CurrentX := x;
 CurrentY := y;

end;



procedure MoveTo(x, y: smallint); assembler;
(*
@description:
Move cursor to absolute position.
*)
asm
	pha
	phx
	phy

	lda x
	sta r0L
	lda x+1
	sta r0H

	lda y
	sta r1L
	lda y+1
	sta r1H

	jsr FB_cursor_position

	ply
	plx
	pla

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


