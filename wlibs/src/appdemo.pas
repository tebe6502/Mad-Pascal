// ------------------------------------------------------------
// Program: appdemo.pas
// Desc...: A8 Library Demo Application
// Author.: Wade Ripkowski, amarok
// Date...: 20220914
// License: GNU General Public License v3.0
// Notes..: mp.exe src\appdemo.pas -ipath:src
//          mads.exe src\appdemo.a65 -x -i:<MadPascalPath>\base -o:bin\appdemo.xex
// ------------------------------------------------------------

// Pull in include files
uses
    Crt, a8defines, a8defwin, a8libmisc, a8libstr, a8libwin, a8libgadg, a8libmenu;


// ------------------------------------------------------------
// Func...: FormInput: Boolean
// Desc...: Demo use of input gadgets
// Returns: TRUE if accepted, else FALSE
// Notes..: Maximum local variable stack space is 256 bytes.
//          MUST use pragma static-locals to move variables to
//          BSS segment due to total size in this function.
// ------------------------------------------------------------
function FormInput: Boolean;
var
    bRA, bRB, bChap, bChbp, bChcp, bV: Byte;
    bW1, bM, bA, bB, bC, bD, bVp, bRAp, bRBp, bCha, bChb, bChc: Byte;
    
    // Input strings & navigation strings
    cA, cB, cC, cD: string[41];
    cF, cI, cR, cX: string[15];
const
    // Regular buttons, radio buttons, and data field names
    paB: array[0..1] of string = ('[ Ok ]', '[Cancel]');
    prA: array[0..2] of string = ('One', 'Two', 'Three');
    prB: array[0..2] of string = ('Choice A', 'Choice B', 'Choice C');
