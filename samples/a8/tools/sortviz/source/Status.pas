unit Status;

interface

uses
  Operation;

procedure UpdateOperationCaption;
procedure IncReadCount;
procedure IncWriteCount;
procedure ResetStatistics;
procedure UpdateStatistics;
procedure ForceUpdateStatistics;
procedure UpdateDelay;
procedure UpdateStatus;

implementation

uses
  Core, Caption;

const
  DIGIT_COUNT = 5;
  MAX_DIGIT = DIGIT_COUNT - 1;
var
  readCount: array[0..MAX_DIGIT] of Byte;
  writeCount: array[0..MAX_DIGIT] of Byte;
  readChanged: Boolean;
  writeChanged: Boolean;
  accessRtClock: Byte;
  numberPtr: PByte;
  textPtr: PByte;
  textBuf: array[0..TEXT_LINE_STEP] of Byte;
  textLen: Byte;

procedure PutByteToTextBuffer(value: Byte);
var
  tmp: Byte;
  ptr: PByte;
begin
  if value >= 100 then
  begin
    Inc(textPtr, 3);
    Inc(textLen, 3);
  end
  else if value >= 10 then
  begin
    Inc(textPtr, 2);
    Inc(textLen, 2);
  end
  else begin
    Inc(textPtr);
    Inc(textLen);
  end;

  ptr := textPtr;

  repeat
    Dec(ptr);
    tmp := value mod 10;
    Inc(tmp, Ord('0'~));
    ptr^ := tmp;
    value := value div 10;
  until value = 0;  
end;

procedure PutCaption(caption: TCaption);
var
  len: Byte;
begin
  len := CAPTIONS_LENGTHS[caption];
  Move(Pointer(CAPTIONS[caption]), textPtr, len);
  Inc(textPtr, len);
  Inc(textLen, len);
end;

procedure PutCharToTextBuffer(c: Char);
begin
  textPtr^ := Byte(c);
  Inc(textPtr);
  Inc(textLen);
end;

procedure UpdateOperationCaption;
var
  pos: Byte;
const
  DEMO_1_STR_LEN: Byte = 6;
  DEMO_2_STR_LEN: Byte = 4;
begin
  textLen := 0;
  textPtr := @textBuf[0];

  if workingMode = wmMainMenu then
  begin
    PutCaption(TCaption(capMainMenuCaption));
  end
  else if workingMode = wmDemoSettings then
  begin
    PutCaption(TCaption(capDemoMethodCaption));
  end
  else if workingMode = wmPaused then
  begin
    PutCaption(TCaption(capPausedCaption));
  end
  else if workingMode = wmQuitQuery then
  begin
    PutCaption(TCaption(capQuitCaption));
  end
  else if workingMode = wmProcessing then
  begin
    if demo then
    begin
      PutCaption(TCaption(capDemo1));

      PutByteToTextBuffer(operationIndex);
      PutCharToTextBuffer('/'~);
      PutByteToTextBuffer(operationCount);

      PutCaption(TCaption(capDemo2));
    end;
    PutCaption(TCaption(OPERATION_CAPTIONS[operationKind]));
  end;

  FillChar(Pointer(TEXT_LINE_1_ADDR), TEXT_LINE_STEP, 0);
  pos := (TEXT_LINE_STEP - textLen) shr 1;
  Move(Pointer(@textBuf[0]), Pointer(TEXT_LINE_1_ADDR + pos), textLen);
end;

procedure ClearNumber;
begin
  FillChar(numberPtr, DIGIT_COUNT, 0);
end;

procedure IncNumber;
var
  i: Byte;
begin
  i := MAX_DIGIT;
  Inc(numberPtr, i);
  while True do
  begin
    if numberPtr^ = 9 then
    begin
      numberPtr^ := 0;
      if i > 0 then
      begin
        Dec(i);
        Dec(numberPtr);
      end
      else break;
    end
    else begin
      Inc(numberPtr^);
      break;
    end;
  end;
end;

procedure IncReadCount;
begin
  numberPtr := @readCount[0];
  readChanged := True;
  IncNumber;
end;

procedure IncWriteCount;
begin
  numberPtr := @writeCount[0];
  writeChanged := True;
  IncNumber;
end;

procedure WriteNumber;
var
  i, tmp: Byte;
  ptr: PByte;
begin
  for i := 0 to MAX_DIGIT do
  begin
    tmp := numberPtr^;
    Inc(tmp, Ord('0'~));
    textPtr^ := tmp;
    Inc(numberPtr);
    Inc(textPtr);
  end;
end;

procedure UpdateStatistics;
const
  READS_ADDR: Word = TEXT_LINE_2_ADDR + 8;
  WRITES_ADDR: Word = TEXT_LINE_2_ADDR + 23;
