unit x16_sysutils;
(*
@type: unit
@name: Various system utilities
@author: MADRAFi
* based on sysutils
@description:
<http://www.freepascal.org/docs-html/rtl/sysutils/index-5.html>
*)

{

BoolToStr
ByteToStr
Date
DateToStr
DeleteFile
DecodeDate
DecodeDateTime
DecodeTime
EncodeDate
EncodeDateTime
EncodeTime
ExtractFileExt
ExtractFilePath
FileExists
FindClose
FindFirst
FindNext
GetTickCount
IntToHex
IntToStr
IsLeapYear
Now
RenameFile
StrToBool
StrToFloat
StrToInt
TimeToStr
Trim
TrimLeft
TrimRight
CurrentMinuteOfDay
CurrentSecondOfDay
CurrentSec100OfDay
MinuteOfDay
SecondOfDay
MinutesToTime
SecondsToTime

}

interface

type	TSearchRec = record
(*
@description:

*)
		Attr: Byte;
		ExcludeAttr: Byte;
		Name: TString;
		FindHandle: Pointer;
	     end;

const
	faReadOnly	= $01;
	faHidden	= $02;
	faSysFile	= $04;
	faVolumeID	= $08;
	faDirectory	= $10;
	faArchive	= $20;
	faAnyFile	= $3f;


	// function AnsiUpperCase(a: PString): string; register;
	// function AnsiLowerCase(a: PString): string; register;
	function BoolToStr(B: Boolean; UseBoolStrs: Boolean): TString;
	function ByteToStr(a: byte): TString; assembler;
	function Date: TDateTime;
	function DateToStr(d: TDateTime): TString;
	procedure DecodeDate(d: TDateTime; var yy,mm,dd: byte);
	procedure DecodeDateTime(d: TDateTime; var yy,mm,dd,h,m,s,ss: byte);
	procedure DecodeTime(d: TDateTime; var h,m,s: byte);
	// function DeleteFile(var FileName: TString): Boolean; assembler;
	function EncodeDate(Year, Month, Day: Byte): TDateTime;
	function EncodeDateTime(Year, Month, Day, Hour, Minute, Second, SetSecond: Byte): TDateTime;
	function EncodeTime(Hour, Minute, Second: Byte): TDateTime;
	// function ExtractFileExt(a: PString): TString;
	// function ExtractFilePath(a: PString): string;
	// function FileExists(name: PString): Boolean;
	// procedure FindClose(var f: TSearchRec); assembler;
	// function FindFirst (FileMask: PString; Attributes: Byte; var SearchResult: TSearchRec): byte;
	// function FindNext(var f: TSearchRec): byte; assembler;
	function IntToHex(Value: cardinal; Digits: byte): TString; register; assembler;
	function IntToStr(a: integer): TString; assembler; stdcall; overload;
	function IntToStr(a: cardinal): TString; assembler; stdcall; overload;
	function IsLeapYear(Year: Word): boolean;
	function Now: TDateTime; assembler;
	// function RenameFile(var OldName,NewName: TString): Boolean; assembler;
	function StrToBool(S: PString): Boolean;
	function StrToFloat(var s: string): real;
	function StrToInt(const s: char): byte; assembler; overload;
	function StrToInt(s: PString): integer; assembler; overload;
	function TimeToStr(d: TDateTime): TString;
	function Trim(var S: string): string;
	function TrimRight(var S: string): string;
	function TrimLeft(var S: string): string;

	function CurrentMinuteOfDay: Word;
	function CurrentSecondOfDay: cardinal;
	function CurrentSec100OfDay: Cardinal;
	function MinuteOfDay (Hour24, Minute: Byte): Word;
	function SecondOfDay (Hour24, Minute, Second: Byte): cardinal;
	procedure MinutesToTime (Md: cardinal; Var Hour24, Minute: Byte);
	procedure SecondsToTime (Sd: cardinal; Var Hour24, Minute, Second: Byte);

implementation

uses StrUtils;


function FindFirst(FileMask: PString; Attributes: Byte; var SearchResult: TSearchRec): byte;
(*
@description: Start a file search and return a findhandle

@param: FileMask: string[32]
@param: Attributes: Byte
@param: SearchResult: TSearchRec

@returns: =0 file matching the specified criteria is found
*)
var f: file;
begin
	assign(f, FileMask);
 asm
	txa:pha

	clc			; iocheck off
	@openfile f #6
