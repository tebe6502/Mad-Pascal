unit ArrayAccess;

interface

procedure Clear;
function GetValue(index: Byte): Byte;
function GetValueSilent(index: Byte): Byte;
procedure SetValue(index, value: Byte);
procedure SetValueSilent(index, value: Byte);
procedure SwapValues(index1, index2: Byte);
procedure SwapValuesSilent(index1, index2: Byte);
procedure DecreaseDelay;
procedure IncreaseDelay;
procedure PauseProcessing;
procedure AbortProcessing;

implementation

uses Core, Crt, Status, Operation, ImageManager, Keyboard;

type
  TMarkerKind = (mkNone, mkRead, mkWrite);

const
  MARKER_COUNT = 10;
  MAX_MARKER = MARKER_COUNT - 1;
  PM_OFFSET = 65;

var
  soundChannel: Byte;
  accessDelayIndex: Byte;
  markers: array[0..MAX_MARKER] of Byte;
  markerKinds: array[0..MAX_MARKER] of Byte;
  markerIndex: Byte;

procedure Clear;
const
  P0_ADDR: Word = PM_P0_ADDR + PM_OFFSET;
  P1_ADDR: Word = PM_P1_ADDR + PM_OFFSET;
  P2_ADDR: Word = PM_P2_ADDR + PM_OFFSET;
  P3_ADDR: Word = PM_P3_ADDR + PM_OFFSET;
begin
  NoSound;
  FillChar(Pointer(P0_ADDR), TABLE_SIZE, 0);
  FillChar(Pointer(P1_ADDR), TABLE_SIZE, 0);
  FillChar(Pointer(P2_ADDR), TABLE_SIZE, 0);
  FillChar(Pointer(P3_ADDR), TABLE_SIZE, 0);
  FillChar(Pointer(@markers[0]), MARKER_COUNT, Byte(mkNone));
  markerIndex := 0;
end;

procedure AbortProcessing;
begin
  NoSound;
  aborted := True;
end;

procedure PauseProcessing;
var
  key: Byte;
begin
  NoSound;
  workingMode := wmPaused;
  UpdateStatus;

  while True do
  begin
    key := GetKey;
    if key = KEY_ESC then
    begin
      AbortProcessing;
      break;
    end
    else if key = KEY_SPACE then
    begin
      break;
    end;
  end;

  workingMode := wmProcessing;
  UpdateStatus;
end;

procedure CheckKeyboard;
var
  key: Byte;
begin
  if KeyPressed then
  begin
    key := GetKey;
    case key of
      KEY_MINUS: DecreaseDelay;
      KEY_PLUS: IncreaseDelay;
      KEY_SPACE: PauseProcessing;
      KEY_TAB:
        begin
          NoSound;
          NextImage;
        end;
    end;
  end;
end;

procedure UpdateMarker(index: Byte; newMarkerKind: Byte);
const
  P0_ADDR: Word = PM_P0_ADDR + PM_OFFSET;
  P1_ADDR: Word = PM_P1_ADDR + PM_OFFSET;
  P2_ADDR: Word = PM_P2_ADDR + PM_OFFSET;
  P3_ADDR: Word = PM_P3_ADDR + PM_OFFSET;
  MK_READ: Byte = Byte(mkRead);
  MK_WRITE: Byte = Byte(mkWrite);
  SOUNDS: array[0..MAX_INDEX] of Byte = (
    0, 2, 3, 5, 6, 8, 10, 11, 13, 14, 16, 18, 19, 21, 22, 24, 26, 27, 29, 30,
    32, 34, 35, 37, 38, 40, 42, 43, 45, 47, 48, 50, 51, 53, 55, 56, 58, 59, 61,
    63, 64, 66, 67, 69, 71, 72, 74, 75, 77, 79, 80, 82, 83, 85, 87, 88, 90, 91,
    93, 95, 96, 98, 99, 101, 103, 104, 106, 107, 109, 111, 112, 114, 115, 117,
    119, 120, 122, 123, 125, 127, 128, 130, 132, 133, 135, 136, 138, 140, 141,
    143, 144, 146, 148, 149, 151, 152, 154, 156, 157, 159, 160, 162, 164, 165,
    167, 168, 170, 172, 173, 175, 176, 178, 180, 181, 183, 184, 186, 188, 189,
    191, 192, 194, 196, 197, 199, 200, 202, 204, 205, 207, 208, 210, 212, 213,
    215, 217, 218, 220, 221, 223, 225, 226, 228, 229, 231, 233, 234, 236, 237,
    239, 241, 242, 244, 245, 247, 249, 250, 252, 253, 255);

