unit system;

{

http://www.freepascal.org/docs-html/rtl/system/index-5.html

Abs
ArcTan
BinStr
Concat
Cos		; real, single
DPeek		; optimization build in compiler
DPoke		; optimization build in compiler
Eof
Exp
FilePos
FileSize
FillByte	; optimization build in compiler
FillChar	; optimization build in compiler
iSqrt		; fast inverse square root
HexStr
Ln
LowerCase
Move		; optimization build in compiler
OctStr
ParamCount
ParamStr
Pause
Peek		; optimization build in compiler
Poke		; optimization build in compiler
Random
ReadConfig
ReadSector
RunError
Seek
SetLength
Sin		; real, single
Space
Str
StringOfChar
Sqr
Sqrt
UpCase
Val
WriteSector

}

interface

type
	TString = string[32];
	TSize = record cx, cy: smallint end;
	TRect = record	left, top, right, bottom: smallint end;
	TPoint = record x,y: SmallInt end;

var	ScreenWidth: word = 40;
	ScreenHeight: word = 24;

	IOResult, ScreenMode: byte;

const
	M_PI_2	= pi*2;
	D_PI_2	= pi/2;
	D_PI_180= pi/180;

	mGTIA = 0;
	mVBXE = $80;
	WINDOW  = $10;			// text window
	NARROW  = $20;			// narrow screen

	VBXE_XDLADR = $0000;		// XDLIST
	VBXE_BCBADR = $0100;		// BLITTER LIST ADDRESS
	VBXE_MAPADR = $1000;		// COLOR MAP ADDRESS
	VBXE_OVRADR = $5000;		// OVERLAY ADDRESS
	VBXE_WINDOW = $B000;		// 4K WINDOW $B000..$BFFF

	iDLI = 0;			// set new DLI vector
	iVBL = 1;			// set new VBL vector

(* Character codes *)

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

(* color defines *)

	COLOR_BLACK		= $00;
	COLOR_WHITE		= $0e;
	COLOR_RED		= $32;
	COLOR_CYAN		= $96;
	COLOR_VIOLET		= $68;
	COLOR_GREEN		= $c4;
	COLOR_BLUE		= $74;
	COLOR_YELLOW		= $ee;
	COLOR_ORANGE		= $4a;
	COLOR_BROWN		= $e4;
	COLOR_LIGHTRED		= $3c;
	COLOR_GRAY1		= $04;
	COLOR_GRAY2		= $06;
	COLOR_GRAY3		= $0a;
	COLOR_LIGHTGREEN	= $cc;
	COLOR_LIGHTBLUE         = $7c;



	function Abs(x: Real): Real; register; assembler; overload;
	function Abs(x: Single): Single; register; assembler; overload;
	function Abs(x: Integer): Integer; register; assembler; overload;
	function ArcTan(value: real): real;
	function BinStr(Value: cardinal; Digits: byte): TString; assembler;
	function Concat(a,b: string): string; assembler; overload;
	function Concat(a: string; b: char): string; assembler; overload;
	function Concat(a: char; b: string): string; assembler; overload;
	function Concat(a,b: char): string; overload;
	function Cos(x: Real): Real; overload;
	function Cos(x: Single): Single; overload;
	function DPeek(a: word): word; register; assembler;
	procedure DPoke(a: word; value: word); register; assembler;
	function Eof(var f: file): Boolean;
	function Exp(x: Real): Real; overload;
	function Exp(x: Float): Float; overload;
	function FilePos(var f: file): cardinal; assembler;
	function FileSize(var f: file): cardinal; assembler;
	procedure FillByte(a: pointer; count: word; value: byte); assembler; register; overload;
	procedure FillByte(var x; count: word; value: byte); assembler; register; overload;
	procedure FillChar(a: pointer; count: word; value: char); assembler; register; overload;
	procedure FillChar(a: pointer; count: word; value: byte); assembler; register; overload;
	procedure FillChar(a: pointer; count: word; value: Boolean); assembler; register; overload;
	procedure FillChar(var x; count: word; value: char); assembler; register; overload;
	procedure FillChar(var x; count: word; value: byte); assembler; register; overload;
	procedure FillChar(var x; count: word; value: Boolean); assembler; register; overload;
	function FloatToStr(a: real): ^string; assembler;
	function HexStr(Value: cardinal; Digits: byte): TString; register; assembler;
	function iSqrt(number: Single): Single;
	function Ln(x: Real): Real; overload;
	function Ln(x: Float): Float; overload;
 	function LowerCase(a: char): char;
	procedure Move(source, dest: pointer; count: word); assembler; register; overload;
	procedure Move(var source, dest; count: word); assembler; register; overload;
	procedure Move(var source; dest: pointer; count: word); assembler; register; overload;
	function OctStr(Value: cardinal; Digits: byte): TString; assembler;
	function ParamCount: byte; assembler;
	function ParamStr(i: byte): TString; assembler;
	procedure Pause; assembler; overload;
	procedure Pause(n: word); assembler; overload;
	function Peek(a: word): byte; register; assembler;
	procedure Poke(a: word; value: byte); register; assembler;
	function Random: Real; overload;
	function Random(range: byte): byte; assembler; overload;
	function Random(range: smallint): smallint; overload;
	function RandomF: Float;
	procedure Randomize; assembler;
	function ReadConfig (devnum: byte): cardinal; assembler;
	procedure ReadSector (devnum: byte; sector: word; var buf); assembler;
	procedure RunError(a: byte);
	procedure Seek(var f: file; a: cardinal); assembler;
	procedure SetLength(var S: string; Len: byte); register; assembler;
	function Sin(x: Real): Real; overload;
	function Sin(x: Single): Single; overload;
	function Space(b: Byte): ^string; assembler;
	procedure Str(a: integer; var s: TString); assembler;
	function StringOfChar(c: Char; l: byte): ^string; assembler;
	function Sqr(x: Real): Real; overload;
	function Sqr(x: Single): Single; overload;
	function Sqr(x: integer): integer; overload;
	function Sqrt(x: Real): Real; overload;
	function Sqrt(x: Single): Single; overload;
	function Sqrt(x: Integer): Integer; overload;
	function UpCase(a: char): char;
	procedure Val(const s: TString; var v: integer; var code: byte); assembler; overload;
	procedure Val(const s: TString; var v: single; var code: byte); overload;
	procedure WriteSector(devnum: byte; sector: word; var buf); assembler;
	function Swap(a: word): word; overload;
	function Swap(a: cardinal): cardinal; overload;