loop
	mwa SearchResult :bp2

	ldy #SearchResult.ExcludeAttr-DATAORIGIN
	lda Attributes
	sta (:bp2),y

	ldy #SearchResult.FindHandle-DATAORIGIN

	lda f
	sta (:bp2),y
	iny
	lda f+1
	sta (:bp2),y

	mwa f :bp2

	ldy #s@file.record
	mva <1 (:bp2),y
	iny
	mva >1 (:bp2),y

	ldy #s@file.nrecord
	mva <64 (:bp2),y
	iny
	mva >64 (:bp2),y

	ldy #s@file.buffer
	mva <@buf (:bp2),y
	iny
	mva >@buf (:bp2),y

	@ReadDirFileName f
	sta Result

	adw SearchResult #SearchResult.Name-DATAORIGIN :bp2

	jsr @DirFileName

	mwa SearchResult :bp2

	ldy #SearchResult.Attr-DATAORIGIN
	txa
	sta (:bp2),y

	and Attributes
	ora Result
	beq loop

	pla:tax
 end;

end;


function FindNext(var f: TSearchRec): byte; assembler;
(*
@description: Find the next entry in a findhandle

@param: var f: TSearchRec

@returns: =0 record matching the criteria, successful
*)
asm
	txa:pha

loop	mwa f :bp2
	ldy #f.FindHandle-DATAORIGIN
	mva (:bp2),y edx
	iny
	mva (:bp2),y edx+1

	@ReadDirFileName edx
	sta Result

	adw f #f.Name-DATAORIGIN :bp2

	jsr @DirFileName

	mwa f :bp2

	ldy #f.Attr-DATAORIGIN
	txa
	sta (:bp2),y

	ldy #f.ExcludeAttr-DATAORIGIN
	and (:bp2),y
	ora Result
	beq loop

	pla:tax
end;


procedure FindClose(var f: TSearchRec); assembler;
(*
@description: Close a find handle

@param: var f: TSearchRec
*)
asm
	txa:pha

	mwa f :bp2
	ldy #f.FindHandle-DATAORIGIN
	mva (:bp2),y edx
	iny
	mva (:bp2),y edx+1

	clc			; iocheck off
	@closefile edx

	pla:tax
end;


function RenameFile(var OldName,NewName: TString): Boolean; assembler;
(*
@description: Renames a file from OldName to NewName

@param: var OldName: string[32]
@param: var NewName: string[32]

@returns: TRUE - successful
@returns: FALSE - I/O error
*)
asm
	txa:pha

	mva #0 @buf

	@addString OldName
	ldy @buf
	lda #','
	sta @buf+1,y
	inc @buf
	@addString NewName

	sec			; iocheck on
	jsr @openfile.lookup
	bmi stop

	lda #32
	sta iccmd,x
	lda <@buf+1
	sta icbufa,x
	lda >@buf+1
	sta icbufa+1,x
	lda #$00
	sta icax1,x
	sta icax2,x

	m@call	ciov

stop	sty MAIN.SYSTEM.IOResult

	bpl ok

	lda #false
	seq

ok	lda #true
	sta Result

	pla:tax
end;


function DeleteFile(var FileName: TString): Boolean; assembler;
(*
@description: Delete a file from the filesystem

@param: var FileName: string[32]

@returns: TRUE - the file was successfully removed
@returns: FALSE - I/O error
*)
asm
	txa:pha

	sec			; iocheck on
	jsr @openfile.lookup
	bmi stop

	lda #33
	sta iccmd,x
	lda FileName
	add #1
	sta icbufa,x
	lda FileName+1
	adc #0
	sta icbufa+1,x
	lda #$00
	sta icax1,x
	sta icax2,x

	m@call	ciov

stop	sty MAIN.SYSTEM.IOResult

	bpl ok

	lda #false
	seq

ok	lda #true
	sta Result

	pla:tax
end;


function FileExists(name: PString): Boolean;
(*
@description: Check whether a particular file exists in the filesystem

@param: name: string[32]

@returns: TRUE - file exists
@returns: FALSE - file not exists
*)
var f: file;
    fm: byte;
begin