var
  addr: Word;
  pos: Byte;
  markerKind: Byte;
begin
  Inc(markerIndex);
  if markerIndex = MARKER_COUNT then
  begin
    markerIndex := 0;
  end;
  markerKind := markerKinds[markerIndex];
  pos := markers[markerIndex];

  if markerKind = mkRead then
  begin
    Poke(P1_ADDR + pos, 0);
    Poke(P3_ADDR + pos, 0);
  end
  else if markerKind = mkWrite then
  begin
    Poke(P0_ADDR + pos, 0);
    Poke(P2_ADDR + pos, 0);
  end;
  
  markers[markerIndex] := index;
  markerKinds[markerIndex] := Byte(newMarkerKind);

  if newMarkerKind = mkRead then
  begin
    Poke(P1_ADDR + index, 255);
    Poke(P3_ADDR + index, 255);
  end
  else if newMarkerKind = mkWrite then
  begin
    Poke(P0_ADDR + index, 255);
    Poke(P2_ADDR + index, 255);
  end;

  Sound(soundChannel, SOUNDS[index], 10, 10);
  Inc(soundChannel);
  if soundChannel = 4 then soundChannel := 0;

  UpdateStatistics;
  CheckKeyboard;

  if accessDelayIndex > 0 then
  begin
    Delay(accessDelay);
  end;
end;

function GetValue(index: Byte): Byte;
begin
  Result := Table[index];
  IncReadCount;
  UpdateMarker(index, mkRead);
end;

function GetValueSilent(index: Byte): Byte;
begin
  Result := Table[index];
end;

procedure SetValue(index, value: Byte);
var
  addr: Word;
begin
  Table[index] := value;

  addr := DisplayListLineAddr[index];
  Poke(addr, ImageLineLoAddr[value]);
  Inc(addr);
  Poke(addr, ImageLineHiAddr[value]);

  IncWriteCount;
  UpdateMarker(index, mkWrite);
end;

procedure SetValueSilent(index, value: Byte);
var
  addr: Word;
begin
  Table[index] := value;

  addr := DisplayListLineAddr[index];
  Poke(addr, ImageLineLoAddr[value]);
  Inc(addr);
  Poke(addr, ImageLineHiAddr[value]);
end;

procedure SwapValues(index1, index2: Byte);
var
  v1, v2: Byte;
begin
  v1 := GetValue(index1);
  v2 := GetValue(index2);
  SetValue(index1, v2);
  SetValue(index2, v1);
end;

procedure SwapValuesSilent(index1, index2: Byte);
var
  v1, v2: Byte;
begin
  v1 := GetValueSilent(index1);
  v2 := GetValueSilent(index2);
  SetValueSilent(index1, v2);
  SetValueSilent(index2, v1);
end;

procedure DecreaseDelay;
begin
  if accessDelayIndex > 0 then
  begin
    Dec(accessDelayIndex);
    accessDelay := SET_VALUE_DELAYS[accessDelayIndex];
    UpdateDelay;
  end;
end;

procedure IncreaseDelay;
begin
  if accessDelayIndex < MAX_INDEX_DELAYS then
  begin
    Inc(accessDelayIndex);
    accessDelay := SET_VALUE_DELAYS[accessDelayIndex];
    UpdateDelay;
  end;
end;

initialization
  accessDelayIndex := 0;
  accessDelay := 0;
  soundChannel := 0;
  markerIndex := 0;
end.