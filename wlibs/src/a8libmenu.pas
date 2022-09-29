// --------------------------------------------------
// Library: a8libmenu.pas
// Desc...: Atari 8 Bit Menu Library
// Author.: Wade Ripkowski, amarok
// Date...: 2022.09
// License: GNU General Public License v3.0
// Note...: Requires: a8defines.pas
//          -Converted from C
// Require: a8libwin.pas
//          a8libstr.pas
//          a8libmisc.pas
// Revised:
// --------------------------------------------------

unit a8libmenu;

interface

// --------------------------------------------------
// Includes
// --------------------------------------------------
uses
    a8defines, a8defwin;


// --------------------------------------------------
// Function Prototypes
// --------------------------------------------------
function MenuV(bN, x, y, bI, bS, bC: Byte; pS: TStringArray): Byte;


implementation

uses
    a8libwin, a8libmisc;

// ------------------------------------------------------------
// Func...: MenuV(bN, x, y, bI, bS, bC: Byte; pS: TStringArray): Byte
// Desc...: Vertical menu
// Param..: bN = Window handle number
//           x = window column for cursor
//           y = window row for cursor
//          bI = Inverse flag (WON = leave on at selection)
//          bS = Start item number
//          bC = Number of menu items
//          pS = pointer to array of menu item strings
// Return.: Selected item #, ESC (XESC), or TAB (XTAB)
// ------------------------------------------------------------
function MenuV(bN, x, y, bI, bS, bC: Byte; pS: TStringArray): Byte;
var
    bF: Boolean;
    bL, bK, tmp: Byte;
    cL: string[39];
    tmpStr: string;
begin
    bF := false;

    // Set default return to start item #
    Result := bS;

    // Continue until finished
    while not bF do
    begin
        // Display each item
        for bL := 0 to bC - 1 do
        begin
            tmpStr := pS[bL];
            SetLength(cL, Length(tmpStr));
            Move(@tmpStr[1], @cL[1], Length(cL));

            // Display item at row count - inverse if start item
            if bL + 1 = Result then
            begin
                tmp := WON;
            end
            else begin
                tmp := WOFF;
            end;
            WPrint(bN, x, y + bL, tmp, cL);
        end;

        // Get key (no inverse key)
        bK := WaitKCX(WOFF);

        // Process key
        if (bK = KDOWN) or (bK = KEQUAL) or (bK = KRIGHT) or (bK = KASTER) then
        begin
            // Increment (move down list)
            Inc(Result);

            // Check for overrun and roll to top
            if Result > bC then
            begin
                Result := 1;
            end;
        end
        else if (bK = KUP) or (bK = KMINUS) or (bK = KLEFT) or (bK = KPLUS) then
        begin
            // Decrement (move up list)
            Dec(Result);

            // Check for underrun and roll to bottom
            if Result < 1 then
            begin
                Result := bC;
            end;
        end;

        // Set last selected item before checking for ESC/TAB/ENTER
        bL := Result;

        // If ESC, set choice to XESC
        if bK = KESC then
        begin
            Result := XESC;
            bF := true;
        end
        // For TAB, set choice to XTAB
        else if bK = KTAB then
        begin
            Result := XTAB;
            bF := true;
        end
        // For enter, just exit
        else if bK = KENTER then
        begin
            bF := true;
        end;
    end;

    // Uninverse last selection if needed
    if bI = WOFF then
    begin
        tmpStr := pS[bL - 1];
        SetLength(cL, Length(tmpStr));
        Move(@tmpStr[1], @cL[1], Length(cL));
        WPrint(bN, x, y + bL - 1, WOFF, cL);
    end;
end;

end.