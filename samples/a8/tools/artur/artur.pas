program artur_atascii_art_editor;
{$librarypath 'blibs'}
uses atari, crt, b_crt, b_system, b_pmg, sysutils, joystick; 

const
{$i const.inc}
{$r resources.rc}
{$i interrupts.inc}
{$I-}


type TConfig = record
    editorBackgroundColor:byte;
    editorForegroundColor:byte;
    arrowsRaw:boolean;
    keyCodeDisplay:byte;
end;

var
    version: string[5] = '0.88'~*;
    config: TConfig;
    b: byte;
    h,w: byte;
    s: string[40];
    c: char;
    key: byte;
    afile: file;
    joyX: shortInt = 0;
    joyY: shortInt = 0;
    joyFire: byte = 1;
    brush: byte = 128;
    keyRepeatCounter: byte = 20;
    oldvbl:pointer = @oldvbl; // value set only to bypass compiler warning
    olddli:pointer = @olddli; // value set only to bypass compiler warning
    mode:byte = MODE_TYPE;
    drawTool:byte = TOOL_DRAW;
    cursorX, cursorY: byte;
    cursor: word; // video memory offset
    cursorChar: byte;
    
    keyDown: boolean = false;
    penDown: boolean = false;
    invert: boolean = false;
    cursorForward: boolean = false;
    statusCustomCharset: boolean = false;
    
    editorCharset: byte;   // upper byte
    p1x: byte = NONE; // selection
    p2x: byte = NONE;
    p1y,p2y: byte; 
    brushHistory: array [0..MAX_BRUSH_HISTORY] of byte;
    brushIndex: byte;
    brushFramePosX: byte;  // pmg frame offset
    
    keychars: array [0..0] of byte absolute KEY_MAP;  // Key 2 char mapping table
    undoBuffers: array [0..FULLSCREEN_UNDO_COUNT-1] of pointer;
    undoActions: array [0..(UNDO_ACTIONS_COUNT-1),0..2] of byte;
    undoBufferIdx: byte = 0;
    undoActionsIdx: byte = 0;
    redoCount: byte = 0;
    
    lineOffset: array [0..23] of word = (
    0, 40, 80, 120, 160,
    200, 240, 280, 320, 360,
    400, 440, 480, 520, 560,
    600, 640, 680, 720, 760,
    800, 840, 880, 920
    );

// ********************************************************
// ******************************************************** GENERAL HELPERS
// ********************************************************


procedure AdjustBrushFrame;
begin
    brushFramePosX := 201 - (brushIndex shl 2);
end;

procedure Swap(var a:byte; var b: byte);
var c:byte;
begin
    c := a;
    a := b;
    b := c;
end;

procedure AddDriveToS;
var l:byte;
begin
    l:=byte(s[0])+2;
    s[0]:=char(l);
    move(s[1],s[3],l);
    s[1]:='D';
    s[2]:=':';
end;

function Hex2DecDigit(c:char): byte;
begin
    result:= $ff;
    case c of
        '0'~..'9'~: result := byte(c) - 16;
        'a'~..'f'~: result := byte(c) - 87;
        'A'~..'F'~: result := byte(c) - 23;
    end;
end;

procedure ParseHex(var i:byte; var err: byte);
var pos,digit,base:byte;
begin
    err := 0;
    i := 0;
    base := 0;
    pos := byte(s[0]);
    repeat
        digit := Hex2DecDigit(s[pos]);
        if digit = $ff then begin
            err := 1;
            exit;
        end;
        i := i + digit shl base;
        inc(base, 4);
        Dec(pos);
    until pos = 0;
end;

procedure ReadJoystick;
begin
    joyX := 0;
    joyY := 0;
    if (stick0 and 1) = 0 then joyY := -1; // up
    if (stick0 and 2) = 0 then joyY := 1;  // down
    if (stick0 and 4) = 0 then joyX := -1; // left
    if (stick0 and 8) = 0 then joyX := 1;  // right
    joyFire := strig0;
end;

procedure InitPMG;
var frame: array [0..5] of byte = (
    %00111111,
    %00100001,
    %00100001,
    %00100001,
    %00100001,
    %00111111
    );
    pmgSettings: array [0..12] of byte = (
    PMG_XOFFSET + 1 * 32,   // players hpos
    PMG_XOFFSET + 2 * 32,
    PMG_XOFFSET + 3 * 32,
    PMG_XOFFSET + 4 * 32,
    PMG_XOFFSET + 24,       // missiles hpos
    PMG_XOFFSET + 16,
    PMG_XOFFSET + 8,
    PMG_XOFFSET,
    PMG_SIZE_x4, // player & missile sizes
    PMG_SIZE_x4,
    PMG_SIZE_x4,
    PMG_SIZE_x4,
    $ff
    );
begin
    PMG_Init(Hi(PMG));
    PMG_gprior_S := %00000001;
    Move(pmgSettings,@PMG_hpos0,13); // init settings
    move(frame,pointer(PMG+$380+112),6); // draw frame
end;

// ********************************************************
// ******************************************************** UNDO OPERATIONS 
// ********************************************************


function NextAction:byte;
begin
    result := undoActionsIdx + 1;
    if result = UNDO_ACTIONS_COUNT then result := 0;
end;

function PrevAction:byte;
begin
    result := undoActionsIdx;
    if result = 0 then result := UNDO_ACTIONS_COUNT;
    dec(result);
end;

procedure InitUndoStorage;
var undoPtr:word;
begin
    undoActionsIdx := 0;
    FillByte(undoActions, UNDO_ACTIONS_COUNT * 3, UNDO_NONE);
    undoBufferIdx := FULLSCREEN_UNDO_COUNT;
    undoPtr := UNDO_SCREENS;
    repeat
        Dec(undoBufferIdx);
        undoBuffers[undoBufferIdx] := pointer(undoPtr);
        undoPtr := undoPtr + SCREEN_SIZE;
    until undoBufferIdx = 0;
end;

procedure SetUndoFromXY(idx, x, y: byte);
begin    
    undoActions[idx , 0] := x;
    undoActions[idx , 1] := y;
    undoActions[idx , 2] := Peek(VIDEO_RAM_ADDRESS + x + lineOffset[y]);
end;

procedure StoreUndoFromXY(x, y: byte);
begin
    SetUndoFromXY(undoActionsIdx, x, y);
