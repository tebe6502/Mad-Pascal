
procedure ClrEol;
(*
@description:
ClrEol clears the current line, starting from the cursor position, to the end of the window.

The cursor doesn't move.
*)
begin

end;


procedure CursorOff;
(*
@description: Hide cursor
*)
begin

end;


procedure CursorOn;
(*
@description: Display cursor
*)
begin

end;

procedure ClrScr;
(*
@description: Clear screen
*)
begin 
	asm
		@SendMessage
		dta 2,12
	end;
end;


procedure DelLine;
(*
@description: Delete line at cursor position
*)
begin
	asm
		@SendMessage
		dta 2,11
	end;
end;


procedure InsLine;
(*
@description: Insert an empty line at cursor position
*)
begin
	asm
		@SendMessage
		dta 2,10
	end;
end;


function ReadKey: char; assembler;
(*
@description: Read key from keybuffer

@returns: char
*)
asm
	@GetKey
	sta result
end;


procedure TextBackground(a: byte); assembler;
(*
@description: Set text background

@param: a - color value 0..255
*)
asm
	lda a
	add #$90
	@putchar
end;


procedure TextColor(a: byte); assembler;
(*
@description: Set text color

@param: a - color value 0..255
*)
asm
	lda a
	add #$80
	@putchar 
end;


procedure Delay(count: word); assembler;
(*
@description: Waits a specified number of milliseconds

@param: count - number of milliseconds
*)
asm
	@SendMessage
	dta 1,1
	@WaitMessage
	mwa DParameters last
	adw last count last
@	
	@SendMessage
	dta 1,1
	@WaitMessage
	cpw DParameters last
	bmi @-
	rts 
last 
	dta a(0)
end;


function Keypressed: Boolean; assembler;
(*
@description: Check if there is a keypress in the keybuffer

@returns: TRUE key has been pressed
@returns: FALSE otherwise
*)
asm
	@SendMessage
	dta 2,2
	@WaitMessage
	lda DParameters
	sta result
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
	lda x 
	seq 
	dec
	sta DParameters
	lda y
	seq 
	dec
	sta DParameters + 1
	@SendMessage 				
	.byte 	2,7	
end;


function WhereX: byte; assembler;
(*
@description: Return X (horizontal) cursor position

@returns: byte (1..40)
*)
asm
	@SendMessage
	dta 2,13
	@WaitMessage
	lda DParameters
	sta result
end;


function WhereY: byte; assembler;
(*
@description: Return Y (vertical) cursor position

@returns: byte (1..24)
*)
asm
	@SendMessage
	dta 2,13
	@WaitMessage
	lda DParameters+1
	sta result
end;


procedure TextMode(Mode: byte); assembler;
(*
@description: Reset E: device

@param: Mode - unused value
*)
asm
	lda #$90 // background to 0
	@putchar
	lda #$82 // text color to 2
	@putchar
	@clrscr;
end;


procedure NoSound; assembler;
(*
@description: Reset POKEY
*)
asm
        @SendMessage 				
        .byte 	8,1	
end;


procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
(*
@description: Plays sound

*)
asm

end;
