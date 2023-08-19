// ------------------------------------------------------------
// Program: stubwin.c
// Desc...: A8 Library Stub Window Program
// Author.: Wade Ripkowski, amarok
// Date...: 20220914
// License: GNU General Public License v3.0
// Notes..: mp.exe src\stubwin.pas -ipath:src
//          mads.exe src\stubwin.a65 -x -i:<MadPascalPath>\base -o:bin\stubwin.xex
// ------------------------------------------------------------

// Pull in include files
uses
    a8defines, a8defwin, a8libwin, a8libmisc;


var
    // Variables
    bW1: Byte;
  
begin
    // Init Window System
    WInit;

    // Open window
    bW1 := WOpen(8, 5, 24, 9, WOFF);
    WOrn(bW1, WPTOP, WPLFT, 'Stub');
    WPrint(bW1, 5, 2, WOFF, 'Inverse');
    WPrint(bW1, 12, 2, WON, 'ATASCII');
    WPrint(bW1, WPCNT, 4, WOFF, 'Unfinished Bitness');
    WPrint(bW1, WPCNT, 6, WON, ' Ok ');

    // Wait for a keystroke or console key
    WaitKCX(WOFF);

    // Close window
    WClose(bW1);
end.