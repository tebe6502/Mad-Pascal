unit b_crt;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: OS independent screen and keyboard routines.
* @version: 0.5.1
* @description:
* Set of useful constants, registers and methods to cope with text input and output without ATARI OS.
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses sysutils, atari;
const
    DEFAULT_SCREENWIDTH = 40;   // @nodoc
    DEFAULT_SCREENHEIGHT = 24;  // @nodoc

    CHAR_RETURN = #$9b;     // Chars returned for special keys in ASCII code
    CHAR_ESCAPE = #$1b;
    CHAR_BACKSPACE = #$7e;
    CHAR_TAB = #$7f;
    CHAR_INVERSE = #$81;
    CHAR_CAPS = #$82;

    ICHAR_RETURN = #219;    // Chars returned for special keys in Antic code
    ICHAR_ESCAPE = #91;
    ICHAR_BACKSPACE = #126;
    ICHAR_TAB = #127;
    ICHAR_INVERSE = #193;
    ICHAR_CAPS = #194;

    CRT_keycode: array [0..255] of char = ( //@nodoc
        'l', 'j', ';', #$ff, #$ff, 'k', '+', '*', 'o', #$ff, 'p', 'u', CHAR_RETURN, 'i', '-', '=', //@nodoc
        'v', #$ff, 'c', #$ff, #$ff, 'b', 'x', 'z', '4', #$ff, '3', '6', CHAR_ESCAPE, '5', '2', '1',
        ',', ' ', '.', 'n', #$ff, 'm', '/', CHAR_INVERSE, 'r', #$ff, 'e', 'y', CHAR_TAB, 't', 'w', 'q',
        '9', #$ff, '0', '7', CHAR_BACKSPACE, '8', '>', #$ff, 'f', 'h', 'd', #$ff, CHAR_CAPS, 'g', 's', 'a',
        'L', 'J', ':', #$ff, #$ff, 'K', '\', '^', 'O', #$ff, 'P', 'U', #$ff, 'I', '_', '|',
        'V', #$ff, 'C', #$ff, #$ff, 'B', 'X', 'Z', '$', #$ff, '#', '&', #$ff, '%', '"', '!',
        '[', ';', ']', 'N', #$ff, 'M', '?', #$ff, 'R', #$ff, 'E', 'Y', #$ff, 'T', 'W', 'Q',
        '(', #$ff, ')', '''', #$ff, '@', #$ff, #$ff, 'F', 'H', 'D', #$ff, #$ff, 'G', 'S', 'A',
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff,
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff,
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff,
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff,
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff,
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff,
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff,
        #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff
    );


var CRT_vram: word;         (* @var contains address of video memory *)
    CRT_size: word;         (* @var contains size of video memory *)
    CRT_screenWidth: byte;  (* @var contains width of screen in bytes *)
    CRT_screenHeight: byte; (* @var contains height of screen in bytes *)
    CRT_cursor: word;       (* @var contains cursor position in memory *)

    CRT_leftMargin: byte;

    kbcode: byte absolute $d209; // code of last pressed key
    consol: byte absolute $d01f; // console keys status

