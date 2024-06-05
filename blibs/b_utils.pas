unit b_utils;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Common Utils
* @version: 0.6.0
* @description:
* Set of useful procedures to simplify common tasks in Atari 8-bit programming.
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses atari;

type TdateTime = record 
(*
* @description: 
* Record type used to store date and time.
*)
    year:word; 
    month:byte;
    day:byte;     // day of month
    hour:byte;
    minute:byte;
    second:byte;
    dow:byte;    // day of week
end;

function CountBits(b: byte):byte;assembler;
(*
* @description:
* Counts number of ones in bits of any byte value.
*
* @param: b - byte value to count bits in
*
* @returns: (byte) - number fo bits turned on
*)
procedure WriteLnCentered(s: string);
(*
* @description:
* Outputs string aligned to center of screen width.
* 
* Length of string should not exceed screen width (40).
*
* @param: s - string to write
*)
procedure WriteRightAligned(w: byte; s: TString);
(*
* @description:
* Outputs string aligned to right of provided width.
* 
* Length of string should not exceed provided width of field.
*
* @param: w - width of field to align
* @param: s - string to write
*)
function NullTermToString(ptr: word): string;
(*
* @description:
* Parses null terminated string into regular pascal string variable.
* 
* @param: ptr (word) - address in memory of null terminated string
* 
* @returns: (string) - regular pascal string type variable
*)
function FFTermToString(ptr: word): string;
(*
* @description:
* Parses string terminated with $FF into regular pascal string variable.
* 
* @param: ptr (word) - address in memory of null terminated string
* 
* @returns: (string) - regular pascal string type variable
*)
procedure ExpandRLE(src: word; dest: word);
(*
* @description:
* Expands RLE compressed data from source memory location and 
* writes expanded data at destination memory address.
* 
* @param: src (word) - source address of compressed data 
* @param: dest (word) - destination address where data is expanded
*)
procedure ExpandLZ4(source: word; dest: word);assembler;
(*
* @description:
* Expands LZ4 compressed data from source memory location and 
* writes expanded data at destination memory address.
* 
* Based on xxl & fox routine from here: <https://xxl.atari.pl/lz4-decompressor/>
* 
* @param: src (word) - source address of compressed data 
* @param: dest (word) - destination address where data is expanded
*)
procedure UnixToDate(ux: cardinal; var date: TDateTime);
(*
* @description:
* Converts unix timestamp to proper date, represented as an record of TDateTime type.
* 
* @param: ux (cardinal) - unix timestamp 
* @param: date (TDateTime) - record where the result of conversion is stored
*)
function Hour24to12(hour: byte):byte;
(*
* @description:
* Converts 24 hour clock indication into to 12 hour
* 
* @param: hour (byte) - hour (0-23)
* 
* @returns: (byte) - hour(0-12)
*)
function HexChar2Dec(c:char):byte;
(*
* @description:
* Converts hex char into proper value in decimal.
* 
* @param: c (char) - hex char (0-9,a-f)
* 
* @returns: (byte) - decimal value (0-15), on error (invalid char) returns 255
*)

procedure Base64Init;
(*
* @description:
* Initializes base64 encoding tables. Must be started once, prior to any compression or decompression process.
*)

procedure Base64Encode(var src, dest: string);
(*
* @description:
* Encodes string using base64 code.
* Be sure that trlaslation arrays are initialized by calling Base64Init first. Once.
* 
* @param: src (string) - source string
* @param: dest (string) - destination string where data is encoded
* 
*)

procedure Base64Decode(var src, dest: string);
(*
* @description:
* Decodes base 64 encoded string 
* Be sure that trlaslation arrays are initialized by calling Base64Init first. Once.
* 
* @param: src (string) - encoded source string
* @param: dest (string) - destination string where data is decoded
* 
*)

implementation

var base64chars: pChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; // @nodoc 
var base64inv: array [0..127] of byte; // @nodoc 

procedure Base64Init;
var i:byte;
begin
	for i := 0 to 63 do
		base64inv[byte(base64chars[i])] := i; 
end;

procedure Base64Encode(var src, dest: string);
var
	l,c,d:byte;
	p:string[3];
	chunk: array[0..3] of char;
begin
	p := '';
	l := byte(src[0]);
	c := l mod 3;
	if c>0 then
		while c<3 do begin
			Inc(p[0]);
			p[byte(p[0])] := '=';
			inc(c);
	end;
	c:=1;
	d:=1;
	repeat
		chunk[0] := base64chars[byte(src[c]) shr 2];
		chunk[1] := base64chars[((byte(src[c]) and 3) shl 4) or ((byte(src[c+1]) and $f0) shr 4)];
		chunk[2] := base64chars[((byte(src[c+2]) and 192) shr 6) or ((byte(src[c+1]) and $0f) shl 2)];
		chunk[3] := base64chars[byte(src[c+2]) and 63];
		move(chunk,dest[d],4);
		Inc(d,4);
		Inc(c,3);
	until c > l;
	dest[0] := char(d - 1);
	l := byte(dest[0]);
	for c:=1 to length(p) do begin
		dest[l] := p[c];
		dec(l);
	end;
	
end;

procedure Base64Decode(var src, dest: string);
var
	l,c,d:byte;
	p:byte;
	chunk: array[0..2] of char;
begin
	l := Length(src);
	p := 0;
	if src[l] = '=' then begin
		src[l] := 'A';
		Inc(p);
		if src[l-1] = '=' then begin
			src[l-1] := 'A';
			Inc(p);
		end;
	end;
	c:=1;
	d:=1;
	repeat
		chunk[0] := char((base64inv[byte(src[c])] shl 2) or (base64inv[byte(src[c+1])] shr 4));
		chunk[1] := char((base64inv[byte(src[c+1])] shl 4) or (base64inv[byte(src[c+2])] shr 2));
		chunk[2] := char((base64inv[byte(src[c+2])] shl 6) or base64inv[byte(src[c+3])]);
		move(chunk,dest[d],3);
		Inc(c,4);
		Inc(d,3);
	until c > l;
	dest[0] := char(d - p - 1);
