unit b_utils;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Common Utils
* @version: 0.5.2
* @description:
* Set of useful procedures to simplify common tasks in Atari 8-bit programming.
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses atari;

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
procedure ExpandLZ4(source: word; dest: word):assembler;
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


implementation

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

procedure ExpandLZ4(source: word; dest: word):assembler;
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

end.
