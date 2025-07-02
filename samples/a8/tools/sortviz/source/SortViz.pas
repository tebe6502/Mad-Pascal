uses crt, sysutils;

uses Core, ArrayAccess, DisplayList, ShuffleAlgorithms, ImageManager, SortingAlgorithms, Status, Operation, Keyboard;

{$R 'data.rc'}

//{$define basicoff}

var
  key: Byte;

procedure RunOperation;
begin
  UpdateOperationCaption;
  ResetStatistics;

  case operationKind of
    okFillAscending: FillAscending;
    okFillDescending: FillDescending;
    okFillPyramid: FillPyramid;
    okFillInterlaced: FillInterlaced;
    okKnuthShuffle: KnuthShuffle;
    okFillAscendingWithShuffle: FillAscendingWithShuffle;
    okInsertionSort: InsertionSort;
    okSelectionSort: SelectionSort;
    okQuickSort: QuickSort;
    okMergeSort: MergeSort;
    okBubbleSort: BubbleSort;
    okCoctailSort: CoctailSort;
    okGnomeSort: GnomeSort;
    okCircleSort: CircleSort;
    okCombSort: CombSort;
    okPancakeSort: PancakeSort;
    okShellSort: ShellSort;
    okOddEvenSort: OddEvenSort;
    okBitonicSort: BitonicSort;
    okRadixSort: RadixSort;
    okHeapSort: HeapSort;
    okDoubleSelectionSort: DoubleSelectionSort;
  end;

  ForceUpdateStatistics;
  Clear;
end;

function TryRunOperation: Boolean;
var
  i: Byte;
begin
  for i := 0 to MAX_OPERATION do
  begin
    if OPERATION_SHORTCUTS[i] = key then
    begin
      operationKind := TOperationKind(i);
      demo := False;
      workingMode := wmProcessing;
      UpdateStatus;

      RunOperation;

      workingMode := wmMainMenu;
      UpdateStatus;
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

function ChooseDemoMethod: Boolean;
var
  i: Byte;
begin
  workingMode := wmDemoSettings;
  UpdateStatus;

  while True do
  begin
    key := GetKey;
    for i := okKnuthShuffle to okFillInterlaced do
    begin
      if key = OPERATION_SHORTCUTS[i] then
      begin
        demoShuffleMethod := TOperationKind(i);
        Result := True;
        Exit;
      end;
      if key = KEY_ESC then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure RunDemo;
var
  i: Byte;
begin
  if ChooseDemoMethod then
  begin
    demo := True;
    workingMode := wmProcessing;
    UpdateStatus;

    operationCount := OPERATION_COUNT - okInsertionSort;
    operationIndex := 1;
    for i := okInsertionSort to MAX_OPERATION do
    begin
      operationKind := demoShuffleMethod;
      RunOperation;
      if aborted then break;
      Delay(200);
      operationKind := TOperationKind(i);
      RunOperation;
      if aborted then break;
      Delay(1000);
      Inc(operationIndex);
    end;
  end;

  workingMode := wmMainMenu;
  UpdateStatus;
end;

procedure ProcessQuitQuery;
var
  key: Byte;
begin
  NoSound;
  workingMode := wmQuitQuery;
  UpdateStatus;

  while True do
  begin
    key := GetKey;
    if key = KEY_Y then
    begin
      quit := True;
      break;
    end
    else if key = KEY_N then
    begin
      break;
    end;
  end;

  workingMode := wmMainMenu;
  UpdateStatus;
end;

procedure SplashScreen;
const
  MAX_LUMINANCE = 15;
  FADE_DELAY = 40;
  SPLASH_DELAY = 2000;
  DELAY_AFTER = 500;
var
  i: Byte;
begin
  SplashScreenShuffle;

  for i := 0 to MAX_LUMINANCE do
  begin
    color1Value := i;
    Delay(FADE_DELAY);
  end;

  SplashScreenSort;
  Delay(SPLASH_DELAY);

  for i := MAX_LUMINANCE downto 0 do
  begin
    color1Value := i;
    Delay(FADE_DELAY);
  end;

  Delay(DELAY_AFTER);
end;

begin
  Randomize;

  InitScreen;
  SplashScreen;
  NextImage;
  InitColors;

  operationKind := okFillAscending;
  RunOperation;
  UpdateStatus;

  repeat
    key := GetKey;
    if not TryRunOperation then
    begin
      case key of
        KEY_TAB: NextImage;
        KEY_MINUS: DecreaseDelay;
        KEY_PLUS: IncreaseDelay;
        KEY_RETURN: RunDemo;
        KEY_ESC: ProcessQuitQuery;
      end;
    end;
  until quit;

  CloseScreen;
end.