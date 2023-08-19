// --------------------------------------------------
// Library: a8libwin.pas
// Desc...: Atari 8 Bit Window Library
// Author.: Wade Ripkowski, amarok
// Date...: 2022.09
// License: GNU General Public License v3.0
// Note...: Requires: a8defwin.pas
//          -Converted from C
//          -Type byte is synonymous with unsigned char (a8defines.pas)
// Depends: a8libstr.pas
// Revised:
// - Added WDiv function
// - Added WClr function
// --------------------------------------------------
unit a8libwin;

interface

// --------------------------------------------------
// Includes
// --------------------------------------------------
uses
    a8defines, a8defwin;

var
    baW: td_wnrec;

// --------------------------------------------------
// Function Prototypes
// --------------------------------------------------
procedure WInit;
procedure WBack(bN: Byte);
function WOpen(x, y, w, h, bT: Byte): Byte;
function WClose(bN: Byte): Byte;
function WStat(bN: Byte): Byte;
function WPos(bN, x, y: Byte): Byte;
function WPut(bN: Byte; x: Char): Byte;
function WPrint(bN, x, y, bI: Byte; pS: string[38]): Byte;
function WOrn(bN, bT, bL: Byte; pS: string[38]): Byte;
function WDiv(bN, y, bD: Byte): Byte;
function WClr(bN: Byte): Byte;


implementation

uses
    Crt, SysUtils, a8libstr;
 
var
    vCur: td_wnpos;

    // Window handle and memory storage
    baWM: array[0..WBUFSZ - 1] of Byte;
    cpWM: ^Byte;

// --------------------------------------------------
// Function: WInit
// Desc....: Initialized windowing system
// --------------------------------------------------
procedure WInit;
var
    bL: Byte;
begin
    // Setup cursor and screen
    Poke(ACURIN, 1);
    Poke(ALMARG, 0);
    ClrScr;

    // Clear window memory
    FillChar(@baWM[0], WBUFSZ, 0);

    // Set index into window memory
    cpWM := baWM;

    // Work on 10 window+system handles
    for bL := 0 to WRECSZ do
    begin
        // Clear window handle record vars
        baW.bU[bL] := WOFF;
        baW.bX[bL] := 0;
        baW.bY[bL] := 0;
        baW.bW[bL] := 0;
        baW.bH[bL] := 0;
        baW.bI[bL] := WOFF;
        baW.cM[bL] := @baWM[0];  // base storage location
        baW.cZ[bL] := 0;
    end;

    // Set virtual cursor coords
    vCur.vX := 0;
    vCur.vY := 0;
end;

// --------------------------------------------------
// Function: WBack(bN: Byte)
// Desc....: Set screen background char
// Param...: bN = character to use
// Notes...: WBNONE for empty background
// --------------------------------------------------
procedure WBack(bN: Byte);
begin
    // Fill screen memory with char
    FillChar(Pointer(DPeek(RSCRN)), 960, ata2int(char(bN)));
end;


// --------------------------------------------------
// Function: WOpen(x, y, w, h, bT: Byte): Byte
// Desc....: Open a window
// Param...: x = column
//           y = row
//           w = width
//           h = height
//           bT = display in inverse
//                WON/WOFF
// Returns.: Window handle number
//           > 100 on error
// Notes...: cL is not manipulated as a string.
//           (0) is data, not size.
// --------------------------------------------------
function WOpen(x, y, w, h, bT: Byte): Byte;
var
    bL, bD, bC: Byte;
    cL: array[0..40] of Byte;
    pS: Word;