end;

procedure StoreScreenToUndoBuffer(bufnum: byte);
begin
    move(pointer(VIDEO_RAM_ADDRESS), undoBuffers[bufnum], SCREEN_SIZE);
end;

procedure RestoreScreenFromUndoBuffer(bufnum: byte);
begin
    move(undoBuffers[bufnum], pointer(VIDEO_RAM_ADDRESS), SCREEN_SIZE);
end;

procedure RemoveBufferFromUndoActions(bufnum:byte);
var undoPtr, action:byte;
begin
    undoPtr := undoActionsIdx;
    repeat 
        if undoPtr = 0 then undoPtr := UNDO_ACTIONS_COUNT;
        Dec(undoPtr);
        action := undoActions[undoPtr , 0];
        if action = UNDO_FROM_BUFFER then 
            if undoActions[undoPtr, 1] = bufnum then begin
                undoActions[undoPtr, 0] := UNDO_NONE;
                action := UNDO_NONE;
            end;
    until (action = UNDO_NONE) or (undoPtr = undoActionsIdx);
end;

procedure StoreUndoBuffer;
begin
    StoreScreenToUndoBuffer(undoBufferIdx);
    RemoveBufferFromUndoActions(undoBufferIdx);
    undoActions[undoActionsIdx , 0] := UNDO_FROM_BUFFER;
    undoActions[undoActionsIdx , 1] := undoBufferIdx;
    Inc(undoBufferIdx);
    if undoBufferIdx = FULLSCREEN_UNDO_COUNT then undoBufferIdx := 0;
end;

procedure RestoreCharFromUndo(idx: byte);
var rx,ry,rc : byte;
begin
    rx := undoActions[idx, 0];
    ry := undoActions[idx, 1];
    rc := undoActions[idx, 2];
    Poke(VIDEO_RAM_ADDRESS + rx + lineOffset[ry], rc);
end;

procedure Restore(actionIdx: byte);
begin
    if undoActions[actionIdx, 0] = UNDO_FROM_BUFFER then begin
        StoreUndoBuffer;
        undoActionsIdx := actionIdx;
        RestoreScreenFromUndoBuffer(undoActions[actionIdx, 1]);
    end else begin // char
        StoreUndoFromXY(undoActions[actionIdx, 0], undoActions[actionIdx, 1]);
        undoActionsIdx := actionIdx;
        RestoreCharFromUndo(actionIdx);
    end;
end;

procedure StoreUndoAction(wholeScreen: boolean);
begin
    redoCount := 0;
    if wholeScreen then StoreUndoBuffer
    else StoreUndoFromXY(cursorX, cursorY);
    undoActionsIdx := NextAction;
end;

procedure TryUndo();
var prev: byte;
begin
    prev := PrevAction;
    if undoActions[prev, 0] <> UNDO_NONE then begin
        Restore(prev);
        if undoActions[prev, 0] = UNDO_FROM_BUFFER then undoBufferIdx := undoActions[prev, 1];
        inc(redoCount);
    end;
end;

procedure TryRedo();
var next: byte;
begin
    next := NextAction;
    if redoCount > 0 then begin
        if undoActions[next, 0] <> UNDO_NONE then begin
            Restore(next);
            dec(redoCount);
        end;
    end;
end;

// ********************************************************
// ******************************************************** EDITOR WINDOW OPERATIONS 
// ********************************************************


procedure ClearEdit;
begin
    FillByte(pointer(VIDEO_RAM_ADDRESS), SCREEN_SIZE, 0);
end;

procedure ClearBuffer;
begin
    FillByte(pointer(VIDEO_BUFFER), SCREEN_SIZE, 0);
end;

procedure StoreEditInBuffer;
begin
    Move(pointer(VIDEO_RAM_ADDRESS), pointer(VIDEO_BUFFER), SCREEN_SIZE);
end;

procedure RestoreEditFromBuffer;
begin
    Move(pointer(VIDEO_BUFFER), pointer(VIDEO_RAM_ADDRESS), SCREEN_SIZE);
end;

procedure DrawRect(x, y, w, h, c: byte);
var carret:word;
begin
    carret := VIDEO_RAM_ADDRESS + lineOffset[y] + x;
    repeat 
        fillByte(pointer(carret), w, c);
        carret := carret + SCREEN_WIDTH;
        dec(h)
    until h = 0;
end;

procedure ReadCursorChar;
begin
    cursorChar := peek(VIDEO_RAM_ADDRESS + cursor);
    if config.keyCodeDisplay = CODE_DISPLAY_ATASCII then cursorChar := Antic2Atascii(cursorChar);
end;

procedure UpdateXYK;
begin
    Str(cursorX, s);
    s := Atascii2Antic(s);
    Poke(STATUS_BAR + 12, byte(' '~));
    Move(s[1], pointer(STATUS_BAR + 11), byte(s[0]));

    Str(cursorY,s);
    s := Atascii2Antic(s);
    Poke(STATUS_BAR + 16, byte(' '~));
    Move(s[1], pointer(STATUS_BAR + 15), byte(s[0]));

    if config.keyCodeDisplay <> CODE_DISPLAY_NONE then begin
    Poke(STATUS_BAR + 18, byte('K'~*));
    s := Atascii2Antic(HexStr(cursorChar,2));
    Move(s[1], pointer(STATUS_BAR + 19), byte(s[0]));
    end;
end;

procedure ShowStatus;
begin
    pause;
    FillByte(pointer(STATUS_BAR), SCREEN_WIDTH, 0);
    s := 'MODE'~* + '      '~ + 'X'~* + '   '~ + 'Y'~* + '   '~ ;
    Move(s[1], pointer(STATUS_BAR + 0), byte(s[0]));
    
    s := 'type '~;
    if mode = 1 then s := 'draw '~;
    if mode = 2 then s := 'block'~;
    Move(s[1], pointer(STATUS_BAR + 4), byte(s[0]));
    
    UpdateXYK;

    for b := MAX_BRUSH_HISTORY downto 0 do poke (STATUS_BAR + SCREEN_WIDTH - 1 - b, brushHistory[b]);
    Poke(STATUS_BAR + 39, brush);
end;

