unit x16_vtui;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: X16 VTUI library for Mad-Pascal.
* @version: 0.1.0

* @description:
* Set of procedures to cover functionality provided by:
*
*
* <https://github.com/JimmyDansbo/VTUIlib>
*
*
*
* It's work in progress, please report any bugs you find.
*
*)

interface

const
{$i vtui8800.inc}

    vtui_mode_80x60 = $00;
    vtui_mode_80x30 = $01;
    vtui_mode_40x60 = $02;
    vtui_mode_40x30 = $03;
    vtui_mode_40x15 = $04;
    vtui_mode_20x30 = $05;
    vtui_mode_20x15 = $06;
    vtui_mode_swap  = $FF;

    // convert PETSCII to screen code
    PETSCII_TRUE    = $00;
    PETSCII_FALSE   = $80;

{$r vtui.res}

type
    TBorder = record
        topLeft: Byte;
        topRight: Byte;
        bottomLeft: Byte;
        bottomRight: Byte;
        hor: byte;
        ver: Byte;
    end;

// var

procedure vtuiInit; assembler;
(*
* @description:
* Initialize library.
*
*
*
*)

procedure vtuiSetScreen(mode: Byte); assembler;
(*
* @description:
* Set the screen mode to supported mode
*
* Modes:
* $00	80x60 text
* $01	80x30 text
* $02	40x60 text
* $03	40x30 text
* $04	40x15 text
* $05	20x30 text
* $06	20x15 text
* $FF	Swap 0 & 3
*
* @param: mode (byte) - Screen mode
*)

procedure vtuiSetBank(bank: Byte); assembler;
(*
* @description:
* Set the VERA bank to 0 or 1
*
*
* @param: bank (byte) - bank number 0 or 1
*)

procedure vtuiSetStride(stride: Byte); assembler;
(*
* @description:
* Set the VERA stride value. It is auto increment step used in VERA address register.
*
*
* @param: stride (byte) - stride value between 0-15
*)

function vtuiPetscii2Scr(input: Byte): Byte;
(*
* @description:
* Convert PETSCII to screencode
*
* @param: input (Char) - character to convert
*)

function vtuiScr2Petscii(input: Byte): Byte;
(*
* @description:
* Convert screencode to PETSCII
*
* @param: input (Char) - character to convert
*)


procedure vtuiClrScr(background: Byte; color: Byte); assembler; overload;
(*
* @description:
* Clear the entire screen with specific character and color.
* The routine is only designed to function with VERA decrement set to 0 and stride set to 1.
*
* @param: background (char) - Background character
* @param: color (byte) - Color value 0-15
*)

procedure vtuiClrScr(background: Byte; color_fg, color_bg: Byte); overload;
(*
* @description:
* Clear the entire screen with specific character and color.
* The routine is only designed to function with VERA decrement set to 0 and stride set to 1.
* Color vaalues are in range 0-15
* @param: background (byte) - Background character petscii code in range 0-255
* @param: color_fg - Foreground color values 0-15
* @param: color_bg - Background color values 0-15
*)

procedure vtuiClrScr(background: Char; color_fg, color_bg: Byte); overload;
(*
* @description:
* Clear the entire screen with specific character and color.
* The routine is only designed to function with VERA decrement set to 0 and stride set to 1.
* Color vaalues are in range 0-15
* @param: background (char) - Background character
* @param: color_fg - Foreground color values 0-15
* @param: color_bg - Background color values 0-15
*)

procedure vtuiGotoXY(x,y: Byte); assembler;
(*
* @description:
* Set VERA address to point to specific coordinates on screen.
*
*
* @param: x (byte) - Coordinates on screen x=0-79 (80 columns) or x=0-39 (40 columns) depending on screen mode
* @param: y (byte) - Coordinates on screen y=0-59 (60 lines) or y=0-29 (30 lines) depending on screen mode
*)

procedure vtuiPrint(s: String; color, convertpetscii: Byte); assembler; overload;
(*
* @description:
* Print a string to screen.
*
*
* @param: s (String) - Text to print
* @param: color (Byte) - Color value 0-15
* @param: convertpetscii (Byte) - Convert PETSCII to screen code, PETSCII_TRUE / PETSICII_FALSE
*)

procedure vtuiPrint(c: Byte; color: Byte); assembler; overload;
(*
* @description:
* Print a char to screen.
*
*
* @param: c (Byte) - Char to print
* @param: color (Byte) - Color value 0-15
*)

