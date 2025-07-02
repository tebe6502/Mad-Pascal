
var DL_game: array [0..23] of byte =
    (
    DL_BLANK8, // 8 blank lines
    DL_DLI + DL_BLANK8, // 8 blank lines
    DL_DLI + DL_LMS + DL_MODE_40x24T2, Lo(TXT_RAM), Hi(TXT_RAM), // status
    DL_DLI + DL_BLANK4,
    DL_DLI + DL_LMS + DL_VSCROLL + DL_MODE_40x12T5,  Lo(GFX_RAM), Hi(GFX_RAM), // maze line 1
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5, // 2
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5, // 10
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_DLI + DL_VSCROLL + DL_MODE_40x12T5,
    DL_MODE_40x12T5,
    DL_JVB, Lo(DLG), Hi(DLG) // jump to start
    );


var DL_LEVEL: array [0..31] of byte =
    (
    DL_BLANK8, // 8 blank lines
    DL_BLANK8, // 8 blank lines
    DL_BLANK8, // 8 blank lines
    DL_LMS + DL_MODE_40x24G4, Lo(TXT_RAM), Hi(TXT_RAM),
    DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4,
    DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4,
    DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4,
    DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4,
    DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4,
    DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4, DL_MODE_40x24G4,
    DL_JVB, Lo(DL), Hi(DL) // jump to start
    );

var DL_TITLE: array [0..57] of byte =
    (
    DL_BLANK8, // 8 blank lines
    DL_DLI + DL_BLANK8, // 8 blank lines
    DL_LMS + DL_MODE_40x24T2, Lo(TXT_RAM), Hi(TXT_RAM),
    DL_DLI + DL_BLANK4, // 8 blank lines
    DL_LMS + DL_MODE_160x96G4,  Lo(LOGO_ADDRESS), Hi(LOGO_ADDRESS),
    $D, $D, $D, $D, $D, $D, $D, $D, $D, $D, $D, $D, $D,
    $D, $D, $D, $D, $D, $D, $D, $D, $D, $D, $D, $D, $D,
    DL_BLANK8, // 8 blank lines
    DL_DLI + DL_BLANK8, // 8 blank lines
    DL_LMS + DL_MODE_40x24T2, Lo(TXT_RAM+40), Hi(TXT_RAM+40),
    2,2,2,2,2,2,2,2,2,2,2,DL_DLI + 2,2,2,2,
    DL_JVB, Lo(DL), Hi(DL) // jump to start
    );

