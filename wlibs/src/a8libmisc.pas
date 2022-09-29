// --------------------------------------------------
// Library: a8libmisc.pas
// Desc...: Atari 8 Bit Misc Library
// Author.: Wade Ripkowski, amarok
// Date...: 2022.09
// License: GNU General Public License v3.0
// Note...: Requires: a8defines.pas
//          -Converted from C
// Revised:
// --------------------------------------------------

unit a8libmisc;

interface

// --------------------------------------------------
// Includes
// --------------------------------------------------
uses
    a8defines;


// --------------------------------------------------
// Function Prototypes
// --------------------------------------------------
function IKC2ATA(bN: Byte): Byte;
function WaitKCX(bI: Byte): Word;

implementation

// ------------------------------------------------------------
// Func...: IKC2ATA(bN: Byte): Byte
// Desc...: Converts internal key code to ATASCII
// Param..: bN = Internal code
// Return.: ATASCII code for IKC<192
//          bN for IKC>191
//          199 for no mapping
// Notes..: Does not change if IKC>191
// ------------------------------------------------------------
function IKC2ATA(bN: Byte): Byte;
const
    cL: array[0..191] of Byte = (
        108, 106,  59, 199, 199, 107,  43,  42, 111, 199,
        112, 117, 155, 105,  45,  61, 118, 199,  99, 199,
        199,  98, 120, 122,  52, 199,  51,  54, 199,  53,
         50,  49,  44,  32,  46, 110, 199, 109,  47, 199,
        114, 199, 101, 121, 199, 116, 119, 113,  57, 199,
         48,  55, 199,  56,  60,  62, 102, 104, 100, 199,
        199, 103, 115,  97,  76,  74,  58, 199, 199,  75,
         92,  94,  79, 199,  80,  85, 199,  73,  95, 124,
         86, 199,  67, 199, 199,  66,  88,  90,  36, 199,
         35,  38, 199,  37,  34,  33,  91,  32,  93,  78,
        199,  77,  63, 199,  82, 199,  69,  89, 199,  84,
         87,  81,  40, 199,  41,  39, 199,  64, 199, 199,
         70,  72,  68, 199, 199,  71,  83,  65,  12,  10,
        123, 199, 199,  11, 199, 199,  15, 199,  16,  21,
        199,   9, 199, 199,  22, 199,   3, 199, 199,   2,
         24,  26, 199, 199, 199, 199, 199, 199, 199, 199,
        199, 199,  96,  14, 199,  13, 199, 199,  18, 199,
          5,  25, 199,  20,  23,  17, 199, 199, 199, 199,
        199, 199, 199, 199,   6,   8,   4, 199, 199,   7,
         19,   1
    );
begin
    // Get ATASCII from array if icode<192
    if bN < 192 then
    begin
        Result := cL[bN];
    end
    // Else dont change it
    else begin
        Result := bN;
    end;
end;


// ------------------------------------------------------------
// Func...: WaitKCX(bI: Byte): Word
// Desc...: Waits for any key, console, or help key press.
// Param..: bI = WON to allow inverse toggle, else WOFF.
// Return.: keycode pressed
// Notes..: XL/XE only
// ------------------------------------------------------------
function WaitKCX(bI: Byte): Word;
var
    bK, bC, bH, bU: Byte;
begin
    Result := 0;

    // Wait for one of the keys
    while (DPeek(KEYPCH) = KNONE) and (Peek(CONSOL) = KCNON) and (Peek(HELPFG) = 0) do;

    // Grab the register values
    bK := Peek(KEYPCH);
    bC := Peek(CONSOL);
    bH := Peek(HELPFG);

    // Process console key
    if bC <> KCNON then
    begin
        Result := bC + 256;
    end
    // Process help key, must debounce
    else if bH > 0 then
    begin
        Result := KFHLP;
        Poke(HELPFG, 0);
    end
    // Toggle CAPS
    else if bK = KCAP then
    begin
        Result := bK;

        // Get current reg value, flip it, and put it back.
        bU := Peek(SHFLOK);
        bU := bU xor 64;
        Poke(SHFLOK, bU);
    end
    // Toggle Inverse
    else if bK = KINV then
    begin
        Result := bK;

        // Toggle if allowed
        if bI = WON then
        begin
            // Get current reg value, flip it, and put it back.
            bU := Peek(INVFLG);
            bU := bu xor 128;
            Poke(INVFLG, bU);
        end;
    end
    // All else
    else begin
        Result := bK;
    end;

    // Debounce key
    Poke(KEYPCH, KNONE);
end;

end.