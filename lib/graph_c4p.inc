
procedure InitGraph(mode: byte); overload;
(*
@description:
Init graphics mode
*)
begin

 asm
    txa:pha

    lda mode
    sta MAIN.SYSTEM.GraphMode

    vic_bank=1
    vic_base=$4000*vic_bank		// A VIC-II bank indicates a 16K region
    screen_memory=$1000 + vic_base
    bitmap_address=$2000 + vic_base

    SwitchVICBank(vic_bank)
    SetHiresBitmapMode()
    SetScreenMemory(screen_memory - vic_base)
    SetBitmapAddress(bitmap_address - vic_base)


;$FFED
;SCREEN. Fetch number of screen rows and columns.
;Input: –
;Output: X = Number of columns (40); Y = Number of rows (25).
;Used registers: X, Y.
;Real address: $E505.

    lda <320
    ldx >320
    ldy #200
    @SCREENSIZE

    pla:tax

 end;

 VideoRam := pointer($6000);

 fillchar(pointer($5000), 1024, 3);

 fillchar(pointer($6000), 200*40, 0);

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

	jmp @exit

HiRes	mva #$07 @putpixel.c_and

	lda color
	and #1
	bne c1_h
c0_h
	sta @putpixel.c_idx
	mva #{and#} @putpixel.msk

	jmp @exit

c1_h	mva #$08 @putpixel.c_idx
	mva #{ora#} @putpixel.msk

end;


procedure PutPixel(x,y: smallint); assembler; overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
asm

	lda y+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	lda X
	and @putpixel.c_and
	ora @putpixel.c_idx
	tay
	lda @putpixel.c0,y
	sta @putpixel.msk+1

	lda Y
	lsr @
	lsr @
	lsr @
	tay

	lda X
	and #%11111000
	add ladr,y
	sta :bp2
	lda X+1
	adc hadr,y
	adc VideoRam+1
	sta :bp2+1

	lda Y
	and #$07
	tay

	jmp @putpixel

stop	rts

ladr	:25 dta l(#*320)
hadr	:25 dta h(#*320)

end;


procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin

 SetColor(color);

 PutPixel(x,y);

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


procedure LineRel(dx, dy: smallint);
(*
@description:
LineRel draws a line starting from the current pointer position to the point(DX,DY),
relative to the current position, in the current line style and color.
The Current Position is set to the endpoint of the line.
*)
begin

 LineTo(CurrentX + dx, CurrentY + dy)

end;


procedure CloseGraph; assembler;
(*
@description:

*)
asm

end;

