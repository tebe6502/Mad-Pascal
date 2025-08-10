(*
Random-dot Stereogram Generator
by Gawor (2020-01-18)
*)

program Stereogram;

{$librarypath 'blibs'}

uses B_Crt, SysUtils, Graph;

const
  CHAR_ARR: array[0..9] of Char = (' '~, '1'~, '2'~, '3'~, '4'~, '5'~, '6'~, '7'~, '8'~, '9'~);
  BOX_BAR = #$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#$12#4~;
  BOX_BAR_INFO = #$12#$12#$12#$17#$12#$12#$12#$17#$12#$12#$12#$17#$12#$12#$12#4~;
  BOX_BAR_INFO2 = 'X  |Y  |M  |D  |'~;
  DEF_DENSITY = 85;
  BOARD_WIDTH = 24;
  BOARD_HEIGHT = 24;
  HELP_MSG0 =
    '    RANDOM-DOT STEREOGRAM GENERATOR     '~* +
    '   version 0.1 (2020-01-18) by Gawor    '~ +
    '                                        '~;
  HELP_MSG1_1 =
    ' Editor keys:                           '~ +
    '  '~ + 'W'~* + ','~ + #$DC + '........ Move cursor - Up          '~ +
    '  '~ + 'S'~* + ','~ + #$DD + '........ Move cursor - Down        '~ +
    '  '~ + 'A'~* + ','~ + #$DE + '........ Move cursor - Left        '~ +
    '  '~ + 'D'~* + ','~ + #$DF + '........ Move cursor - Right       '~ +
    '  '~ + '0'~* + '-'~ + '9'~* + '........ Set level                 '~;
  HELP_MSG1_2 =
    '  '~ + 'SPACE'~* + ','~ + 'RET'~* + '.. Put selected level at     '~ +
    '              actual cursor position    '~ +
    '  '~ + 'BACKSPACE'~* + '.. Clear actual positoin     '~ +
    '  '~ + 'M'~* + '.......... Change edit mode          '~ +
    '  '~ + 'G'~* + '.......... Set density               '~ +
    '  '~ + 'P'~* + '.......... Paint stereogram          '~;
  HELP_MSG1_3 =
    '  '~ + 'L'~* + '.......... Load from file            '~ +
    '  '~ + 'K'~* + '.......... Save fo file              '~ +
    '  '~ + 'C'~* + '.......... Clear all                 '~ +
    '  '~ + 'H'~* + '.......... Show this help            '~ +
    '  '~ + 'X'~* + ','~ + 'ESC'~* + '...... Quit - exit to DOS        '~ +
    '                                        '~;
  HELP_MSG1_4 =
    ' Preview keys:                          '~ +
    '  '~ + 'ESC'~* + '........ Back to editor            '~;

  HELP_MSG2_1 =
    ' Status bar:                            '~ +
    '                                        '~ +
    '                                        '~ +
    ' '~ + #$51#$52#$52#$52#$52#$52#$52#$52#$52#$52#$52#$52#$52#$52#$52 + ' X position of cursor   '~ +
    ' '~ + #$7C + '                                      '~ +
    ' '~ + #$7C + '   '~ + #$51#$52#$52#$52#$52#$52#$52#$52#$52#$52#$52 + ' Y position of cursor   '~;
  HELP_MSG2_2 =
    ' '~ + #$7C + '   '~ + #$7C + '                                  '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$51#$52#$52#$52#$52#$52#$52 + ' Actual level (z-order) '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C + '                              '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$51#$52#$52#$52#$52#$52 + ' Edit mode:             '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '       '~ + #7 + ' '~ + #7 + ' - normal          '~;
  HELP_MSG2_3 =
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '       '~ + #7 + ' '~* + #7 + ' - insert / draw   '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '       '~ + #7 + 'R'~ + #7 + ' - draw rectangle  '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '       Key '~ + 'M'~* + ' - change mode   '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '                             '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '  '~ + #$51#$52#$52 + ' Density (1-99)         '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '  '~ + #$7C + '    Key '~ + 'G'~* + ' - set density   '~;
  HELP_MSG2_4 =
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '  '~ + #$7C + '                          '~ +
    ' '~ + #$7C + '   '~ + #$7C + '   '~ + #$7C#$7C + '  '~ + #$7C + '                          '~ +
    #$52#$52#$52#$57#$52#$52#$52#$57#$52#$52#$52#$57#$52#$52#$52#$45 + '                        '~ +
    'X12|Y21|M5R|D85|                        '~;

  HELP_MSG3_1 =
    ' Author:                                '~ +
    '   Gawor (2020-01-18)                   '~;
  HELP_MSG3_2 =
    ' Credits:                               '~ +
    '   Compiled with MadPascal by TeBe      '~ +
    '       http://mads.atari8.info          '~;

