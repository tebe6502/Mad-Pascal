unit dos;

{

http://www.freepascal.org/docs-html/rtl/dos/index-5.html

CurrentMinuteOfDay
CurrentSec100OfDay
CurrentSecondOfDay
DosVersion
GetTime
MinuteOfDay
MinutesToTime
SecondOfDay
SecondsToTime
SetTime

}

interface

	function DosVersion: word; assembler;
	procedure GetTime(var hour, minute, second, sec100: word);
	procedure SetTime(hour, minute, second, sec100: word);
	function CurrentMinuteOfDay: Word;
	function CurrentSecondOfDay: cardinal;
	function CurrentSec100OfDay: Cardinal;
	function MinuteOfDay (Hour24, Minute: Word): Word;
	function SecondOfDay (Hour24, Minute, Second: Word): cardinal;
	procedure MinutesToTime (Md: cardinal; Var Hour24, Minute: Word);
	procedure SecondsToTime (Sd: cardinal; Var Hour24, Minute, Second: Word);


implementation

var
	palntsc: byte absolute $d014;


function DosVersion: word; assembler;
asm
{	txa:pha

; sparta_detect.asm
; (c) idea by KMK, code: mikey
;
; $Id: sparta_detect.asm,v 1.2 2006/09/27 22:59:27 mikey Exp $
; 

p0	= bp2
fsymbol	= $07EB
                   
sparta_detect

; if peek($700) = 'S' and bit($701) sets V then we're SDX

	lda $0700
	cmp #$53	; 'S'
	bne no_sparta
	lda $0701
	cmp #$40
	bcc no_sparta
	cmp #$44
	bcc _oldsdx

; we're running 4.4 - the old method is INVALID as of 4.42

	lda #<sym_t
	ldx #>sym_t
	jsr fsymbol
	sta p0
	stx p0+1
	ldy #$06
	bne _fv

; we're running SDX, find (DOSVEC)-$150 

_oldsdx	lda $a
	sec
	sbc #<$150
	sta p0
	lda $b
	sbc #>$150
	sta p0+1

; ok, hopefully we have established the address. 
; now peek at it. return the value. 

	ldy #0
_fv	lda (p0),y

	jmp _end

sym_t	.byte "T_      "

no_sparta	lda #$ff

_end	sta Result
	mva $f31 Result+1

	pla:tax

; if A=$FF -> No SDX :(
; if A=$FE -> SDX is in OSROM mode
; if A=$00 -> SDX doesn't use any XMS banks
; if A=anything else -> BANKED mode, and A is the bank number 

; 0F31         0          SpartaDOS 2.3e
;              13            DOS 4.0
;              15         SpartaDOS 1.1
;              19         Atari DOS 2.5 
;              76         Atari DOS 3.0
;              78         Atari DOS 3.0
;              89         SpartaDOS 3.2d
;              108          MYDOS 4.0
;              207        OSS OS/A+ 4.00
;              221          MYDOS 4.50
;              238        OSS DOS XL 2.3
;              244         Atari DOS XE

; 070C         0          OSS DOS XL 2.3
;              124        Atari DOS 2.0s
};
end;


procedure GetTime(var hour, minute, second, sec100: word);
//----------------------------------------------------------------------------------------------
// Set system time
//----------------------------------------------------------------------------------------------
var	time: cardinal;
	tmp: word;
	fps: byte;
begin

asm
{	mva #$00 time+3
	mva :rtclok time+2 
	mva :rtclok+1 time+1 
	mva :rtclok+2 time
};

 if palntsc = 1 then
  fps := 50
 else
  fps := 60;
  
 time := time div fps;
 
 tmp := time div 3600;
 hour := tmp mod 24;

 dec(time, tmp*3600);
 
 tmp := time div 60;
 minute := tmp;

 dec(time, tmp*60);

 second := time;
 
end;


procedure SetTime(hour, minute, second, sec100: word);
//----------------------------------------------------------------------------------------------
// Set system time
//----------------------------------------------------------------------------------------------
var	time: cardinal;
	fps: byte;
begin

 time := (hour mod 24) * 3600 + minute * 60 + second;

 if palntsc = 1 then
  fps := 50
 else
  fps := 60;
 
 time := time * fps;

asm
{	mva time+2 :rtclok
	mva time+1 :rtclok+1
	mva time :rtclok+2
};
end;


FUNCTION CurrentMinuteOfDay: Word;
VAR Hour, Minute, Second, Sec100: Word;
BEGIN
   GetTime(Hour, Minute, Second, Sec100);		{ Get current time }
   Result := (Hour * 60) + Minute;			{ Minute from midnight }
END;


FUNCTION CurrentSecondOfDay: cardinal;
VAR Hour, Minute, Second, Sec100: Word;
BEGIN
   GetTime(Hour, Minute, Second, Sec100);		{ Get current time }
   Result := (Hour * 3600) +  (Minute * 60) + Second;	{ Second from midnight }
END;


FUNCTION CurrentSec100OfDay: Cardinal;
VAR Hour, Minute, Second, Sec100: Word;
BEGIN
   GetTime(Hour, Minute, Second, Sec100);		{ Get current time }
   Result := (Hour * 360000) + (Minute * 6000) + (Second*100) + Sec100; { Sec100 from midnight }
END;


FUNCTION MinuteOfDay (Hour24, Minute: Word): Word;
BEGIN
   Result := (Hour24 * 60) + Minute;			{ Minute from midnight }
END;


FUNCTION SecondOfDay (Hour24, Minute, Second: Word): cardinal;
BEGIN
   Result := (Hour24 * 3600) + (Minute * 60) + Second;	{ Second from midnight }
END;


PROCEDURE MinutesToTime (Md: cardinal; Var Hour24, Minute: Word);
BEGIN
   Hour24 := Md DIV 60;					{ Hours of time }
   Minute := Md MOD 60;					{ Minutes of time }
END;


PROCEDURE SecondsToTime (Sd: cardinal; Var Hour24, Minute, Second: Word);
BEGIN
   Hour24 := Sd DIV 3600;				{ Hours of time }
   Minute := Sd MOD 3600 DIV 60;			{ Minutes of time }
   Second := Sd MOD 60;					{ Seconds of time }
END;


end.