procedure vtuiHLine(c: Byte; len: Byte; color: Byte); assembler; overload;
(*
* @description:
* Draw a horizontal line from left to right, starting at current position.
*
*
* @param: c (Byte) - Char to print
* @param: len (Byte) - Length of line
* @param: color (Byte) - Color value 0-15
*)

procedure vtuiVLine(c: Byte; hgt: Byte; color: Byte); assembler; overload;
(*
* @description:
* Draw a vertical line from top to bottom, starting at current position.
*
*
* @param: c (Byte) - Char to print
* @param: hgt (Byte) - Height of line
* @param: color (Byte) - Color value 0-15
*)

procedure vtuiBorder(mode: Byte; len, hgt: Byte; color: Byte); assembler; overload;
(*
* @description:
* Create a box with a specific border.
*
*
* @param: mode (Byte) - Type of border
* @param: len (Byte) - Length of box
* @param: hgt (Byte) - Height of box
* @param: color (Byte) - Color value 0-15
*)


// procedure vtuiBorder(topLeft, topRight, bottomLeft, bottomRight, hor, ver:Byte; len, hgt: Byte; color: Byte); assembler; overload;
procedure vtuiBorder(border: TBorder; hor, ver:Byte; color: Byte); assembler; overload;
(*
* @description:
* Create a box with a custom border.
*
*
* @param: topLeft (Byte) - Top Left character
* @param: topRight (Byte) - Top Right character
* @param: bottomLeft (Byte) - Bottom Left character
* @param: bottomRight (Byte) - Bottom Right character
* @param: hor (Byte) - Horizontal character
* @param: ver (Byte) - Vertical character
* @param: len (Byte) - Length of box
* @param: hgt (Byte) - Height of box
* @param: color (Byte) - Color value 0-15
*)

procedure vtuiFillBox(c: Byte; len, hgt: Byte; color: Byte);assembler; overload;
(*
* @description:
* Draw a filled box starting at current position.
*
*
* @param: c (Byte) - Char to fill with
* @param: len (Byte) - Length of box
* @param: hgt (Byte) - Height of box
* @param: color (Byte) - Color value 0-15
*)

procedure vtuiFillBox(c: Char; len, hgt: Byte; color: Byte); overload;
(*
* @description:
* Draw a filled box starting at current position.
*
*
* @param: c (Char) - Char to fill with
* @param: len (Byte) - Length of box
* @param: hgt (Byte) - Height of box
* @param: color (Byte) - Color value 0-15
*)

procedure vtuiSaveRect(len, hgt: Byte; addr: Word; memtype: Byte); assembler;
(*
* @description:
* Save an area from screen to memory. Notice that each character on screen takes up 2 bytes of memory because a byte is used for color information.
* It saves from current position.
*
* @param: len (Byte) - Length of rectangle to save
* @param: hgt (Byte) - Height of rectangle to save
* @param: addr (Word) - Memory address to save screen to
* @param: memtype (Byte) - Memory type to save. Possible value is $00 - save to RAM, $80 - save to VRAM
*)

procedure vtuiRestoreRect(len, hgt: Byte; addr: Word; memtype: Byte); assembler;
(*
* @description:
* Restore an area from memory to screen.
* It restores to current position.
*
* @param: len (Byte) - Length of rectangle to save
* @param: hgt (Byte) - Height of rectangle to save
* @param: addr (Word) - Memory address to save screen to
* @param: memtype (Byte) - Memory type to save. Possible value is $00 - save to RAM, $80 - save to VRAM
*)

implementation


procedure vtuiInit; assembler;
asm
    pha
    phx
    phy
    jsr VTUI_initialize
    ply
    plx
    pla
end;

procedure vtuiSetScreen(mode: Byte); assembler;
asm
    pha
    phx
    phy
    lda mode
    jsr VTUI_screen_set
    ply
    plx
    pla
end;

procedure vtuiSetBank(bank: Byte); assembler;
asm
    pha

    pla
end;

procedure vtuiSetStride(stride: Byte); assembler;
asm
    pha
    lda stride
    jsr VTUI_set_stride
    pla
end;

function vtuiPetscii2Scr(input: Byte): Byte;
begin
    asm
        lda adr.input
        jsr VTUI_pet2scr
        sta result
    end;
end;


function vtuiScr2Petscii(input: Byte): Byte;
begin
    asm
        lda adr.input
        jsr VTUI_scr2pet
        sta result
    end;
end;


procedure vtuiClrScr(background: Byte; color: Byte); assembler; overload;
asm
    phy
    lda background
    ldx color
    jsr VTUI_clr_scr
    ply
end;