procedure ShowMenuBar;
begin
    FillByte(pointer(MENU_BAR), SCREEN_WIDTH, 0);
    if mode = MODE_TYPE then begin
        s:='CAPS:'~* + 'brush  '~ + 'RETURN:'~* + 'paint  '~ + 'INSERT'~ + ' '~ + 'INVERSE'~ ;
        Move(s[1], pointer(MENU_BAR + 0), byte(s[0]));
        if cursorForward then begin 
            s := 'INSERT'~*;
            Move(s[1], pointer(MENU_BAR + 26), byte(s[0]));
        end;
        if invert then begin 
            s := 'INVERSE'~*;
            Move(s[1], pointer(MENU_BAR + 33), byte(s[0]));
        end;
    end;
    if mode = MODE_DRAW then begin
        s:='CAPS:'~* + 'brush   '~ + 
            'D'~* + 'raw   '~ + 
            'L'~* + 'ine   '~ + 
            'F'~* + 'rame   '~ + 
            'B'~* + 'lock'~ ;
        Move(s[1], pointer(MENU_BAR + 0), byte(s[0]));
        if drawTool = TOOL_DRAW then begin
            s:='DRAW'~*;
            Move(s[1], pointer(MENU_BAR + 13), byte(s[0]));
        end;
        if drawTool = TOOL_LINE then begin
            s:='LINE'~*;
            Move(s[1], pointer(MENU_BAR + 20), byte(s[0]));
        end;
        if drawTool = TOOL_FRAME then begin
            s:='FRAME'~*;
            Move(s[1], pointer(MENU_BAR + 27), byte(s[0]));
        end;
        if drawTool = TOOL_BLOCK then begin
            s:='BLOCK'~*;
            Move(s[1], pointer(MENU_BAR + 35), byte(s[0]));
        end;
    end;
    if mode = MODE_BLOCK then begin
        if p2x = NONE then begin
            s:='Select area with '~ + 'RETURN'~* + ' or '~ + 'FIRE'~*;
            Move(s[1], pointer(MENU_BAR), byte(s[0]));
        end else begin
            s:= 'C'~* + 'opy  '~ + 
            'M'~* + 'ove  '~ +
            'F'~* + 'ill  '~ +
            'I'~* + 'nvert  '~ +
            'S'~* + 'ave  '~ ;
            Move(s[1], pointer(MENU_BAR), byte(s[0]));
        end;
    end;
end;

// ********************************************************
// ******************************************************** CURSOR OPERATIONS
// ********************************************************


procedure XorCursor(x, y:byte);
var px, cursor_mask: byte;
    cursor_pmg: word;
begin
    px := x shr 3; // div 8
    cursor_pmg := PMG + $180 + (px * $80) + (y shl 2) + PMG_YOFFSET;
    px := x and %111; // mod 8
    cursor_mask := %10000000 shr px;
    px:=4;
    repeat 
        poke(cursor_pmg,peek(cursor_pmg) xor cursor_mask);
        inc(cursor_pmg);
        dec(px);
    until px = 0
end;

procedure EraseAllCursors;
begin
    FillByte(pointer(PMG + $180),$280 - 16,0);
end;
    
procedure InitCursor;
begin
    cursorX := 0;
    cursorY := 0;
    cursor := 0;
    XorCursor(cursorX, cursorY);
end; 

procedure DrawSelection(pc1x,pc1y,pc2x,pc2y: byte);
var x,y:byte;
begin
    EraseAllCursors;
    if pc1x > pc2x then Swap(pc1x, pc2x);
    if pc1y > pc2y then Swap(pc1y, pc2y);
    for x := pc1x to pc2x do begin 
        XorCursor(x, pc1y);
        if pc1y <> pc2y then XorCursor(x, pc2y);
    end;
    for y := pc1y+1 to pc2y-1 do begin 
        XorCursor(pc1x, y);
        if pc1x <> pc2x then XorCursor(pc2x, y);
    end;
end;

procedure DrawLine;
var deltax, deltay,
    d, dinc1, dinc2,
    xinc1, xinc2,
    yinc1, yinc2 : shortInt;
    numpixels, x, y, i: byte;
    cur: boolean;
begin
    cur := p2x = NONE;
    
    if not cur then StoreUndoAction(true);

    p2x := cursorX;
    p2y := cursorY;
    deltax := p2x - p1x;
    if deltax < 0 then deltax := -deltax;
    deltay := p2y - p1y;
    if deltay < 0 then deltay := -deltay;
    
    if deltax >= deltay then
    begin
        numpixels := deltax + 1;
        d := (byte(deltay) shl 1) - deltax;
        dinc1 := deltay Shl 1;
        dinc2 := (deltay - deltax) shl 1;
        xinc1 := 1;
        xinc2 := 1;
        yinc1 := 0;
        yinc2 := 1;
    end
    else begin
        numpixels := deltay + 1;
        d := (byte(deltax) shl 1) - deltay;
        dinc1 := deltax Shl 1;
        dinc2 := (deltax - deltay) shl 1;
        xinc1 := 0;
        xinc2 := 1;
        yinc1 := 1;
        yinc2 := 1;
    end;

    if p1x > p2x then begin
        xinc1 := - xinc1;
        xinc2 := - xinc2;
    end;
    if p1y > p2y then begin
        yinc1 := - yinc1;
        yinc2 := - yinc2;
    end;

    x := p1x;
    y := p1y;

    for i := 1 to numpixels do begin
        if cur then begin
            if (i < numpixels) then XorCursor(x,y);
        end else Poke(VIDEO_RAM_ADDRESS + lineOffset[y] + x, brush);
        if d < 0 then begin
            d := d + dinc1;
            x := x + xinc1;
            y := y + yinc1;
        end
        else begin
            d := d + dinc2;
            x := x + xinc2;
            y := y + yinc2;
        end;
    end;
    if cur then p2x := NONE;
end;

procedure MoveCursor(dx, dy: shortInt);
var selectionMode:boolean;
begin
    pause;
    selectionMode := false;
    XorCursor(cursorX, cursorY);

    cursorX := cursorX + dx;
    if cursorX = $ff then cursorX := SCREEN_WIDTH - 1;
    if cursorX = SCREEN_WIDTH then cursorX := 0;
    cursorY := cursorY + dy;
    if cursorY = $ff then cursorY := SCREEN_HEIGHT - 1;
    if cursorY = SCREEN_HEIGHT then cursorY := 0;
    cursor := lineOffset[cursorY] + cursorX;
