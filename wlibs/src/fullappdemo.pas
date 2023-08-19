// ------------------------------------------------------------
// Program: fullappdemo.pas
// Desc...: A8 Library Demo Application
// Author.: Wade Ripkowski, amarok, MADRAFi
// Date...: 2023.03
// License: GNU General Public License v3.0
// Notes..: mp.exe src\fullappdemo.pas -ipath:src
//          mads.exe src\fullappdemo.a65 -x -i:<MadPascalPath>\base -o:bin\fullappdemo.xex
// ------------------------------------------------------------

// Pull in include files
uses
    crt, sysutils, a8defines, a8defwin, a8libmisc, a8libstr, a8libwin, a8libgadg, a8libmenu;

// Variables
var
    bW1, bW2, bC: Byte;
    bE: Boolean;

const
    pcM: array[0..2] of string =
      (' Main ', ' Sub-Menu ', ' About ');


// ------------------------------------------------------------
// Func...: FileInput: Boolean
// Desc...: Demo use of input gadgets
// Returns: TRUE if accepted, else FALSE
// ------------------------------------------------------------
function FileInput: Boolean;

const
    list_drives: array[0..7] of string = ('D1:', 'D2:', 'D3:', 'D4:', 'D5:', 'D6:', 'D7:', 'D8:');
    buttons : array[0..1] of string = ('[  OK  ]', '[Cancel]');
    list_files: array[0..9] of string = ('FILE.XEX', 'FILE2.TXT', 'FILE3.DAT', 'CORE.BIN', 'FILE555.BIN', 'FILE6.BIN', 'FILE77.BIN', 'FILE8.BIN', 'FILE999.BIN', 'FILE101010.BIN');
    FILE_SIZE = 12;

var
    win_file: Byte;
    read_drive, selected_drive: Byte;
    read_file: Byte;
    selected_file: String[FILE_SIZE];
    selected_list: Byte;
    read_list: Byte;
    bM: Byte;
    i, tmp: Byte;    

begin
    Result:= false;
    selected_drive:=1;
    selected_list:=1;
    // selected_file:='            ';
    selected_file:= list_files[selected_list - 1];
    tmp:= Length(selected_file);
    SetLength(selected_file, FILE_SIZE);
    FillChar(@selected_file[tmp + 1], FILE_SIZE - tmp, CHSPACE );
    
    win_file:=WOpen(5, 4, 30, 16, WOFF);
    WOrn(win_file, WPTOP, WPLFT, 'Choose a file');


    WPrint(win_file, 2, 2, WOFF, 'File:');
    WDiv(win_file, 3, WON);

    WPrint(win_file, 21, 4, WOFF, 'Drive:');
    GCombo(win_file, 21, 5, GDISP, selected_drive, 8, list_drives);
    
    WPrint(win_file, 2, 4, WOFF, 'List:');
    GList(win_file, 2, 5, GDISP, selected_list, 8, Length(list_files), list_files);

    GButton(win_file, 19, 11, GVERT, GDISP, 2, buttons);
    repeat

        // file
        read_file:= GInput(win_file, 8, 2, GFILE, 12, selected_file);
        if (read_file <> XESC) then
        begin
            for i:=0 to Length(list_files) - 1 do
            begin
                if list_files[i] = Trim(selected_file) then
                begin
                    selected_list:= i + 1;
                    GList(win_file, 2, 5, GDISP, selected_list, 8, Length(list_files), list_files);
                end;
            end; 
        end
        else if (read_file = XESC) then 
        begin
            bM:= XESC;
            break;
        end;

        // Drives combo
        read_drive:= GCombo(win_file, 21, 5, GEDIT, selected_drive, 8, list_drives);
        if (read_drive <> XESC) then
        begin
            selected_drive := read_drive;
        end
        else if (read_drive = XESC) then 
        begin
            bM:= XESC;
            break;
        end;

        GCombo(win_file, 21, 5, GDISP, selected_drive, 8, list_drives);

        // Files List
        read_list:= GList(win_file, 2, 5, GEDIT, selected_list, 8, Length(list_files), list_files);
        if (read_list <> XESC) then
        begin
            selected_list := read_list;
            selected_file:= list_files[selected_list - 1];
            tmp:= Length(selected_file);
            SetLength(selected_file, FILE_SIZE);
            FillChar(@selected_file[tmp + 1], FILE_SIZE - tmp, CHSPACE );
            WPrint(win_file, 8, 2, WOFF, selected_file);
        end
        else if (read_list = XESC) then 
        begin
            bM:= XESC;
            break;
        end;

        GList(win_file, 2, 5, GDISP, selected_list, 8, Length(list_files), list_files);

        // Buttons to confirm
        bM := GButton(win_file, 19, 11, GVERT, GEDIT, 2, buttons);    
        GButton(win_file, 19, 11, GVERT, GDISP, 2, buttons);

    until bM <> XTAB;

    if bM = 1 then
    begin
        Result:=true;
        GAlert(Concat(Concat('Processing...', list_drives[selected_drive - 1]), selected_file));
    end;

      WClose(win_file);