procedure CRT_Init(vram_address: word; width, height: byte); overload;
(*
*   @description:
*   Initializes CRT library with video ram located at specified memory address,
*   using custom values for screen width and height.
*
*   @param: vram_address - memory address of video ram
*   @param: width - width of the screen (chars)
*   @param: height - height of the screen (rows)
*)
procedure CRT_Init(vram_address: word); overload;
(*
*   @description:
*   Initializes CRT library with video ram located at specified memory address,
*   Screen size is defined as default values (40 x 24).
*
*   @param: vram_address - memory address of video ram
*)
procedure CRT_Init; overload;
(*
*   @description:
*   Initializes CRT library with video ram pointed by savmsc register,
*   Screen size is defined as default values (40 x 24).
*
*   @param: vram_address - memory address of video ram
*)
procedure CRT_Clear; overload;
(*
*   @description:
*   Clears screen.
*)
procedure CRT_Clear(filler: byte); overload;
(*
*   @description:
*   Clears screen using specified byte as filling value.
*)
procedure CRT_ClearRow(row: byte); overload;
(*
*   @description:
*   Clears specified row of a screen.
*
*   @param: row - number of row to clear
*)
procedure CRT_ClearRow; overload;
(*
*   @description:
*   Clears current row of a screen.
*)
procedure CRT_GotoXY(x, y: byte);
(*
*   @description:
*   Moves cursor to specified position on screen.
*
*   x=0, y=0 is upper left corner.
*
*   @param: x - cursor's horizontal position
*   @param: y - cursor's vertical position
*)
function CRT_WhereY: byte;
(*
*   @description:
*   Returns current vertical position of cursor (row).
*
*   @returns: (byte) - current row
*)
function CRT_WhereX: byte;
(*
*   @description:
*   Returns current horizontal position of cursor (column).
*
*   @returns: (byte) - current column
*)
function CRT_GetXY(x, y: byte): byte;
(*
*   @description:
*   Returns byte located at specified position on screen.
*
*   x=0, y=0 is upper left corner.
*
*   @param: x - cursor's horizontal position
*   @param: y - cursor's vertical position
*
*   @returns: (byte) - value at specified position
*)
procedure CRT_Write(s: string); overload;
(*
*   @description:
*   Outputs string at current cursor position.
*
*   This function outputs text in Antic coding, not ATASCII.
*   Add 'tilda' after finishing quote of your string to use Antic coding.
*
*   Example:  Write('Hello Atari'~);
*
*
*   You may also use Atascii2Antic function, to convert strings.
*
*   @param: s - string of text in Antic code
*)
procedure CRT_Write(c: char); overload;
procedure CRT_Write(num: byte); overload;
procedure CRT_Write(num: word); overload;
procedure CRT_Write(num: cardinal); overload;
procedure CRT_Write(num: integer); overload;
(*
*   @description:
*   Outputs integer value at current cursor position.
*
*   @param: num - value to write.
*)
procedure CRT_Write(num: real); overload;
(*
*   @description:
*   Outputs real value at current cursor position.
*
*   @param: num - value to write.
*)
procedure CRT_WriteXY(x,y: byte; s: string);
(*
*   @description:
*   Outputs string at desired position of the screen.
*
*   x=0, y=0 is upper left corner.
*
*   @param: x - cursor's horizontal position
*   @param: y - cursor's vertical position
*   @param: s - string to output (in Antic code)
*)
procedure CRT_WriteCentered(row: byte; s:string); overload;
(*
*   @description:
*   Outputs centered string at specified row of the screen.
*
*   @param: row - row number
*   @param: s - string to output (in Antic code)
*)
procedure CRT_WriteCentered(s:string); overload;
(*
*   @description:
*   Outputs centered string in current row of cursor.
*
*   @param: s - string to output (in Antic code)
*)
procedure CRT_WriteRightAligned(row: byte; s: string); overload;
(*
*   @description:
*   Outputs string right aligned at specified row of the screen.
*
*   @param: row - row number
*   @param: s - string to output (in Antic code)
*)
procedure CRT_WriteRightAligned(s: string); overload;
(*
*   @description:
*   Outputs string right aligned in current row of cursor.
*
*   @param: s - string to output (in Antic code)
*)
procedure CRT_Put(b: byte); overload;
(*
*   @description:
*   Outputs single byte at current position of the cursor.
*
*   @param: b - byte to be writen
*)
procedure CRT_Put(x, y, b: byte); overload;
(*
*   @description:
*   Outputs single byte at desired position of the screen.
*
*   x=0, y=0 is upper left corner.
*
*   @param: x - cursor's horizontal position
*   @param: y - cursor's vertical position
*   @param: b - byte to be writen
*)
function CRT_KeyPressed: boolean;
(*
*   @description:
*   Returns true if any key on keyboard is pressed down.
*
*   @returns: (boolean) true if any key is down
*)
function CRT_ReadKey: byte;
(*
*   @description:
*   Waits for key to be pressed and returns it's keyboard code.
*
*   @returns: keyboard code of pressed key.
*)
function CRT_ReadChar: byte;
(*
*   @description:
*   Waits for key to be pressed and returns it's value in ATASCII code.
*
*   @returns: ATASCII code of pressed key.
*)
function CRT_ReadCharI: byte;
(*
*   @description:
*   Waits for key to be pressed and returns it's value in ANTIC code.
*
*   @returns: ANTIC code of pressed key.
*)
function CRT_ReadStringI(limit: byte): string; overload;
(*
*   @description:
*   Reads string from keyboard, finished with return key,
*   and returns it's value in ANTIC code.
*
*   You can provide maximum number of chars to be entered.
*
*   @params: limit - maximum length of string
*
*   @returns: entered string in ANTIC code
*)
function CRT_ReadStringI: string; overload;
(*
*   @description:
*   Reads string from keyboard, finished with return key,
*   and returns it's value in ANTIC code.
*
*   Maximum length is 255 chars
*
*   @returns: entered string in ANTIC code
*)
function CRT_ReadString(limit: byte): string; overload;
(*
*   @description:
*   Reads string from keyboard, finished with return key,
*   and returns it's value in ATASCII code.
*
*   You can provide maximum number of chars to be entered.
*
*   @params: limit - maximum length of string
*
*   @returns: entered string in ATASCII code
*)
function CRT_ReadString: string; overload;
(*
*   @description:
*   Reads string from keyboard, finished with return key,
*   and returns it's value in ATASCII code.
*
*   Maximum length is 255 chars
*
*   @returns: entered string in ATASCII code
*)
function CRT_ReadInt: integer;
(*
*   @description:
*   Reads integer value from keyboard, finished with return key,
*
*   @returns: (integer) entered integer value
*)
function CRT_ReadFloat: real;
(*
*   @description:
*   Reads floating point value from keyboard, finished with return key,
*
*   Dot symbol '.' is used to separate fractional part.
*
*   @returns: (real) entered floating point value
*)
procedure CRT_NewLine; overload;
(*
*   @description:
*   Moves cursor to next line of screen.
*)
procedure CRT_NewLine(offset: byte); overload;
(*
*   @description:
*   Moves cursor to next line of screen and sets left margin (text offset).
*
*   @param: offset - new value for left margin
*)
procedure CRT_NewLines(count: byte);
(*
*   @description:
*   Moves cursor down by specifien number of lines.
*
*   @param: number of lines
*)
procedure CRT_CarriageReturn;
(*
*   @description:
*   Moves cursor to the left margin of the screen,
*
*)
procedure CRT_Invert(x, y, width: byte);
(*
*   @description:
*   Inverts part of the screen.
*
*   x=0, y=0 is upper left corner.
*
*   @param: x - starting cursor's horizontal position
*   @param: y - starting cursor's vertical position
*   @param: b - number of characters to be inverted
*)
procedure CRT_InvertRow(row: byte);
(*
*   @description:
*   Inverts selected row of the screen.
*
*   @param: row - row number to invert
*)
function CRT_StartPressed: boolean;
(*
*   @description:
*   Returns true if START key is pressed down.
*
*   @returns: (boolean) true if START key is down
*)
function CRT_SelectPressed: boolean;
(*
*   @description:
*   Returns true if SELECT key is pressed down.
*
*   @returns: (boolean) true if SELECT key is down
*)
function CRT_OptionPressed: boolean;
(*
*   @description:
*   Returns true if OPTION key is pressed down.
*
*   @returns: (boolean) true if OPTION key is down
*)
function CRT_HelpPressed:boolean;
(*
*   @description:
*   Returns true if HELP key is pressed down.
*
*   @returns: (boolean) true if HELP key is down
*)
function Atascii2Antic(c: byte): byte;overload;
(*
*   @description:
*   Converts single byte from ATASCII to ANTIC coding.
*
*   @param: c - byte to convert
*)
function Antic2Atascii(c: byte): byte; overload;
(*
*   @description:
*   Converts single byte from ANTIC to ATASCII coding.
*
*   @param: c - byte to convert
*)
function Atascii2Antic(s: string): string; overload;
(*
*   @description:
*   Converts text string from ATASCII to ANTIC coding.
*
*   @param: s - string to convert
*)
function Antic2Atascii(s: string): string; overload;
(*
*   @description:
*   Converts text string from ANTIC to ATASCII coding.
*
*   @param: s - string to convert
*)