//    cursor := lineOffset[cursorY];
//    cursor := cursor + cursorX;
    
    if (mode = MODE_DRAW) or (mode = MODE_BLOCK) then 
        if (p1x <> NONE) and (p2x = NONE) then begin 
            EraseAllCursors;
            if (mode = MODE_DRAW) and (drawTool = TOOL_LINE) then DrawLine
            else begin  // draw box
                DrawSelection(p1x, p1y, cursorX, cursorY);
                selectionMode := true;
            end;        
        end;
        
    if not selectionMode then XorCursor(cursorX, cursorY);
    ReadCursorChar;
    UpdateXYK;
    keyDown := false;
end;

procedure ClearSelection;
begin
    EraseAllCursors;
    p1x := NONE; p2x := NONE;
    XorCursor(cursorX, cursorY);
end;

procedure checkCursorKeys(offset:byte);
begin
    if key = $06 + offset then MoveCursor(-1,0); // left
    if key = $07 + offset then MoveCursor(1,0);  // right
    if key = $0E + offset then MoveCursor(0,-1); // up
    if key = $0F + offset then MoveCursor(0,1);  // down
end;


// ********************************************************
// ******************************************************** GUI OPERATIONS
// ********************************************************


procedure WriteSXY(x, y: byte);
var carret:word;
begin
    carret := VIDEO_RAM_ADDRESS + lineOffset[y] + x;
    Move(s[1], pointer(carret), byte(s[0]));
end;

function GetHexVal(x,y,default: byte):byte;
var err,i:byte;
begin
    result := default;
    CRT_GotoXY(x, y);
    CRT_Write('  '~);    
    XorCursor(x, y);
    XorCursor(x + 1, y);
    CRT_GotoXY(x, y);
    s := CRT_ReadStringI(2);
    ParseHex(i, err);
    if err = 0 then result := i;
    XorCursor(x, y);
    XorCursor(x + 1, y);
end;

procedure GetFileName(x, y:byte);
const 
    FIL_W = 23;
    FIL_H = 6;
var i:byte;
begin
    DrawRect(x, y, FIL_W, FIL_H, byte(' '~));
    s := 'Enter Filename:'~;
    Inc(x); Inc(x); Inc(y);
    WriteSXY(x,y);
    Inc(y); Inc(y);
    for i := x to x + 13 do XorCursor(i , y);
    CRT_GotoXY(x, y);
    s := '            ';
    s := CRT_ReadString(12);
    for i := x to x + 13 do XorCursor(i , y);
    Inc(y);
    CRT_GotoXY(x, y);
    if keypressed then ReadKey;
    s := AnsiUpperCase(s);
    AddDriveToS;
end;

procedure SelectTool(tool: byte);
begin
    drawTool := tool;
    ShowMenuBar;
    keyDown := false;
    ClearSelection;        
end;

procedure NextMode;
begin
    Inc(mode);
    if mode = MODE_LAST then mode := 0;
    keyRepeatCounter := KEY_DELAY;
    ClearSelection;
    ShowStatus;
    ShowMenuBar;
end;

procedure OpenModal;
begin
    keyRepeatCounter := KEY_DELAY;
    EraseAllCursors;
    editorCharset := Hi(DEFAULT_CHARSET);
    StoreEditInBuffer;    
end;

procedure CloseModal;
begin
    RestoreEditFromBuffer;
    EraseAllCursors;
    MoveCursor(0, 0);
    if p2x <> NONE then DrawSelection(p1x, p1y, p2x, p2y);
    XorCursor(cursorX, cursorY);
    editorCharset := Hi(CUSTOM_CHARSET);
    keyRepeatCounter := KEY_DELAY;
end;

// ********************************************************
// ******************************************************** BRUSH OPERATIONS
// ********************************************************


procedure HistoryBack;
begin
    Inc(brushIndex);
    if brushIndex > MAX_BRUSH_HISTORY then brushIndex := 0;
    brush := brushHistory[brushIndex];
    AdjustBrushFrame;
end;

procedure HistoryFwd;
begin
    if brushIndex = 0 then brushIndex := MAX_BRUSH_HISTORY + 1;
    Dec(brushIndex);
    brush := brushHistory[brushIndex];
    AdjustBrushFrame;
end;

procedure InjectBrush(c:byte);
var i,prev:byte;
begin
    i := 0;
    prev := brushHistory[i];
    brushHistory[i] := c;
    repeat
        if prev = c then exit;
        Inc(i);
        b := brushHistory[i];
        brushHistory[i] := prev;
        prev := b;
    until i > MAX_BRUSH_HISTORY;
end;

procedure UseBrush(c:byte);
begin
    if c = brushHistory[0] then exit;
    InjectBrush(c);
    brushIndex := 0;
    brush := c;
    AdjustBrushFrame;
    ShowStatus;
end;

procedure PokeBrush;
begin
    StoreUndoAction(false);
    Poke(VIDEO_RAM_ADDRESS + cursor, brush);
    ReadCursorChar;    
end;

procedure SetBrushFromKey;
begin
    b := Atascii2Antic(keychars[key]);
    if invert then b := b xor 128;
    brush := b;
end;
   
procedure WriteSpace;
begin   
    b := brush;
    brush := 0;
    if invert then brush := 128;
    StoreUndoAction(false);
    PokeBrush;
    brush := b;
    keyDown := false;
end;

function BrushSelector:byte;
const 
    BRS_X = 11;
    BRS_Y = 2;
    BRS_W = 18;
    BRS_H = 20;
var vram: word; 
    cbrush: byte;
    cx,cy,koffset: byte;
    moved,done: boolean;

    procedure UpdateBrushCursor;
    begin;
        XorCursor(cx, cy);
        cx := BRS_X + 1 + cbrush and 15;
        cy := BRS_Y + 3 + cbrush shr 4;
        XorCursor(cx, cy);
    end;

