unit system;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Standard supported functions of Mad Pascal

 @version: 1.2

 @description:
 <http://www.freepascal.org/docs-html/rtl/system/index-5.html>
*)


{

Abs
ArcTan
Ata2Int
BinStr
CompareByte
Concat
Copy
Cos		; real, single
DPeek		; optimization build in compiler
DPoke		; optimization build in compiler
Eof
Exp
FilePos
FileSize
FillByte	; optimization build in compiler
FillChar	; optimization build in compiler
IsLetter
IsDigit
iSqrt		; fast inverse square root
GetResourceHandle; optimization build in compiler
HexStr
Ln
LowerCase
Move		; optimization build in compiler
NtoBE
OctStr
ParamCount
ParamStr
Pause
Peek		; optimization build in compiler
Poke		; optimization build in compiler
Random
ReadConfig
ReadSector
RolByte
RolWord
RolDWord
RorByte
RorWord
RorDWord
RunError
SarShortint
SarSmallint
SarLongint
Seek
SetLength
Sin		; real, single
SizeOfResource	; optimization build in compiler
Space
Str
StringOfChar
Sqr
Sqrt		; sqrt(x) = exp(0.5*ln(x))
UpCase
Val
WriteSector

}

interface

type	TString = string[32];
	(*
	@description:

	*)

type	TSize = record cx, cy: smallint end;
	(*
	@description:
	TSize is a type to describe the size of a rectangular area, where cx is the width, cy is the height (in pixels) of the rectangle.
	*)

type	TRect = record	left, top, right, bottom: smallint end;
	(*
	@description:
	TRect is a type to describe a rectangular area.
	*)

type	TPoint = record x,y: SmallInt end;
	(*
	@description:
	This record describes a coordinate.
	*)

type	TDateTime = record yy,mm,dd,h,m,s: byte end;
	(*
	@description:
	This record describes Date-Time.
	*)

type	TLastArcCoords = record x,y,xstart,ystart,xend,yend: smallint end;
	(*
	@description:

	*)

type	PtrUInt = word;
	(*
	@description:

	*)

type	PBoolean = ^Boolean;
	(*
	@description:

	*)

type	PByte = ^byte;
	(*
	@description:

	*)

type	PWord = ^word;
	(*
	@description:

	*)

type	PLongWord = ^cardinal;
	(*
	@description:

	*)

type	PCardinal = ^cardinal;
	(*
	@description:

	*)

type	PSmallint = ^smallint;
	(*
	@description:

	*)

type	PInteger = ^integer;
	(*
	@description:

	*)

type	PReal = ^real;
	(*
	@description:

	*)

type	PSingle = ^single;
	(*
	@description:

	*)

type	PFloat16 = ^float16;
	(*
	@description:

	*)

type	PString = ^string;
	(*
	@description:

	*)

type	PByteArray = ^byte;
	(*
	@description:

	*)

type	PWordArray = ^word;
	(*
	@description:

	*)

const

{$ifdef atari}
	__PORTB_BANKS = $0101;		// memory banks array
{$endif}

	M_PI_2	= pi*2;
	D_PI_2	= pi/2;
	D_PI_180= pi/180;

{$ifdef atari}
	mGTIA	= 0;
	mVBXE	= $80;
//	WINDOW	= $10;			// text window
//	NARROW	= $20;			// narrow screen

	VBXE_XDLADR = $0000;		// XDLIST
	VBXE_BCBTMP = $00E0;		// BLITTER TEMP
	VBXE_BCBADR = $0100;		// BLITTER LIST ADDRESS
	VBXE_MAPADR = $1000;		// COLOR MAP ADDRESS
	VBXE_CHBASE = $1000;		// CHARSET BASE ADDRESS
	VBXE_OVRADR = $5000;		// OVERLAY ADDRESS
	VBXE_WINDOW = $B000;		// 4K WINDOW $B000..$BFFF

	iDLI = 0;			// set new DLI vector
	iVBL = 1;			// set new VBLD vector
	iVBLD = 1;
	iVBLI = 2;			// set new VBLI vector
	iTIM1 = 3;			// set new IRQ TIMER1 vector
	iTIM2 = 4;			// set new IRQ TIMER2 vector
	iTIM4 = 5;			// set new IRQ TIMER4 vector

{$endif}

(* Character codes *)
{$ifdef atari}
	CH_DELCHR	= chr($FE);	// delete char under the cursor
	CH_ENTER	= chr($9B);
	CH_ESC		= chr($1B);
	CH_CURS_UP	= chr(28);
	CH_CURS_DOWN	= chr(29);
	CH_CURS_LEFT	= chr(30);
	CH_CURS_RIGHT	= chr(31);

	CH_TAB		= chr($7F);	// tabulator
	CH_EOL		= chr($9B);	// end-of-line marker
	CH_CLR		= chr($7D);	// clear screen
	CH_BELL		= chr($FD);	// bell
	CH_DEL		= chr($7E);	// back space (delete char to the left)
	CH_DELLINE	= chr($9C);	// delete line
	CH_INSLINE	= chr($9D);	// insert line
{$endif}

(* Character codes *)
{$ifdef neo}
	NEO_CURSOR_LEFT 	= chr(1);
	NEO_CURSOR_RIGHT	= chr(4);
	NEO_INSERT		= chr(5);
	NEO_PAGE_DOWN		= chr(6);
	NEO_END			= chr(7);
	NEO_BACKSPACE		= chr(8);
	NEO_HTAB		= chr(9);	// horizontal tab
	NEO_LINE_FEED		= chr(10);
	NEO_CLEAR_SCREEN	= chr(12);
	NEO_ENTER		= chr(13);
	NEO_PAGE_UP		= chr(18);
	NEO_CURSOR_DOWN 	= chr(19);
	NEO_CURSOR_HOME		= chr(20);
	NEO_VTAB 		= chr(22);	// vertical tab
	NEO_CURSOR_UP		= chr(23);
	NEO_CURSOR_REV		= chr(24);	// cursor reverse
	NEO_DELETE		= chr(26);
	NEO_ESCAPE		= chr(27);	// general break – e.g. exits BASIC
 
 	//--------------------------//
	// color control characters //
	//--------------------------//

	NEO_COLOR_BLACK		= chr($80);
	NEO_COLOR_RED		= chr($81);
	NEO_COLOR_GREEN		= chr($82);
	NEO_COLOR_YELLOW	= chr($83);
	NEO_COLOR_BLUE		= chr($84);
	NEO_COLOR_MAGENTA	= chr($85);
	NEO_COLOR_CYAN		= chr($86);
	NEO_COLOR_WHITE		= chr($87);
	NEO_COLOR_ALT_BLACK	= chr($88);
	NEO_COLOR_DARK_GREY	= chr($89);
	NEO_COLOR_DARK_GREEN	= chr($8A);
	NEO_COLOR_ORANGE	= chr($8B);
	NEO_COLOR_DARK_ORANGE	= chr($8C);
	NEO_COLOR_BROWN		= chr($8D);
	NEO_COLOR_PINK		= chr($8E);
	NEO_COLOR_LIGHT_GREY	= chr($8F);

{$endif}