implementation

function Atascii2Antic(c: byte): byte; overload;
begin
    asm {
        lda c
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror
        sta result;
    };
end;

function Antic2Atascii(c: byte):byte;overload;
begin
    asm {
        lda c
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$40-1
        bcs @+
        adc #2*$60
@       plp
        ror
        sta result;
    };
end;

function Atascii2Antic(s: string):string;overload;
var i:byte;
begin
    result[0]:=s[0];
    for i:=1 to byte(s[0]) do
        result[i]:=char(Atascii2Antic(byte(s[i])));
end;

function Antic2Atascii(s: string):string;overload;
var i:byte;
begin
    result[0]:=s[0];
    for i:=1 to byte(s[0]) do
        result[i]:=char(Antic2Atascii(byte(s[i])));
end;

procedure CRT_Init(vram_address: word; width, height: byte);overload;
begin
    CRT_vram := vram_address;
    CRT_screenWidth := width;
    CRT_screenHeight := height;
    CRT_size := width * height;
    CRT_cursor := CRT_vram;
    CRT_leftMargin := 0;
end;

procedure CRT_Init(vram_address: word);overload;
begin
    CRT_Init(vram_address, DEFAULT_SCREENWIDTH, DEFAULT_SCREENHEIGHT);
end;

procedure CRT_Init;overload;
begin
    CRT_Init(savmsc, DEFAULT_SCREENWIDTH, DEFAULT_SCREENHEIGHT);
