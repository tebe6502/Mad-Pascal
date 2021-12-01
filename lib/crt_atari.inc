
procedure CursorOff;
(*
@description: Hide cursor
*)
begin

 crsinh:=1;		// znacznik widocznosci kursora

 write( CH_CURS_RIGHT, CH_CURS_LEFT );

end;


procedure CursorOn;
(*
@description: Display cursor
*)
begin

 crsinh:=0;		// znacznik widocznosci kursora

 write( CH_CURS_RIGHT, CH_CURS_LEFT );

end;


procedure ClrScr;
(*
@description: Clear screen
*)
begin

 write( CH_CLR );

end;


procedure DelLine;
(*
@description: Delete line at cursor position
*)
begin

 write( CH_DELLINE );

end;


procedure InsLine;
(*
@description: Insert an empty line at cursor position
*)
begin

 write( CH_INSLINE );

end;


function ReadKey: char; assembler;
(*
@description: Read key from keybuffer

@returns: char
*)
asm
	m@call @GetKey
	sta Result
end;


procedure TextBackground(a: byte); assembler;
(*
@description: Set text background

@param: a - color value 0..255
*)
asm
	mwa a colpf2s
end;


procedure TextColor(a: byte); assembler;
(*
@description: Set text color

@param: a - color value 0..255
*)
asm
	mva a colpf1s
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

@	:8 lda:cmp:req vcount

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
	ldy #$00	; false
	lda kbcodes
	cmp #$ff
	beq skp
	iny		; true

;	sty kbcodes

skp	sty Result
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
	ldy x
	beq @+

	dey

@	sty colcrs
	mvy #$00 colcrs+1

	ldy y
	beq @+

	dey

@	sty rowcrs
end;


function WhereX: byte; assembler;
(*
@description: Return X (horizontal) cursor position

@returns: byte (1..40)
*)

asm
	ldy colcrs
	iny
	sty Result

end;


function WhereY: byte; assembler;
(*
@description: Return Y (vertical) cursor position

@returns: byte (1..24)
*)

asm
	ldy rowcrs
	iny
	sty Result
end;