begin
  if accessRtClock <> RTCLOK then
  begin
    accessRtClock := RTCLOK;
    if readChanged then
    begin
      textPtr := Pointer(READS_ADDR);
      numberPtr := @readCount[0];
      WriteNumber;
      readChanged := False;
    end;

    if writeChanged then
    begin
      textPtr := Pointer(WRITES_ADDR);
      numberPtr := @writeCount[0];
      WriteNumber;
      writeChanged := False;
    end;
  end;
end;

procedure ForceUpdateStatistics;
const
  READS_ADDR: Word = TEXT_LINE_2_ADDR + 8;
  WRITES_ADDR: Word = TEXT_LINE_2_ADDR + 23;
begin
  accessRtClock := RTCLOK;
  textPtr := Pointer(READS_ADDR);
  numberPtr := @readCount[0];
  WriteNumber;
  readChanged := False;

  textPtr := Pointer(WRITES_ADDR);
  numberPtr := @writeCount[0];
  WriteNumber;
  writeChanged := False;
end;

procedure UpdateDelay;
const
  ADDR: Word = TEXT_LINE_2_ADDR + 37;
begin
  textPtr := Pointer(ADDR);
  PutByteToTextBuffer(accessDelay);
  if accessDelay < 100 then
    PutCharToTextBuffer(' '~);
end;

procedure ResetStatistics;
const
  READS_ADDR: Word = TEXT_LINE_2_ADDR + 2;
  WRITES_ADDR: Word = TEXT_LINE_2_ADDR + 16;
  DELAY_ADDR: Word = TEXT_LINE_2_ADDR + 31;
begin
  aborted := False;

  FillChar(Pointer(TEXT_LINE_2_ADDR), LINE_STEP, 0);

  textPtr := Pointer(READS_ADDR);
  PutCaption(TCaption(capReads));
  textPtr := Pointer(WRITES_ADDR);
  PutCaption(TCaption(capWrites));
  textPtr := Pointer(DELAY_ADDR);
  PutCaption(TCaption(capDelay));

  UpdateDelay;

  numberPtr := @readCount[0];
  readChanged := True;
  ClearNumber;
  numberPtr := @writeCount[0];
  writeChanged := True;
  ClearNumber;

  ForceUpdateStatistics;
end;

procedure UpdateStatus;
const
  RESTART_ADDR: Word = SCROLL_LINE_ADDR + TEXT_LINE_STEP;
var
  len: Byte;
  i: Byte;
  last: Byte;
  scrollActive: Boolean;
begin
  UpdateOperationCaption;

  pauseScroll := True;
  textPtr := Pointer(SCROLL_LINE_ADDR);
  textLen := 0;
  FillChar(textPtr, SCROLL_LINE_LENGTH, 0);

  scrollActive := (workingMode = wmMainMenu) or (workingMode = wmDemoSettings);
  
  if scrollActive then
    Inc(textPtr, TEXT_LINE_STEP);

  if (workingMode = wmMainMenu) or (workingMode = wmDemoSettings) then
  begin
    if workingMode = wmDemoSettings then
    begin
      PutCaption(TCaption(capDemoMethodKeys));
      last := Byte(okFillInterlaced);
    end
    else begin
      PutCaption(TCaption(capMainMenuKeys));
      last := MAX_OPERATION;
    end;

    for i := 0 to last do
    begin
      PutCharToTextBuffer(' '~);
      PutCharToTextBuffer(Char($40));
      PutCharToTextBuffer(OPERATION_SHORTCUT_TEXTS[i]);
      PutCharToTextBuffer(Char($41));
      PutCaption(TCaption(OPERATION_CAPTIONS[i]));
    end;
  end
  else if workingMode = wmPaused then
  begin
    Inc(textPtr, 7);
    PutCaption(TCaption(capPausedKeys));
  end
  else if workingMode = wmProcessing then
  begin
    Inc(textPtr, 3);
    PutCaption(TCaption(capProcessingKeys));
  end
  else if workingMode = wmQuitQuery then
  begin
    Inc(textPtr, 12);
    PutCaption(TCaption(capQuitKeys));
  end
  else Exit;

  if scrollActive then
  begin
    // clone text to fill the whole visible line
    len := textLen;
    while textLen < TEXT_LINE_STEP do
    begin
      Move(Pointer(RESTART_ADDR), textPtr, len);
      Inc(textLen, len);
      Inc(textPtr, len);
    end;

    // clone beginning of text to wrap it
    Move(Pointer(Word(RESTART_ADDR)), textPtr, TEXT_LINE_STEP);
    scrollEndAddr := Word(textPtr);
    pauseScroll := False;
  end;

  resetScroll := True;
end;

end.