end;


procedure CRT_Clear;overload;
begin
    FillChar(pointer(CRT_vram), CRT_size, 0);
    CRT_cursor := CRT_vram;
end;

procedure CRT_Clear(filler: byte);overload;
begin
    FillChar(pointer(CRT_vram), CRT_size, filler);
    CRT_cursor := CRT_vram;
end;

procedure CRT_GotoXY(x,y: byte);
begin
    CRT_cursor := y * CRT_screenWidth + x + CRT_vram;
end;

function CRT_WhereY:byte;
begin
    result := word(CRT_cursor - CRT_vram) div CRT_screenWidth;
end;

function CRT_WhereX:byte;
begin
    result := word(CRT_cursor - CRT_vram) mod CRT_screenWidth;
end;

procedure CRT_Write(s: string);overload;
begin
    move(s[1], pointer(CRT_cursor), byte(s[0]));
    Inc(CRT_cursor, byte(s[0]));
end;

procedure CRT_Write(c: char);overload;
begin
    poke(CRT_cursor, byte(c));
    Inc(CRT_cursor);
end;

procedure CRT_Write(num: byte);overload;
begin
    CRT_Write(Atascii2Antic(IntToStr(num)));
end;

procedure CRT_Write(num: word);overload;
begin
    CRT_Write(Atascii2Antic(IntToStr(num)));
end;

procedure CRT_Write(num: cardinal);overload;
begin
    CRT_Write(Atascii2Antic(IntToStr(num)));
end;

procedure CRT_Write(num: integer);overload;
begin
    CRT_Write(Atascii2Antic(IntToStr(num)));
end;

procedure CRT_Write(num: real);overload;
begin
    CRT_Write(Atascii2Antic(FloatToStr(num)));
end;

procedure CRT_WriteXY(x,y: byte; s: string);
begin
    CRT_GotoXY(x,y);
    CRT_Write(s);
end;

procedure CRT_Put(b: byte);overload;
begin
    Poke(CRT_cursor, b);
    Inc(CRT_cursor);
end;

procedure CRT_Put(x, y, b: byte);overload;
begin
    CRT_GotoXY(x,y);
    Poke(CRT_cursor, b);
    Inc(CRT_cursor);
end;

function CRT_GetXY(x, y: byte):byte;
begin
    result := peek(y * CRT_screenWidth + x + CRT_vram);
end;

function CRT_KeyPressed: boolean;
begin
    result := false;
    if skstat and 4 = 0 then result:=true;
end;

function CRT_ReadKey: byte;
begin
    result := kbcode;
    repeat until (not CRT_KeyPressed) or (result<>kbcode);
    repeat until CRT_KeyPressed;
    result := kbcode;
end;

function CRT_ReadChar: byte;
begin
    repeat
        result := byte(CRT_keycode[CRT_ReadKey]);
    until result <> 255;
end;