{
; XIO 13,#1,0,0,"D:FOOBAR12.DAT"

 ciov = $e456

 fname .byte "D:FOOBAR12.DAT",$9b

 get_status
       ldx #$10            ;IOCB #1
       lda #$0d            ;komenda: STATUS
       sta iccmd,x
       lda #<fname         ;adres nazwy pliku
       sta icbufa,x
       lda #>fname
       sta icbufa+1,x
       lda #$00
       sta icax1,x
       sta icax2,x
       jsr ciov
       ...
}
  fm:=FileMode;

  {$I-}
  Assign (f, name);
  FileMode := fmOpenRead;
  Reset (f);
  Result:=(IoResult<128) and (length(name)>0);
  Close (f);
  {$I+}

  FileMode:=fm;
end;


function ByteToStr(a: byte): TString; assembler;
(*
@description: Converts input byte to a string

https://codebase64.org/doku.php?id=base:tiny_.a_to_ascii_routine

@param: a: byte

@returns: pointer to string
.Y = hundreds, .X = tens, .A = ones
*)

asm
	txa:pha

	lda a
	ldy #$2f
	ldx #$3a
	sec
@	iny
	sbc #100
	bcs @-
@	dex
	adc #10
	bmi @-
	adc #$2f

	sta adr.Result+3
	stx adr.Result+2
	sty adr.Result+1

	ldy #3
lp	cpy #1
	beq skp
	lda adr.Result+1
	cmp #$30
	bne skp

	lda adr.Result+2
	sta adr.Result+1
	lda adr.Result+3
	sta adr.Result+2

	dey
	bne lp

skp	sty adr.Result

	pla:tax
end;


function IntToStr(a: integer): TString; assembler; stdcall; overload;
(*
@description: Convert an INTEGER value to a decimal string

@param: a: integer

@returns: pointer to string
*)
asm
	txa:pha

	inx

	@ValueToStr #@printINT

	ldx #$20
	mva:rpl @buf,x adr.Result,x-

	pla:tax
end;


function IntToStr(a: cardinal): TString; assembler; stdcall; overload;
(*
@description: Convert an CARDINAL value to a decimal string

@param: a: cardinal

@returns: pointer to string
*)
asm
	txa:pha

	inx

	@ValueToStr #@printCARD

	ldx #$20
	mva:rpl @buf,x adr.Result,x-

	pla:tax
end;


function StrToInt(const s: char): byte; assembler; overload;
(*
@description: Convert a char to an byte value

@param: s: char

@returns: byte
*)
asm
	mva s @buf+1
	mva #1 @buf

	@StrToInt #@buf

	mva edx Result
end;


function StrToInt(s: PString): integer; assembler; overload;
(*
@description: Convert a string to an integer value

@param: s: string[32]

@returns: integer (32bit)
*)
asm
	@StrToInt s

	mva edx Result
	mva edx+1 Result+1
	mva edx+2 Result+2
	mva edx+3 Result+3
end;



function TryStrToInt(s: PString; var i: integer): Boolean; assembler; overload;
(*
@description:
TryStrToInt tries to convert the string S to an integer, and returns True if this was successful.
In that case the converted integer is returned in I. If the conversion failed, (an invalid string,
or the value is out of range) then False is returned.

@param: s: string[32]

@returns: i      - integer (32bit)
          result - Boolean
*)
asm
	@StrToInt s

	cpy #0
	beq ok

	lda #$00
	sta :edx
	sta :edx+1
	sta :edx+2
	sta :edx+3

	ldy #$ff	; Y = $FF + 1 (FALSE)
ok	iny		; Y = $00 + 1 (TRUE)

	sty Result

	mwa i :bp2
	ldy #0
	mva :edx (:bp2),y+
	mva :edx+1 (:bp2),y+
	mva :edx+2 (:bp2),y+
	mva :edx+3 (:bp2),y
end;


function TryStrToInt(s: PString; var i: byte): Boolean; assembler; overload;
(*
@description:
TryStrToInt tries to convert the string S to an byte, and returns True if this was successful.
In that case the converted integer is returned in I. If the conversion failed, (an invalid string,
or the value is out of range) then False is returned.

@param: s: string[32]

@returns: i      - byte
          result - Boolean
*)
asm
	@StrToInt s

	cpy #0
	beq ok

err	lda #$00
	sta :edx
	sta :edx+1
	sta :edx+2
	sta :edx+3

	ldy #$ff	; Y = $FF + 1 (FALSE)