begin
    EraseAllCursors;
    result := brush;
    cbrush := brush;
    keyRepeatCounter := KEY_DELAY;
    StoreEditInBuffer;
    DrawRect(BRS_X, BRS_Y, BRS_W, BRS_H, byte(' '*~));
    s := 'Select Brush'*~;
    WriteSXY(BRS_X+1, BRS_Y+1);
    
    // print pallete
    vram := VIDEO_RAM_ADDRESS + lineOffset[BRS_Y + 3] + BRS_X + 1;
    b := 0;
    repeat
        poke(vram, b);
        inc(b);
        inc(vram);
        if b and 15 = 0 then inc(vram, SCREEN_WIDTH - 16);
    until b = 0;
    
    cbrush := brush;
    cx := BRS_X + 1 + cbrush and 15;
    cy := BRS_Y + 3 + cbrush shr 4;
    XorCursor(cx, cy);

    done := false;
    repeat

        ReadJoystick;

        if keyRepeatCounter = 0 then begin
            if keypressed then begin
                c := readKey;
                if c = char(27) then done := true; // esc -> cancel
                if (kbcode = $0C) or (kbcode = $3C) then begin // return, caps -> select brush
                    if cbrush > 127 then invert := true;
                    UseBrush(cbrush);
                    result := cbrush;
                    done := true;
                end;
                moved := false; // arrows
                if kbcode = $21 then begin // space -> add brush to history
                    UseBrush(cbrush);
                    moved := true;
                end;
                koffset := $80;
                if config.arrowsRaw then koffset := 0;
                if kbcode = $06 + koffset then begin
                    dec(cbrush);  
                    moved := true;
                end;
                if kbcode = $07 + koffset then begin 
                    inc(cbrush);
                    moved := true;
                end;
                if kbcode = $0E + koffset then begin 
                    dec(cbrush,16);
                    moved := true;
                end;
                if kbcode = $0F + koffset then begin 
                    inc(cbrush,16);
                    moved := true;
                end;
                if moved then UpdateBrushCursor
                else begin
                    b := Atascii2Antic(keychars[kbcode]); // set brush
                    if invert then b := b xor 128;
                    brush := b;
                    ShowStatus;
                end;
                keyRepeatCounter := KEY_DELAY;
            end;
        
            if (joyX <> 0) or (joyY <> 0) then begin
                joyY := joyY * 16;
                cbrush := cbrush + joyY;
                cbrush := cbrush + joyX;
                UpdateBrushCursor;
                keyRepeatCounter := JOY_DELAY;
            end;
            if joyFire = 0 then begin 
                if cbrush > 127 then invert := true;
                result := cbrush;
                keyRepeatCounter := FIRE_DELAY;
                done := true;
            end;
            

        end;
        
    until done;

    XorCursor(cx, cy);
    CloseModal;
end;

// ********************************************************
// ******************************************************** BLOCK OPERATIONS
// ********************************************************


function SortPointsAndGetCorner:word;
begin
    if p1x > p2x then Swap(p1x, p2x);
    if p1y > p2y then Swap(p1y, p2y);
    result := VIDEO_RAM_ADDRESS + lineOffset[p1y] + p1x;
end;

procedure InvertBlock;
var x,y: byte;
    vram: word;
begin
    StoreUndoAction(true);
    vram := SortPointsAndGetCorner - p1x;
    for y := p1y to p2y do begin
        for x := p1x to p2x do begin
            poke(vram + x, peek(vram + x) xor 128);
        end;
        inc(vram, SCREEN_WIDTH);
    end;
end;

procedure CalculateWidthAndHeight;
begin
    w := p2x - p1x + 1;
    h := p2y - p1y + 1;
end;

procedure DrawBlock;
var vram: word;
begin
    StoreUndoAction(true);
    vram := SortPointsAndGetCorner;
    CalculateWidthAndHeight;
    DrawRect(p1x, p1y, w, h, brush);
end;

procedure CopyBlock(moveBlock:boolean);
var vram, bram: word;
begin
    StoreUndoAction(true);
    bram := SortPointsAndGetCorner - VIDEO_RAM_ADDRESS + VIDEO_BUFFER;
    vram := VIDEO_RAM_ADDRESS + cursor;
    CalculateWidthAndHeight;
    if cursorX + w >= SCREEN_WIDTH then w := SCREEN_WIDTH - cursorX;
    if cursorY + h >= SCREEN_HEIGHT then h := SCREEN_HEIGHT - cursorY;
    StoreEditInBuffer;
    if moveBlock then begin
        DrawRect(p1x, p1y, w, h, 0);
        p1x := cursorX;
        p1y := cursorY;
        p2x := cursorX + w - 1;
        p2y := cursorY + h - 1;
        DrawSelection(p1x, p1y, p2x, p2y);
        XorCursor(cursorX, cursorY);
    end;
    repeat
        Move(pointer(bram), pointer(vram), w);
        Inc(vram, SCREEN_WIDTH);
        Inc(bram, SCREEN_WIDTH);
        if vram >= VIDEO_RAM_ADDRESS + SCREEN_SIZE then Dec(vram,SCREEN_SIZE);
        Dec(h);
    until h = 0;
end;

procedure DrawFrame;
var vram: word;
begin
    StoreUndoAction(true);
    vram := SortPointsAndGetCorner;
    CalculateWidthAndHeight;
    FillByte(pointer(vram), w, brush);
    Dec(h);
    while h > 0 do begin
        poke(vram, brush);
        poke(vram + w - 1, brush);
        inc(vram, SCREEN_WIDTH);
        Dec(h);
    end;
    FillByte(pointer(vram), w, brush);
end;

// ********************************************************
// ******************************************************** DISK OPERATIONS
// ********************************************************

procedure IOStatus;
begin
    s:='';
    //CRT_Write(ioresult); // debug
    case ioresult of
        133: s := 'Device Error!'~;
        136, 139:
             s := 'Bad Filename!'~;
        168: begin
             s := 'Bad Filename!'~;
        end;
        1,3:   s := 'Success.'~;
    end;
    CRT_Write(s);
    Readkey;
    Close(afile);
end;

procedure LoadData(buf: pointer; size: word);
begin
    Assign(afile, s); 
    Reset(afile, 1);
    BlockRead(afile, buf, size);
    IOStatus;
end;

procedure SaveData(buf: pointer; size: word);
begin
    Assign(afile, s); 
    Rewrite(afile, 1);
    BlockWrite(afile, buf, size);
    IOStatus;
end;

procedure LoadConfig;
begin
    s := 'ARTURCFG.SYS';
    AddDriveToS;
    if FileExists(s) then begin 
        Assign(afile, s); 
        Reset(afile, 1);
        BlockRead(afile, config, SizeOf(TConfig));
        Close(afile);
    end;