function CRT_ReadCharI: byte;
begin
    result := Atascii2Antic(CRT_ReadChar);
end;

function CRT_ReadStringI(limit: byte): string; overload;
var a: char;
begin
    result := '';
    repeat
        a := char(CRT_ReadCharI);
        if a = ICHAR_RETURN then exit(result);
        if (a = ICHAR_BACKSPACE) and (byte(result[0])>0) then begin
            Dec(CRT_cursor);
            Poke(CRT_cursor,0);
            Dec(result[0]);
        end else
        if (a <> ICHAR_CAPS)
        and (a <> ICHAR_INVERSE)
        and (a <> ICHAR_TAB)
        and (a <> ICHAR_ESCAPE)
        and (a <> ICHAR_BACKSPACE)
        and (byte(result[0])<limit) then begin
            CRT_Put(byte(a));
            Inc(result[0]);
            result[byte(result[0])] := a;
        end;
    until false;
end;

function CRT_ReadStringI: string; overload;
begin
    result := CRT_ReadStringI(255);
end;

function CRT_ReadString(limit: byte): string; overload;
begin
    result := Antic2Atascii(CRT_ReadStringI(limit));
end;

function CRT_ReadString: string; overload;
begin
    result := CRT_ReadString(255);
end;

function CRT_ReadInt:integer;
begin
    result := StrToInt(CRT_ReadString);
end;

function CRT_ReadFloat:real;
var s: string;
begin
    s := CRT_ReadString;
    result := StrToFloat(s);
end;

procedure CRT_NewLine(offset: byte); overload;
begin
    CRT_leftMargin := offset;
    CRT_cursor := CRT_cursor + CRT_screenWidth - ((CRT_cursor - CRT_vram) mod CRT_screenWidth) + offset;
end;

procedure CRT_NewLine; overload;
begin
    CRT_NewLine(CRT_leftMargin);
end;

procedure CRT_NewLines(count: byte);
begin
    while count>0 do begin
        CRT_NewLine(CRT_leftMargin);
        Dec(count);
    end;
end;

procedure CRT_WriteCentered(row: byte; s:string);overload;
var off:byte;
begin
    off := (CRT_screenWidth shr 1) - (Length(s) shr 1) - 1;
    Inc(CRT_cursor,off);
    CRT_GotoXY(off,row);
    CRT_Write(s);
end;

procedure CRT_WriteCentered(s:string);overload;
begin
    CRT_WriteCentered(CRT_WhereY, s);
end;

procedure CRT_WriteRightAligned(row: byte; s: string); overload;
var off:byte;
begin
    off := CRT_screenWidth - Length(s);
    Inc(CRT_cursor,off);
    CRT_GotoXY(off,row);
    CRT_Write(s);
end;

procedure CRT_WriteRightAligned(s: string); overload;
begin
    CRT_WriteRightAligned(CRT_WhereY, s);
end;

procedure CRT_ClearRow(row: byte);overload;
begin
    CRT_GotoXY(CRT_leftMargin, row);
    FillByte(pointer(CRT_vram + (row * CRT_screenWidth)), CRT_screenWidth, 0);
end;

procedure CRT_ClearRow;overload;
begin
    CRT_ClearRow(CRT_WhereY);
end;

procedure CRT_CarriageReturn;
begin
    CRT_GotoXY(CRT_leftMargin, CRT_WhereY);
end;

procedure CRT_Invert(x, y, width: byte);
var cursor:word;
begin
    cursor := CRT_vram + (y * CRT_screenWidth) + x;
    while width>0 do begin
        Poke(cursor,Peek(cursor) xor 128);
        Dec(width);
        Inc(cursor);
    end;
end;

procedure CRT_InvertRow(row: byte);
begin
    CRT_Invert(0, CRT_WhereY, CRT_screenWidth);
end;

function CRT_StartPressed:boolean;
begin
    result := consol and 1 = 0;
end;

function CRT_SelectPressed:boolean;
begin
    result := consol and 2 = 0;
end;

function CRT_OptionPressed:boolean;
begin
    result := consol and 4 = 0;
end;

function CRT_HelpPressed:boolean;
begin
    result := (skstat and 4 = 0) and (kbcode and %00111111 = 17);
end;

end.
