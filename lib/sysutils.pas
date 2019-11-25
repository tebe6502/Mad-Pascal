unit sysutils;
(*
@type: unit
@name: Various system utilities
@author: Tomasz Biela (Tebe)

@description:
<http://www.freepascal.org/docs-html/rtl/sysutils/index-5.html>
*)

{

AnsiUpperCase
Beep
BoolToStr
Click
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

}

interface

type	TSearchRec = record
(*
@description:

*)
		Attr: Byte;
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


	function AnsiUpperCase(const a: string): string;
	procedure Beep;
	function BoolToStr(B: Boolean; UseBoolStrs: Boolean): TString;
	procedure Click; assembler;
	function Date: TDateTime;
	function DateToStr(d: TDateTime): TString;
	procedure DecodeDate(d: TDateTime; var yy,mm,dd: byte);
	procedure DecodeDateTime(d: TDateTime; var yy,mm,dd,h,m,s: byte);
	procedure DecodeTime(d: TDateTime; var h,m,s: byte);
	function DeleteFile(var FileName: TString): Boolean; assembler;
	function EncodeDate(Year, Month, Day: Byte): TDateTime;
	function EncodeDateTime(Year, Month, Day, Hour, Minute, Second: Byte): TDateTime;
	function EncodeTime(Hour, Minute, Second: Byte): TDateTime;
	function ExtractFileExt(const a: string): TString;
	function ExtractFilePath(const a: string): string;
	function FileExists(name: TString): Boolean;
	procedure FindClose(var f: TSearchRec); assembler;
	function FindFirst (const FileMask: TString; Attributes: Byte; var SearchResult: TSearchRec): byte;
	function FindNext(var f: TSearchRec): byte; assembler;
	function GetTickCount: cardinal; assembler;
	function IntToHex(Value: cardinal; Digits: byte): TString; register; assembler;
	function IntToStr(a: integer): ^string; assembler;
	function IsLeapYear(Year: Word): boolean;
	function Now: TDateTime;
	function RenameFile(var OldName,NewName: TString): Boolean; assembler;
	function StrToBool(const S: TString): Boolean;
	function StrToFloat(var s: TString): real;
	function StrToInt(const s: char): byte; assembler; overload;
	function StrToInt(const s: TString): integer; assembler; overload;
	function TimeToStr(d: TDateTime): TString;
	function Trim(var S: string): string;

implementation

uses DOS, StrUtils;


