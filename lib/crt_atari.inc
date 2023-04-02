
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
	mva a colpf2s

	ora colpf1s
	sta fildat
end;


procedure TextColor(a: byte); assembler;
(*
@description: Set text color

@param: a - color value 0..255
*)
asm
	mva a colpf1s

	ora colpf2s
	sta fildat
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
	seq
	iny		; true
	sty Result
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

@	tya
test	cmp #24
	bcc @+

	sbc #24
	jmp test
@
	sta rowcrs
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


procedure ClrEol;
(*
@description:
ClrEol clears the current line, starting from the cursor position, to the end of the window.

The cursor doesn't move.
*)
begin
 FillChar( pointer(word(DPeek(88)+WhereX)+WhereY*40-41), byte(41-byte(WhereX)), 0);
end;


procedure TextMode(Mode: byte); assembler;
(*
@description: Reset E: device

@param: Mode - unused value
*)
asm
	txa:pha

	@clrscr

	pla:tax
end;


procedure NoSound; assembler;
(*
@description: Reset POKEY

https://atariage.com/forums/topic/151841-init-of-the-pokey/?do=findComment&comment=1856144

https://atarionline.pl/forum/comments.php?DiscussionID=6889&page=1#Item_17
*)
asm
	lda #0
	sta $d208
	sta $d218

	sta $d20f
	sta $d21f

	sta wsync
	sta wsync

	ldy #3
	sty $d20f
	sty $d21f

	ldy #8
lp	sta $d200,y
	sta $d210,y
	dey
	bpl lp
end;


procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
(*
@description: Plays sound

@param: Chan - channel (0..3) primary POKEY, (4..7) secondary POKEY
@param: Freq - frequency (0..255)
@param: Dist - distortion (0,2,4,6,8,10,12,14)
@param: Vol - volume (0..15)
*)
//----------------------------------------------------------------------------------------------
// Chan = 0..3 primary Pokey
// Chan = 4..7 secondary Pokey
//----------------------------------------------------------------------------------------------
asm
	lda Chan
	and #7

	ldy #$10
	cmp #4
	scs
	ldy #$00
	sty npokey

	and #3

	asl @
	add #0
npokey	equ *-1
	tay

	lda #$00
	sta audctl
	lda #$03
	sta skctl

	lda Freq
	sta audf1,y

	lda Vol
	and #$0F
	sta _t

	lda Dist	; -> bit 7-6-5
	:4 asl @
	ora #0
_t	equ *-1
	sta audc1,y
end;