type
  TBoard = array[0..BOARD_WIDTH - 1, 0..BOARD_HEIGHT - 1] of Byte;
  TReadMode = (roNormal, roUpper, roNumber);
  TMode = (mDefault, mPaint, mRectangle);
  TSubMode = (smSelectPt1, smSelectPt2);

const
  MODE_CHR: array[Ord(roNormal)..Ord(mRectangle)] of Char = (' '~, ' '~*, 'R'~);

var
  Board: TBoard;
  Density: Byte;
  Key, PKey: Char;
  PosX, PosY: Byte;
  LastLevel: Byte;
  DoQuit: Boolean;
  Mode: TMode;
  SubMode: TSubMode;
  PtX, PtY: Byte;

// modified function from 'blibs' libary
function CRT_ReadStringEx(Limit: Byte; Mode: TReadMode): String; overload;
var
  C: Char;
begin
  Result := '';
  Poke(CRT_Cursor, $80);
  repeat
    C := Char(CRT_ReadChar);
    if C = CHAR_RETURN then
      Exit(Result);
    if C = CHAR_ESCAPE then
      Exit('');
    if (C = CHAR_BACKSPACE) and (Byte(Result[0]) > 0) then
    begin
      Poke(CRT_cursor,0);
      Dec(CRT_cursor);
      Poke(CRT_cursor,$80);
      Dec(Result[0]);
    end
    else
    if (C <> CHAR_CAPS) and (C <> CHAR_INVERSE) and (C <> CHAR_TAB)
      and (C <> CHAR_BACKSPACE) and (Byte(Result[0]) < Limit) then
    begin
      case Mode of
        roUpper: C := UpCase(C);
        roNumber: if ((C < '0') or (C > '9')) then
          C := #0;
      end;
      if C <> #0 then
      begin
        CRT_Put(Atascii2Antic(Byte(C)));
        Poke(CRT_cursor, $80);
        Inc(Result[0]);
        Result[Byte(Result[0])] := C;
      end;
    end;
  until False;
end;

procedure DrawLegend;
var
  I: Byte;