begin
    Result := false;
    bRA := 1;
    bRB := 1;
    bChap := GCOFF;
    bChbp := GCON;
    bChcp := GCOFF;
    bV := 10;

    // Define navigation strings
    cF := 'Nav:          ';
    cF[5] := CHUP;
    cF[6] := CHDN;
    cF[7] := CHLFT;
    cF[8] := CHRGT;
    cF[9] := CHTAB;
    cF[10] := CHESC;
    cF[11] := CHBTRGT;

    cI := 'Nav:    ^cS^cE';
    cI[5] := CHLFT;
    cI[6] := CHRGT;
    cI[7] := CHESC;
    cI[8] := CHBTRGT;

    cR := 'Nav:          ';
    cR[5] := CHUP;
    cR[6] := CHDN;
    cR[7] := CHLFT;
    cR[8] := CHRGT;
    cR[9] := CHTAB;
    cR[10] := CHESC;
    cR[12] := CHBTRGT;

    cX := 'Nav:X         ';
    cX[7] := CHTAB;
    cX[8] := CHESC;
    cX[9] := CHBTRGT;
    
    // Define input string defaults
    cA := '-100.00                                 ';
    cB := 'This string has something to edit in it!';
    cC := '                                        ';
    cD := ' Any character string!                  ';
    cD[1] := CHBALL;
    cD[23] := CHBALL;

    // Set radio button and spinner previous selection defaults
    bRAp := bRA;
    bRBp := bRB;
    bVp := bV;

    // Open window & draw form
    bW1 := WOpen(2, 4, 36, 18, WOFF);
    WOrn(bW1, WPTOP, WPLFT, 'Input Form');
    WOrn(bW1, WPTOP, WPRGT, 'Edit');
    WOrn(bW1, WPBOT, WPLFT, cF);

    WPrint(bW1, 1, 1, WOFF, 'Data Fields');
    WPrint(bW1, 2, 2, WOFF, 'Numer:');
    WPrint(bW1, 2, 3, WOFF, 'Alpha:');
    WPrint(bW1, 2, 4, WOFF, 'AlNum:');
    WPrint(bW1, 2, 5, WOFF, 'Any..:');
    WPrint(bW1, 2, 6, WOFF, 'Spin.:');
    GSpin(bW1, 8, 6, 0, 100, bVp, GDISP);

    WPrint(bW1, 1, 8, WOFF, 'Radio Buttons (h)');
    GRadio(bW1, 2, 9, GHORZ, GDISP, bRAp, 3, prA);

    WPrint(bW1, 1, 11, WOFF, 'Radio Buttons (v)');
    GRadio(bW1, 2, 12, GVERT, GDISP, bRBp, 3, prB);

    WPrint(bW1, 20, 11, WOFF, 'Check Boxes');
    WPrint(bW1, 25, 12, WOFF, 'Milk');
    WPrint(bW1, 25, 13, WOFF, 'Bread');
    WPrint(bW1, 25, 14, WOFF, 'Butter');
    GCheck(bW1, 21, 12, GDISP, bChap);
    GCheck(bW1, 21, 13, GDISP, bChbp);
    GCheck(bW1, 21, 14, GDISP, bChcp);

    GButton(bW1, 21, 16, GDISP, 2, paB);

    // Display fields as is
    WPrint(bW1, 8, 2, WOFF, cA);
    WPrint(bW1, 8, 3, WOFF, cB);
    WPrint(bW1, 8, 4, WOFF, cC);
    WPrint(bW1, 8, 5, WOFF, cD);

    // Loop until form accepted
    repeat
        // ----- Display Input Fields -----
        // Show navigation info
        WOrn(bW1, WPBOT, WPLFT, cI);

        // Edit fields
        bA := GInput(bW1, 8, 2, GNUMER, 27, cA);
        bB := GInput(bW1, 8, 3, GALPHA, 27, cB);
        bC := GInput(bW1, 8, 4, GALNUM, 27, cC);
        bD := GInput(bW1, 8, 5, GANY, 27, cD);

        // ----- Spinner Input -----
        bV := GSpin(bW1, 8, 6, 0, 100, bVp, GEDIT);
        if (bV <> XESC) and (bV <> XTAB) then
        begin
            bVp := bV;
        end;

        // ----- Display Radio Buttons - horizontal -----
        // Show navigation info
        WOrn(bW1, WPBOT, WPLFT, cR);

        // Process buttons
        bRA := GRadio(bW1, 2, 9, GHORZ, GEDIT, bRAp, 3, prA);

        // If not bypass, set previous selected value
        if (bRA <> XESC) and (bRA <> XTAB) then
        begin
            bRAp := bRA;
        end;

        // Redisplay buttons
        GRadio(bW1, 2, 9, GHORZ, GDISP, bRAp, 3, prA);

        // ----- Display Radio Buttons - vertical -----
        bRB := GRadio(bW1, 2, 12, GVERT, GEDIT, bRBp, 3, prB);

        // If not bypass, set previous selected value
        if (bRB <> XESC) and (bRB <> XTAB) then
        begin
            bRBp := bRB;
        end;

        // Redisplay buttons
        GRadio(bW1, 2, 12, GVERT, GDISP, bRBp, 3, prB);

        // ----- Display Check Boxes -----
        // Set footer
        WOrn(bW1, WPBOT, WPLFT, cX);

        // Stay on this check until ESC, TAB, or set
        repeat
            // Display button and get choice
            bCha := GCheck(bW1, 21, 12, GEDIT, bChap);

            // If not ESC or TAB, set previous value
            if (bCha <> XESC) and (bCha <> XTAB) then
            begin
                bChap := bCha;
            end;
        until (bCha = XESC) or (bCha = XTAB);

        // Stay on this check until ESC, TAB, or set
        repeat
            // Display button and get choice
            bChb := GCheck(bW1, 21, 13, GEDIT, bChbp);

            // If not ESC or TAB, set previous value
            if (bChb <> XESC) and (bChb <> XTAB) then
            begin
                bChbp := bChb;
            end;
        until (bChb = XESC) or (bChb = XTAB);

        // Stay on this check until ESC, TAB, or set
        repeat
            // Display button and get choice
            bChc := GCheck(bW1, 21, 14, GEDIT, bChcp);

            // If not ESC or TAB, set previous value
            if (bChc <> XESC) and (bChc <> XTAB) then
            begin
                bChcp := bChc;
            end;
        until (bChc = XESC) or (bChc = XTAB);

        // Set footer
        WOrn(bW1, WPBOT, WPLFT, cF);

        // Prompt to accept form and redisplay buttons
        bM := GButton(bW1, 21, 16, GEDIT, 2, paB);
        GButton(bW1, 21, 16, GDISP, 2, paB);
    until bM <> XTAB;

    // Check for acceptance (OK button), and set exit flag
    if bM = 1 then
    begin
        Result := true;
        GAlert('Doing something with entered data...');
    end;

    // Close window
    WClose(bW1);
end;

// ------------------------------------------------------------
// Func...: ProgTest
// Desc...: Demos window status and progress bar.
// ------------------------------------------------------------
procedure ProgTest;
var
    bW1, bW2, bL, bS: Byte;
    iV: Word;
