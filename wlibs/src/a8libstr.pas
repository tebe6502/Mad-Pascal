// --------------------------------------------------
// Library: a8libstr.pas
// Desc...: Atari 8 Bit String Library
// Author.: Wade Ripkowski, amarok
// Date...: 2022.09
// License: GNU General Public License v3.0
// Note...: Requires: a8defines.pas
//          -Converted from C
//          -Type byte is synonymous with unsigned char (a8defines.h)
// Revised:
// --------------------------------------------------

unit a8libstr;

interface

// --------------------------------------------------
// Includes
// --------------------------------------------------
uses
    a8defines;


// --------------------------------------------------
// Function Prototypes
// --------------------------------------------------
procedure StrInv(pS: PByte; bS: Byte);
procedure StrAI(pS: PByte; bS: Byte);
function CharAI(bC: Byte): Byte;
function ByteToStr3(bN: Byte): string[3];

implementation

// ------------------------------------------------------------
// Func...: StrInv(pS: PByte; bS: Byte)
// Desc...: Inverses chars of a string from start
// Param..: pS = pointer to string to inverse
//          bS = size (number) of chars in string to inverse
// ------------------------------------------------------------
procedure StrInv(pS: PByte; bS: Byte);
var
    bL: Byte;
begin
    // Loop through number of requested chars
    for bL := 0 to bS - 1 do
    begin
        // Dereference, change char value by 128, increment pointer
        pS^ := pS^ xor 128;
        Inc(ps);
    end;
end;


// ------------------------------------------------------------
// Func...: StrAI(pS: PByte; bS: Byte)
// Desc...: Converts string from ATASCII code to internal code
// Param..: pS = pointer to string to convert
//          bS = size (number) of chars in string to convert
// Notes..: Manual iteration so we can process space which has
//          0 as internal code (c string terminator).
// ------------------------------------------------------------
procedure StrAI(pS: PByte; bS: Byte);
var
    bL: Byte;
begin
    // Process each element
    for bL := 0 to bS - 1 do
    begin
        pS^ := byte(ata2int(char(pS^)));
        // Increment pointer to next char
        Inc(pS);
    end;
end;


// ------------------------------------------------------------
// Func...: CharAI(bC: Byte): Byte
// Desc...: Converts byte from ATASCII code to internal code
// Param..: bC = byte to convert
// ------------------------------------------------------------
function CharAI(bC: Byte): Byte;
begin
     Result := byte(ata2int(char(bC)));
end;


// ------------------------------------------------------------
// Func...: ByteToStr3(bN: Byte): string[3];
// Desc...: Converts byte number into string like %3d
// Param..: bN = number to convert
// ------------------------------------------------------------
function ByteToStr3(bN: Byte): string[3];
begin
    Result := '   ';
    Result[3] := Char(Byte('0') + bN mod 10);
    if bN > 9 then
    begin
        bN := bN div 10;
        Result[2] := Char(Byte('0') + bN mod 10);
        if bN > 9 then
        begin
            bN := bN div 10;
            Result[1] := Char(Byte('0') + bN mod 10);
        end;
    end;
end;


end.