(* color defines *)
{$ifdef atari}
	PAL_PMCOLOR0	= 0;		// palette index Palette[..] , HPalette[..]
	PAL_PMCOLOR1	= 1;
	PAL_PMCOLOR2	= 2;
	PAL_PMCOLOR3	= 3;

	PAL_COLOR0	= 4;
	PAL_COLOR1	= 5;
	PAL_COLOR2	= 6;
	PAL_COLOR3	= 7;
	PAL_COLBAK	= 8;

	COLOR_BLACK		= $00;
	COLOR_WHITE		= $0e;
	COLOR_RED		= $32;
	COLOR_CYAN		= $96;
	COLOR_VIOLET		= $68;
	COLOR_GREEN		= $c4;
	COLOR_BLUE		= $74;
	COLOR_YELLOW		= $ee;
	COLOR_ORANGE		= $28;
	COLOR_BROWN		= $e4;
	COLOR_LIGHTRED		= $3c;
	COLOR_GRAY1		= $04;
	COLOR_GRAY2		= $06;
	COLOR_GRAY3		= $0a;
	COLOR_LIGHTGREEN	= $cc;
	COLOR_LIGHTBLUE 	= $7c;
{$endif}

(* file mode *)
{$ifndef raw}
	fmOpenRead	= $04;
	fmOpenWrite	= $08;
	fmOpenAppend	= $09;
	fmOpenReadWrite	= $0c;
{$endif}

{$ifndef raw}
var	ScreenWidth: smallint = 40;	(* @var current screen width *)
	ScreenHeight: smallint = 24;	(* @var current screen height *)

	DateSeparator: Char = '-';

{$ifdef atari}
	[volatile] Rnd: byte absolute $d20a;

	Palette: array [0..8] of byte absolute 704;
	HPalette: array [0..8] of byte absolute $d012;
{$endif}

	FileMode: byte = fmOpenReadWrite;

	GraphMode: byte;		(* @var current screen mode *)

	IOResult: byte;			(* @var result of last file IO operation *)

	EoLn: Boolean;			(* @var end of line status *)
{$endif}

	function Abs(x: Real): Real; register; assembler; overload;
	function Abs(x: Single): Single; register; assembler; overload;
	function Abs(x: float16): float16; register; assembler; overload;
	function Abs(x: shortint): shortint; register; assembler; overload;
	function Abs(x: smallint): smallint; register; assembler; overload;
	function Abs(x: Integer): Integer; register; assembler; overload;
	function ArcTan(value: real): real; overload;
	function ArcTan(value: single): single; overload;
	function ata2int(a: char): char; assembler;
	function BinStr(Value: cardinal; Digits: byte): TString; assembler;
	function CompareByte(P1,P2: PByte; Len: word): smallint; register; overload;
	function CompareByte(P1,P2: PByte; Len: byte): smallint; register; overload;
	function Concat(a,b: PString): string; assembler; overload;
	function Concat(a: PString; b: char): string; assembler; overload;
	function Concat(a: char; b: PString): string; assembler; overload;
	function Concat(a,b: char): string; overload;
	function Copy(var S: String; Index: Byte; Count: Byte): string; assembler;
	function Cos(x: Real): Real; overload;
	function Cos(x: Single): Single; overload;
	function Cos(x: float16): float16; overload;
	function Cos(x: ShortReal): ShortReal; overload;
	procedure Delete(var s: string; index, count: byte);
	function DPeek(a: word): word; register; stdcall; assembler;
	procedure DPoke(a: word; value: word); register; stdcall; assembler;
	function Eof(var f: file): Boolean;
	function Exp(x: Real): Real; overload;
	function Exp(x: Float): Float; overload;
	function Exp(x: Float16): Float16; overload;
	function FilePos(var f: file): cardinal; assembler;
	function FileSize(var f: file): cardinal; assembler;
	procedure FillByte(a: pointer; count: word; value: byte); assembler; register; overload; inline;
	procedure FillByte(var a; count: word; value: byte); assembler; register; overload; inline;
	procedure FillChar(a: pointer; count: word; value: char); assembler; register; overload; inline;
	procedure FillChar(a: pointer; count: word; value: byte); assembler; register; overload; inline;
	procedure FillChar(a: pointer; count: word; value: Boolean); assembler; register; overload; inline;
	procedure FillChar(var a; count: word; value: Boolean); assembler; register; overload; inline;
	procedure FillChar(var a; count: word; value: byte); assembler; register; overload; inline;
	function FloatToStr(a: real): TString; stdcall; assembler;
	procedure FreeMem(var p; size: word); assembler; register;
	procedure GetMem(var p; size: word); assembler; register; overload;
	function GetMem(size: word): pointer; assembler; register; overload;
	function HexStr(Value: cardinal; Digits: byte): TString; register; assembler;
	function IsLetter(A: char): Boolean;
	function IsDigit(A: char): Boolean;
	function iSqrt(number: Single): Single;
	function Ln(x: Real): Real; overload;
	function Ln(x: Float): Float; overload;
 	function LowerCase(a: char): char;
	procedure Move(source, dest: pointer; count: word); assembler; register; overload; inline;
	procedure Move(var source, dest; count: word); assembler; register; overload; inline;
	procedure Move(var source; dest: pointer; count: word); assembler; register; overload; inline;
	procedure Move(source: pointer; var dest; count: word); assembler; register; overload; inline;
	function NtoBE(AValue: word): word; overload;
	function NtoBE(AValue: cardinal): cardinal; overload;
	function OctStr(Value: cardinal; Digits: byte): TString; assembler;
	function ParamCount: byte; assembler;
	function ParamStr(i: byte): TString; assembler;
	procedure Pause; assembler; overload;							//platform dependent
	procedure Pause(n: word); assembler; overload;						//platform dependent
	function Peek(a: word): byte; register; stdcall; assembler;
	procedure Poke(a: word; value: byte); register; stdcall; assembler;
	function Pos(c: char; s: string): byte; overload;
	function Pos(s1: string; s2: string): byte; overload;
	function Random: Real; overload;							//platform dependent
	function Random(range: byte): byte; assembler; overload;				//platform dependent
	function Random(range: smallint): smallint; overload;					//platform dependent
	function RandomF: Float;								//platform dependent
	function RandomF16: Float16;								//platform dependent
	procedure Randomize; assembler;								//platform dependent
	function RolByte(Const AValue : Byte): Byte; overload;
	function RolByte(Const AValue : Byte;const Dist : Byte): Byte; overload;
	function RolWord(Const AValue : Word): Word; overload;
	function RolWord(Const AValue : Word;const Dist : Byte): Word; overload;
	function RolDWord(Const AValue : DWord): DWord; overload;
	function RolDWord(Const AValue : DWord;const Dist : Byte): DWord; overload;
	function RorByte(Const AValue : Byte): Byte; overload;
	function RorByte(Const AValue : Byte;const Dist : Byte): Byte; overload;
	function RorWord(Const AValue : Word): Word; overload;
	function RorWord(Const AValue : Word;const Dist : Byte): Word; overload;
	function RorDWord(const AValue: DWord): DWord; overload;
	function RorDWord(const AValue: DWord; const Dist: Byte): DWord; overload;
	procedure RunError(a: byte);
	function SarShortint(Const AValue : Shortint;const Shift : Byte): Shortint;
	function SarSmallint(Const AValue : Smallint;const Shift : Byte): Smallint;
	function SarLongint(Const AValue : Longint;const Shift : Byte): Longint;
	procedure Seek(var f: file; a: cardinal); assembler;
	procedure SetLength(var S: string; Len: byte); register; assembler;
	function Sin(x: Real): Real; overload;
	function Sin(x: Single): Single; overload;
	function Sin(x: float16): float16; overload;
	function Sin(x: shortreal): shortreal; overload;
	function Space(b: Byte): ^string; assembler;
	procedure Str(a: integer; var s: TString); overload; stdcall; assembler;
	procedure Str(a: cardinal; var s: TString); overload; stdcall; assembler;
	function StringOfChar(c: Char; l: byte): ^string; assembler;
	function Sqr(x: Real): Real; overload;
	function Sqr(x: Single): Single; overload;
	function Sqr(x: integer): integer; overload;
	function Sqrt(x: ShortReal): ShortReal; overload;
	function Sqrt(x: Real): Real; overload;
	function Sqrt(x: Single): Single; overload;
	function Sqrt(x: float16): float16; overload;
	function Sqrt(x: Integer): Single; overload;
	function UpCase(a: char): char; overload;
	function UpCase(a: string): string; overload;
	procedure Val(s: PString; var v: integer; var code: byte); assembler; overload;
	procedure Val(s: PString; var v: real; var code: byte); overload; //register;
	procedure Val(s: PString; var v: single; var code: byte); overload; //register;
	function Swap(a: word): word; overload;
	function Swap(a: cardinal): cardinal; overload;


