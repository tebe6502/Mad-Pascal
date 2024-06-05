unit b_dl;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Display List manipulation library.
* @version: 1.1.0
* @description:
* Set of useful constants and methods, to customize display lists for the Atari 8-bit.
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface

uses atari;

const
    DL_BLANK1 = 0; // 1 blank line
    DL_BLANK2 = %00010000; // 2 blank lines
    DL_BLANK3 = %00100000; // 3 blank lines
    DL_BLANK4 = %00110000; // 4 blank lines
    DL_BLANK5 = %01000000; // 5 blank lines
    DL_BLANK6 = %01010000; // 6 blank lines
    DL_BLANK7 = %01100000; // 7 blank lines
    DL_BLANK8 = %01110000; // 8 blank lines

    DL_DLI = %10000000; // Order to run DLI
    DL_LMS = %01000000; // Order to set new memory address
    DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
    DL_HSCROLL = %00010000; // Turn on horizontal scroll on this line

    DL_MODE_40x24T2 = 2; // Antic Modes
    DL_MODE_40x24T5 = 4;
    DL_MODE_40x12T5 = 5;
    DL_MODE_20x24T5 = 6;
    DL_MODE_20x12T5 = 7;
    DL_MODE_40x24G4 = 8;
    DL_MODE_80x48G2 = 9;
    DL_MODE_80x48G4 = $A;
    DL_MODE_160x96G2 = $B;
    DL_MODE_160x192G2 = $C;
    DL_MODE_160x96G4 = $D;
    DL_MODE_160x192G4 = $E;
    DL_MODE_320x192G2 = $F;

    DL_JMP = %00000001; // Order to jump
    DL_JVB = %01000001; // Jump to begining

var DL_address:word; (* @var contains memory of Display List *)
    DL_cursor:byte;  (* @var contains position of modification cursor *)

procedure DL_Init(address:word);
(*
* @description:
* Initializes new empty Display List at desired address.
* Sets DL_cursor at 0.
*
* @param: address - Display List memory address
*)
procedure DL_Push(value:byte);overload;
(*
* @description:
* Pushes single byte value into Display List at DL_cursor position. Moves cursor one byte forward.
*
* Use it to set with mode lines and blanks.
*
* @param: value - Display List element to push
*)
procedure DL_Push(value, count:byte);overload;
(*
* @description:
* Pushes multple bytes with single value into Display List at DL_cursor position. Moves cursor to position of first byte after added values.
*
* Use it to set multiple mode lines and blanks.
*
* @param: value - value of byte to push
* @param: count - number of bytes to push
*)
procedure DL_Push(address: word);overload;
(*
* @description:
* Pushes address value into Display List at DL_cursor position. Moves cursor two bytes forward.
*
* @param: address - (word) address to push
*)
procedure DL_Push(value: byte; address: word);overload;
(*
* @description:
* Pushes byte value and address value into Display List at DL_cursor position. Moves cursor three bytes forward.
*
* Use with DL_LMS and jump orders.
*
* @param: value - Display List order to push
* @param: address - address to push
*)
procedure DL_Start;
(*
* @description:
* Order ANTIC to use currently defined Display List.
*)
function DL_Attach:word;
(*
* @description:
* Attaches to current (system) Display List.
* Sets modification pointer at 0, so next DL_Push overwrites first byte of Display List.
*
* @returns: (word) - memory address of current Display List
*)
function DL_Seek(offset:byte):byte;
(*
* @description:
* Moves DL_cursor to desired position, and returns byte value stored at this offset.
*
* @param: offset - new DL_cursor position
*
* @returns: (byte) - byte at cursor
*)
function DL_SeekW(offset:byte):word;
(*
* @description:
* Moves DL_cursor to desired position, and returns word value stored at this offset.
*
* @param: offset - new DL_cursor position
*
* @returns: (word) - word at cursor
*)
function DL_Find(val: byte):byte;
(*
* @description:
* Tries to find desired value in Display List starting from DL_cursor.
* It checks only first 255 bytes of DL.
* Returns offset of first found element, or $ff (255) if not found.
*
* @param: val - value to find
*
* @returns: (byte) - offset of found element (or 255 if not found)
*)
procedure DL_Poke(offset: byte; val: byte);
(*
* @description:
* Moves DL_cursor to desired position, and puts a byte value at this offset.
*
* @param: offset - new DL_cursor position
* @param: val - value to poke
*)
procedure DL_PokeW(offset: byte; val: word);
(*
* @description:
* Moves DL_cursor to desired position, and puts a word value at this offset.
*
* @param: offset - new DL_cursor position
* @param: val - value to poke
*)

implementation

procedure DL_Init(address: word);
begin
    DL_address := address;
    DL_cursor := 0;
end;

procedure DL_Push(value: byte);overload;
begin
    Poke(DL_address + DL_cursor,value);
    Inc(DL_cursor);
end;

procedure DL_Push(value, count: byte);overload;
begin
    while count > 0 do begin
        DL_Push(value);
        Dec(count);
    end;
end;

procedure DL_Push(address: word);overload;
begin
    DL_Push(Lo(address));
    DL_Push(Hi(address));
end;

procedure DL_Push(value: byte; address: word);overload;
begin
    DL_Push(value);
    DL_Push(address);
end;

procedure DL_Start;
begin
    Pause;
    SDLSTL := DL_address;
end;

function DL_Attach:word;
begin
    DL_address := sdlstl;
    DL_cursor := 0;
end;

function DL_Seek(offset: byte):byte;
begin
    DL_cursor := offset;
    result := peek(DL_address + DL_cursor);
end;

function DL_SeekW(offset: byte):word;
begin
    DL_cursor := offset;
    result := dpeek(DL_address + DL_cursor);
end;

function DL_Find(val: byte):byte;
begin
    result := DL_cursor;
    repeat
        if peek(DL_address + result) = val then exit(result);
        Inc(result);
    until result = $ff;
end;

procedure DL_Poke(offset: byte; val: byte);
begin
    DL_cursor := offset;
    poke(DL_address + DL_cursor, val);
end;

procedure DL_PokeW(offset: byte; val: word);
begin
    DL_cursor := offset;
    dpoke(DL_address + DL_cursor, val);
end;

end.
