
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
@description:
Init graphics mode
*)
begin

 asm
    vic_bank=1

    vic_base=$4000*vic_bank		// A VIC-II bank indicates a 16K region
    screen_memory=$1000 + vic_base
    bitmap_address=$2000 + vic_base

    mwa #bitmap_address VideoRAM
    mwa #screen_memory ScreenRAM

    txa:pha

    lda mode
    sta MAIN.SYSTEM.GraphMode

    cmp #VGAHi
    beq _hi
    cmp #VGAMed
    beq _med

_0
    jsr $FF81	; SCINIT. Initialize VIC
    jsr $FF84	; IOINIT. Initialize CIA's, SID volume

    lda <40
    ldx >40
    ldy #25

    bne skp

_med

    SwitchVICBank(vic_bank)
    SetMulticolorBitmapMode()
    SetScreenMemory(screen_memory - vic_base)
    SetBitmapAddress(bitmap_address - vic_base)

    lda <160
    ldx >160
    ldy #200

    bne skp

_hi
    SwitchVICBank(vic_bank)
    SetHiresBitmapMode()
    SetScreenMemory(screen_memory - vic_base)
    SetBitmapAddress(bitmap_address - vic_base)

    lda <320
    ldx >320
    ldy #200

skp
    @SCREENSIZE

    pla:tax

 end;

 fillchar(VideoRam, 25*320, 0);
 fillchar(ScreenRAM, 25*40, 32);	// 32 = WHITE * 16 + BLUE

 SetColor(0);

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

 sta MAIN.C64.Backgroundcolor0

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

; -----------------------------------------

	lda MAIN.SYSTEM.GraphMode
	cmp #VGAHi
	beq HiRes

MedRes
	lda X
	and #3
	tay
	lda @putpixel.color,y
	sta @putpixel.msk+1

	ldy Y

	lda X
	and #%11111100

	asl @
	rol X+1

	add @putpixel.ladr,y
	sta :bp2
	lda X+1
	adc @putpixel.hadr,y
	adc VideoRam+1
	sta :bp2+1

	jmp @putpixel

stop	rts

; -----------------------------------------

HiRes
	lda X
	and #7
	tay
	lda @putpixel.color,y
	sta @putpixel.msk+1

	ldy Y

	lda X
	and #%11111000
	add @putpixel.ladr,y
	sta :bp2
	lda X+1
	adc @putpixel.hadr,y
	adc VideoRam+1
	sta :bp2+1

	jmp @putpixel

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

; -----------------------------------------

	lda MAIN.SYSTEM.GraphMode
	cmp #VGAHi
	beq HiRes

MedRes
	lda X
	and #3
	tay
	lda m_mask,y
	sta m_msk+1

	ldy Y

	lda X
	and #%11111100

	asl @
	rol X+1

	add @putpixel.ladr,y
	sta :bp2
	lda X+1
	adc @putpixel.hadr,y
	adc VideoRam+1
	sta :bp2+1

	ldy #$00

	lda (:bp2),y
m_msk	and #$00
	sta Result

	lda X
	and #3
	eor #3
	tay
	beq stop

@	lsr Result
	lsr Result
	dey
	bne @-

stop	rts

; -----------------------------------------

m_mask	dta $c0,$30,$0c,$03
h_mask	dta $80,$40,$20,$10,$08,$04,$02,$01

; -----------------------------------------

HiRes
	lda X
	and #7
	tay
	lda h_mask,y
	sta h_msk+1

	ldy Y

	lda X
	and #%11111000
	add @putpixel.ladr,y
	sta :bp2
	lda X+1
	adc @putpixel.hadr,y
	adc VideoRam+1
	sta :bp2+1

	ldy #$00

	lda (:bp2),y
h_msk	and #$00
	seq
	lda #1
	sta Result
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


procedure OutTextXY(x,y: smallint; s: string);
begin


end;
