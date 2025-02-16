
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
getkey	lda $cb
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
	sta 647
end;


procedure TextColor(a: byte); assembler;
(*
@description: Set text color

@param: a - color value 0..255
*)
asm
	sta 646
end;


procedure Delay(count: word); assembler;
(*
@description: Waits a specified number of milliseconds

@param: count - number of milliseconds
*)
asm
	txa:pha

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

stop	pla:tax
end;


function Keypressed: Boolean; assembler;
(*
@description: Check if there is a keypress in the keybuffer

@returns: TRUE key has been pressed
@returns: FALSE otherwise
*)
asm
	txa:pha

	jsr $F142
	sta $cb

	seq
	lda #1
	sta Result

	pla:tax
end;


procedure GotoXY(x,y: byte); assembler;
(*
@description:
Set cursor position on screen.


GotoXY positions the cursor at (X,Y), X in horizontal, Y in vertical direction relative to

the origin of the current window. The origin is located at (1,1), the upper-left corner of the window.

@param: x - horizontal positions (1..40)
@param: y - vertical positions (1..24)
*)

asm
	txa:pha
	clc

	ldx y
	seq
	dex

	ldy x
	seq
	dey

	jsr $FFF0	; PLOT

	pla:tax
end;


function WhereX: byte; assembler;
(*
@description: Return X (horizontal) cursor position

@returns: byte (1..40)
*)

asm
	txa:pha
	sec

	jsr $FFF0	; PLOT
	iny
	sty Result

	pla:tax
end;


function WhereY: byte; assembler;
(*
@description: Return Y (vertical) cursor position

@returns: byte (1..24)
*)

asm
	txa:pha
	sec

	jsr $FFF0	; PLOT
	inx
	stx Result

	pla:tax
end;


procedure ClrEol;
(*
@description:
ClrEol clears the current line, starting from the cursor position, to the end of the window.

The cursor doesn't move.
*)
begin

 FillChar( pointer($400+WhereX+WhereY*40-41), byte(41-byte(WhereX)), 32);

end;


procedure TextMode(Mode: byte); assembler;
(*
@description: Reset E: device

@param: Mode - unused value
*)
asm
	txa:pha

	jsr $FF81	; SCINIT. Initialize VIC
	jsr $FF84	; IOINIT. Initialize CIA's, SID volume

	pla:tax
end;


procedure NoSound; assembler;
(*
@description: Reset POKEY
*)
asm
	txa:pha

	jsr $FF84	; IOINIT. Initialize CIA's, SID volume

	pla:tax
end;


procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
(*
@description: Plays sound

*)
asm

end;
