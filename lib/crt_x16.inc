
procedure CursorOff;
(*
@description: Hide cursor
*)
begin

 poke(204, 1);

end;


procedure CursorOn;
(*
@description: Display cursor
*)
begin

 poke(204, 0);

end;


procedure ClrScr;
(*
@description: Clear screen
*)
begin

 asm
	jsr @ClrScr
 end;

end;


procedure DelLine;
(*
@description: Delete line at cursor position
*)
begin

end;


procedure InsLine;
(*
@description: Insert an empty line at cursor position
*)
begin

end;


function ReadKey: char; assembler;
(*
@description: Read key from keybuffer

@returns: char
*)
asm
getkey	lda CURRKEY
	cmp #$40
	beq getkey

	scc
	eor #%00100000

	sta Result
end;


procedure TextBackground(a: byte); assembler;
(*
@description: Set text background

@param: a - color value 0..255
*)
asm
	phx

	lda a
	jsr CHROUT
	lda #PETSCII_SWAP_COLOR
	jsr CHROUT
	lda PETSCII_COLOR_WHITE
	jsr CHROUT
	
	plx
end;


procedure TextColor(a: byte); assembler;
(*
@description: Set text color

@param: a - color value 0..255
*)
asm

	lda a
	jsr CHROUT

end;


procedure Delay(count: word); assembler;
(*
@description: Waits a specified number of milliseconds

@param: count - number of milliseconds
*)
asm
	phx

	ldx #0
	ldy #0

loop	cpy count
	bne @+
	cpx count+1
	beq stop

@	lda #$40

cnt	adc #1
	bne cnt

	iny
	sne
	inx

	bne loop

stop	plx

end;


function Keypressed: Boolean; assembler;
(*
@description: Check if there is a keypress in the keybuffer

@returns: TRUE key has been pressed
@returns: FALSE otherwise
*)
asm
	// txa:pha
	phx

	jsr GETIN
	sta CURRKEY

	seq
	lda #1
	sta Result

	// pla:tax
	plx
end;


procedure GotoXY(x,y: byte); assembler;
(*
@description:
Set cursor position on screen.


GotoXY positions the cursor at (X,Y), X in horizontal, Y in vertical direction relative to

the origin of the current window. The origin is located at (1,1), the upper-left corner of the window.

@param: x - horizontal positions (1..80)
@param: y - vertical positions (1..60)
*)

asm
	// txa:pha
	phx
	clc

	ldx y
	seq
	dex

	ldy x
	seq
	dey

	jsr PLOT

	// pla:tax
	plx
end;


function WhereX: byte; assembler;
(*
@description: Return X (horizontal) cursor position

@returns: byte (1..80)
*)

asm
	// txa:pha
	phx
	sec

	jsr PLOT
	iny
	sty Result

	// pla:tax
	plx
end;


function WhereY: byte; assembler;
(*
@description: Return Y (vertical) cursor position

@returns: byte (1..60)
*)

asm
	// txa:pha
	phx
	sec

	jsr PLOT
	inx
	stx Result

	// pla:tax
	plx
end;


procedure ClrEol;
(*
@description:
ClrEol clears the current line, starting from the cursor position, to the end of the window.

The cursor doesn't move.
*)
begin

//  FillChar( pointer($400+WhereX+WhereY*40-41), byte(41-byte(WhereX)), 32);

end;


procedure TextMode(Mode: byte); assembler;
(*
@description: Set the screen mode

@param: Mode - screen mode

CX16_80x60	$00     80x60 text
CX16_80x30	$01     80x30 text
CX16_40x60	$02     40x60 text
CX16_40x30	$03     40x30 text
CX16_40x15	$04     40x15 text
CX16_20x30	$05     20x30 text
CX16_20x15	$06     20x15 text
CX16_22x23	$07     22x23 text
CX16_64x50	$08     64x50 text
CX16_64x25	$09     64x25 text
CX16_32x50	$0A     32x50 text
CX16_32x25	$0B     32x25 text

*)
asm
	// txa:pha
	phx

	lda Mode
	cmp #$0b
	bcs stop

	clc
	jsr screen_mode

// stop	pla:tax
	plx
end;

procedure SetTextCharset(charset: pointer); assembler;
(*
@description: Sets charset
pointer to a 2 KB RAM area that gets uploaded as the new 8x8 character set. The data has to consist of 256 characters of 8 bytes each, top to bottom, with the MSB on the left and set bits representing the foreground color.

@param: charset - pointer to 2 KB RAM area


*)
asm
	// txa:pha
	phx

	lda #0
	ldx #<CHARSET
	ldy#>CHARSET
	jsr screen_set_charset

	// pla:tax
	plx
end;

procedure NoSound; assembler;
(*
@description: Reset sound
*)
asm

	jsr IOINIT	; Initialize CIAs, SID volume

end;


procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
(*
@description: Plays sound

@param: Chan - channel (0..3) primary POKEY, (4..7) secondary POKEY
@param: Freq - frequency (0..255)
@param: Dist - distortion (0,2,4,6,8,10,12,14)
@param: Vol - volume (0..15)
*)
asm

end;
