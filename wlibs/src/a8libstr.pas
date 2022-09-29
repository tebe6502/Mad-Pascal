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
function ByteToStr3(bN: Byte): string;

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
        if (pS^ >= 0) and (pS^ <= 31) then
        begin
            pS^ := pS^ + 64;
        end
        else if (pS^ >= 32) and (pS^ <= 95) then
        begin
            pS^ := pS^ - 32;
        end
        else if (pS^ >= 128) and (pS^ <= 159) then
        begin
            pS^ := pS^ + 64;
        end
        else if (pS^ >= 160) and (pS^ <= 223) then
        begin
            pS^ := pS^ - 32;
        end;

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
    if (bC >= 0) and (bC <= 31) then
    begin
        Result := bC + 64;
    end
    else if (bC >= 32) and (bC <= 95) then
    begin
        Result := bC - 32;
    end
    else if (bC >= 128) and (bC <= 159) then
    begin
        Result := bC + 64;
    end
    else if (bC >= 160) and (bC <= 223) then
    begin
        Result := bC - 32;
    end
    else begin
        Result := bC;
    end;
end;


// ------------------------------------------------------------
// Func...: ByteToStr3(bN: Byte): string;
// Desc...: Converts byte number into string like %3d
// Param..: bN = number to convert
// ------------------------------------------------------------
function ByteToStr3(bN: Byte): string;
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