begin
  for I := 0 to 23 do
  begin
    CRT_GotoXY(15, I);
    CRT_Write('|');
  end;
  CRT_GotoXY(0, 0);
  CRT_Write('STEREOGRAM v0.1'~*);
  CRT_GotoXY(0, 1);
  CRT_Write('by Gawor [2020]'~);
  CRT_GotoXY(0, 2);
  CRT_Write(BOX_BAR);
  CRT_GotoXY(0, 3);
  CRT_Write('Keys:'~);
  CRT_GotoXY(0, 4);
  CRT_Write('W'~* + ','~ + #$DC + '-Up'~);
  CRT_GotoXY(0, 5);
  CRT_Write('S'~* + ','~ + #$DD + '-Down'~);
  CRT_GotoXY(0, 6);
  CRT_Write('A'~* + ','~ + #$DE + '-Left'~);
  CRT_GotoXY(0, 7);
  CRT_Write('D'~* + ','~ + #$DF + '-Right'~);
  CRT_GotoXY(0, 8);
  CRT_Write('0'~* + '-'~ + '9'~* + '-Set level'~);
  CRT_GotoXY(0, 9);
  CRT_Write('SPACE'~* + ','~ + 'RET'~* + '-Set'~);
  CRT_GotoXY(0, 10);
  CRT_Write('BACKSPACE'~* + '-Clear'~);
  CRT_GotoXY(0, 11);
  CRT_Write('M'~* + '-Mode'~);
  CRT_GotoXY(0, 12);
  CRT_Write('G'~* + '-Density'~);
  CRT_GotoXY(0, 13);
  CRT_Write('P'~* + '-Paint'~);
  CRT_GotoXY(0, 14);
  CRT_Write('L'~* + '-Load'~);
  CRT_GotoXY(0, 15);
  CRT_Write('K'~* + '-Save'~);
  CRT_GotoXY(0, 16);
  CRT_Write('C'~* + '-Clear all'~);
  CRT_GotoXY(0, 17);
  CRT_Write('H'~* + '-Help'~);
  CRT_GotoXY(0, 18);
  CRT_Write('X'~* + ','~ + 'ESC'~* + '-Quit'~);
  CRT_GotoXY(0, 22);
  CRT_Write(BOX_BAR_INFO);
  CRT_GotoXY(0, 23);
  CRT_Write(BOX_BAR_INFO2);
end;

procedure DrawBoard(SX, SY, EX, EY: Byte; Invers: Boolean); overload;
var
  I, J: Byte;
  C: Char;
begin
  if SX > EX then
  begin
    I := SX;
    SX := EX;
    EX := I;
  end;
  if SY > EY then
  begin
    I := SY;
    SY := EY;
    EY := I;
  end;
  for I := SY to EY do
  begin
    CRT_GotoXY(16 + SX, I);
    for J := SX to EX do
    begin
      C := CHAR_ARR[Board[J, I]];
      if Invers then
        C := Char(Byte(C) or $80);
      CRT_Write(C);
    end;
  end;
end;

procedure DrawBoard; overload;
begin
  DrawBoard(0, 0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, False);
end;

procedure DrawRect(SX, SY, EX, EY: Byte);
var
  X, Y: Byte;
begin
  if (SX = EX) and (SY = EY) then
  begin
    Board[SX, SY] := LastLevel;
    Exit;
  end;
  if SX > EX then
  begin
    X := EX;
    EX := SX;
    SX := X;
  end;
  if SY > EY then
  begin
    Y := EY;
    EY := SY;
    SY := Y;
  end;
  for X := SX to EX do
    for Y := SY to EY do
      Board[X, Y] := LastLevel;
end;

function EnterFileName: String;
begin
  CRT_GotoXY(0, 19);
  CRT_Write(BOX_BAR);
  CRT_GotoXY(0, 20);
  CRT_Write('Enter file name'~);
  CRT_GotoXY(0, 21);
  Result := CRT_ReadStringEx(15, TReadMode.roUpper);
end;

procedure ClearFileName;
begin
  CRT_GotoXY(0, 19);
  CRT_Write('               |'~);
  CRT_GotoXY(0, 20);
  CRT_Write('               '~);
  CRT_GotoXY(0, 21);
  CRT_Write('               '~);
end;

procedure SaveBoard;
var
  FN: String;
  F: File;
  Err: Boolean;
begin
  Err := False;
  FN := EnterFileName;
  if Length(FN) > 0 then
  begin
    Assign(F, FN);
    if IOResult <= 127 then
    begin
      Rewrite(F, 1);
      if IOResult <= 127 then
      begin
        BlockWrite(F, Board, SizeOf(Board));
        if IOResult > 127 then
          Err := True;
      end
      else
        Err := True;
      Close(F);
    end
    else
      Err := True;
  end;
  if Err then
  begin
    CRT_GotoXY(0, 20);
    CRT_Write('Error on save..'~);
    CRT_ReadKey;
  end;
  ClearFileName;
end;

procedure LoadBoard;
var
  FN: String;
  F: File;
  Err: Boolean;
  X, Y: Byte;
  W: Word;
begin
  Err := False;
  FN := EnterFileName;
  if Length(FN) > 0 then
  begin
    if FileExists(FN) then
    begin
      Assign(F, FN);
      if IOResult <= 127 then
      begin
        Reset(F, 1);
        if IOResult <= 127 then
        begin
          BlockRead(F, Board, SizeOf(Board), W);
          if IOResult > 127 then
            Err := True
          else
            for X := 0 to BOARD_WIDTH - 1 do
              for Y := 0 to BOARD_HEIGHT - 1 do
                if Board[X, Y] > 9 then
                  Board[X, Y] := 9;
        end
        else
          Err := True;
        Close(F);
      end
      else
        Err := True;
    end
    else
      Err := True;
  end;
  if Err then
  begin
    CRT_GotoXY(0, 20);
    CRT_Write('Error on load..'~);
    CRT_ReadKey;
  end;
  ClearFileName;
end;

procedure ReadDensity;
var
  S: String;
  ND: Byte;
begin
  CRT_GotoXY(0, 19);
  CRT_Write(BOX_BAR);
  CRT_GotoXY(0, 20);
  CRT_Write('Density  1 - 99'~);
  CRT_GotoXY(0, 21);
  S := CRT_ReadStringEx(2, TReadMode(roNumber));
  if Length(S) > 0 then
  begin
    ND := StrToInt(S);
    if ND > 99 then
      ND := 99
    else if ND = 0 then
      ND := 1;
    Density := ND;
  end;
  ClearFileName;
end;

procedure ClearBoard;
begin
  FillChar(Board, SizeOf(Board), 0);
end;

procedure DemoBoard;
var
  X, Y, L: Byte;
begin
  ClearBoard;
  for L := 1 to 9 do
    for X := L - 1 to 18 - L do
      for Y := L - 1 to 18 - L do
        Board[X + 3, Y + 3] := L;
end;

function YesNo(AMsg: String): Boolean;
var
  Ch: Char;
begin
  CRT_GotoXY(0, 20);
  CRT_Write(BOX_BAR);
  CRT_GotoXY(0, 21);
  CRT_Write(AMsg);
  repeat
    Ch := UpCase(Char(CRT_ReadChar));
  until (Ch = 'Y') or (Ch = 'N') or (Ch = CHAR_ESCAPE);
  Result := Ch = 'Y';
  CRT_GotoXY(0, 20);
  CRT_Write('               |'~);
  CRT_GotoXY(0, 21);
  CRT_Write('               '~);
end;

procedure Paint;

function GetBoardLevel(X, Y: Word): Byte;
var
  BX, BY: Byte;
begin
  if (X >= 40) and (X < 280) then
  begin
    BX := (X - 40) div 10;
    BY := Y div 8;
    Result := Board[BX, BY];
  end
  else
    Result := 0;
end;

var
  X, Y: Word;
  S, L: Byte;
begin
  for Y := 0 to 191 do
    for X := 0 to 31 do
      if Random(100) > Density then
        PutPixel(X, Y, 1);
  for S := 1 to 9 do
    for Y := 0 to 191 do
      for X := 0 to 31 do
      begin
        L := GetBoardLevel((S - 1) * 32 + X + 16, Y);
        PutPixel(S * 32 + X - L, Y, GetPixel((S - 1) * 32 + X, Y));
        if CRT_KeyPressed then
          Exit;
      end;
end;

procedure UpdateCurosPos(X, Y: Byte); overload;
var
  Ch: Char;
begin
  if (X <= BOARD_WIDTH - 1) and (Y <= BOARD_WIDTH - 1) and ((X <> PosX) or (Y <> PosY)) then
  begin
    CRT_GotoXY(16 + PosX, PosY);
    CRT_Write(CHAR_ARR[Board[PosX, PosY]]);
    PosX := X;
    PosY := Y;
  end;
  Ch := Char(Byte(CHAR_ARR[Board[PosX, PosY]]) or $80);
  CRT_GotoXY(16 + PosX, PosY);
  CRT_Write(Ch);
  CRT_GotoXY(1, 23);
  if PosX < 9 then
    CRT_Write(' '~);
  CRT_Write(PosX + 1);
  CRT_GotoXY(5, 23);
  if PosY < 9 then
    CRT_Write(' '~);
  CRT_Write(PosY + 1);
  CRT_GotoXY(9, 23);
  CRT_Write(CHAR_ARR[LastLevel]);
  CRT_Write(MODE_CHR[Ord(Mode)]);
  CRT_GotoXY(13, 23);
  if Density < 10 then
    CRT_Write(' '~);
  CRT_Write(Density);

  if (Mode = mRectangle) and (SubMode = smSelectPt2) then
  begin
    DrawBoard;
    DrawBoard(PtX, PtY, PosX, PosY, True)
  end
end;

procedure UpdateCurosPos; overload;
begin
  UpdateCurosPos(PosX, PosY);
end;

procedure ShowHelp;
begin
  CRT_Clear;
  CRT_GotoXY(0, 0);
  CRT_Write(HELP_MSG0);
  CRT_Write(HELP_MSG1_1);
  CRT_Write(HELP_MSG1_2);
  CRT_Write(HELP_MSG1_3);
  CRT_Write(HELP_MSG1_4);
  CRT_ReadKey;
  CRT_GotoXY(0, 3);
  CRT_Write(HELP_MSG2_1);
  CRT_Write(HELP_MSG2_2);
  CRT_Write(HELP_MSG2_3);
  CRT_Write(HELP_MSG2_4);
  CRT_ReadKey;
  CRT_Clear;
  CRT_GotoXY(0, 0);
  CRT_Write(HELP_MSG0);
  CRT_Write(HELP_MSG3_1);
  CRT_GotoXY(0, 7);
  CRT_Write(HELP_MSG3_2);
  CRT_ReadKey;
  CRT_Clear;
  DrawLegend;
  DrawBoard;
  UpdateCurosPos;
end;

begin
  Randomize;

  Density := DEF_DENSITY;
  DoQuit := False;
  Mode := mDefault;

  DemoBoard;

  InitGraph(0);

  CRT_Init;
  CRT_Clear;

  DrawLegend;
  DrawBoard;

  PosX := 1;
  PosY := 1;

  UpdateCurosPos(0, 0);

  repeat
    Key := Char(CRT_ReadChar);
    case UpCase(Key) of
      'W', #45: begin
        if (Mode = mPaint) and (PosY > 0) then
          Board[PosX, PosY - 1] := LastLevel;
        UpdateCurosPos(PosX, PosY - 1);
      end;
      'S', #61: begin
        if (Mode = mPaint) and (PosY < BOARD_HEIGHT - 1) then
          Board[PosX, PosY + 1] := LastLevel;
        UpdateCurosPos(PosX, PosY + 1);
      end;
      'A', #43: begin
        if (Mode = mPaint) and (PosX > 0) then
          Board[PosX - 1, PosY] := LastLevel;
        UpdateCurosPos(PosX - 1, PosY);
      end;
      'D', #42: begin
        if (Mode = mPaint) and (PosX < BOARD_WIDTH - 1) then
          Board[PosX + 1, PosY] := LastLevel;
        UpdateCurosPos(PosX + 1, PosY);
      end;
      '0'..'9': begin
        LastLevel := StrToInt(Key);
        if (Mode = mDefault) or (Mode = mPaint) then
          Board[PosX, PosY] := LastLevel;
        UpdateCurosPos;
      end;
      ' ', CHAR_RETURN: begin
        if Mode = mRectangle then
          if SubMode = smSelectPt1 then
          begin
            PtX := PosX;
            PtY := PosY;
            SubMode := smSelectPt2;
          end
          else
          begin
            DrawRect(PtX, PtY, PosX, PosY);
            SubMode := smSelectPt1;
            DrawBoard;
          end
        else
          Board[PosX, PosY] := LastLevel;
        UpdateCurosPos;
      end;
      CHAR_BACKSPACE: begin
        Board[PosX, PosY] := 0;
        UpdateCurosPos;
      end;
      'C': if YesNo('Clear all?  Y/N'~) then
      begin
        ClearBoard;
        DrawBoard;
        UpdateCurosPos;
      end;
      'X', CHAR_ESCAPE: begin
        if (Mode = mRectangle) and (SubMode = smSelectPt2) then
        begin
          SubMode := smSelectPt1;
          DrawBoard(PtX, PtY, PosX, PosY, False);
          UpdateCurosPos;
        end
        else
          DoQuit := YesNo('Quit?       Y/N'~);
      end;
      'K': SaveBoard;
      'L': begin
        LoadBoard;
        DrawBoard;
        UpdateCurosPos;
      end;
      'P': begin
        InitGraph(8 + 16);
        Paint;
        PKey := #0;
        repeat
          PKey := Char(CRT_ReadChar);
        until PKey = CHAR_ESCAPE;
        InitGraph(0);
        DrawLegend;
        DrawBoard;
        UpdateCurosPos;
      end;
      'G': begin
        ReadDensity;
        UpdateCurosPos;
      end;
      'M': begin
        if Mode = mRectangle then
        begin
          if SubMode = smSelectPt2 then
            DrawBoard;
          Mode := mDefault;
        end
        else
          Inc(Mode);
        SubMode := smSelectPt1;
        UpdateCurosPos;
      end;
      'H': ShowHelp;
    end;
  until DoQuit;
  CRT_Clear;
  CRT_WriteCentered(11, ' BYE... '~*);
end.