procedure Beep;
(*
@description: Sound the system bell
*)
begin

 write( #$fd );		// CH_BELL

end;


procedure Click ; assembler;
(*
@description: Sound the system click
*)
asm
{
	LDA #$00	;poke zero into
	STA $D01F	;...CONSOL (53279)
};
end;


function GetTickCount: cardinal; assembler;
(*
@description: Get tick count

@returns: 32bit tick count
*)
asm
{	mva :rtclok+2 Result
	mva :rtclok+1 Result+1
	mva :rtclok Result+2
	mva #$00 Result+3
};
end;


function FindFirst (const FileMask: TString; Attributes: Byte; var SearchResult: TSearchRec): byte;
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
{	txa:pha

loop	clc			; iocheck off
	@openfile f #6

	mwa SearchResult :bp2

	ldy #SearchResult.Attr-DATAORIGIN
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

	txa
	and Attributes
	ora Result
	beq loop

	pla:tax
};
end;


function FindNext(var f: TSearchRec): byte; assembler;
(*
@description: Find the next entry in a findhandle

@param: var f: TSearchRec

@returns: =0 record matching the criteria, successful
*)
asm
{	txa:pha

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
	and (:bp2),y
	ora Result
	beq loop

	pla:tax
};
end;


procedure FindClose(var f: TSearchRec); assembler;
(*
@description: Close a find handle

@param: var f: TSearchRec
*)
asm
{	txa:pha

	mwa f :bp2
	ldy #f.FindHandle-DATAORIGIN
	mva (:bp2),y edx
	iny
	mva (:bp2),y edx+1

	clc			; iocheck off
	@closefile edx

	pla:tax
};
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
{	txa:pha

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
	jsr ciov

stop	sty MAIN.SYSTEM.IOResult

	bpl ok

	lda #false
	seq

ok	lda #true
	sta Result

	pla:tax
};
end;


function DeleteFile(var FileName: TString): Boolean; assembler;
(*
@description: Delete a file from the filesystem

@param: var FileName: string[32]

@returns: TRUE - the file was successfully removed
@returns: FALSE - I/O error
*)
asm
{	txa:pha

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
	jsr ciov

stop	sty MAIN.SYSTEM.IOResult

	bpl ok

	lda #false
	seq

ok	lda #true
	sta Result

	pla:tax
};
end;


function FileExists(name: TString): Boolean;
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


function IntToStr(a: integer): ^string; assembler;
(*
@description: Convert an integer value to a decimal string

@param: a: integer

@returns: pointer to string
*)
asm
{	txa:pha

	inx

	@ValueToStr #@printINT

	mwa #@buf Result

	pla:tax
};
end;


function StrToInt(const s: char): byte; assembler; overload;
(*
@description: Convert a char to an byte value

@param: s: char

@returns: byte
*)
asm
{	mva s @buf+1
	mva #1 @buf

	@StrToInt #@buf

	mva edx Result
};
end;


function StrToInt(const s: TString): integer; assembler; overload;
(*
@description: Convert a string to an integer value

@param: s: string[32]

@returns: integer (32bit)
*)
asm
{	@StrToInt #adr.s

	mva edx Result
	mva edx+1 Result+1
	mva edx+2 Result+2
	mva edx+3 Result+3
};
end;


function IntToHex(Value: cardinal; Digits: byte): TString; register; assembler;
(*
@description: Convert an integer value to a hexadecimal string

@param: Value: cardinal (32bit)
@param: Digits - number of characters

@returns: string[32]
*)
asm
{	txa:pha

	jsr @hexStr

	@move #@buf Result #33

	pla:tax
};
end;


function StrToFloat(var s: TString): real;
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
		result := result * 10.0 +  real(ord(s[n])-ord('0'));

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


function ExtractFileExt(const a: string): TString;
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


function ExtractFilePath(const a: string): string;
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


function AnsiUpperCase(const a: string): string;
(*
@description: Return an uppercase version of a string

@param: const a: string[255]

@returns: string[255]
*)
var i, j: byte;
begin

 Result:=a;

 i:=byte(a[0]);

 if i<>0 then
  for j:=1 to i do Result[j]:=UpCase(Result[j]);

end;


function Now: TDateTime;
(*
@description:
Read actual Date-Time (Sparta DOS X, R-Time 8, SIO Real-Time Clock)

@returns: TDateTime
*)
var v: word;
begin

 v:=DosVersion;

 if v and $ff = $ff then begin

asm
{	txa:pha

	ldx #11
	mva:rpl readrtc,x ddevic,x-

	jsr jsioint

	sty MAIN.SYSTEM.IOResult

	jmp skp

readrtc	dta $45,1,$93,$40
	dta a(adr.Result)
	dta 7,0,a(6),$ee,$a0

skp	pla:tax

};

 end else

asm
{
fsymbol	= $07EB

	txa:pha

	lda <I_GETTD
	ldx >I_GETTD
	jsr fsymbol
	sta _gettd+1
	stx _gettd+2

_gettd	jsr $ffff

	ldy #13		    ; COMTAB+13 (DATER + TIMER)
cp	lda (dosvec),y
	sta adr.Result-13,y
	iny
	cpy #13+6
	bne cp

	jmp skp_

I_GETTD	dta c'I_GETTD '

skp_	pla:tax
};
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

@param: d: TDateTime

@returns: TString
*)
var s: TString;
begin

 Result:=IntToStr(d.yy); Result:=AddChar('0', Result, 2);
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
 Result:=Concat(Result,DateSeparator);

 s:=IntToStr(d.m); s:=AddChar('0', s, 2);
 Result:=Concat(Result,s);
 Result:=Concat(Result,DateSeparator);

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


procedure DecodeDateTime(d: TDateTime; var yy,mm,dd,h,m,s: byte);
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


function StrToBool(const S: TString): Boolean;
(*
@description:
StrToBool will convert the string S to a boolean value.
The string S can contain one of 'True', 'False' (case is ignored) or a numerical value.
If it contains a numerical value, 0 is converted to False, all other values result in True.

@param: S: TString

@returns: Boolean
*)
begin

 if (AnsiUpperCase(S) = 'TRUE') or (S = '1') then
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


function EncodeDateTime(Year, Month, Day, Hour, Minute, Second: Byte): TDateTime;
(*
@description:
EncodeDateTime encodes the values Year, Month, Day, Hour, Minute and Second to a date/time valueand returns this value.

@param: Year: Byte
@param: Month: Byte
@param: Day: Byte
@param: Hour: Byte
@param: Minute: Byte
@param: Second: Byte

@returns: TDateTime
*)
begin

 Result.yy:=Year;
 Result.mm:=Month;
 Result.dd:=Day;

 Result.h:=Hour;
 Result.m:=Minute;
 Result.s:=Second;

end;


function Trim(var S: string): string;
(*
@description:
Trim whitespace from the ends of a string.

@param: S: String

@return: string
*)
var i : byte;
begin
 
 i:=length(s);
 while (i>0) and (s[i]=' ') do dec(i);

 Result:=s;
 Result[0]:=chr(i);
 
// Result:=Copy(s,1,i);
end;


end.