ok	iny		; Y = $00 + 1 (TRUE)

	sty Result

	lda :edx+1	; > 255 (out of range)
	ora :edx+2
	ora :edx+3
	bne err

	ldy i+1
	sty :bp+1
	ldy i
	lda :edx
	sta (:bp),y
end;



function IntToHex(Value: cardinal; Digits: byte): TString; register; assembler;
(*
@description: Convert an integer value to a hexadecimal string

@param: Value: cardinal (32bit)
@param: Digits - number of characters

@returns: string[32]
*)
asm
	jsr @hexStr

;	@move #@buf Result #33
	ldy #256-33
	mva:rne @buf+33-256,y adr.Result+33-256,y+
end;


function StrToFloat(var s: string): real;
(*
@description: Convert a string to a floating-point value

@param: var s: string[32]

@returns: real (Q24.8)
*)
var n, dotpos, len: byte;
begin

 result:=0.0;

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
			Result := Result * 10.0 +  real(ord(s[n])-ord('0'))
		else begin
			Result := 0.0;
			exit;
		end;

	inc(n);
	end;

	while dotpos <> 0 do begin
		result := result / 10;
		dec(dotpos);
	end;

	if (s[1]='-') then			//If s[] is "negative"
		result :=  -result;

 end;

end;


function ExtractFileExt(a: PString): TString;
(*
@description: Return the extension from a filename

@param: const a: string[255]

@returns: string[32]
*)
var i, j, k: byte;
begin

 Result[0]:=#0;

 i:=byte(a[0]);

 if i<>0 then begin

  while (i>0) and (a[i]<>'.') do dec(i);

  j:=byte(a[0])-i;

  Result[0]:=chr(j+1);

  for k:=0 to j do Result[k+1]:=a[i+k];

 end;

end;