end;

procedure SaveConfig;
begin
    s := 'ARTURCFG.SYS';
    AddDriveToS;
    SaveData(@config, SizeOf(TConfig));
end;

procedure SaveBlock;
var vram:array [0..0] of byte absolute VIDEO_BUFFER;
    ptr:word;
const 
    SVB_X = 5;
    SVB_Y = 2;
    SVB_W = 30;
    SVB_H = 12;
begin
    OpenModal;    
    DrawRect(SVB_X,SVB_Y,SVB_W,SVB_H,byte(' '*~));
    s:='SAViNG DATA BLOCK'*~;
    WriteSXY(SVB_X + 1,SVB_Y + 1);
    s:='----------------------------'*~;    
    WriteSXY(SVB_X + 1,SVB_Y + 2);
    CRT_GotoXY(SVB_X + 1,SVB_Y + 4);
    GetFileName(SVB_X + 1, SVB_Y + 4);

    Assign(afile, s); 
    Rewrite(afile, 1);

    ptr := SortPointsAndGetCorner - VIDEO_RAM_ADDRESS;
    CalculateWidthAndHeight;
    repeat    
        BlockWrite(afile, vram[ptr], w);
        dec(h);
        Inc(ptr, SCREEN_WIDTH);
    until h = 0;

    IOStatus;
    CloseModal;
end;

procedure SaveBinary;
var 
    header: array [0..0] of byte absolute BIN_HEADER;
    charset: array [0..0] of byte absolute CUSTOM_CHARSET;
begin
    Assign(afile, s); 
    Rewrite(afile, 1);

    BlockWrite(afile, header, BIN_HEADER_SIZE);
    BlockWrite(afile, charset, $400 + SCREEN_SIZE);
    BlockWrite(afile, config.editorBackgroundColor, 2);

    IOStatus;
    CloseModal
end;


// ********************************************************
// ******************************************************** MENU WINDOWS
// ********************************************************


procedure ShowHelp;
const 
    HLP_X = 5;
    HLP_Y = 2;
    HLP_W = 30;
    HLP_H = 20;
begin
    OpenModal;    
    DrawRect(HLP_X,HLP_Y,HLP_W,HLP_H,byte(' '*~));
    s:='ARTur - v.      bocianu''2020'*~;
    WriteSXY(HLP_X+1,HLP_Y+1);
    move(version,s,10);
    WriteSXY(HLP_X+11,HLP_Y+1);
    s:='----------------------------'*~;
    WriteSXY(HLP_X+1,HLP_Y+2);
    s:='ATASCII Art Editor'~*;
    WriteSXY(HLP_X+1,HLP_Y+3);
    s:='START'~ + '  - I/O menu'~*;
    WriteSXY(HLP_X+1,HLP_Y+6);
    s:='SELECT'~ + ' - change mode'~*;
    WriteSXY(HLP_X+1,HLP_Y+8);
    s:='OPTION'~ + ' - settings'~*;
    WriteSXY(HLP_X+1,HLP_Y+10);
    s:='HELP'~ + '   - this screen'~*;
    WriteSXY(HLP_X+1,HLP_Y+12);

    s:='Press '~* + 'any'~ + ' key'~*;
    WriteSXY(HLP_X+1,HLP_Y+HLP_H-2);

    repeat 
        if CRT_HelpPressed and (keyRepeatCounter = 0) then break;
    until keypressed;
    CloseModal;
    if keypressed then readKey;
end;

function HasExt(var s:string; var e:string):boolean;
var i, ei:byte;
begin
    result := false;
    i := 1;
    ei := 1;
    repeat 
        if s[i] = '.'~ then result := true;
        Inc(i);
    until result or (i = 10);
    if result then begin 
        repeat 
            if s[i] <> e[ei] then result := false;
            Inc(i);
            Inc(ei);
        until (not result) or (ei = 4);   
    end;
end;

procedure ShowIOMenu;
const 
    IO_X = 1;
    IO_Y = 1;
    IO_W = 38;
    IO_H = 22;
var done: boolean;    
    Info : TSearchRec;
    dirPage : byte;
    next: byte;


    procedure showDir(page: byte);
    var row:byte;
        ext:string[3];
        skip:byte;
        
    begin
        skip := page shl 4;
        DrawRect(IO_X + IO_W - 13, IO_Y + 3, 12, 16, byte(' '~));
        s := '            '*~;
        WriteSXY(IO_X + IO_W - 13, IO_Y + IO_H - 2);
        if FindFirst('D:*.*', faAnyFile, Info) = 0 then begin
            row := 0;
            ext := 'SYS'~;
            repeat
                s := Atascii2Antic(Info.Name);
                if not HasExt(s, ext) then begin
                    if skip = 0 then begin
                        WriteSXY(IO_X + IO_W - 13, IO_Y + 3 + row);
                        inc(row);
                    end else dec(skip);
                end;
                next := FindNext(Info);
            until (next <> 0) or (row = 16);
            FindClose(Info);
        end;
        if next = 0 then begin
            s := '>'~;
            WriteSXY(IO_X + IO_W - 2, IO_Y + IO_H - 2);
        end;
        if page > 0 then begin
            s := '<'~;
            WriteSXY(IO_X + IO_W - 13, IO_Y + IO_H - 2);
        end;

    end;