end;

procedure WriteRightAligned(w: byte; s: TString);
var len: byte;
begin
	len := w - Length(s);
    Write(Space(len), s);
end;

procedure WriteLnCentered(s: string);
begin
    Writeln(Space((40 - Length(s)) div 2), s);
end;

function NullTermToString(ptr: word): string;
begin
    result[0] := Char(0);
    while Peek(ptr) <> 0 do begin
        Inc(result[0]);
        result[byte(result[0])] := char(Peek(ptr));
        Inc(ptr);
    end;
end; 

function FFTermToString(ptr: word): string;
begin
    result[0] := Char(0);
    while Peek(ptr) <> $ff do begin
        Inc(result[0]);
        result[byte(result[0])] := char(Peek(ptr));
        Inc(ptr);
    end;
end; 

function CountBits(b: byte):byte;assembler;
asm {
		lda b
		ldy #0                  ; Clear bit count
BitShiftLoop:
        asl                     ; Shift a bit
        bcc BitCountSkip        ; Did a one shift out?
        iny                     ; Add one to count
        ora #0                  ; Retest for zero
BitCountSkip:
        bne BitShiftLoop        ; Repeat till zero
        sty result
};
end;

procedure ExpandRLE(src: word; dest: word);
var value, count:byte;
begin
    value := peek(src);
    while value<>0 do begin
        Inc(src);
        count := (value shr 1) + 1;
        if Odd(value) then begin // just repeat data
            Move(pointer(src),pointer(dest),count);
            Inc(src,count);
        end else begin  // expand
            FillChar(pointer(dest),count,peek(src));
            Inc(src);
        end;
        Inc(dest,count);
        value := peek(src);
    end;
end; 

procedure ExpandLZ4(source: word; dest: word);assembler;
asm {
                  mwa dest xdest
                  mwa source xsource
unlz4
                  jsr    GET_BYTE                  ; length of literals
                  sta    token
               :4 lsr
                  beq    read_offset                     ; there is no literal
                  cmp    #$0f
                  jsr    getlength
literals          jsr    GET_BYTE
                  jsr    store
                  bne    literals
read_offset       jsr    GET_BYTE
                  tay
                  sec
                  eor    #$ff
                  adc    xdest
                  sta    src
                  tya
                  php
                  jsr    GET_BYTE
                  plp
                  bne    not_done
                  tay
                  beq    unlz4_done
not_done          eor    #$ff
                  adc    xdest+1
                  sta    src+1
                  ; c=1
                  lda    #$ff
token             equ    *-1
                  and    #$0f
                  adc    #$03                            ; 3+1=4
                  cmp    #$13
                  jsr    getLength

@                 lda    $ffff
src               equ    *-2
                  inw    src
                  jsr    store
                  bne    @-
                  beq    unlz4                           ; zawsze
store             sta    $ffff
xdest              equ    *-2
                  inw    xdest
                  dec    lenL
                  bne    unlz4_done
                  dec    lenH
unlz4_done        rts
getLength_next    jsr    GET_BYTE
                  tay
                  clc
                  adc    #$00
lenL              equ    *-1
                  bcc    @+
                  inc    lenH
@                 iny
getLength         sta    lenL
                  beq    getLength_next
                  tay
                  beq    @+
                  inc    lenH
@                 rts
lenH              .byte    $00
get_byte          lda    $ffff
xsource           equ    *-2
                  inw    xsource
                  rts
};
end; 

procedure UnixToDate(ux: cardinal; var date:TDateTime);
var second, minute, hour, day, month, year, dow, dim: cardinal;
    leap: boolean;
    daysInYear: word;
    daysInMonth: array [0..11] of byte = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    fin:boolean;
begin
    fin := false;
    second := ux;
    minute := ux div 60;
    second := second - minute * 60;
    hour   := minute div 60;
    minute := minute - hour * 60;
    day    := hour div 24;
    hour   := hour - day * 24;
    
    year   := 1970;
    dow    := 4;
    
    repeat;
        leap := (year mod 4 = 0) and ((year mod 100 <> 0) or (year mod 400 = 0));
        daysInYear := 365;
        if leap then inc(daysInYear);
        if day >= daysInYear then begin
            inc(dow);
            if leap then inc(dow);
            day := day - daysInYear;
            if dow >= 7 then dow := dow -7;
            inc(year);
        end else begin
            date.day := day;
            dow := dow + day;
            dow := dow mod 7;
            month := 0;
            repeat
                dim := daysInMonth[month];
                if (month = 1) and leap then inc(dim);
                if day >= dim then day := day - dim else fin := true;;
                inc(month);
            until fin or (month = 12);
            fin := true;
        end;
    until fin;
    date.second := second;
    date.minute := minute;
    date.hour := hour;
    date.day := day + 1;
    date.month := month; 
    date.year := year;
    date.dow := dow;
end;

function Hour24to12(hour: byte):byte;
begin
    result := hour;
    if hour > 12 then result := hour - 12;
end;

function HexChar2Dec(c:char):byte;
begin
    result:=$ff;
    case c of
        '0'..'9': begin 
            exit(byte(byte(c)-48));
        end;
        'a'..'f': begin 
            exit(byte(byte(c)-87));
        end;
        'A'..'F': begin 
            exit(byte(byte(c)-55));
        end;
    end;
end;

end.