function ExtractFilePath(a: PString): string;
(*
@description: Extract the path from a filename

@param: const a: string[255]

@returns: string[255]
*)
var i, k: byte;
begin

 Result[0]:=#0;

 i:=byte(a[0]);

 if i<>0 then begin

  while (i>0) and (a[i]<>'\') and (a[i]<>'>') and (a[i]<>':') do dec(i);

  Result[0]:=chr(i);

  for k:=0 to i-1 do Result[k+1]:=a[k+1];

 end;

end;


function AnsiUpperCase(a: PString): string; register;
(*
@description: Return an uppercase version of a string

@param: a: PString

@returns: string[255]
*)
var j: byte;
begin

 Result:=a;

 for j:=length(a) downto 1 do Result[j] := UpCase(Result[j]);

end;


function AnsiLowerCase(a: PString): string; register;
(*
@description: AnsiLowerCase converts the string S to lowercase characters and returns the resulting string.

@param: a: PString

@returns: string[255]
*)
var j: byte;
begin

 Result:=a;

 for j:=length(a) downto 1 do Result[j] := LowerCase(Result[j]);

end;


function Now: TDateTime; assembler;
(*
@description:
Read actual Date-Time

@returns: TDateTime
*)
asm
	pha
	phx
	phy
	jsr clock_get_date_time

	lda r0L
	sta Result.yy

	lda r0H
	sta Result.mm

	lda r1L
	sta Result.dd

	lda r1H
	sta Result.h

	lda r2L
	sta Result.m

	lda r2H
	sta Result.s

	lda r3L
	sta Result.ss

	ply
	plx
	pla
end;


function Date: TDateTime;
(*
@description:
Read actual Date

@returns: TDateTime
*)
begin

 Result := Now;

end;


function DateToStr(d: TDateTime): TString;
(*
@description:
Converts a TDateTime value to a date string.
* year is counted from year 1900
@param: d: TDateTime

@returns: TString
*)
var s: TString;
begin

 Result:=IntToStr(1900 + d.yy);
// Result:=AddChar('0', Result, 2);
 Result:=Concat(Result,DateSeparator);

 s:=IntToStr(d.mm); s:=AddChar('0', s, 2);
 Result:=Concat(Result,s);
 Result:=Concat(Result,DateSeparator);

 s:=IntToStr(d.dd); s:=AddChar('0', s, 2);
 Result:=Concat(Result,s);

end;


function TimeToStr(d: TDateTime): TString;
(*
@description:
Converts a TDateTime value to a time string.

@param: d: TDateTime

@returns: TString
*)
var s: TString;
begin

 Result:=IntToStr(d.h); Result:=AddChar('0', Result, 2);
 Result:=Concat(Result,TimeSeparator);

 s:=IntToStr(d.m); s:=AddChar('0', s, 2);
 Result:=Concat(Result,s);
 Result:=Concat(Result,TimeSeparator);

 s:=IntToStr(d.s); s:=AddChar('0', s, 2);
 Result:=Concat(Result,s);

end;


procedure DecodeDate(d: TDateTime; var yy,mm,dd: byte);
(*
@description:
Decode a TDateTime to a year,month,day triplet

@param: d: TDateTime
@param: yy: byte - year
@param: mm: byte - month
@param: dd: byte - day
*)
begin

 yy:=d.yy;
 mm:=d.mm;
 dd:=d.dd;

end;


procedure DecodeTime(d: TDateTime; var h,m,s: byte);
(*
@description:
Decode a TDateTime to a hour,minute,second triplet

@param: d: TDateTime
@param: h: byte - hour
@param: m: byte - minute
@param: s: byte - second
*)
begin

 h:=d.h;
 m:=d.m;
 s:=d.s;

end;


procedure DecodeDateTime(d: TDateTime; var yy,mm,dd,h,m,s,ss: byte);
(*
@description:
Decode a TDateTime to a year,month,day, hour,minute,second

@param: d: TDateTime
@param: yy: byte - year
@param: mm: byte - month
@param: dd: byte - day
@param: h: byte - hour
@param: m: byte - minute
@param: s: byte - second
*)
begin

 yy:=d.yy;
 mm:=d.mm;
 dd:=d.dd;

 h:=d.h;
 m:=d.m;
 s:=d.s;
 ss:=d.ss;
end;


function BoolToStr(B: Boolean; UseBoolStrs: Boolean): TString;
(*
@description:
BoolToStr converts the boolean B to one of the strings 'TRUE' or 'FALSE'

@param: B: Boolean
@param: UseBoolStrs: Boolean

@returns: TString
*)
begin

 if UseBoolStrs then begin

  case B of
    true: Result:='TRUE';
   false: Result:='FALSE';
  end;

 end else

  case B of
    true: Result:='1';
   false: Result:='0';
  end;

end;


function StrToBool(S: PString): Boolean;
(*
@description:
StrToBool will convert the string S to a boolean value.
The string S can contain one of 'True', 'False' (case is ignored) or a numerical value.
If it contains a numerical value, 0 is converted to False, all other values result in True.

@param: S: TString

@returns: Boolean
*)
var i: integer;
    e: byte;
begin

 val(S, i, e);

 if e = 0 then begin

  if i = 0 then
   Result := false
  else
   Result := true;

 end else

 if (AnsiUpperCase(S) = 'TRUE') then
  Result := true
 else
  Result := false;

end;


function IsLeapYear(Year: Word): boolean;
(*
@description:
IsLeapYear returns True if Year is a leap year, False otherwise.

@param: Year: Word

@returns: Boolean
*)
begin
  Result := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));
end;


function EncodeDate(Year, Month, Day: Byte): TDateTime;
(*
@description:
EncodeDate encodes the Year, Month and Day variables to a date in TDateTime format. It does the opposite of the DecodeDate procedure.

@param: Year: Byte
@param: Month: Byte
@param: Day: Byte

@returns: TDateTime
*)
begin

 Result.yy:=Year;
 Result.mm:=Month;
 Result.dd:=Day;

end;


function EncodeTime(Hour, Minute, Second: Byte): TDateTime;
(*
@description:
EncodeTime encodes the Hour, Minute and Second variables to a date in TDateTime format. It does the opposite of the DecodeTime procedure.

@param: Hour: Byte
@param: Minute: Byte
@param: Second: Byte

@returns: TDateTime
*)
begin

 Result.h:=Hour;
 Result.m:=Minute;
 Result.s:=Second;

end;


function EncodeDateTime(Year, Month, Day, Hour, Minute, Second, SetSecond: Byte): TDateTime;
(*
@description:
EncodeDateTime encodes the values Year, Month, Day, Hour, Minute and Second to a date/time valueand returns this value.

@param: Year: Byte
@param: Month: Byte
@param: Day: Byte
@param: Hour: Byte
@param: Minute: Byte
@param: Second: Byte
@param: SetSecond: Byte

@returns: TDateTime
*)
begin

 Result.yy:=Year;
 Result.mm:=Month;
 Result.dd:=Day;

 Result.h:=Hour;
 Result.m:=Minute;
 Result.s:=Second;
 Result.ss:=SetSecond;

