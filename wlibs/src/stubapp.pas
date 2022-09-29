// ------------------------------------------------------------
// Program: stubapp.pas
// Desc...: A8 Library Stub Application
// Author.: Wade Ripkowski, amarok
// Date...: 20220914
// License: GNU General Public License v3.0
// Notes..: mp.exe src\stubapp.pas -ipath:src
//          mads.exe src\stubapp.a65 -x -i:<MadPascalPath>\base -o:bin\stubapp.xex
// ------------------------------------------------------------

// Pull in include files
uses
    a8defines, a8defwin, a8libmisc, a8libstr, a8libwin, a8libgadg, a8libmenu;


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
// Func...: SubMenu3
// Desc...: Sub menu routine
// ------------------------------------------------------------
procedure SubMenu3;
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


var
    // Variables
    bW1, bW2, bC: Byte;
    bD: Boolean;
const
    pcM: array[0..4] of string =
      ( ' Sub-Menu 1 ', ' Sub-Menu 2 ', ' Sub-Menu 3 ', ' About      ', ' Exit       ');
begin
    bD := false;

    // Setup screen
    WInit;

    // Set Background
    WBack(14);

    // Open header window
    bW1 := WOpen(0, 0, 40, 3, WON);
    WPrint(bW1, WPCNT, 1, WOFF, 'A P P L I C A T I O N');

    // Open menu window
    bW2 := WOpen(13, 7, 12, 9, WOFF);
    WOrn(bW2, WPTOP, WPCNT, 'Menu');

    // Loop until done (Exit selected)
    while not bD do
    begin
        // Call menu
        bC := MenuV(bW2, 1, 2, WOFF, 1, 5, pcM);

        // Process choice
        case bC of
            1: GAlert(' Sub-Menu 1 selected. ');
            2: GAlert(' Sub-Menu 2 selected. ');
            3: SubMenu3;
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