end;


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
    bW1 := WOpen(2, 3, 36, 18, WOFF);
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

    GButton(bW1, 21, 16, GHORZ, GDISP, 2, paB);

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
        if (bA = XESC) then
        begin
            bM:= XESC;
            break;
        end;
        bB := GInput(bW1, 8, 3, GALPHA, 27, cB);
        if (bB = XESC) then
        begin
            bM:= XESC;
            break;
        end;
        bC := GInput(bW1, 8, 4, GALNUM, 27, cC);
        if (bC = XESC) then
        begin
            bM:= XESC;
            break;
        end;
        bD := GInput(bW1, 8, 5, GANY, 27, cD);
        if (bD = XESC) then
        begin
            bM:= XESC;
            break;
        end;
        // ----- Spinner Input -----
        bV := GSpin(bW1, 8, 6, 0, 100, bVp, GEDIT);
        if (bV <> XESC) then
        begin
            bVp := bV;
        end
        else if (bV = XESC) then 
        begin
            bM:= XESC;
            break;
        end;

        // ----- Display Radio Buttons - horizontal -----
        // Show navigation info
        WOrn(bW1, WPBOT, WPLFT, cR);

        // Process buttons
        bRA := GRadio(bW1, 2, 9, GHORZ, GEDIT, bRAp, 3, prA);

        // If not bypass, set previous selected value
        if (bRA <> XESC) then
        begin
            bRAp := bRA;
        end
        else if (bRA = XESC) then 
        begin
            bM:= XESC;
            break;
        end;

        // Redisplay buttons
        GRadio(bW1, 2, 9, GHORZ, GDISP, bRAp, 3, prA);

        // ----- Display Radio Buttons - vertical -----
        bRB := GRadio(bW1, 2, 12, GVERT, GEDIT, bRBp, 3, prB);

        // If not bypass, set previous selected value
        if (bRB <> XESC) then
        begin
            bRBp := bRB;
        end
        else if (bRB = XESC) then 
        begin
            bM:= XESC;
            break;
        end;

        // Redisplay buttons
        GRadio(bW1, 2, 12, GVERT, GDISP, bRBp, 3, prB);

        // ----- Display Check Boxes -----
        // Set footer
        WOrn(bW1, WPBOT, WPLFT, cX);

        // Stay on this check until ESC, TAB, or set
        // repeat
            // Display button and get choice
            bCha := GCheck(bW1, 21, 12, GEDIT, bChap);

            // If not ESC or TAB, set previous value
            if (bCha <> XESC) and (bCha <> XTAB) then
            begin
                bChap := bCha;
            end
            else if (bCha = XESC) then 
            begin
                bM:= XESC;
                break;
            end;
        // until (bCha = XESC) or (bCha = XTAB) or (bCha = XNONE);

        // Stay on this check until ESC, TAB, or set
        // repeat
            // Display button and get choice
            bChb := GCheck(bW1, 21, 13, GEDIT, bChbp);

            // If not ESC or TAB, set previous value
            if (bChb <> XESC) then
            begin
                bChbp := bChb;
            end
            else if (bChb = XESC) then 
            begin
                bM:= XESC;
                break;
            end;
        // until (bChb = XESC) or (bChb = XTAB) or (bCha = XNONE);

        // Stay on this check until ESC, TAB, or set
        // repeat
            // Display button and get choice
            bChc := GCheck(bW1, 21, 14, GEDIT, bChcp);

            // If not ESC or TAB, set previous value
            if (bChc <> XESC) then
            begin
                bChcp := bChc;
            end
            else if (bChc = XESC) then 
            begin
                bM:= XESC;
                break;
            end;
        // until (bChc = XESC) or (bChc = XTAB) or (bCha = XNONE);

        // Set footer
        WOrn(bW1, WPBOT, WPLFT, cF);

        // Prompt to accept form and redisplay buttons
        bM := GButton(bW1, 21, 16, GHORZ, GEDIT, 2, paB);
        GButton(bW1, 21, 16, GHORZ, GDISP, 2, paB);
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
    bW1 := WOpen(10, 3, 20, 14, WOFF);
    WOrn(bW1, WPTOP, WPLFT, 'Status');
    WPrint(bW1, 1, 1, WOFF, 'Window Status');
    WPrint(bW1, 1, 2, WOFF, '------ ------');

    // Open progress bar window
    bW2 := WOpen(8, 17, 24, 4, WOFF);
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
    WClr(bW1);
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
    bW1 := WOpen(1, 5, 38, 15, WOFF);
    WOrn(bW1, WPTOP, WPLFT, 'About');
    WPrint(bW1, WPCNT,  1, WOFF, 'Full Application Demo');
    WPrint(bW1, WPCNT,  2, WOFF, 'Version 1.10-PAS');
    WPrint(bW1, WPCNT,  4, WOFF, '(C) 2022-2023 Wade Ripkowski,');
    WPrint(bW1, WPCNT,  5, WOFF, 'amarok, MADRAFi');
    WPrint(bW1, WPCNT,  7, WOFF, 'Application to demonstrate');
    WPrint(bW1, WPCNT,  8, WOFF, 'the MadPascal library.');
    WPrint(bW1, WPCNT,  10, WOFF, '');
    WPrint(bW1, 2,     11, WOFF, 'V1-PAS-2023-Atari8: PAS (MadPascal)');
    WPrint(bW1, WPCNT, 13, WON,  '[  Ok  ]');

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
    bC := 1;
    // Open window
    bW1 := WOpen(8, 3, 14, 5, WOFF);

    // Loop until exit
    while not bD do
    begin
        // Display menu and get choice
        bC := WMenu(bW1, 1, 1, GVERT, WOFF, bC, 3, pcM);

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

