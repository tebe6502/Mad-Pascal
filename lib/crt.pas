unit crt;

{

http://www.freepascal.org/docs-html/rtl/crt/index-5.html

Consol
ClrEol
ClrScr
CursorOff
CursorOn
Delay
DelLine
GotoXY
InsLine
Keypressed
NoSound
ReadKey
Sound
TextBackground
TextColor
TextMode
WhereX
WhereY

}

interface

var
	TextAttr: byte = 0;
	Consol: byte absolute $d01f;

const
	CN_START_SELECT_OPTION	= 0;		// Consol value
	CN_SELECT_OPTION	= 1;
	CN_START_OPTION		= 2;
	CN_OPTION		= 3;
	CN_START_SELECT		= 4;
	CN_SELECT		= 5;
	CN_START		= 6;
	CN_NONE			= 7;

{ CRT modes }
	BW40	= 0;		{ 40x25 B/W on Color Adapter }
	CO40	= 1;		{ 40x25 Color on Color Adapter }
	BW80	= 2;		{ 80x25 B/W on Color Adapter }
	CO80	= 3;		{ 80x25 Color on Color Adapter }
	Mono	= 7;		{ 80x25 on Monochrome Adapter }

{ Mode constants for 3.0 compatibility }
	C40	= CO40;
	C80	= CO80;

	procedure ClrEol;
	procedure ClrScr;
	procedure CursorOff;
	procedure CursorOn;
	procedure Delay(count: word); assembler;
	procedure DelLine;
	procedure GotoXY(x,y: byte); assembler;
	procedure InsLine;
	function Keypressed: Boolean; assembler;
	procedure NoSound; assembler;
	function ReadKey: char; assembler;
	procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
	procedure TextBackground(a: byte); assembler;
	procedure TextColor(a: byte); assembler;
	procedure TextMode(Mode: byte); assembler;
	function WhereX: byte; assembler;		// Return X (horizontal) cursor position
	function WhereY: byte; assembler;		// Return Y (vertical) cursor position


implementation

uses atari;


procedure CursorOff;
//----------------------------------------------------------------------------------------------
// Hide cursor
//----------------------------------------------------------------------------------------------
begin

 crsinh:=1;		// znacznik widocznosci kursora

 write( CH_CURS_RIGHT, CH_CURS_LEFT );

end;


procedure CursorOn;
//----------------------------------------------------------------------------------------------
// Display cursor
//----------------------------------------------------------------------------------------------
begin

 crsinh:=0;		// znacznik widocznosci kursora

 write( CH_CURS_RIGHT, CH_CURS_LEFT );

end;


procedure ClrScr;
//----------------------------------------------------------------------------------------------
// Clear screen
//----------------------------------------------------------------------------------------------
begin
	write( CH_CLR );
end;


procedure DelLine;
//----------------------------------------------------------------------------------------------
// Delete line at cursor position
//----------------------------------------------------------------------------------------------
begin
	write( CH_DELLINE );
end;


procedure InsLine;
//----------------------------------------------------------------------------------------------
// Insert an empty line at cursor position
//----------------------------------------------------------------------------------------------
begin
	write( CH_INSLINE );
end;


function ReadKey: char; assembler;
asm
{	txa:pha

	@GetKey

	sta Result

	pla:tax
};
end;


procedure TextBackground(a: byte); assembler;
asm
{	mwa a colpf2s
};
end;


procedure TextColor(a: byte); assembler;
asm
{	mva a colpf1s
};
end;


procedure Delay(count: word); assembler;
asm
{	txa:pha

	ldx #0
	ldy #0

loop	cpy count
	bne @+
	cpx count+1
	beq stop

@	:16 sta wsync

	iny
	sne
	inx

	bne loop

stop	pla:tax
};
end;


function Keypressed: Boolean; assembler;
asm
{	ldy #$00	; false
	lda kbcodes
	cmp #$ff
	beq skp
	iny		; true

;	sty kbcodes

skp	sty Result
};
end;


procedure GotoXY(x,y: byte); assembler;
//----------------------------------------------------------------------------------------------
// Set cursor position on screen
//
// GotoXY positions the cursor at (X,Y), X in horizontal, Y in vertical direction relative to
// the origin of the current window. The origin is located at (1,1), the upper-left corner
// of the window.
//----------------------------------------------------------------------------------------------
asm
{	ldy x
	beq @+
	dey
	sty colcrs

@	ldy y
	beq @+
	dey
	sty rowcrs
@
};
end;


function WhereX: byte; assembler;
asm
{
	ldy colcrs
	iny
	sty Result
};
end;


function WhereY: byte; assembler;
asm
{
	ldy rowcrs
	iny
	sty Result
};
end;


procedure ClrEol;
//----------------------------------------------------------------------------------------------
// ClrEol clears the current line, starting from the cursor position, to the end of the window.
// The cursor doesn't move
//----------------------------------------------------------------------------------------------
begin
	FillChar( pointer(word(DPeek(88)+WhereX)+WhereY*40), byte(40-byte(WhereX)), 0);
end;


procedure NoSound; assembler;
asm
{	jsr @rstsnd

	ldy #8
lp	sta $d200,y
	sta $d210,y
	dey
	bpl lp
};
end;


procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
//----------------------------------------------------------------------------------------------
// Chan = 0..3 primary Pokey
// Chan = 4..7 secondary Pokey
//----------------------------------------------------------------------------------------------
asm
{	lda Chan
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

	lda Dist
	:4 asl @
	ora #0
_t	equ *-1
	sta audc1,y
};
end;

procedure TextMode(Mode: byte); assembler;
asm
{
	@clrscr
};
end;


end.