implementation

var
	RndSeed: smallint;


procedure RunError(a: byte);
(*
@description:
Print error message

@param: a - error number
*)
begin
	writeln(#69,#82,#82,#32, a);	// 'ERR ',a	; kody znakow oddzielone przecinkiem nie zostana potraktowane jako ciag znakowy ktory kompilator zapisuje do stalych
	halt(2);
end;


function ata2int(a: char): char; assembler;
asm
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror

	sta Result;
end;


function HexStr(Value: cardinal; Digits: byte): TString; register; assembler;
(*
@description:
Convert cardinal value to string with hexadecimal representation.

@param: Value
@param: Digits

@returns: string[32]
*)
asm
	jsr @hexStr

;	@move #@buf Result #33
	ldy #256-33
	mva:rne @buf+33-256,y adr.Result+33-256,y+
end;


function Peek(a: word): byte; register; stdcall; assembler;
(*
@description:
Reads BYTE from the desired memory address

@param: a - memory address

@returns: byte
*)
asm
	ldy #0
	mva (:edx),y Result
end;


function DPeek(a: word): word; register; stdcall; assembler;
(*
@description:
Reads WORD from the desired memory address

@param: a - memory address

@returns: word
*)
asm
	ldy #0
	mva (:edx),y Result
	iny
	mva (:edx),y Result+1
end;


function Abs(x: Real): Real; register; assembler; overload;
(*
@description:
Abs returns the absolute value of a variable.

The result of the function has the same type as its argument, which can be any numerical type.

@param: x - Real (Q24.8)

@returns: Real (Q24.8)
*)
asm
	lda :edx+3
	spl
	jsr negEDX

	mva :edx Result
	mva :edx+1 Result+1
	mva :edx+2 Result+2
	mva :edx+3 Result+3
end;


function Abs(x: Single): Single; register; assembler; overload;
(*
@description:
Abs returns the absolute value of a variable.

The result of the function has the same type as its argument, which can be any numerical type.

@param: x - Single

@returns: Single
*)
asm
	lda :edx+3
	and #$7f
	sta Result+3

	mva :edx Result
	mva :edx+1 Result+1
	mva :edx+2 Result+2
end;


function Abs(x: float16): float16; register; assembler; overload;
(*
@description:
Abs returns the absolute value of a variable.

The result of the function has the same type as its argument, which can be any numerical type.

@param: x - Single

@returns: Single
*)
asm
	lda :edx+1
	and #$7f
	sta Result+1

	mva :edx Result
end;


function Abs(x: shortint): shortint; register; assembler; overload;
(*
@description:
Abs returns the absolute value of a variable.

The result of the function has the same type as its argument, which can be any numerical type.

@param: x - shortint

@returns: shortint
*)
asm
	lda :edx
	bpl @+

	eor #$ff
	add #1
@
	sta Result
end;


function Abs(x: smallint): smallint; register; assembler; overload;
(*
@description:
Abs returns the absolute value of a variable.

The result of the function has the same type as its argument, which can be any numerical type.

@param: x - smallint

@returns: smallint
*)
asm
	lda :edx+1
	bpl @+

	lda #$00
	sub :edx
	sta :edx
	lda #$00
	sbc :edx+1
	sta :edx+1
@
	sta Result+1

	mva :edx Result
end;


function Abs(x: Integer): Integer; register; assembler; overload;
(*
@description:
Abs returns the absolute value of a variable.

The result of the function has the same type as its argument, which can be any numerical type.

@param: x - Integer

@returns: Integer
*)
asm
	lda :edx+3
	spl
	jsr negEDX

	sta Result+3

	mva :edx Result
	mva :edx+1 Result+1
	mva :edx+2 Result+2
end;


function Sqr(x: Real): Real; overload;
(*
@description:
Sqr returns the square of its argument X

@param: x - Real (Q24.8)

@returns: Real (Q24.8)
*)
begin

 Result := x*x;

end;


function Sqr(x: Single): Single; overload;
(*
@description:
Sqr returns the square of its argument X

@param: x - Single

@returns: Single
*)
begin

 Result := x*x;

end;


function Sqr(x: integer): integer; overload;
(*
@description:
Sqr returns the square of its argument X

@param: x - integer

@returns: integer
*)
begin

 Result := x*x;

end;


function Sqrt(x: ShortReal): ShortReal; overload;
(*
@description
Sqrt returns the square root of its argument X, which must be positive

@param: x - ShortReal (Q8.8)

@returns: ShortReal (Q8.8)
*)
var sp: ^shortreal;
    c: word;
begin
	Result:=0.0;

	if x < 0.0 then exit;

	sp:=@c;

	c:=word(x);

	c:=(c shr 4) + $10;

	Result := sp^;

	Result:=(Result+x/Result);// * 0.5;

	asm
	 lda Result+1
	 asl @

	 ror Result+1
	 ror Result
	end;

	Result:=(Result+x/Result) ;//* 0.5;

	asm
	 lda Result+1
	 asl @

	 ror Result+1
	 ror Result
	end;

	Result:=(Result+x/Result) ;//* 0.5;

	asm
	 lda Result+1
	 asl @

	 ror Result+1
	 ror Result
	end;

end;


function Sqrt(x: Real): Real; overload;
(*
@description
Sqrt returns the square root of its argument X, which must be positive

@param: x - Real (Q24.8)

@returns: Real (Q24.8)
*)
var sp: ^real;
    c: cardinal;
begin
	Result:=0.0;

	if x < 0.0 then exit;

	sp:=@c;

	c:=cardinal(x);

	c:=(c shr 8) + $100;

	Result := sp^;

	Result:=(Result+x/Result); //* 0.5;

	asm
	 lda Result+3
	 asl @

	 ror Result+3
	 ror Result+2
	 ror Result+1
	 ror Result
	end;

	Result:=(Result+x/Result); //* 0.5;


	asm
	 lda Result+3
	 asl @

	 ror Result+3
	 ror Result+2
	 ror Result+1
	 ror Result
	end;

	Result:=(Result+x/Result); //* 0.5;

	asm
	 lda Result+3
	 asl @

	 ror Result+3
	 ror Result+2
	 ror Result+1
	 ror Result
	end;

end;


function Sqrt(x: Single): Single; overload;
(*
@description
Sqrt returns the square root of its argument X, which must be positive

@param: x - Single

@returns: Single
*)
var sp: ^single;
    c: cardinal;
begin
	Result:=0;

	if integer(x) < 0 then exit;

	sp:=@c;

	c:=cardinal(x);

	if c > $3f800000 then c := (c - $3f800000) shr 1 + $3f800000;	// 1 = f32($3f800000)

	Result := sp^;

	Result:=(Result+x/Result) * 0.5;
	Result:=(Result+x/Result) * 0.5;
//	Result:=(Result+x/Result) * 0.5;
end;


function Sqrt(x: float16): float16; overload;
(*
@description
Sqrt returns the square root of its argument X, which must be positive

@param: x - float16

@returns: float16
*)
var sp: ^float16;
    c: word;
begin
	Result:=0;

	if smallint(x) < 0 then exit;

	sp:=@c;

	c:=word(x);

	if c > $3c00 then c := (c - $3c00) shr 1 + $3c00;

	Result := sp^;

	Result:=(Result+x/Result) * 0.5;
//	Result:=(Result+x/Result) * 0.5;
//	Result:=(Result+x/Result) * 0.5;
end;


function Sqrt(x: Integer): Single; overload;
(*
@description
Sqrt returns the square root of its argument X, which must be positive

@param: x - integer

@returns: integer
*)
var sp: ^single;
    c: cardinal;
begin
	Result:=0;

	if x < 0 then exit;

	sp:=@c;

	c:=cardinal(single(x));

	if c > $3f800000 then c := (c - $3f800000) shr 1 + $3f800000;

	Result := sp^;

	Result:=(Result+x/Result) * 0.5;
	Result:=(Result+x/Result) * 0.5;
//	Result:=(Result+x/Result) * 0.5;
end;


function iSqrt(number: Single): Single;
(*
@description:
Fast inverse square root

<https://en.wikipedia.org/wiki/Fast_inverse_square_root>

<https://pl.wikipedia.org/wiki/Szybka_odwrotno%C5%9B%C4%87_pierwiastka_kwadratowego>

@param: number - Single

@returns: Single
*)
var sp: ^single;
    c: cardinal;
    f0, f1: single;
const
    threehalfs: single = 1.5;
begin

	sp:=@c;

	f0 := number * 0.5;
	c  := cardinal(number);		// evil floating point bit level hacking
	c  := $5f3759df - (c shr 1);	// what the fuck?
        f1 := f0 * sp^ * sp^;
	Result := sp^ * ( 1.5 - f1 );	// 1st iteration

end;


function ArcTan(value: real): real; overload;
(*
@description:
Arctan returns the Arctangent of Value, which can be any Real type.

The resulting angle is in radial units.

@param: value - Real (Q24.8)

@returns: Real (Q24.8)
*)
var x, y: real;
    sign: Boolean;
begin
  sign:=false;
  x:=value;
  y:=0.0;

  if (value=0.0) then begin
    Result:=0.0;
    exit;
  end else
   if (x < 0.0) then begin
    sign:=true;
    x:=-x;
   end;

  x:=(x-1.0)/(x+1.0);
  y:=x*x;
  x := ((((((((.0028662257*y - .0161657367)*y + .0429096138)*y -
             .0752896400)*y + .1065626393)*y - .1420889944)*y +
             .1999355085)*y - .3333314528)*y + 1.0)*x;
  x:= .785398163397 + x;

  if sign then
   Result := -x
  else
   Result := x;

end;


function ArcTan(value: single): single; overload;
(*
@description:
Arctan returns the Arctangent of Value, which can be any Real type.

The resulting angle is in radial units.

@param: value - Real (Q24.8)

@returns: Real (Q24.8)
*)
var x, y: single;
    sign: Boolean;
begin
  sign:=false;
  x:=value;
  y:=0;

  if (integer(value) = 0) then begin
    Result:=0;
    exit;
  end else
   if (integer(x) < 0) then begin
    sign:=true;
    x:=-x;
   end;

  x:=(x-1)/(x+1);
  y:=x*x;
  x := ((((((((.0028662257*y - .0161657367)*y + .0429096138)*y -
             .0752896400)*y + .1065626393)*y - .1420889944)*y +
             .1999355085)*y - .3333314528)*y + 1.0)*x;
  x:= .785398163397 + x;

  if sign then
   Result := -x
  else
   Result := x;

end;


function Exp(x: Real): Real; overload;
(*
@description:
Exp returns the exponent of X, i.e. the number e to the power X.

<https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent>

@param: x - Real (Q24.8)

@returns: Real (Q24.8)
*)
var P, Fraction, I, L: Real;
begin
    Fraction := x;
    P := x + 1;
    I := 1;

    while L <> P do begin
        I := I + 1;
        Fraction :=Fraction * (x / I);
        L := P;
        P := P + Fraction;
    end;

    Result := P;
end;


function Exp(x: Float): Float; overload;
(*
@description:
Exp returns the exponent of X, i.e. the number e to the power X.

<https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent>

@param: x - Float (Single)

@returns: Float (Single)
*)
var P, Fraction, I, L: Float;
begin
    Fraction := x;
    P := x + 1;
    I := 1;

    while L <> P do begin
        I := I + 1;
        Fraction :=Fraction * (x / I);
        L := P;
        P := P + Fraction;
    end;

    Result := P;
end;


function Exp(x: Float16): Float16; overload;
(*
@description:
Exp returns the exponent of X, i.e. the number e to the power X.

<https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent>

@param: x - Float16

@returns: Float16
*)
var P, Fraction, I, L: Float16;
begin
    Fraction := x;
    P := x + 1;
    I := 1;

    while L <> P do begin
        I := I + 1;
        Fraction :=Fraction * (x / I);
        L := P;
        P := P + Fraction;
    end;

    Result := P;
end;


function Ln(x: Real): Real; overload;
(*
@description:
Ln returns the natural logarithm of the Real parameter X. X must be positive.

<https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent>

@param: x - Real (Q24.8)

@returns: Real (Q24.8)
*)
var N, P, K, L, R, A, E: Real;
begin
		E := 2.71828182845905;
		P := x;
		N := 0;

	if X>0.0 then begin

                // This speeds up the convergence by calculating the integral
		while(P >= E) do begin
			P := P / E;
			N := N + 1;
		end;

                N := N + (P / E);
		P := x;

		while true do begin
			A := N;
			K := N - 1;
			L := P / Exp(K);
			R := K * E;
			N := (L + R) / E;

			if A-N < 0.01 then Break;
		end;

	end;

		Result := N;
end;


function Ln(x: Float): Float; overload;
(*
@description:
Ln returns the natural logarithm of the Real parameter X. X must be positive.

<https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent>

@param: x - Float (Single)

@returns: Float (Single)
*)
var N, P, K, L, R, A, E: Float;
begin
		E := 2.71828182845905;
		P := x;
		N := 0;

	if x > Float(0) then begin

                // This speeds up the convergence by calculating the integral
		while(P >= E) do begin
			P := P / E;
			N := N + 1;
		end;

                N := N + (P / E);
		P := x;

		while true do begin
			A := N;
			K := N - 1;
			L := P / Exp(K);
			R := K * E;
			N := (L + R) / E;

			if A-N < Float(0.01) then Break;
		end;

	end;

		Result := N;
end;


function FileSize(var f: file): cardinal; assembler;
(*
@description:
Size of file (SDX only)

@param: f - file handle

@returns: cardinal
*)
asm
	txa:pha

	mwa f :bp2

	ldy #s@file.chanel
	lda (:bp2),y
	tax
	lda #39
	sta iccmd,x

	m@call	ciov

	sty IOResult

	mva icax3,x result
	mva icax4,x result+1
	mva icax5,x result+2
	mva #$00 result+3

	pla:tax
end;


function FilePos(var f: file): cardinal; assembler;
(*
@description:
Get position in file (SDX only)

@param: f - file handle

@returns: cardinal
*)
asm
	txa:pha

	mwa f :bp2

	ldy #s@file.chanel
	lda (:bp2),y
	tax
	lda #38
	sta iccmd,x

	m@call	ciov

	sty IOResult

	mva icax3,x :eax
	mva icax4,x :eax+1
	mva icax5,x :eax+2

	mva #$00 :eax+3
	sta :ecx+2
	sta :ecx+3

	ldy #s@file.record
	lda (:bp2),y
	sta :ecx
	iny
	lda (:bp2),y
	sta :ecx+1

	jsr @CARDINAL.DIV		; common\cardinal.asm

	mva :eax Result
	mva :eax+1 Result+1
	mva :eax+2 Result+2
	mva :eax+3 Result+3

	pla:tax
end;


procedure Seek(var f: file; a: cardinal); assembler;
(*
@description:
Set file position (SDX only)

@param: f - file handle
@param: a - new position
*)
asm
	txa:pha

	mwa f :bp2

	ldy #s@file.chanel
	lda (:bp2),y
	tax
	lda #37
	sta iccmd,x

	ldy #s@file.record
	lda (:bp2),y
	sta :eax
	iny
	lda (:bp2),y
	sta :eax+1
	lda #$00
	sta :eax+2
	sta :eax+3

	mva a :ecx
	mva a+1 :ecx+1
	mva a+2 :ecx+2
	mva a+3 :ecx+3

	jsr imulECX

	mva :eax icax3,x
	mva :eax+1 icax4,x
	mva :eax+2 icax5,x

	m@call	ciov

	sty IOResult

	pla:tax
end;


function Eof(var f: file): Boolean;
(*
@description:
Check for end of file

@param: f - file handle

@returns: TRUE if the file-pointer has reached the end of the file
@return: FALSE in all other cases
*)
var i: cardinal;
    bf: array [0..255] of byte;
begin
	i:=FilePos(f);

	blockread(f, bf, 1);

	Seek(f, i);

asm
{	mwa f :bp2

	ldy #s@file.status
	lda (:bp2),y
	and #e@file.eof
	sta Result
};
end;


function IsLetter(A: char): Boolean;
(*
@description:
Check if A is a letter.

@param: A - char

@returns: Boolean
*)
begin

 case a of
  'a'..'z' : Result := true;
  'A'..'Z' : Result := true;
 else
  Result := false
 end;

end;


function IsDigit(A: char): Boolean;
(*
@description:
Check if A is a digit.

@param: A - char

@returns: Boolean
*)
begin

 Result := (a>='0') and (a<='9');

end;


function LowerCase(a: char): char;
(*
@description:
Converts a character to lowercase

@param: a - char

@returns: char
*)
begin

 case a of
  'A'..'Z': Result := chr(byte(a) + 32)
 else
  Result := a
 end;

end;


function UpCase(a: char): char; overload;
(*
@description:
Converts a character to uppercase

@param: a - char

@returns: char
*)
begin

 case a of
  'a'..'z': Result := chr(byte(a) - 32)
 else
  Result := a
 end;

end;


function UpCase(a: string): string; overload;
var i: byte;
    ch: char;
(*
@description:
Converts characters to uppercase

@param: a - string

@returns: string
*)
begin

 Result:=a;

 for i:=1 to length(a) do begin

   ch:=a[i];

   case ch of
    'a'..'z': ch := chr(byte(ch) - 32)
   end;

   Result[i] := ch;

 end;

end;


procedure Val(s: PString; var v: integer; var code: byte); assembler; overload;
(*
@description:
Calculate numerical value of a string

@param: s - string
@param: v - pointer to integer - result
@param: code - pointer to integer - error code
*)
asm
	@StrToInt s

	tya
	pha

	mwa code :bp2
	ldy #0

	pla
	sta (:bp2),y

	mwa v :bp2

	mva :edx (:bp2),y+
	mva :edx+1 (:bp2),y+
	mva :edx+2 (:bp2),y+
	mva :edx+3 (:bp2),y
end;


procedure Val(s: PString; var v: real; var code: byte); overload; //register;
(*
@description:
Calculate numerical value of a string

@param: s - string
@param: v - pointer to real - result
@param: code - pointer to integer - error code
*)
var n, dotpos, len: byte;
    r: real;
begin

 r:=0.0;

 code:=1;

 len:=1 + byte(s[0]);

 if len > 1 then begin

	dotpos:=0;

	if (s[1] = '-') or (s[1] = '+') then	//Added line to check sign.If the number is signed,
		n:=2				//set n to position 2.
	else					//(number is not signed)
		n:=1;				//set n to position 1.

// If the number was signed,then we set n to 2,
// so that we start with s[2],and at the end
// if the number was negative we will multiply by -1.

	while n<len do begin			//n is already set to the position of the fisrt number.

	if (s[n] = '.') then
		dotpos := len - n - 1
        else
		if isDigit(s[n]) then
			r := r * 10.0 +  real(ord(s[n])-ord('0'))
		else begin
			v := 0.0;
			code := n;
			exit;
		end;

	inc(n);
	end;

	while dotpos <> 0 do begin
		r := r / 10;
		dec(dotpos);
	end;

	if (s[1]='-') then			//If s[] is "negative"
		r :=  -r;

	code := 0;
 end;

 v := r;

end;


procedure Val(s: PString; var v: single; var code: byte); overload; //register;
(*
@description:
Calculate numerical value of a string

@param: s - string
@param: v - pointer to integer - result
@param: code - pointer to integer - error code
*)
var n, dotpos, len: byte;
    f: single;
begin

 f:=0;

 code:=1;

 len:=length(s) + 1;

 if len > 1 then begin

	dotpos:=0;

	if (s[1] = '-') or (s[1] = '+') then	//Added line to check sign.If the number is signed,
		n:=2				//set n to position 2.
	else					//(number is not signed)
		n:=1;				//set n to position 1.

// If the number was signed,then we set n to 2,
// so that we start with s[2],and at the end
// if the number was negative we will multiply by -1.

	while n<len do begin			//n is already set to the position of the fisrt number.

	if (s[n] = '.') then
		dotpos := len - n - 1
        else
		if isDigit(s[n]) then
			f := f * 10 +  single(ord(s[n])-ord('0'))
		else begin
			v := 0;
			code := n;
			exit;
		end;

	inc(n);
	end;

	while dotpos <> 0 do begin
		f := f * 0.1;			// '* 0.1' is faster than '/ 10'
		dec(dotpos);
	end;

	if (s[1]='-') then			// If s[] is "negative"
		f :=  -f;

	code := 0;
 end;

 v := f;

end;


function FloatToStr(a: real): TString; stdcall; assembler;
(*
@description:
Convert a float value to a string

@param: a - Real (Q24.8)

@returns: string[32]
*)
asm
	txa:pha

	inx		; parameter A

	@ValueToStr #@printREAL

	ldx #$20
	mva:rpl @buf,x adr.Result,x-

	pla:tax
end;


procedure Str(a: integer; var s: TString); overload; stdcall; assembler;
(*
@description:
Convert a numerical value to a string

@param: a - integer
@param: s - string[32] - result
*)
asm
	txa:pha

	inx		; parameter A
	inx		; parameter S

	@ValueToStr #@printINT

	@buf2str s	; !!! koniecznie przez wskaznik

	pla:tax
end;


procedure Str(a: cardinal; var s: TString); overload; stdcall; assembler;
(*
@description:
Convert a numerical value to a string

@param: a - integer
@param: s - string[32] - result
*)
asm
	txa:pha

	inx		; parameter A
	inx		; parameter S

	@ValueToStr #@printCARD

	@buf2str s	; !!! koniecznie przez wskaznik

	pla:tax
end;


procedure Poke(a: word; value: byte); register; stdcall; assembler;
(*
@description:
Store BYTE at the desired memory address

@param: a - memory address
@param: value (0..255)
*)
asm
	ldy #0
	mva value (:edx),y
end;


procedure DPoke(a: word; value: word); register; stdcall; assembler;
(*
@description:
Store WORD at the desired memory address

@param: a - memory address
@param: value (0..65535)
*)
asm
	ldy #0
	mva value (:edx),y
	iny
	mva value+1 (:edx),y
end;


procedure FillChar(a: pointer; count: word; value: char); assembler; register; overload; inline;
(*
@description:
Fills the memory starting at A with Count Characters with value equal to Value

@param: a - pointer
@param: count
@param: value - Char
*)
asm
	jsr @fill
end;


procedure FillChar(a: pointer; count: word; value: byte); assembler; register; overload; inline;
(*
@description:
Fills the memory starting at A with Count Characters with value equal to Value

@param: a - pointer
@param: count
@param: value - Byte
*)
asm
	jsr @fill
end;


procedure FillChar(a: pointer; count: word; value: Boolean); assembler; register; overload; inline;
(*
@description:
Fills the memory starting at A with Count Characters with value equal to Value

@param: a - pointer
@param: count
@param: value - Boolean
*)
asm
	jsr @fill
end;


procedure FillChar(var a; count: word; value: Boolean); assembler; register; overload; inline;
(*
@description:
Fills the memory starting at A with Count Characters with value equal to Value

@param: a - array
@param: count
@param: value - Boolean
*)
asm
	jsr @fill
end;


procedure FillChar(var a; count: word; value: Byte); assembler; register; overload; inline;
(*
@description:
Fills the memory starting at A with Count Characters with value equal to Value

@param: a - array
@param: count
@param: value - Boolean
*)
asm
	jsr @fill
end;


procedure FillByte(a: pointer; count: word; value: byte); assembler; register; overload; inline;
(*
@description:
Fills the memory starting at A with Count Characters with value equal to Value

@param: a - pointer
@param: count
@param: value - Byte
*)
asm
	jsr @fill
end;


procedure FillByte(var a; count: word; value: byte); assembler; register; overload; inline;
(*
@description:
Fills the memory starting at A with Count Characters with value equal to Value

@param: a - array
@param: count
@param: value - Byte
*)
asm
	jsr @fill
end;


procedure Move(source, dest: pointer; count: word); assembler; register; overload; inline;
(*
@description:
Moves Count bytes from Source to Dest

@param: source - pointer
@param: dest - pointer
@param: count - word

@returns: cardinal
*)
asm
	jsr @move
end;

procedure Move(var source, dest; count: word); assembler; register; overload; inline;
(*
@description:

*)
asm
	jsr @move
end;

procedure Move(var source; dest: pointer; count: word); assembler; register; overload; inline;
(*
@description:

*)
asm
	jsr @move
end;


procedure Move(source: pointer;var dest; count: word); assembler; register; overload; inline;
(*
@description:

*)
asm
	jsr @move
end;


function rsincos(x: real; sc: boolean): real;
//----------------------------------------------------------------------------------------------
// http://atariage.com/forums/topic/240919-mad-pascal/page-10#entry3818764
//----------------------------------------------------------------------------------------------
var i: byte;
begin

 while x > M_PI_2 do x := x - M_PI_2;
 while x < 0.0    do x := x + M_PI_2;

    { Normalize argument, divide by (pi/2) }
    x := x * 0.63661977236758134308;

    { Get's integer part, should be }
    i := trunc(x);

    { Fixes negative part, needed to calculate "fractional" part }
    if x<0 then dec(i);

    { And finally get's fractional part }
    x := x - shortint(i);

    { If we need cosine, adds pi/2 }
    if sc then inc(i);

    { Test quadrant, odd values are reflected }
    if (i and 1) = 0 then x := 1 - x;

    { Calculate cosine(x) with optimal polynomial approximation }
    x := x * x;
    Result := ((0.019940292 * x - 0.23369547) * x + 1) * (1-x);

    { Test quadrant to return negative values }
    if (i and 2) = 2 then Result := -Result;

end;


function Sin(x: Real): Real; overload;
(*
@description:
Calculate sine of angle

@param: X - angle in radians (Q24.8)

@returns: Q24.8
*)
begin
	Result := rsincos(x, false);
end;


function Cos(x: Real): Real; overload;
(*
@description:
Calculate cosine of angle

@param: X - angle in radians (Q24.8)

@returns: Q24.8
*)
begin
	Result := rsincos(x, true);
end;


function srsincos(x: ShortReal; sc: boolean): ShortReal;
//----------------------------------------------------------------------------------------------
// http://atariage.com/forums/topic/240919-mad-pascal/page-10#entry3818764
//----------------------------------------------------------------------------------------------
var i: byte;
begin

 while x > M_PI_2 do x := x - M_PI_2;
 while x < 0.0    do x := x + M_PI_2;

    { Normalize argument, divide by (pi/2) }
    x := x * 0.63661977236758134308;

    { Get's integer part, should be }
    i := trunc(x);

    { Fixes negative part, needed to calculate "fractional" part }
    if x<0 then dec(i);

    { And finally get's fractional part }
    x := x - shortint(i);

    { If we need cosine, adds pi/2 }
    if sc then inc(i);

    { Test quadrant, odd values are reflected }
    if (i and 1) = 0 then x := 1 - x;

    { Calculate cosine(x) with optimal polynomial approximation }
    x := x * x;
    Result := ((0.019940292 * x - 0.23369547) * x + 1) * (1-x);

    { Test quadrant to return negative values }
    if (i and 2) = 2 then Result := -Result;

end;


function Sin(x: ShortReal): ShortReal; overload;
(*
@description:
Calculate sine of angle

@param: X - angle in radians (Q24.8)

@returns: Q24.8
*)
begin
	Result := srsincos(x, false);
end;


function Cos(x: ShortReal): ShortReal; overload;
(*
@description:
Calculate cosine of angle

@param: X - angle in radians (Q24.8)

@returns: Q24.8
*)
begin
	Result := srsincos(x, true);
end;



function fsincos(x: single; sc: boolean): single;
//----------------------------------------------------------------------------------------------
// https://atariage.com/forums/topic/240919-mad-pascal/?do=findComment&comment=3818764
//----------------------------------------------------------------------------------------------
var i: byte;
begin

    while x > single(M_PI_2) do x := x - M_PI_2;
    while integer(x) < 0 do x := x + M_PI_2;

    { Normalize argument, divide by (pi/2) }
    x := x * 0.63661977236758134308;

    { Get's integer part, should be }
    i := trunc(x);

    { Fixes negative part, needed to calculate "fractional" part }
    if integer(x) < 0 then dec(i); { this is shorter than "x < 0" }

    { And finally get's fractional part }
    x := x - shortint(i);

    { If we need cosine, adds pi/2 }
    if sc then inc(i);

    { Test quadrant, odd values are reflected }
    if (i and 1) = 0 then x := 1 - x;

    { Calculate cosine(x) with optimal polynomial approximation }
    x := x * x;
    Result := (((0.019940292 - x * 0.00084688153) * x - 0.23369547) * x + 1) * (1-x);

    { Test quadrant to return negative values }
    if (i and 2) = 2 then Result := -Result;
end;


function Sin(x: single): single; overload;
(*
@description:
Calculate sine of angle

@param: X - angle in radians (Single)

@returns: Single
*)
begin
    Result := fsincos(x, false);
end;


function Cos(x: single): single; overload;
(*
@description:
Calculate cosine of angle

@param: X - angle in radians (Single)

@returns: Single
*)
begin
    Result := fsincos(x, true);
end;


function fsincos16(x: float16; sc: boolean): float16;
//----------------------------------------------------------------------------------------------
// https://atariage.com/forums/topic/240919-mad-pascal/?do=findComment&comment=3818764
//----------------------------------------------------------------------------------------------
var i: byte;
begin

    while x > M_PI_2 do x := x - M_PI_2;
    while smallint(x) < 0 do x := x + M_PI_2;

    { Normalize argument, divide by (pi/2) }
    x := x * 0.63661977236758134308;

    { Get's integer part, should be }
    i := trunc(x);

    { Fixes negative part, needed to calculate "fractional" part }
    if smallint(x) < 0 then dec(i); { this is shorter than "x < 0" }

    { And finally get's fractional part }
    x := x - i ;

    { If we need cosine, adds pi/2 }
    if sc then inc(i);

    { Test quadrant, odd values are reflected }
    if (i and 1) = 0 then x := 1 - x;

    { Calculate cosine(x) with optimal polynomial approximation }
    x := x * x;

    Result := (((0.019940292 - x * 0.00084688153) * x - 0.23369547) * x + 1) * (1-x);

    { Test quadrant to return negative values }
    if (i and 2) = 2 then Result := -Result;
end;


function Sin(x: float16): float16; overload;
(*
@description:
Calculate sine of angle

@param: X - angle in radians (Single)

@returns: Single
*)
begin
    Result := fsincos16(x, false);
end;


function Cos(x: float16): float16; overload;
(*
@description:
Calculate cosine of angle

@param: X - angle in radians (Single)

@returns: Single
*)
begin
    Result := fsincos16(x, true);
end;


function Space(b: Byte): ^string; assembler;
(*
@description:
Return a string of spaces

@param: b - number of spaces

@returns: pointer to string
*)
asm
	ldy #0
	lda #' '
	sta:rne @buf,y+

	mva b @buf

	mwa #@buf Result
end;


function StringOfChar(c: Char; l: byte): ^string; assembler;
(*
@description:
Return a string consisting of 1 character repeated N times.

@param: c - character
@param: l - counter (BYTE)

@returns: pointer to string
*)
asm
	ldy #0
	lda c
	sta:rne @buf,y+

	mva l @buf

	mwa #@buf Result
end;


procedure SetLength(var S: string; Len: byte); register; assembler;
(*
@description:
Set length of a string.

@param: S - string
@param: len - new length (BYTE)
*)
asm
	ldy #0
	mva Len (:edx),y
end;


function BinStr(Value: cardinal; Digits: byte): TString; assembler;
(*
@description:
Convert integer to string with binary representation.

@param: Value - Cardinal
@param: Digits - Byte

@returns: string[32]
*)
asm
	txa:pha

	ldy Digits
	cpy #32
	scc
	ldy #32

	sty @buf

_tob1	lda #0
	lsr Value+3
	ror Value+2
	ror Value+1
	ror Value
	adc #'0'
	sta @buf,y
	dey
	bne _tob1

;	@move #@buf Result #33
	ldy #256-33
	mva:rne @buf+33-256,y adr.Result+33-256,y+

	pla:tax
end;


function OctStr(Value: cardinal; Digits: byte): TString; assembler;
(*
@description:
Convert integer to a string with octal representation.

@param: Value - Cardinal
@param: Digits - Byte

@returns: string[32]
*)
asm
	txa:pha

	ldy Digits
	cpy #32
	scc
	ldy #32

	sty @buf

_toct1	ldx #3
	lda #0
_toct2	lsr Value+3
	ror Value+2
	ror Value+1
	ror Value
	ror @
	dex
	bne _toct2

	:5 lsr @

	ora #'0'
	sta @buf,y

	dey
	bne _toct1

;	@move #@buf Result #33
	ldy #256-33
	mva:rne @buf+33-256,y adr.Result+33-256,y+

	pla:tax
end;


{$i '../src/targets/system.inc'}


procedure Delete(var s: string; index, count: byte);
(*
@description:
Delete removes Count characters from string S, starting at position Index.

@param: s
        index
	count
*)
var l: byte;
    ch: char;
begin

 l:=length(s);

 if index > l then exit;

 if index + count > l then count := l - index + 1;


 while index <= l do begin

  s[index] := s[index + count];

  inc(index);
 end;


 if count > l then
  ch := #0
 else
  ch := chr(l - count);

 s[0] := ch;

end;


function Pos(c: char; s: string): byte; overload;
(*
@description:
Pos returns the index of Substr in S, if S contains Substr. In case Substr isn't found, 0 is returned. The search is case-sensitive.

@param: c - char (Substr)
        s - string
*)
var
    slen: byte;
    i    : byte;
begin
    slen := Length(s);
    result := 0;

    for i := 1 to slen do
    begin
        if s[i] = c then
        begin
            result := i;
            break;
        end;
    end
end;


function Pos(s1: string; s2: string): byte; overload;
(*
@description:
Pos returns the index of Substr in S, if S contains Substr. In case Substr isn't found, 0 is returned. The search is case-sensitive.

@param: s1 - string (Substr)
        s2 - string
*)
var
    s1len: byte;
    s2len: byte;
    i    : byte;
    j    : byte;
begin
    s1len := Length(s1);
    s2len := Length(s2);

    result := 0;

    for i := 1 to s2len - s1len do // 1 to 14
    begin

        for j := 0 to s1len - 1 do // 0 to 17
        begin
            if s2[i+j] <> s1[j+1] then // 1 <> 1
            begin
                break;
            end;
        end;

        if j = s1len then
        begin
            result := i;
            break;
        end;

    end
end;


function Concat(a,b: PString): string; assembler; overload;
(*
@description:
Append one string to another.

@param: a - first string
@param: b - second string

@returns: string (a+b)
*)
asm
	cpw a #@buf
	beq skp

	mva #0 @buf
	@addString a
skp
	@addString b

	ldy #0
	mva:rne @buf,y adr.Result,y+
end;


function Concat(a: PString; b: char): string; assembler; overload;
(*
@description:

*)
asm
	cpw a #@buf
	beq skp

	mva #0 @buf
	@addString a
skp
	inc @buf
	ldy @buf
	lda b
	sta @buf,y

	ldy #0
	mva:rne @buf,y adr.Result,y+
end;


function Concat(a: char; b: PString): string; assembler; overload;
(*
@description:

*)
asm
	mva #1 @buf
	lda a
	sta @buf+1
	@addString b

	ldy #0
	mva:rne @buf,y adr.Result,y+
end;


function Concat(a,b: char): string; overload;
(*
@description:

*)
begin
 Result[0]:=chr(2);
 Result[1]:=a;
 Result[2]:=b;
end;


function Copy(var S: String; Index: Byte; Count: Byte): string; assembler;
(*
@description:

*)
asm
	txa:pha

	mwa S :bp2
	ldy #0

	lda Index
	sne
	lda #1
	cmp (:bp2),y
	seq
	bcs stop

	sta Index
	add Count
	sta ln
	lda #$00
	adc #$00

	cmp #$00
	bne @+
	lda #0
ln	equ *-1
	cmp (:bp2),y
@	beq ok
	bcc ok

	lda (:bp2),y
	sub Index
	add #1
	sta Count

ok	lda Count
	sta adr.Result
	beq stop

	ldx #0
	ldy Index
lp	lda (:bp2),y
	sta adr.Result+1,x
	iny
	inx
	cpx Count
	bne lp

stop	pla:tax
end;


function Swap(a: word): word; overload;
(*
@description:
Swap high and low bytes of a variable

@param: a - word

@returns: word
*)
begin

 Result := a shr 8 + a shl 8;

end;


function Swap(a: cardinal): cardinal; overload;
(*
@description:
Swap high and low words of a variable

@param: a - cardinal

@returns: cardinal
*)
begin

 Result := a shr 16 + a shl 16;

end;


procedure GetMem(var p; size: word); assembler; register; overload;
(*
@description:
Getmem reserves Size bytes memory, and returns a pointer to this memory in p.

@param: p - pointer
@param: size
*)
asm
	ldy #$00
	lda :psptr
	sta (P),y
	iny
	lda :psptr+1
	sta (P),y

	adw :psptr size
end;


function GetMem(size: word): pointer; assembler; register; overload;
(*
@description:
Getmem reserves Size bytes memory, and returns a pointer to this memory in Result.

@param: size
*)
asm
	lda :psptr
	sta Result
	lda :psptr+1
	sta Result+1

	adw :psptr size
end;


procedure FreeMem(var p; size: word); assembler; register;
(*
@description:
Freemem releases the memory occupied by the pointer P

@param: p - pointer
@param: size
*)
asm
	cpw psptr #:PROGRAMSTACK
	beq skp
	bcc skp

	ldy #$00
	tya
	sta (P),y
	iny
	sta (P),y

	sbw :psptr size
skp
end;


function CompareByte(P1,P2: PByte; Len: word): smallint; register; overload;
(*
@description:
Compare 2 memory buffers byte per byte

@param: P1, P2 - pointer
@param: Len - length
*)
begin

 Result:=0;

 if P1 <> P2 then begin

  inc(Len, word(P1));

  while P1 < pointer(Len) do begin

   Result:=(P1[0] - P2[0]);

   if Result <> 0 then Break;

   inc(P1);
   inc(P2);

 end;

 end;

end;


function CompareByte(P1,P2: PByte; Len: byte): smallint; register; overload;
(*
@description:
Compare 2 memory buffers byte per byte

@param: P1, P2 - pointer
@param: Len - length
*)
begin

 Result:=0;

 if P1 <> P2 then begin

  dec(Len);

  while Len <> $ff do begin

   Result:=(P1[Len] - P2[Len]);

   if Result <> 0 then Break;

   dec(Len);

 end;

 end;

end;


function NtoBE(AValue: word): word; overload;
(*
@description:
Convert Native-ordered integer to a Big Endian-ordered integer

<https://www.freepascal.org/docs-html/rtl/system/ntobe.html>

@param: AValue - Word
@result: Word
*)
begin

 Result := (AValue shl 8) or (AValue shr 8);

end;


function NtoBE(AValue: cardinal): cardinal; overload;
(*
@description:
Convert Native-ordered integer to a Big Endian-ordered integer

@param: AValue - Cardinal
@result: Cardinal
*)
begin

 Result := ((AValue and $FF) shl 24) or ((AValue and $FF00) shl 8) or ((AValue and $FF0000) shr 8) or ((AValue and $FF000000) shr 24);

end;


function RorByte(Const AValue : Byte): Byte; overload;
begin
  Result:=(AValue shr 1) or (AValue shl 7);
end;


function RorByte(Const AValue : Byte;const Dist : Byte): Byte; overload;
begin
  Result:=(AValue shr (Dist and 7)) or (AValue shl (8-(Dist and 7)));
end;


function RolByte(Const AValue : Byte): Byte; overload;
begin
  Result:=(AValue shl 1) or (AValue shr 7);
end;


function RolByte(Const AValue : Byte;const Dist : Byte): Byte; overload;
begin
  Result:=(AValue shl (Dist and 7)) or (AValue shr (8-(Dist and 7)));
end;


function RorWord(Const AValue : Word): Word; overload;
begin
  Result:=(AValue shr 1) or (AValue shl 15);
end;


function RorWord(Const AValue : Word;const Dist : Byte): Word; overload;
begin
  Result:=(AValue shr (Dist and 15)) or (AValue shl (16-(Dist and 15)));
end;


function RolWord(Const AValue : Word): Word; overload;
begin
  Result:=(AValue shl 1) or (AValue shr 15);
end;


function RolWord(Const AValue : Word;const Dist : Byte): Word; overload;
begin
  Result:=(AValue shl (Dist and 15)) or (AValue shr (16-(Dist and 15)));
end;


function RorDWord(const AValue: DWord): DWord; overload;
begin
  Result:=(AValue shr 1) or (AValue shl 31);
end;


function RorDWord(const AValue: DWord; const Dist: Byte): DWord; overload;
begin
  Result:=(AValue shr (Dist and 31)) or (AValue shl (32-(Dist and 31)));
end;


function RolDWord(Const AValue : DWord): DWord; overload;
begin
  Result:=(AValue shl 1) or (AValue shr 31);
end;


function RolDWord(Const AValue : DWord;const Dist : Byte): DWord; overload;
begin
  Result:=(AValue shl (Dist and 31)) or (AValue shr (32-(Dist and 31)));
end;


function SarShortint(Const AValue : Shortint;const Shift : Byte): Shortint;
begin
  Result:=shortint(byte(byte(byte(AValue) shr (Shift and 7)) or (byte(shortint(byte(0-byte(byte(AValue) shr 7)) and byte(shortint(0-(ord((Shift and 7)<>0){ and 1}))))) shl (8-(Shift and 7)))));
end;


function SarSmallint(Const AValue : Smallint;const Shift : Byte): Smallint;
begin
  Result:=smallint(word(word(word(AValue) shr (Shift and 15)) or (word(smallint(word(0-word(word(AValue) shr 15)) and word(smallint(0-(ord((Shift and 15)<>0){ and 1}))))) shl (16-(Shift and 15)))));
end;


function SarLongint(Const AValue : Longint;const Shift : Byte): Longint;
begin
  Result:=longint(dword(dword(dword(AValue) shr (Shift and 31)) or (dword(longint(dword(0-dword(dword(AValue) shr 31)) and dword(longint(0-(ord((Shift and 31)<>0){ and 1}))))) shl (32-(Shift and 31)))));
end;

end.