begin
    OpenModal;
    DrawRect(IO_X, IO_Y, IO_W, IO_H, byte(' '*~));
    s:='I/O MENU                Files:'*~;
    WriteSXY(IO_X+1,IO_Y+1);
    s:='----------------------- ------------'*~;
    WriteSXY(IO_X+1,IO_Y+2);
    s:='N'~ + 'ew image (clear)'~*;
    WriteSXY(IO_X+1,IO_Y+4);
    s:='L'~ + 'oad ATASCII image'~*;
    WriteSXY(IO_X+1,IO_Y+6);
    s:='S'~ + 'ave ATASCII image'~*;
    WriteSXY(IO_X + 1,IO_Y+8);
    s:='Save e'*~ + 'X'~ + 'ecutable binary'~*;
    WriteSXY(IO_X + 1,IO_Y+10);
    s:='Load custom '*~ + 'C'~ + 'harset'~*;
    WriteSXY(IO_X + 1,IO_Y+12);
    s:='Restore '*~ + 'D'~ + 'efault charset'~*;
    WriteSXY(IO_X + 1,IO_Y+14);
    s:='Q'~ + 'uit to DOS'~*;
    WriteSXY(IO_X + 1,IO_Y+16);
    s:='Press '~* + 'ESC'~ + ' to leave '~*;
    WriteSXY(IO_X + 1,IO_Y+IO_H-2);

    done := false;
    dirPage := 0;
    next := 0;
    showDir(dirPage);
        
    repeat
        c := readKey;
        if c = 'n' then begin
            ClearBuffer; 
            done := true;
        end;
        if c = 'l' then begin
            GetFileName(IO_X+1, IO_Y+7);
            LoadData(pointer(VIDEO_BUFFER), SCREEN_SIZE);
            InitUndoStorage;
            done := true;
        end;
        if c = 's' then begin
            GetFileName(IO_X+1, IO_Y+9);
            SaveData(pointer(VIDEO_BUFFER), SCREEN_SIZE);
            done := true;
        end;
        if c = 'x' then begin
            GetFileName(IO_X+1, IO_Y+11);
            SaveBinary;
            done := true;
        end;
        if c = 'c' then begin
            GetFileName(IO_X+1, IO_Y+13);
            LoadData(pointer(CUSTOM_CHARSET), $400);
            done := true;
        end;
        if c = 'd' then begin
            Move(pointer(DEFAULT_CHARSET), pointer(CUSTOM_CHARSET), $400);
            done := true;
        end;
        if c = 'q' then begin
            mode := MODE_EXIT;
            done := true;
        end;
        if c = '>' then if next = 0 then begin
                Inc(dirPage);
                showDir(dirPage);
        end;
        if c = '<' then if dirPage > 0 then begin
                Dec(dirPage);
                showDir(dirPage);
        end;
        if c = char(27) then done := true; //esc
    until done;
    CloseModal;
end;

procedure ShowSettings;
const 
    OPT_X = 5;
    OPT_Y = 2;
    OPT_W = 30;
    OPT_H = 20;
begin
    OpenModal;
    DrawRect(OPT_X, OPT_Y, OPT_W, OPT_H, byte(' '*~));
    s:='EDiTOR SETTiNGS'*~;
    WriteSXY(OPT_X+1,OPT_Y+1);
    s:='----------------------------'*~;
    WriteSXY(OPT_X+1,OPT_Y+2);
    
    repeat
        s:='B'~ + 'ackground color: $'~*;
        WriteSXY(OPT_X+1,OPT_Y+4);
        s:=Atascii2Antic(HexStr(config.editorBackgroundColor,2));
        WriteSXY(OPT_X+20,OPT_Y+4);
        
        s:='F'~ + 'oreground color: $'~*;
        WriteSXY(OPT_X+1,OPT_Y+6);
        s:=Atascii2Antic(HexStr(config.editorForegroundColor,2));
        WriteSXY(OPT_X+20,OPT_Y+6);
        
        s:='A'~ + 'rrows without Ctrl: '~*;
        WriteSXY(OPT_X+1,OPT_Y+8); 
        if config.arrowsRaw then s := 'on'~ + ' '~*
        else s := 'off'~;
        WriteSXY(OPT_X+22,OPT_Y+8); 
        
        s:='C'~ + 'harcode display: '~*;
        WriteSXY(OPT_X+1,OPT_Y+10); 
        s := 'off'~+'    '*~;
        if config.keyCodeDisplay = CODE_DISPLAY_ATASCII then s := 'ATASCII'~;
        if config.keyCodeDisplay = CODE_DISPLAY_ANTIC then s := 'Antic'~ + '  '~*;
        WriteSXY(OPT_X+19,OPT_Y+10); 

        s:='S'~ + 'ave config'~*;
        WriteSXY(OPT_X+1,OPT_Y+12); 

        s:='Press '~* + 'ESC'~ + ' to leave'~*;
        WriteSXY(OPT_X+1,OPT_Y+OPT_H-2);

        c := readKey;
        if c = 'a' then config.arrowsRaw := not config.arrowsRaw;
        if c = 'b' then config.editorBackgroundColor := GetHexVal(OPT_X+20, OPT_Y+4, config.editorBackgroundColor);
        if c = 'f' then config.editorForegroundColor := GetHexVal(OPT_X+20, OPT_Y+6, config.editorForegroundColor);
        if c = 'c' then begin
            Inc(config.keyCodeDisplay);
            if config.keyCodeDisplay = 3 then config.keyCodeDisplay := 0;
        end;
        if c = 's' then begin         
            CRT_GotoXY(OPT_X+1,OPT_Y+12);
            SaveConfig; 
            c := char(27); 
        end;
    until c = char(27);

    CloseModal;
end;



//**************************************************************************************************************
//**************************************************************************************************************

//                                                   M A I N

//**************************************************************************************************************
//**************************************************************************************************************