begin
    // Open status window
    bW1 := WOpen(9, 2, 20, 14, WOFF);
    WOrn(bW1, WPTOP, WPLFT, 'Status');
    WPrint(bW1, 1, 1, WOFF, 'Window Status');
    WPrint(bW1, 1, 2, WOFF, '------ ------');

    // Open progress bar window
    bW2 := WOpen(7, 18, 24, 4, WOFF);
    WPrint(bW2, 2, 1, WOFF, 'Progress:');

    // Display initial progress bar
    GProg(bW2, 2, 2, 0);

    // Loop through each window handle
    for bL := 0 to 9 do
    begin
        // Get the window status
        bS := WStat(bL);

        // Print the window handle #
        WPos(bW1, 6, 3 + bL);
        WPut(bW1, Char(bL + 48));

        // Print the window handle status
        if bs = WON then
        begin
            WPrint(bW1, 8, 3 + bL, WOFF, 'Used');
        end
        else begin
            WPrint(bW1, 8, 3 + bL, WOFF, 'Free');
        end;

        // Update progress bar
        iV := ((bL + 1) mod 10) * 10;
        if iV = 0 then
        begin
            iV := 100;
        end;
        GProg(bW2, 2, 2, iV);

        // Wait 1 second
        Delay(1000);
    end;

    GAlert(' Press a key to continue. ');

    // Close windows
    WClose(bW2);
    WClose(bW1);
end;


// ------------------------------------------------------------
// Func...: About
// Desc...: About Dialog
// ------------------------------------------------------------
procedure About;
var
    bW1: Byte;
begin
    // Show window
    bW1 := WOpen(1, 6, 38, 15, WOFF);
    WOrn(bW1, WPTOP, WPLFT, 'About');
    WPrint(bW1, WPCNT,  1, WOFF, 'Demo Application');
    WPrint(bW1, WPCNT,  2, WOFF, 'Version 1.00-PAS');
    WPrint(bW1, WPCNT,  3, WOFF, '(C) 2022  Wade Ripkowski, amarok');
    WPrint(bW1, WPCNT,  5, WOFF, 'Application to demonstrate');
    WPrint(bW1, WPCNT,  6, WOFF, 'the MadPascal library.');
    WPrint(bW1, WPCNT,  7, WOFF, 'Converted from C.');
    WPrint(bW1, 4,      9, WOFF, 'V1-2021-Atari8: Action!');
    WPrint(bW1, 2,     10, WOFF, 'V1-C-2022-Atari8: C (CC65)');
    WPrint(bW1, 2,     11, WOFF, 'V1-PAS-2022-Atari8: PAS (MadPascal)');
    WPrint(bW1, WPCNT, 13, WON,  ' Ok ');

    // Wait for key
    WaitKCX(WOFF);

    // Close window
    WClose(bW1);
end;


// ------------------------------------------------------------
// Func...: SubMenu
// Desc...: Sub menu routine
// ------------------------------------------------------------
procedure SubMenu;
var
    bW1, bC: Byte;
    bD: Boolean;
const
    pcM: array[0..2] of string = (' Sub-Item 1 ', ' Sub-Item 2 ', ' Sub-Item 3 ');

begin
    bD := false;

    // Open window
    bW1 := WOpen(16, 10, 14, 5, WOFF);
    WOrn(bW1, WPTOP, WPLFT, 'Sub-Menu');

    // Loop until exit
    while not bD do
    begin
        // Display menu and get choice
        bC := MenuV(bW1, 1, 1, WOFF, 1, 3, pcM);

        // Process choice
        case bC of
            1: GAlert(' Sub-Item 1 selected. ');
            2: GAlert(' Sub-Item 2 selected. ');
            3: GAlert(' Sub-Item 3 selected. ');
            XESC: bD := true;
        end;
    end;

    // Close window
    WClose(bW1);
end;


// Variables
var
    bW1, bW2, bC: Byte;
    bD: Boolean;
const
    pcM: array[0..4] of string =
      (' Input Form   ', ' Progress Bar ', ' Sub-Menu     ', ' About        ', ' Exit         ');
begin
    bD := false;

    // Setup screen
    WInit;
    WBack(14);

    // Open header window
    bW1 := WOpen(0, 0, 40, 3, WON);
    WPrint(bW1, WPCNT, 1, WOFF, 'D E M O N S T R A T I O N');

    // Open menu window
    bW2 := WOpen(12, 7, 16, 9, WOFF);
    WOrn(bW2, WPTOP, WPCNT, 'Menu');

    // Loop until done (Exit selected)
    while not bD do
    begin
        // Call menu
        bC := MenuV(bW2, 1, 2, WON, 1, 5, pcM);

        // Process choice
        case bC of
            1: FormInput;
            2: ProgTest;
            3: SubMenu;
            4: About;
            5: bD := true;
        end;

        // Exit on ESC as well
        if bC = XESC then
        begin
            bD := true;
        end;
    end;

    // Close windows
    WClose(bW2);
    WClose(bW1);
end.