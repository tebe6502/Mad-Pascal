unit sysutils;

{

http://www.freepascal.org/docs-html/rtl/sysutils/index-5.html

AnsiUpperCase
Beep
DeleteFile
ExtractFileExt
ExtractFilePath
FileExists
FindClose
FindFirst
FindNext
GetTickCount
IntToHex
IntToStr
RenameFile
StrToFloat
StrToInt

}

interface

type
TSearchRec = record
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
	function DeleteFile(var FileName: TString): Boolean; assembler;
	function ExtractFileExt(const a: string): TString;
	function ExtractFilePath(const a: string): string;
	function FileExists(name: TString): Boolean;
	procedure FindClose(var f: TSearchRec); assembler;
	function FindFirst (const FileMask: TString; Attributes: Byte; var SearchResult: TSearchRec): byte;
	function FindNext(var f: TSearchRec): byte; assembler;
	function GetTickCount: cardinal; assembler;
	function IntToHex(Value: cardinal; Digits: byte): TString; register; assembler;
	function IntToStr(a: integer): ^string; assembler;
	function RenameFile(var OldName,NewName: TString): Boolean; assembler;
	function StrToFloat(var s: TString): real;
	function StrToInt(const s: char): byte; assembler; overload;
	function StrToInt(const s: TString): integer; assembler; overload;



implementation


procedure Beep;
//----------------------------------------------------------------------------------------------
// Sound the system bell
//----------------------------------------------------------------------------------------------
begin

 write( #$fd );		// CH_BELL

end;


function GetTickCount: cardinal; assembler;
//----------------------------------------------------------------------------------------------
// Get tick count
//----------------------------------------------------------------------------------------------
asm
{	mva :rtclok+2 Result
	mva :rtclok+1 Result+1
	mva :rtclok Result+2
	mva #$00 Result+3
};
end;


function FindFirst (const FileMask: TString; Attributes: Byte; var SearchResult: TSearchRec): byte;
//----------------------------------------------------------------------------------------------
// Start a file search and return a findhandle
//----------------------------------------------------------------------------------------------
var f: file;
begin
	assign(f, FileMask);
asm
{	txa:pha

loop	clc			; iocheck off
	@openfile f #6

	mwa SearchResult bp2

	ldy #SearchResult.Attr-DATAORIGIN
	lda Attributes
	sta (bp2),y

	ldy #SearchResult.FindHandle-DATAORIGIN

	lda f
	sta (bp2),y
	iny
	lda f+1
	sta (bp2),y

	mwa f bp2

	ldy #s@file.record
	mva <1 (bp2),y
	iny
	mva >1 (bp2),y

	ldy #s@file.nrecord
	mva <64 (bp2),y
	iny
	mva >64 (bp2),y

	ldy #s@file.buffer
	mva <@buf (bp2),y
	iny
	mva >@buf (bp2),y

	@ReadDirFileName f
	sta Result

	adw SearchResult #SearchResult.Name-DATAORIGIN bp2

	jsr @DirFileName

	txa
	and Attributes
	ora Result
	beq loop

	pla:tax
};
end;


function FindNext(var f: TSearchRec): byte; assembler;
//----------------------------------------------------------------------------------------------
// Find the next entry in a findhandle
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

loop	mwa f bp2
	ldy #f.FindHandle-DATAORIGIN
	mva (bp2),y edx
	iny
	mva (bp2),y edx+1

	@ReadDirFileName edx
	sta Result

	adw f #f.Name-DATAORIGIN bp2

	jsr @DirFileName

	mwa f bp2
	ldy #f.Attr-DATAORIGIN
	txa
	and (bp2),y
	ora Result
	beq loop

	pla:tax
};
end;


procedure FindClose(var f: TSearchRec); assembler;
//----------------------------------------------------------------------------------------------
// Close a find handle
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

	mwa f bp2
	ldy #f.FindHandle-DATAORIGIN
	mva (bp2),y edx
	iny
	mva (bp2),y edx+1

	clc			; iocheck off
	@closefile edx

	pla:tax
};
end;


function RenameFile(var OldName,NewName: TString): Boolean; assembler;
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
var f: file;
begin

  {$I-}
  Assign (f, name);
  Reset (f);
  Result:=(IoResult<128) and (length(name)>0);
  Close (f);
  {$I+}

end;


function IntToStr(a: integer): ^string; assembler;
//----------------------------------------------------------------------------------------------
// Convert an integer value to a decimal string
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

	inx

	@ValueToStr #@printINT

	mwa #@buf Result

	pla:tax
};
end;


function StrToInt(const s: char): byte; assembler; overload;
//----------------------------------------------------------------------------------------------
// Convert a string to an byte value
//----------------------------------------------------------------------------------------------
asm
{	mva s @buf+1
	mva #1 @buf

	@StrToInt #@buf

	mva edx Result
};
end;


function StrToInt(const s: TString): integer; assembler; overload;
//----------------------------------------------------------------------------------------------
// Convert a string to an integer value
//----------------------------------------------------------------------------------------------
asm
{	@StrToInt #adr.s

	mva edx Result
	mva edx+1 Result+1
	mva edx+2 Result+2
	mva edx+3 Result+3
};
end;


function IntToHex(Value: cardinal; Digits: byte): TString; register; assembler;
//----------------------------------------------------------------------------------------------
// Convert an integer value to a hexadecimal string
//----------------------------------------------------------------------------------------------
asm
{	txa:pha

	jsr @hexStr

	@move #@buf Result #33

	pla:tax
};
end;


function StrToFloat(var s: TString): real;
//----------------------------------------------------------------------------------------------
// Convert a string to a floating-point value
//----------------------------------------------------------------------------------------------
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
var i, j: byte;
begin

 Result:=a;

 i:=byte(a[0]);

 if i<>0 then
  for j:=1 to i do Result[j]:=UpCase(Result[j]);

end;


end.

