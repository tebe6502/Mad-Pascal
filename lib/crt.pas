unit CRT;
(*
@type: unit
@name: Mad Pascal screen and keyboard handling units
@author: Tomasz Biela (Tebe)

@description:
<http://www.freepascal.org/docs-html/rtl/crt/index-5.html>
*)


{

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

{$IFDEF ATARI}
var
	TextAttr: byte = 0;			(* @var Text Attribute *)
	Consol: byte absolute $d01f;		// CONSOL register
{$ENDIF}

const
{$IFDEF ATARI}
	CN_START_SELECT_OPTION	= 0;		// Consol values
	CN_SELECT_OPTION	= 1;
	CN_START_OPTION		= 2;
	CN_OPTION		= 3;
	CN_START_SELECT		= 4;
	CN_SELECT		= 5;
	CN_START		= 6;
	CN_NONE			= 7;
{$ENDIF}

{$IFNDEF X16}
{ CRT modes }
	BW40	= 0;		{ 40x25 B/W on Color Adapter }
	CO40	= 1;		{ 40x25 Color on Color Adapter }
	BW80	= 2;		{ 80x25 B/W on Color Adapter }
	CO80	= 3;		{ 80x25 Color on Color Adapter }
	Mono	= 7;		{ 80x25 on Monochrome Adapter }

  { Mode constants for 3.0 compatibility }
	C40	= CO40;
	C80	= CO80;
{$ENDIF}

{ Foreground and background color constants }

{$IFDEF X16}

  PETSCII_COLOR_WHITE	        = $05;
  PETSCII_COLOR_RED           = $1c;
  PETSCII_COLOR_GREEN	        = $1e;
  PETSCII_COLOR_BLUE	        = $1f;
  PETSCII_COLOR_ORANGE	      = $81;
  PETSCII_COLOR_BLACK	        = $90;
  PETSCII_COLOR_BROWN	        = $95;
  PETSCII_COLOR_PINK	        = $96;
  PETSCII_COLOR_DARK_GREY	    = $97;
  PETSCII_COLOR_GREY	        = $98;
  PETSCII_COLOR_LIGHT_GREEN 	= $99;
  PETSCII_COLOR_LIGHT_BLUE	  = $9a;
  PETSCII_COLOR_LIGHT_GREY	  = $9b;
  PETSCII_COLOR_PURPLE	      = $9c;
  PETSCII_COLOR_YELLOW	      = $9e;
  PETSCII_COLOR_CYAN	        = $9f;

  BLACK                 = PETSCII_COLOR_BLACK;
  WHITE                 = PETSCII_COLOR_WHITE;
  RED                   = PETSCII_COLOR_RED;
  CYAN                  = PETSCII_COLOR_CYAN;
  PURPLE                = PETSCII_COLOR_PURPLE;
  GREEN                 = PETSCII_COLOR_GREEN;
  BLUE                  = PETSCII_COLOR_BLUE;
  YELLOW                = PETSCII_COLOR_YELLOW;
  ORANGE                = PETSCII_COLOR_ORANGE;
  BROWN                 = PETSCII_COLOR_BROWN;
  LIGHT_RED             = PETSCII_COLOR_PINK;
  DARK_GREY             = PETSCII_COLOR_DARK_GREY;
  GREY                  = PETSCII_COLOR_GREY;
  LIGHT_GREEN           = PETSCII_COLOR_LIGHT_GREEN;
  LIGHT_BLUE            = PETSCII_COLOR_LIGHT_BLUE;
  LIGHT_GREY            = PETSCII_COLOR_LIGHT_GREY;

{ CRT modes }
  X16_MODE_80x60  = $00;
  X16_MODE_80x30  = $01;     
  X16_MODE_40x60  = $02;
  X16_MODE_40x30  = $03;    
  X16_MODE_40x15  = $04;     
  X16_MODE_20x30  = $05;
  X16_MODE_20x15  = $06;
  X16_MODE_22x23  = $07;
  X16_MODE_64x50  = $08;     
  X16_MODE_64x25  = $09;     
  X16_MODE_32x50  = $0A;     
  X16_MODE_32x25  = $0B;     

	BW40	= X16_MODE_40x30;		{ 40x30 }
	CO40	= X16_MODE_40x60;		{ 40x60 }
	BW80	= X16_MODE_80x30;		{ 80x30 }
	CO80	= X16_MODE_80x60;		{ 80x60 }
	Mono	= X16_MODE_80x30;		{ 80x30 }
  
  { Mode constants for 3.0 compatibility }
	C40	= CO40;
	C80	= CO80;
{$ENDIF}

{$IFDEF C64}

  BLACK                 = $0;
  WHITE                 = $1;
  RED                   = $2;
  CYAN                  = $3;
  PURPLE                = $4;
  GREEN                 = $5;
  BLUE                  = $6;
  YELLOW                = $7;
  ORANGE                = $8;
  BROWN                 = $9;
  LIGHT_RED             = $A;
  DARK_GREY             = $B;
  GREY                  = $C;
  LIGHT_GREEN           = $D;
  LIGHT_BLUE            = $E;
  LIGHT_GREY            = $F;

{$ENDIF}


{$IFDEF C4P}

  BLACK                 = $0;
  WHITE                 = $1;
  RED                   = $2;
  CYAN                  = $3;
  PURPLE                = $4;
  GREEN                 = $5;
  BLUE                  = $6;
  YELLOW                = $7;
  ORANGE                = $8;
  BROWN                 = $9;
  YELLOW_GREEN          = $A;
  PINK                  = $B;
  BLUE_GREEN            = $C;
  LIGHT_BLUE            = $D;
  DARK_BLUE             = $E;
  LIGHT_GREEN           = $F;

{$ENDIF}


{$IFDEF ATARI}

  BLACK                 = $00;
  WHITE                 = $0F;
  RED                   = $26;
  CYAN                  = $AC;
  PURPLE                = $48;
  GREEN                 = $B6;
  BLUE                  = $86;
  YELLOW                = $DC;
  ORANGE                = $18;
  BROWN                 = $F4;
  LIGHT_RED             = $2A;
  DARK_GREY             = $04;
  GREY                  = $08;
  LIGHT_GREEN           = $BC;
  LIGHT_BLUE            = $9A;
  LIGHT_GREY            = $0C;

{$ENDIF}



{ Add-in for blinking }
	Blink		= 128;


	procedure ClrEol;
	procedure ClrScr;                                                                          //platform dependent
	procedure CursorOff;
	procedure CursorOn;
	procedure Delay(count: word); assembler;
	procedure DelLine;
	procedure GotoXY(x,y: byte); assembler;                                                    //platform dependent
	procedure InsLine;
	function Keypressed: Boolean; assembler;                                                   //platform dependent
	procedure NoSound; assembler;
	function ReadKey: char; assembler;                                                         //platform dependent
	procedure Sound(Chan,Freq,Dist,Vol: byte); assembler;
	procedure TextBackground(a: byte); assembler;
	procedure TextColor(a: byte); assembler;
	procedure TextMode(Mode: byte); assembler;
	function WhereX: byte; assembler;                                                          //platform dependent
	function WhereY: byte; assembler;                                                          //platform dependent
{$IFDEF X16}
  procedure TextCharset(charset: pointer); assembler;                                     //platform dependent
{$ENDIF}

implementation

{$IFDEF ATARI}

uses atari;

{$ENDIF}

{$IFDEF X16}

uses x16;

{$ENDIF}


{$i '../src/targets/crt.inc'}


end.