begin
    Result := WENONE;

    // Cycle through handles (exluding system)
    for bL := 0 to WRECSZ do
    begin
        // If handle is not in use
        if baW.bU[bL] = WOFF then
        begin
            // Set handle in use
            baW.bU[bL] := WON;

            // Set storage address and size
            baW.cM[bL] := Pointer(cpWM);
            baW.cZ[bL] := w * h;

            // Set other handle vars
            baW.bX[bL] := x;
            baW.bY[bL] := y;
            baW.bW[bL] := w;
            baW.bH[bL] := h;
            baW.bI[bL] := bT;

            // Find top left corner of window in memory
            pS := DPeek(RSCRN) + (y * 40) + x;

            // Draw window
            for bD := 0 to h - 1 do
            begin
                // Build window line as string (internal char codes)

                // If top or bottom line ("+-+")
                if (bD = 0) or (bD = h - 1) then
                begin
                    // Set solid line
                    FillChar(@cL[0], w, 82);

                    // Top line corners
                    if bD = 0 then
                    begin
                        cL[0] := 81;
                        cL[w - 1] := 69;
                    end
                    // Bottom line corners
                    else begin
                        cL[0] := 90;
                        cL[w - 1] := 67;
                    end;
                end
                // Middle line "| |"
                else begin
                    // Set space and sides
                    FillChar(@cL[0], w, 0);
                    cL[0] := 124;
                    cL[w - 1] := 124;
                end;

                // If inverse flag, flip line
                if bT = WON then
                begin
                    for bC := 0 to w - 1 do
                    begin
                        cL[bC] := cL[bC] xor 128;
                    end;
                end;

                // Save underlying screen to win mem
                Move(Pointer(pS), cpWM, w);
                // Inc mem ptr index by win width
                Inc(cpWM, w);
                // Move line to screen
                Move(@cL[0], Pointer(pS), w);
                // Inc screen by 40 to next line start
                Inc(pS, 40);
            end;

            // Set return to handle number
            Result := bL;

            // Exit loop
            break;
        end;
    end;
end;


// --------------------------------------------------
// Function: WClose(bN: Byte): Byte
// Desc....: Closes a window
// Param...: bN = window handle number
// Returns.: 0 if success
//           >100 on error
// --------------------------------------------------
function WClose(bN: Byte): Byte;
var
    bL: Byte;
    pS: Word;
    pA: PByte;
begin
    Result := WENOPN;

    // Only if handle in use
    if baW.bU[bN] = WON then
    begin
        // Find top left corner of window in screen memory
        pS := DPeek(RSCRN) + (baW.bY[bN] * 40) + baW.bX[bN];

        // Set temp ptr to start of win mem
        pA := baW.cM[bN];

        // Restore screen line by line
        for bL := 0 to baW.bH[bN] - 1 do
        begin
            // Restore underlying screen
            Move(pA, Pointer(pS), baW.bW[bN]);
            // Inc mem ptr index by width
            pA := pA + baW.bW[bN];
            // Inc screen by 40 to next line
            Inc(pS, 40);
        end;

        // Clear window memory
        FillChar(baW.cM[bN], baW.cZ[bN], 0);

        // Set win mem ptr to prev location
        cpWM := cpWM - baW.cZ[bN];

        // Clear handle
        baW.bU[bN] := WOFF;
        baW.bX[bN] := 0;
        baW.bY[bN] := 0;
        baW.bW[bN] := 0;
        baW.bH[bN] := 0;
        baW.bI[bN] := WOFF;
        baW.cM[bN] := @baWM[0];  // point as base storage
        baW.cZ[bN] := 0;

        // Set return
        Result := 0;
    end;
end;


// --------------------------------------------------
// Function: WStat(bN: Byte): Byte
// Desc....: Tests if window handle is open
// Param...: bN = window handle number
// Returns.: WON (in use)
//           WOFF (not used)
// --------------------------------------------------
function WStat(bN: Byte): Byte;
begin
    Result := baW.bU[bN];
end;


// --------------------------------------------------
// Function: WPos(bN, x, y: Byte): Byte
// Desc....: Moves cursor to x,y in window
//           or x,y of screen
// Param...: bN = window handle number
//                or WPABS for screen
// Returns.: WON (in use)
//           WOFF (not used)
// --------------------------------------------------
function WPos(bN, x, y: Byte): Byte;
begin
    Result := 0;

    // If absolute mode
    if bN = WPABS then
    begin
        // Set screen coords
        vCur.vX := x;
        vCur.vY := y;
    end
    // Window mode
    else begin
        // Only if handle in use
        if baW.bU[bN] = WON then
        begin
            // Set relative window pos
            vCur.vX := baW.bX[bN] + x;
            vCur.vY := baW.bY[bN] + y;
        end;
    end;