begin

    Pause;
    GetIntVec(iVBL, oldvbl);
    GetIntVec(iDLI, olddli);
    SetIntVec(iVBL, @vbl);
    SetIntVec(iDLI, @dli);
    SDLSTL := DISPLAY_LIST_ADDRESS;
    nmien := $c0; 
    CRT_Init(VIDEO_RAM_ADDRESS, SCREEN_WIDTH, SCREEN_HEIGHT);

    Move(pointer(DEFAULT_CHARSET), pointer(CUSTOM_CHARSET), $400);
    editorCharset := Hi(CUSTOM_CHARSET);
    poke(729, OS_REPEAT_DELAY); // keyboard repeat delay
    poke(730, OS_REPEAT_RATE);  // keyboard repeat rate

    config.editorBackgroundColor := BG_DEFAULT;
    config.editorForegroundColor := FG_DEFAULT;

    ClearEdit;
    InitPMG;
    InitCursor;
    InitUndoStorage;
    LoadConfig;
    
    ShowMenuBar;
    ShowStatus;
    ShowHelp;

    repeat
        Pause;

        // ******************************************* ALL MODES
        
        if keyRepeatCounter = 0 then begin
            if CRT_StartPressed then ShowIOMenu;
            if CRT_SelectPressed then NextMode;
            if CRT_OptionPressed then ShowSettings;
            if CRT_HelpPressed then ShowHelp;

            if keyDown then begin
                
                checkCursorKeys($80);
                if config.arrowsRaw then checkCursorKeys(0);

                if key = $27 then begin // INVERSE
                    invert := not invert;
                    brush := brush xor 128;
                    ShowMenuBar;
                    ShowStatus;
                    keyDown := false;
                end;

                if key = $3C then begin // CAPSLOCK
                    brush := BrushSelector;
                    ShowStatus;
                    keyDown := false;
                end;

                if key = $7C then begin // SHIFT + CAPSLOCK
                    brush := Peek(VIDEO_RAM_ADDRESS + cursor);
                    ShowStatus;
                    keyDown := false;
                end;
    
                if key = $2C then begin // TAB
                    HistoryBack;
                    ShowStatus;
                    keyDown := false;
                end;

                if key = $6C then begin // SHIFT + TAB
                    HistoryFwd;
                    ShowStatus;
                    keyDown := false;
                end;

                if key = $5C then begin // SHIFT + ESC
                    statusCustomCharset := not statusCustomCharset;
                    keyDown := false;
                end;
                
                if key = $B4 then begin // CTRL - BACKSPACE
                    TryUndo; 
                    ReadCursorChar;
                    keyDown := false;
                end;
                if key = $F4 then begin // CTRL - SHIFT - BACKSPACE
                    TryRedo; 
                    ReadCursorChar;
                    keyDown := false;
                end;

            end;
            
            ReadJoystick;

            if (joyX <> 0) or (joyY <> 0) then begin
                MoveCursor(joyX, joyY);
                keyRepeatCounter := JOY_DELAY;
            end;
        end;
        
        
        // ******************************************** MODE : TYPE 
        
        if mode = MODE_TYPE then begin
            if joyFire = 0 then begin // FIRE
                PokeBrush;
                UseBrush(brush);
                joyFire := 1;
                keyDown := false;
            end;
            if keyDown then begin
                if (key = $0C) then begin // RETURN
                    PokeBrush;
                    UseBrush(brush);
                    if cursorForward then MoveCursor(1,0);
                    keyDown := false;
                end;
                if key = $77 then begin // INSERT
                    cursorForward := not cursorForward;
                    ShowMenuBar;
                    keyDown := false;
                end;
                if key = $21 then begin // SPACE
                    WriteSpace;
                    if cursorForward then MoveCursor(1,0);
                end;
                if cursorForward then begin
                    if key = $34 then begin // BACKSPACE (only in insert mode)
                        MoveCursor(-1,0);
                        WriteSpace;
                    end;
                end;
            
            end;                        // ANY OTHER KEY  (writes and sets brush)
            if keyDown then begin
                SetBrushFromKey;
                PokeBrush;
                UseBrush(brush);
                if cursorForward then MoveCursor(1,0);
                ShowStatus;
            end;
        end;


        // *************************************************** MODE : DRAW
        
        if mode = MODE_DRAW then begin
            if joyFire = 0 then begin // FIRE
                joyFire := 1;
                penDown := true;
                keyRepeatCounter := FIRE_DELAY;
            end;        
            if keyDown then begin
                if key = $1c then begin // ESC
                    ClearSelection;
                    keyDown := false;
                end;
                if key = $0C then begin // RETURN
                    penDown := true;
                    keyDown := false;
                end;

                if key = $21 then begin // SPACE
                    WriteSpace;
                    ClearSelection;
                    ShowStatus;
                end;
                if c = 'd' then SelectTool(TOOL_DRAW);
                if c = 'l' then SelectTool(TOOL_LINE);
                if c = 'f' then SelectTool(TOOL_FRAME);
                if c = 'b' then SelectTool(TOOL_BLOCK);
            end;                        // ANY OTHER KEY  (sets brush)
            if keyDown then begin
                SetBrushFromKey;
                ShowStatus;
            end;

            if penDown then begin
                if drawTool = TOOL_DRAW then begin
                    PokeBrush;
                    UseBrush(brush);
                end else 
                if p1x = NONE then begin // first point empty
                    p1x := cursorX;
                    p1y := cursorY;
                end else begin // first point set
                    if p2x = NONE then begin // but second empty 
                        p2x := cursorX;
                        p2y := cursorY;
                        if drawTool = TOOL_LINE then DrawLine;
                        if drawTool = TOOL_FRAME then DrawFrame;
                        if drawTool = TOOL_BLOCK then DrawBlock;
                        ReadCursorChar;
                        UseBrush(brush);
                        ClearSelection;
                    end;
                end;
                penDown := false;
            end;
        end;


        // ********************************************** MODE : RECT
        
        if mode = MODE_BLOCK then begin
            if joyFire = 0 then begin // FIRE
                joyFire := 1;
                penDown := true;
                keyRepeatCounter := FIRE_DELAY;
            end;        
            if keyDown then begin
                if key = $1c then begin // ESC
                    ClearSelection;
                    ShowMenuBar;
                    keyDown := false;
                end;
                if key = $0C then begin // RETURN
                    penDown := true;
                    keyDown := false;
                end;
                if p2x <> NONE then begin
                    if c = 'c' then CopyBlock(false);
                    if c = 'm' then CopyBlock(true);
                    if c = 's' then SaveBlock;
                    if c = 'i' then InvertBlock;
                    if c = 'f' then DrawBlock;
                    ReadCursorChar;
                    ShowStatus;
                end;
            end;                        // ANY OTHER KEY  (sets brush)


            if penDown then begin
                if p1x = NONE then begin // first point empty
                    p1x := cursorX;
                    p1y := cursorY;
                end else begin // first point set
                    if p2x = NONE then begin // but second empty 
                        p2x := cursorX;
                        p2y := cursorY;
                        XorCursor(cursorX, cursorY);
                        ShowMenuBar;
                    end else begin // selection done
                      ClearSelection;                      
                      ShowMenuBar;
                    end;
                end;
                penDown := false;
            end;
        end;
    
        if keyDown then keyDown := false;

        if keypressed then begin
            c := Readkey;
            key := KBCODE;
            keyDown := true;
        end;

    until mode = MODE_EXIT;

(*  restore system settings and exit *)

    Pause;
    PMG_Disable;
    SetIntVec(iVBL, oldvbl);
    SetIntVec(iDLI, olddli);
    nmien := $40; // turn off dli
    TextMode(0);
    halt;
end.