// ------------------------------------------------------------
// Func...: MainMenu
// Desc...: Main menu routine
// ------------------------------------------------------------
procedure MainMenu;
var
    bW1, bC: Byte;
    bD: Boolean;
const
    pcM: array[0..3] of string = (' File     ', ' Input    ', ' Progress ', ' Exit     ');

begin
    bD := false;
    bC := 1;
    // Open window
    bW1 := WOpen(1, 3, 12, 6, WOFF);

    // Loop until exit
    while not bD do
    begin
        // Display menu and get choice
        bC := WMenu(bW1, 1, 1, GVERT, WON, bC, 4, pcM);

        // Process choice
        case bC of
            1: FileInput;
            2: FormInput;
            3: if GConfirm('Are you sure?') then ProgTest;
            4:  begin
                    bE := true;
                    bD := true;
                end;
            XESC: bD := true;
        end;
    end;

    // Close window
    WClose(bW1);
end;

begin
    bE := false;
    bC := 1;
    // Setup screen
    WInit;
    WBack($2E);

    // Open menu window
    bW1 := WOpen(0, 0, 40, 3, WOFF);
    

    // Open header window
    bW2 := WOpen(0, 21, 40, 3, WON);
    WPrint(bW2, WPCNT, 1, WOFF, 'D E M O N S T R A T I O N');

    // Loop until done (Exit selected)
    while not bE do
    begin
        // Call menu
        bC := WMenu(bW1, 1, 1, GHORZ, WON, bC, 3, pcM);

        // Process choice
        case bC of
            1: MainMenu;
            2: SubMenu;
            3: About;
        end;

        // Exit on ESC as well
        if bC = XESC then
        begin
            bE := true;
        end;
    end;

    // Close windows
    WClose(bW2);
    WClose(bW1);
end.