end;


// --------------------------------------------------
// Function: WPut(bN: Byte; x: Char): Byte
// Desc....: Puts byte x in window at virtual curs coord
// Param...: bN = window handle number
//            x = ATASCII byte to display (char)
// Returns.: WON (in use)
//           WOFF (not used)
// --------------------------------------------------
function WPut(bN: Byte; x: Char): Byte;
var
    bT: Char;
    cS: Word;
begin
    Result := WENOPN;

    // Set working var
    bT := x;

    // Only if handle is used
    if baW.bU[bN] = WON then
    begin
        // If window is inverse, flip string
        if baW.bI[bN] = WON then
        begin
            bT := Char(Byte(bT) xor 128);
        end;

        // Put byte to screen at current cursor coord
        cS := DPeek(RSCRN) + (vCur.vY * 40) + vCur.vX;
        Poke(cS, CharAI(Byte(x)));

        // Increment virtual cursor by 1
        Inc(vCur.vX);

        // Set return code
        Result := 0;
    end;
end;


// --------------------------------------------------
// Function: WPrint(bN, x, y, bI: Byte; pS: string): Byte
// Desc....: Print text in window at window pos
// Param...: bN = window handle number
//            x = column to print at
//            y = row to print at
//           bI = inverse flag (WON for inverse)
//           pS = text string pointer
// Returns.: 0 if success
//           >100 on error
// Notes...: Test will automatically be inverse if window is inverse.
// --------------------------------------------------
function WPrint(bN, x, y, bI: Byte; pS: string[38]): Byte;
var
    bL, tmp: Byte;
    cS: Word;
    cL: string[129];
begin
    Result := WENOPN;

    // Only if handle is in use
    if baW.bU[bN] = WON then
    begin
        // Copy string to line buffer
        bL := Length(pS);
        SetLength(cL, bL);
        Move(@pS[1], @cL[1], bL);

        // amarok: added checking if x <> WPCNT

        // Ensure text wont overrun
        // Check len not > width-x-1.
        // x is column offset.
        // width includes frames, remove 1
        // instead of 2 due to x as 1 based
        if (x <> WPCNT) and (bL > baW.bW[bN] - x - 1) then
        begin
            // Add terminator, get new length
            bL := baW.bW[bN] - x - 1;
            SetLength(cL, bL);
        end;

        // Convert from ATA to Int
        StrAI(@cL[1], bL);

        // Make inverse if ON
        if (baW.bI[bN] = WON) or (bI = WON) then
        begin
            StrInv(@cL[1], bL);
        end;

        // Find top left corner of window in scrn mem (inside frame)
        cS := DPeek(RSCRN) + (baW.bY[bN] * 40) + baW.bX[bN];

        // Add 40 for each row (Y)
        Inc(cS, y * 40);

        // If not center, move to X pos
        if x <> WPCNT then
        begin
            // Add x for column
            Inc(cS, x);
        end
        // Else move to centered position
        else begin
            Inc(cS, (baW.bW[bN] - bL) div 2);
        end;

        // Move line to screen
        Move(@cL[1], Pointer(cS), bL);

        // Set valid return
        Result := 0;
    end;
end;


// --------------------------------------------------
// Function: WOrn(bN, bT, bL: Byte; pS: string): Byte
// Desc....: Add ornament decor to window
// Param...: bN = window handle number
//           bT = Top or bottom (WPTOP/WPBOT)
//           bL = Position (WPLFT/WPRGT/WPCNT)
//           pS = Text string
// Returns.: 0 if success
//           >100 on error
// Notes...: Max 36 for frame and bookends
// --------------------------------------------------
function WOrn(bN, bT, bL: Byte; pS: string[38]): Byte;
var
    bS: Byte;
    cS: Word;
    cL: string[36];