procedure vtuiClrScr(background: Byte; color_fg, color_bg: Byte); overload;
var
    c: byte;
begin
    c:= (color_bg shl 4) + color_fg;
    asm
        phy
        lda background
        ldx c
        jsr VTUI_clr_scr
        ply
    end;
end;

procedure vtuiClrScr(background: Char; color_fg, color_bg: Byte); overload;
var
    tmp: byte;
    c: byte;
begin
    tmp:=Ord(background);
    c:= (color_bg shl 4) + color_fg;
    asm
        phy
        lda tmp
        ldx c
        jsr VTUI_clr_scr
        ply
    end;
end;

procedure vtuiGotoXY(x,y: Byte); assembler;
asm
    pha
    phy
    lda x
    ldy y
    jsr VTUI_gotoxy
    ply
    pla
end;

procedure vtuiPrint(s: String; color, convertpetscii: Byte); assembler; overload;
asm
    pha
    phx
    phy
    lda #<(adr.s+1)
    sta r0L
    lda #>(adr.s+1)
    sta r0H

    // read string size
    ldy adr.s
    ldx color
    lda convertpetscii
    jsr VTUI_print_str
    ply
    plx
    pla
end;


procedure vtuiPrint(c: Byte; color: Byte); assembler; overload;
asm
    pha
    phx
    phy
    lda c
    ldx color
    jsr VTUI_plot_char
    ply
    plx
    pla
end;

procedure vtuiHLine(c: Byte; len: Byte; color: Byte); assembler; overload;
asm
    pha
    lda c
    ldx color
    ldy len
    jsr VTUI_hline
    pla
end;


procedure vtuiVLine(c: Byte; hgt: Byte; color: Byte); assembler; overload;
asm
    pha
    lda c
    ldx color
    ldy hgt
    jsr VTUI_vline
    pla
end;


procedure vtuiBorder(mode: Byte; len, hgt: Byte; color: Byte); assembler; overload;
asm
        phx
        lda len
        sta r1L
        lda hgt
        sta r2L
        ldx color

        lda mode
        cmp #6
        bcs stop

        jsr VTUI_border

    stop:
        plx
end;

// procedure vtuiBorder(topLeft, topRight, bottomLeft, bottomRight, hor, ver:Byte; len, hgt: Byte; color: Byte); assembler; overload;
procedure vtuiBorder(border: TBorder; hor, ver:Byte; color: Byte); assembler; overload;
asm
    pha
    phx
    phy
    lda hor
    sta r1L
    lda ver
    sta r2L

    lda border.topLeft
    sta r3H
    lda border.topRight
    sta r3L
    lda border.bottomLeft
    sta r4H
    lda border.bottomRight
    sta r4L
    // same character on top and bottom
    lda border.hor
    sta r5H
    sta r5L
    // same character on left and right
    lda border.ver
    sta r6H
    sta r6L


    ldx color
    lda #6

    jsr VTUI_border
    ply
    plx
    pla
end;


procedure vtuiFillBox(c: Byte; len, hgt: Byte; color: Byte);assembler; overload;
asm
    phx
    phy
    lda len
    sta r1L
    lda hgt
    sta r2L
    lda c
    ldx color
    jsr VTUI_fill_box
    ply
    plx
end;

procedure vtuiFillBox(c: Char; len, hgt: Byte; color: Byte); overload;
var
    tmp: byte;
begin
    tmp:=Ord(c);
    asm
        phx
        phy
        lda len
        sta r1L
        lda hgt
        sta r2L
        lda tmp
        ldx color
        jsr VTUI_fill_box
        ply
        plx
    end;
end;

procedure vtuiSaveRect(len, hgt: Byte; addr: Word; memtype: Byte); assembler;
asm
    pha
    phx
    phy
    lda	len
	sta	r1l		    ; Width
    lda hgt
    sta	r2l		    ; Height

    lda addr
    sta r0L
    lda addr+1
    sta r0H

    lda	memtype		; Save to VRAM

	clc			    ; Bank 0
	jsr	VTUI_save_rect
    ply
    plx
    pha
end;

procedure vtuiRestoreRect(len, hgt: Byte; addr: Word; memtype: Byte); assembler;
asm
    pha
    phx
    phy
    lda	len
	sta	r1l		    ; Width
    lda hgt
    sta	r2l		    ; Height

    lda addr
    sta r0L
    lda addr+1
    sta r0H

    lda	memtype		; Save to VRAM

	clc			    ; Bank 0
	jsr	VTUI_rest_rect
    ply
    plx
    pla

end;


end.