end;


function blank_char(a: char): Boolean;
begin

 Result:=false;

 case a of
  ' ', #9: Result := true;
 end;

end;


function TrimRight(var S: string): string;
(*
@description:
Trim strips blank characters at the end of S and returns the resulting string.

@param: S: String

@return: string
*)
var i : byte;
begin

 i:=length(s);
 while (i>0) and blank_char(s[i]) do dec(i);

 Result:=s;
 Result[0]:=chr(i);

end;


function TrimLeft(var S: string): string;
(*
@description:
Trim strips blank characters at the beginning of S and returns the resulting string.

@param: S: String

@return: string
*)
var i, k : byte;
begin

 Result:=S;

 if length(S) > 0 then begin

 i:=1;
 while blank_char(s[i]) do inc(i);

 k:=0;
 while i <= length(S) do begin
  Result[k+1] := S[i];

  inc(k);
  inc(i);
 end;

 Result[0]:=chr(k);

 end;

end;


function Trim(var S: string): string;
(*
@description:
Trim strips blank characters at the beginning and end of S and returns the resulting string.

@param: S: String

@return: string
*)
begin

 Result := TrimLeft(S);
 Result := TrimRight(Result);

end;



function CompareMem(P1,P2: PByte; Len: word): Boolean; register;
begin

 Result := true;

 if P1 <> P2 then begin

  inc(Len, word(P1));

  while P1 < pointer(Len) do begin

   if P1[0] <> P2[0] then begin Result:=false; Break end;

   inc(P1);
   inc(P2);

  end;

 end;

end;

function CurrentMinuteOfDay: Word;
(*
@description:
Returns the number of minutes since midnight of a current system time.

@returns: word (Range: 0 - 1439)
*)

var d: TDateTime;
begin
	d:=Date();		{ Get current time }
	Result := (d.h * 60) + d.m;			{ Minute from midnight }
end;

function CurrentSecondOfDay: Cardinal;
(*
@description:
Returns the number of seconds since midnight of current system time.

@returns: cardinal (Range: 0 - 86399)
*)

var d: TDateTime;
begin
	d:=Date();		{ Get current time }
	Result := (d.h * 3600) +  (d.m * 60) + d.s;	{ Second from midnight }
end;

function CurrentSec100OfDay: Cardinal;
(*
@description:
Returns the 1/100ths of a second since midnight of current system time.

@returns: cardinal (Range: 0 - 8639999)
*)

var d: TDateTime;
begin
	d:=Date();		{ Get current time }
	Result := (d.h * 360000) + (d.m * 6000) + (d.s*100) + d.ss; { Sec100 from midnight }
end;

function MinuteOfDay (Hour24, Minute: Byte): Word;
(*
@description:
Returns the number of minutes since midnight of a valid given time.

@returns: word (Range: 0 - 1439)
*)
begin
   Result := (Hour24 * 60) + Minute;			{ Minute from midnight }
end;


function SecondOfDay (Hour24, Minute, Second: Byte): cardinal;
(*
@description:
Returns the number of seconds since midnight of a valid given time.

@returns: cardinal (Range: 0 - 86399)
*)
begin
   Result := (Hour24 * 3600) + (Minute * 60) + Second;	{ Second from midnight }
end;

procedure MinutesToTime (Md: cardinal; Var Hour24, Minute: Byte);
(*
@description:
Returns the time in hours and minutes of a given number of minutes.

@param: Md - minutes
@param: Hour24 - hour variable
@param: Minute - minute variable
*)
begin
   Hour24 := Md div 60;					{ Hours of time }
   Minute := Md mod 60;					{ Minutes of time }
end;


procedure SecondsToTime (Sd: cardinal; Var Hour24, Minute, Second: Byte);
(*
@description:
Returns the time in hours, mins and secs of a given number of seconds.

@param: Sd - seconds
@param: Hour24 - hour variable
@param: Minute - minute variable
@param: Second - second variabler
*)
begin
   Hour24 := Sd div 3600;				{ Hours of time }
   Minute := Sd mod 3600 div 60;		{ Minutes of time }
   Second := Sd mod 60;					{ Seconds of time }
end;


end.