implementation

var
	RndSeed: smallint;


function ReadConfig(devnum: byte): cardinal; assembler;
{
DVSTAT
Byte 0 ($02ea):
Bit 0:Indicates the last command frame had an error.
Bit 1:Checksum, indicates that there was a checksum error in the last command or data frame
Bit 2:Indicates that the last operation by the drive was in error.
Bit 3:Indicates a write protected diskette. 1=Write protect
Bit 4:Indicates the drive motor is on. 1=motor on
Bit 5:A one indicates MFM format (double density)
Bit 6:Not used
Bit 7:Indicates Density and a Half if 1

Byte 1 ($02eb):
Bit 0:FDC Busy should always be a 1
Bit 1:FDC Data Request should always be 1
Bit 2:FDC Lost data should always be 1
Bit 3:FDC CRC error, a 0 indicates the last sector read had a CRC error
Bit 4:FDC Record not found, a 0 indicates last sector not found
Bit 5:FDC record type, a 0 indicates deleted data mark
Bit 6:FDC write protect, indicates write protected disk
Bit 7:FDC door is open, 0 indicates door is open

Byte 2 ($2ec):
Timeout value for doing a format.

Byte 3 ($2ed):
not used, should be zero
}
asm
{	txa:pha

	lda devnum
	jsr @sio.devnrm
	bmi _err

	lda #'S'	; odczyt statusu stacji
	sta dcmnd

	jsr jdskint	; $e453
	bmi _err

	ldx <256	; 256 bajtow
	ldy >256	; w sektorze

	lda dvstat
	and #%00100000
	bne _skp

	ldx <128	;128 bajtow
	ldy >128	;w sektorze

_skp	jsr @sio.devsec

	mva dvstat result
	mva dvstat+1 result+1
	mva dvstat+2 result+2
	mva dvstat+3 result+3

	ldy #0

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure ReadSector(devnum: byte; sector: word; var buf); assembler;
asm
{	txa:pha

	lda devnum
	jsr @sio.devnrm
	bmi _err

	lda sector
	sta daux1
	lda sector+1
	sta daux2

	ldx buf
	ldy buf+1
	lda #'R'

	jsr @sio

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure WriteSector(devnum: byte; sector: word; var buf); assembler;
asm
{	txa:pha

	lda devnum
	jsr @sio.devnrm
	bmi _err

	lda sector
	sta daux1
	lda sector+1
	sta daux2

	ldx buf
	ldy buf+1
	lda #'P'

	jsr @sio

_err	sty MAIN.SYSTEM.IOResult

	pla:tax
};
end;


procedure RunError(a: byte);
begin
	writeln('Runtime error ', a);
	halt;
end;


function HexStr(Value: cardinal; Digits: byte): TString; register; assembler;
asm
{	txa:pha

	jsr @hexStr

	@move #@buf Result #33

	pla:tax
};
end;


function Peek(a: word): byte; register; assembler;
asm
{	ldy #0
	mva (edx),y Result
};
end;


function DPeek(a: word): word; register; assembler;
asm
{	ldy #0
	mva (edx),y Result
	iny
	mva (edx),y Result+1
};
end;


procedure Randomize; assembler;
asm
{	mva $d20a RndSeed
	mva #$00  RndSeed+1
};
end;


function Random: Real; overload;
begin

asm
{
 lda $d20a
 sta Result

 lda #$00
 sta Result+1
 sta Result+2
 sta Result+3
};

 Result:= 1 - Result;

(*
asm
{	txa:pha

_t	= edx

	LDA #$0

	sta result+1
	sta result+2
	sta result+3

	STA _T
RAN1	INC _T
	JSR POLY
	CMP #$0
	BEQ RAN1
	ORA #$10
	ldy #0
;

RAN2	INY
	JSR POLY
	ROL @
	ROL @
	ROL @
	ROL @
	AND #$F0
	STA _T+1
	JSR POLY
	ORA _T+1
	STA result-1,y
;	CPY #4
;	BCC RAN2
;	LDA _T
;	INY
;	STA result,y

	pla:tax

	jmp stop

POLY	TYA
	PHA
	LDY #$0
POLY1	INY
	CLC
	ROL POLYN
	ROL POLYN+1
	ROL POLYN+2
	ROL POLYN+3
	ROL POLYN+4
	ROL POLYN+5
	ROL POLYN+6
	ROL POLYN+7
	BCC POLY3
;
	LDX #$0
POLY2	LDA POLYN,X
	EOR GEN,X
	STA POLYN,X
	INX
	CPX #8
	BCC POLY2
	SEC
;
POLY3	ROL _T+2
	CPY #4
	BCC POLY1
;
	PLA
	TAY
	LDA _T+2
	AND #$0F
	CMP #$0A
	BCS POLY
	RTS
;
;
GEN	dta a($A1)
	dta $A2,$1A,$A2,$91,$C3,$93,$C0
;
POLYN	dta a($63)
	dta $42,$A1,$23,$55,$09,$03,$87

stop
};
*)

end;


function RandomF: Float;
begin

asm
{
 lda $d20a
 and #$7f
 sta Result+2
 mva $d20a Result+1

 lda #$00
 sta Result
 lda #$3f
 sta Result+3
};

 Result:= 1 - Result;

end;


function Random(range: byte): byte; assembler; overload;
asm
{
;BYTE FUNC Rand(BYTE range)
; returns random number between 0 and
; range-1.  If range=0, then a random
; number between 0 and 255 is returned

	ldy	$d20a		; RANDOM

	lda	range
	beq	stop

	sta	ecx
	sty	eax

	jsr	imulCL
	tay

stop	sty	Result
};
end;


function Random(range: smallint): smallint; overload;
begin

 if range = 0 then
	Result := 0
 else begin

	RndSeed := $4595 * RndSeed;
	Result := RndSeed mod range;

asm
{	lda range+1
	bpl plus

	lda Result+1
	bmi ok
	bpl sign

plus	lda Result+1
	bpl ok

sign	lda #0
	sub Result
	sta Result

	lda #0
	sbc Result+1
	sta Result+1
ok
};

  end;

end;


(*
function IntToReal(x: integer): Real; register; assembler;
//----------------------------------------------------------------------------------------------
// Convert an integer value to a real value
//----------------------------------------------------------------------------------------------
asm
{	mva edx+2 result+3
	mva edx+1 result+2
	mva edx result+1
	mva #0 result
};
end;
*)


function Abs(x: Real): Real; register; assembler; overload;
//----------------------------------------------------------------------------------------------
// Abs returns the absolute value of a variable.
// The result of the function has the same type as its argument, which can be any numerical type.
//----------------------------------------------------------------------------------------------
asm
{	lda edx+3
	spl
	jsr negEDX

	mva edx Result
	mva edx+1 Result+1
	mva edx+2 Result+2
	mva edx+3 Result+3
};
end;


function Abs(x: Single): Single; register; assembler; overload;
//----------------------------------------------------------------------------------------------
// Abs returns the absolute value of a variable.
// The result of the function has the same type as its argument, which can be any numerical type.
//----------------------------------------------------------------------------------------------
asm
{	lda edx+3
	and #$7f
	sta Result+3

	mva edx Result
	mva edx+1 Result+1
	mva edx+2 Result+2
};
end;


function Abs(x: Integer): Integer; register; assembler; overload;
//----------------------------------------------------------------------------------------------
// Abs returns the absolute value of a variable.
// The result of the function has the same type as its argument, which can be any numerical type.
//----------------------------------------------------------------------------------------------
asm
{	lda edx+3
	spl
	jsr negEDX

	mva edx Result
	mva edx+1 Result+1
	mva edx+2 Result+2
	mva edx+3 Result+3
};
end;


function Sqr(x: Real): Real; overload;
//----------------------------------------------------------------------------------------------
// Sqr returns the square of its argument X
//----------------------------------------------------------------------------------------------
begin

 Result := x*x;

end;


function Sqr(x: Single): Single; overload;
//----------------------------------------------------------------------------------------------
// Sqr returns the square of its argument X
//----------------------------------------------------------------------------------------------
begin

 Result := x*x;

end;


function Sqr(x: integer): integer; overload;
//----------------------------------------------------------------------------------------------
// Sqr returns the square of its argument X
//----------------------------------------------------------------------------------------------
begin

 Result := x*x;

end;


function Sqrt(x: Real): Real; overload;
//----------------------------------------------------------------------------------------------
// Sqrt returns the square root of its argument X, which must be positive
//----------------------------------------------------------------------------------------------
var Divisor: Real;
begin
{ Hero's algorithm }

if x < 0.0 then exit;

Result  := x;
Divisor := 1.0;

while Abs(Result - Divisor) > 0.01 do
  begin
  Divisor := (Result + Divisor) * 0.5;
  Result := x / Divisor;
  end;
end;


function Sqrt(x: Single): Single; overload;
//----------------------------------------------------------------------------------------------
// Sqrt returns the square root of its argument X, which must be positive
//----------------------------------------------------------------------------------------------
var sp: ^single;
    c: cardinal;
begin

	sp:=@c;

	c := cardinal(x) - $3f800000;
	c := c shr 1;
	c := c + $3f800000;

	Result := sp^;

	Result:=(Result+x/Result) * 0.5;
	Result:=(Result+x/Result) * 0.5;
end;

(*
function Sqrt(x: Single): Single; overload;
//----------------------------------------------------------------------------------------------
// Sqrt returns the square root of its argument X, which must be positive
//----------------------------------------------------------------------------------------------
var Divisor: Single;
begin
{ Hero's algorithm }

if x < single(0) then exit;

Result  := x;
Divisor := 1;

while Abs(Result - Divisor) > single(0.0001) do
  begin
  Divisor := (Result + Divisor) * 0.5;
  Result := x / Divisor;
  end;
end;
*)


function Sqrt(x: Integer): Integer; overload;
//----------------------------------------------------------------------------------------------
// Sqrt returns the square root of its argument X, which must be positive.
//----------------------------------------------------------------------------------------------
var
  Divisor: Integer;
begin
{ Hero's algorithm }

if x < 0 then exit;

Result  := x;
Divisor := 1;

while Abs(Result - Divisor) > 1 do
  begin
  Divisor := (Result + Divisor) shr 1;
  Result := x div Divisor;
  end;
end;


function iSqrt(number: Single): Single;
//----------------------------------------------------------------------------------------------
// https://en.wikipedia.org/wiki/Fast_inverse_square_root
// https://pl.wikipedia.org/wiki/Szybka_odwrotno%C5%9B%C4%87_pierwiastka_kwadratowego
//----------------------------------------------------------------------------------------------
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


function ArcTan(value: real): real;
//----------------------------------------------------------------------------------------------
// Arctan returns the Arctangent of X, which can be any Real type.
// The resulting angle is in radial units.
//----------------------------------------------------------------------------------------------
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


function Exp(x: Real): Real; overload;
//----------------------------------------------------------------------------------------------
// Exp returns the exponent of X, i.e. the number e to the power X.
// https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent
//----------------------------------------------------------------------------------------------
var P, Fraction, I, L: Real;
begin
    Fraction := x;
    P := x + 1;
    I := 1;

    while L<>P do begin
        I := I + 1;
        Fraction :=Fraction * (x / I);
        L := P;
        P := P + Fraction;
    end;

    Result := P;
end;


function Exp(x: Float): Float; overload;
//----------------------------------------------------------------------------------------------
// Exp returns the exponent of X, i.e. the number e to the power X.
// https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent
//----------------------------------------------------------------------------------------------
var P, Fraction, I, L: Float;
begin
    Fraction := x;
    P := x + 1;
    I := 1;

    while L<>P do begin
        I := I + 1;
        Fraction :=Fraction * (x / I);
        L := P;
        P := P + Fraction;
    end;

    Result := P;
end;


function Ln(x: Real): Real; overload;
//----------------------------------------------------------------------------------------------
// Ln returns the natural logarithm of the Real parameter X. X must be positive.
// https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent
//----------------------------------------------------------------------------------------------
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
//----------------------------------------------------------------------------------------------
// Ln returns the natural logarithm of the Real parameter X. X must be positive.
// https://www.codeproject.com/Tips/311714/Natural-Logarithms-and-Exponent
//----------------------------------------------------------------------------------------------
var N, P, K, L, R, A, E: Float;
begin
		E := 2.71828182845905;
		P := x;
		N := 0;

	if x>Float(0) then begin

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
asm
{	txa:pha

	mwa f bp2

	ldy #s@file.chanel
	lda (bp2),y
	tax
	lda #39
	sta iccmd,x
	jsr ciov

	sty IOResult

	mva icax3,x result
	mva icax4,x result+1
	mva icax5,x result+2
	mva #$00 result+3

	pla:tax
};
end;


function FilePos(var f: file): cardinal; assembler;
asm
{	txa:pha

	mwa f bp2

	ldy #s@file.chanel
	lda (bp2),y
	tax
	lda #38
	sta iccmd,x
	jsr ciov

	sty IOResult

	mva icax3,x result
	mva icax4,x result+1
	mva icax5,x result+2
	mva #$00 result+3

	pla:tax
};
end;


procedure Seek(var f: file; a: cardinal); assembler;
asm
{	txa:pha

	mwa f bp2

	ldy #s@file.chanel
	lda (bp2),y
	tax
	lda #37
	sta iccmd,x

	mva a icax3,x
	mva a+1 icax4,x
	mva a+2 icax5,x

	jsr ciov

	sty IOResult

	pla:tax
};
end;


function Eof(var f: file): Boolean;
var i: cardinal;
    tmp: byte;
begin
	i:=FilePos(f);
asm
{	mwa f bp2

	ldy #s@file.record
	lda (bp2),y
	pha
	lda #1
	sta (bp2),y
	iny
	lda (bp2),y
	pha
	lda #0
	sta (bp2),y

};
	blockread(f, tmp, 1);

	Seek(f, i);
asm
{	ldy #s@file.record
	iny
	pla
	sta (bp2),y
	dey
	pla
	sta (bp2),y

	ldy #s@file.status
	lda (bp2),y
	and #e@file.eof
	sta Result
};
end;


function LowerCase(a: char): char;
//----------------------------------------------------------------------------------------------
// Converts a character to lowercase
//----------------------------------------------------------------------------------------------
begin

 case a of
  'A'..'Z': Result := chr(byte(a) + 32)
 else
  Result := a
 end;

end;


function UpCase(a: char): char;
//----------------------------------------------------------------------------------------------
// Converts a character to uppercase
//----------------------------------------------------------------------------------------------
begin

 case a of
  'a'..'z': Result := chr(byte(a) - 32)
 else
  Result := a
 end;

end;


procedure Val(const s: TString; var v: integer; var code: byte); assembler; overload;
//----------------------------------------------------------------------------------------------
// Calculate numerical value of a string
//----------------------------------------------------------------------------------------------
asm
{	@StrToInt #adr.s

	tya
	pha

	mwa code bp2
	ldy #0

	pla
	sta (bp2),y

	mwa v bp2

	mva edx (bp2),y+
	mva edx+1 (bp2),y+
	mva edx+2 (bp2),y+
	mva edx+3 (bp2),y
};
end;


procedure Val(const s: TString; var v: single; var code: byte); overload;
//----------------------------------------------------------------------------------------------
// Calculate numerical value of a string
//----------------------------------------------------------------------------------------------
var n, dotpos, len: byte;
    f: single;
begin

 f:=0;

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
		f := f * 10 +  single(ord(s[n])-ord('0'));

	inc(n);
	end;

	while dotpos <> 0 do begin
		f := f * 0.1;			// '* 0.1' is faster than '/ 10'
		dec(dotpos);
	end;

	if (s[1]='-') then			// If s[] is "negative"
		f :=  -f;

 end;

 v := f;

end;


function FloatToStr(a: real): ^string; assembler;
//----------------------------------------------------------------------------------------------
// Convert a float value to a string
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

	inx

	@ValueToStr #@printREAL

	mwa #@buf Result

	pla:tax
};
end;


procedure Str(a: integer; var s: TString); assembler;
//----------------------------------------------------------------------------------------------
// Convert a numerical value to a string
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

	inx

	@ValueToStr #@printINT

	@move #@buf s #16	; !!! koniecznie przez wskaznik

	pla:tax
};
end;


procedure Poke(a: word; value: byte); register; assembler;
asm
{	ldy #0
	mva value (edx),y
};
end;


procedure DPoke(a: word; value: word); register; assembler;
asm
{	ldy #0
	mva value (edx),y
	iny
	mva value+1 (edx),y
};
end;


procedure FillChar(a: pointer; count: word; value: char); assembler; register; overload;
//----------------------------------------------------------------------------------------------
// Fills the memory starting at A with Count Characters with value equal to Value
//----------------------------------------------------------------------------------------------
asm
{	jsr @fill
};
end;

procedure FillChar(a: pointer; count: word; value: byte); assembler; register; overload;
//----------------------------------------------------------------------------------------------
// Fills the memory starting at A with Count Bytes with value equal to Value
//----------------------------------------------------------------------------------------------
asm
{	jsr @fill
};
end;

procedure FillChar(a: pointer; count: word; value: Boolean); assembler; register; overload;
//----------------------------------------------------------------------------------------------
// Fills the memory starting at A with Count Boolean with value equal to Value
//----------------------------------------------------------------------------------------------
asm
{	jsr @fill
};
end;

procedure FillChar(var x; count: word; value: char); assembler; register; overload;
asm
{	jsr @fill
};
end;

procedure FillChar(var x; count: word; value: byte); assembler; register; overload;
asm
{	jsr @fill
};
end;

procedure FillChar(var x; count: word; value: Boolean); assembler; register; overload;
asm
{	jsr @fill
};
end;


procedure FillByte(a: pointer; count: word; value: byte); assembler; register; overload;
//----------------------------------------------------------------------------------------------
// Fills the memory starting at A with Count Bytes with value equal to Value
//----------------------------------------------------------------------------------------------
asm
{	jsr @fill
};
end;

procedure FillByte(var x; count: word; value: byte); assembler; register; overload;
asm
{	jsr @fill
};
end;


procedure Move(source, dest: pointer; count: word); assembler; register; overload;
//----------------------------------------------------------------------------------------------
// Moves Count bytes from Source to Dest
//----------------------------------------------------------------------------------------------
asm
{	jsr @move
};
end;

procedure Move(var source, dest; count: word); assembler; register; overload;
asm
{	jsr @move
};
end;

procedure Move(var source; dest: pointer; count: word); assembler; register; overload;
asm
{	jsr @move
};
end;


function Sin(x: Real): Real; overload;
var
  r, x2: Real;
  a: byte;
begin

 while x > M_PI_2 do x := x - M_PI_2;
 while x < 0.0    do x := x + M_PI_2;

 Result := 0;
 r := x;
 x2 := x * x;

 a:=2;

 while a<19 do begin			// !!! 19 !!! aby COS byl precyzyjnie wyliczony
  Result := Result + r;
  r := (-r) * x2 / real((a + 1) * a);

  inc(a, 2);
 end;

end;


function Cos(x: Real): Real; overload;
begin
 Result := Sin(x + D_PI_2);
end;


(*
function Sin(x: single): single; overload;
var
  r, x2: single;
  a: byte;
begin

while x > single(M_PI_2) do x := x - M_PI_2;
while x < single(0) do x := x + M_PI_2;

Result := 0;
r := x;
x2 := x * x;

 a:=2;

 while a<27 do begin			// !!! 27 !!! aby COS byl precyzyjnie wyliczony
  Result := Result + r;
  r := (-r) * x2 / single((a + 1) * a);
  inc(a, 2);
 end;

end;


function Cos(x: Single): Single; overload;
begin
 x:=x + D_PI_2;
 Result := Sin(x);
end;
*)


function fsincos(x: single; sc: boolean): single;
//----------------------------------------------------------------------------------------------
// http://atariage.com/forums/topic/240919-mad-pascal/page-10#entry3818764
//----------------------------------------------------------------------------------------------
var i: byte;
begin

    while x > single(M_PI_2) do x := x - M_PI_2;
    while x < single(0) do x := x + M_PI_2;

    { Normalize argument, divide by (pi/2) }
    x := x * 0.63661977236758134308;

    { Get's integer part, should be }
    i := trunc(x);

    { Fixes negative part, needed to calculate "fractional" part }
    if cardinal(x) >= $80000000 then { this is shorter than "x < 0" }
        dec(i);

    { And finally get's fractional part }
    x := x - single(shortint(i));

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


function sin(x: single): single; overload;
begin
    Result := fsincos(x, false);
end;


function cos(x: single): single; overload;
begin
    Result := fsincos(x, true);
end;


function Space(b: Byte): ^string; assembler;
//----------------------------------------------------------------------------------------------
// Return a string of spaces
//----------------------------------------------------------------------------------------------
asm
{	ldy #0
	lda #' '
	sta:rne @buf,y+

	mva b @buf

	mwa #@buf Result
};
end;


function StringOfChar(c: Char; l: byte): ^string; assembler;
asm
{	ldy #0
	lda c
	sta:rne @buf,y+

	mva l @buf

	mwa #@buf Result
};
end;


procedure SetLength(var S: string; Len: byte); register; assembler;
asm
{	ldy #0
	mva Len (edx),y
};
end;


function BinStr(Value: cardinal; Digits: byte): TString; assembler;
asm
{	txa:pha

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

	@move #@buf Result #33

	pla:tax
};
end;


function OctStr(Value: cardinal; Digits: byte): TString; assembler;
asm
{	txa:pha

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

	@move #@buf Result #33

	pla:tax
};
end;


procedure Pause; assembler; overload;
asm
{	lda:cmp:req :rtclok+2
};
end;


procedure Pause(n: word); assembler; overload;
asm
{	lda n
	ora n+1
	beq stop

	mwa n timcnt3

	lda #$FF
	sta timflg3
	lda:rne timflg3
stop
};
end;


function ParamCount: byte; assembler;
asm
{	@cmdline #255
	sta Result
};
end;


function ParamStr(i: byte): TString; assembler;
asm
{	@cmdline i
	@move #@buf Result #33
};
end;


function Concat(a,b: string): string; assembler; overload;
asm
{	mva #0 @buf
	@addString #adr.a
	@addString #adr.b
	@move #@buf #adr.Result #256
};
end;


function Concat(a: string; b: char): string; assembler; overload;
asm
{	mva #0 @buf
	@addString #adr.a
	inc @buf
	ldy @buf
	lda b
	sta @buf,y
	@move #@buf #adr.Result #256
};
end;


function Concat(a: char; b: string): string; assembler; overload;
asm
{	mva #1 @buf
	lda a
	sta @buf+1
	@addString #adr.b
	@move #@buf #adr.Result #256
};
end;


function Concat(a,b: char): string; overload;
begin
 Result[0]:=chr(2);
 Result[1]:=a;
 Result[2]:=b;
end;


function Swap(a: word): word; overload;
begin

 Result := a shr 8 + a shl 8;

end;


function Swap(a: cardinal): cardinal; overload;
begin

 Result := a shr 16 + a shl 16;

end;


end.