begin
    Result := WENOPN;

    // Only if handle in use
    if baW.bU[bN] = WON then
    begin
        // Create footer string
        bS := Length(pS) + 2;
        SetLength(cL, bS);
        cL[1] := #4;
        Move(@pS[1], @cL[2], Length(pS));
        cL[bS] := #1;

        // Convert from ATA to Int
        StrAI(@cL[1], bS);

        // If window inverse on, inverse all
        if baW.bI[bN] = WON then
        begin
            StrInv(@cL[1], bS);
        end
        // Else, just inverse title part
        else begin
            // Skip bookends
            StrInv(@cL[2], bS - 2);
        end;

        // Find window top screen location
        cS := DPeek(RSCRN) + (baW.bY[bN] * 40);

        // If bottom find lower location
        if bT = WPBOT then
        begin
            Inc(cS, (baW.bH[bN] - 1) * 40);
        end;

        // If left, add 1 (corner)
        if bL = WPLFT then
        begin
            Inc(cS, baW.bX[bN] + 1);
        end
        // If right, add x + width - length - 1
        else if bL = WPRGT then
        begin
            Inc(cS, baW.bX[bN] + baW.bW[bN] - bS - 1);
        end
        // Else center
        else begin
            Inc(cS, baW.bX[bN] + ((baW.bW[bN] - bS) div 2));
        end;

        // Move ornament to screen
        Move(@cL[1], Pointer(cS), bS);

        // Set valid return
        Result := 0;
    end;
end;

// --------------------------------------------------
// Function: WDiv(bN: Byte, y: Byte, bD: Byte): Byte
// Desc....: Add or remove divider
// Param...: bN = window handle number
//            y = Which row for divider
//           bD = Display On/Off flag
// Returns.: 0 if success
//           >100 on error
// --------------------------------------------------
function WDiv(bN, y, bD: Byte): Byte;
var 
    bR : Byte = WENOPN;
    bS, bL : Byte;
    cS: Word;
    cL: String[41];

begin
    // Only if window open
    if (baW.bU[bN] = WON) then
    begin
        // Get window width
        bS := baW.bW[bN];

        // Create divider string

        // If turning on, set ornaments
        if (bD = WON) then
        begin
            // Set solid line
            FillChar(cL, bS, 82);
            cL[1] := char(65);
            cL[bS] := char(68);
        end
        else begin
            // Set blank line
            FillChar(cL, bS, 0);
            cL[1] := char(124);
            cL[bS] := char(124);
        end;

        // If inverse flag, flip line
        if (baW.bI[bN] = WON) then
        begin
            for bL := 1 to bS do
            begin
                cL[bL] := Char(Byte(cL[bL]) xor 128);    
            end;
        end;

        // Find location on screen
        cS := DPeek(RSCRN) + ((baW.bY[bN] + y) * 40) + baW.bX[bN];

        // Move to screen
        Move(@cL[1], Pointer(cS), bS);


        // Set valid return
        bR := 0;
    end;

    Result := bR;
end;

// --------------------------------------------------
// Function: WClr(bN: Byte): Byte
// Desc....: Clears window contents
// Param...: bN = window handle number
// Returns.: 0 if success
//           >100 on error
// --------------------------------------------------
function WClr(bN: Byte): Byte;

var
    bR : Byte = WENOPN;
    bS, bL : Byte;
    cS: Word;
    cL: String[40 - 2];

begin
    // Only if window in use
    if (baW.bU[bN] = WON) then
    begin
        // Find top left corner of window in screen memory (inside frame)
        cS := DPeek(RSCRN) + (baW.bY[bN] * 40) + baW.bX[bN] + 41;

        // Determine width (minus frames)
        bS := baW.bW[bN] - 2;

        // Set blank line
        FillChar(cL, bS, 0);


        // If window is inverse, flip line
        if (baW.bI[bN] = WON) then
        begin
            StrInv(cL, bS);
        end;

        // Clear window line by line
        for bL := 1 to baW.bH[bN] - 2 do
        begin
            Move(@cL[1], Pointer(cS), bS);
            Inc(cS, 40);    
        end;

        // Set valid return
        bR := 0;
    end;

    Result := bR;
end;

end.