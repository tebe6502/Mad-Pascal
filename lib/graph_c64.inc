
procedure InitGraph(mode: byte); overload;
(*
@description:
Init graphics mode
*)
begin

 asm
    txa:pha

    vic_bank=1
    vic_base=$4000*vic_bank		// A VIC-II bank indicates a 16K region
    screen_memory=$1000 + vic_base
    bitmap_address=$2000 + vic_base

    SwitchVICBank(vic_bank)
    SetHiresBitmapMode()
    SetScreenMemory(screen_memory - vic_base)
    SetBitmapAddress(bitmap_address - vic_base)

    lda <320
    ldx >320
    ldy #200
    @SCREENSIZE

    pla:tax

 end;

 VideoRam := $6000;

 fillchar(pointer($5000), 1024, 3);

 fillchar(pointer($6000), 200*40, 0);

end;


procedure InitGraph(driver, mode: byte; dev: PByte); overload;
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

end;


procedure PutPixel(x,y: smallint); assembler; overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
const
     tand : array [0..7] of byte = ($80,$40,$20,$10,$08,$04,$02,$01);

asm
	lda X
	and #$07
	tay
	lda adr.TAND,y
	sta _ora+1

	lda Y
	lsr @
	lsr @
	lsr @
	sta :eax
	lda #$00
	sta :eax+1
	jsr @mul320

	lda X
	and #%11111000
	add :eax
	sta :eax
	lda X+1
	adc :eax+1
	sta :eax+1

	lda Y
	and #$07
	add :eax
	tay

	lda VideoRam+1
	adc :eax+1
	sta :bp+1

	lda (:bp),y
_ora	ora #$00
	sta (:bp),y
end;


procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin

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
