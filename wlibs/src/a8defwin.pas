// Library: a8defwin.pas
// Desc...: Atari 8 Bit Library Global Window definitions
// Author.: Wade Ripkowski, amarok
// Date...: 2022.09
// License: GNU General Public License v3.0
// Note...: Requires: a8defines.pas
//          -Converted from C
// Revised:

unit a8defwin;

interface

uses
    a8defines;

type
    // Window handle info
    td_wnrec = record
        bU, bX, bY, bW, bH, bI: array[0..WRECSZ] of Byte;
        cM: array[0..WRECSZ] of ^Byte;
        cZ: array[0..WRECSZ] of Word;
    end;

    // Window position - virtual cursor
    td_wnpos = record
        vX, vY: Byte;
    end;

    TStringArray = array[0..0] of String[40];

implementation

end.