unit Operation;

interface

uses
  Core, Caption, Keyboard;

type
  TOperationKind =
  (
    okKnuthShuffle,
    okFillAscendingWithShuffle,
    okFillAscending,
    okFillDescending,
    okFillPyramid,
    okFillInterlaced,
    okInsertionSort,
    okSelectionSort,
    okQuickSort,
    okMergeSort,
    okBubbleSort,
    okCoctailSort,
    okGnomeSort,
    okCircleSort,
    okCombSort,
    okPancakeSort,
    okShellSort,
    okOddEvenSort,
    okBitonicSort,
    okRadixSort,
    okHeapSort,
    okDoubleSelectionSort
  );

  TWorkingMode =
  (
    wmMainMenu,
    wmDemoSettings,
    wmProcessing,
    wmPaused,
    wmQuitQuery
  );

const
  OPERATION_COUNT = 22;
  MAX_OPERATION = OPERATION_COUNT - 1;
  
  OPERATION_CAPTIONS: array[0..MAX_OPERATION] of Byte = (
    capKnuthShuffle,
    capFillAscendingWithShuffle,
    capFillAscending,
    capFillDescending,
    capFillPyramid,
    capFillInterlaced,
    capInsertionSort,
    capSelectionSort,
    capQuickSort,
    capMergeSort,
    capBubbleSort,
    capCoctailSort,
    capGnomeSort,
    capCircleSort,
    capCombSort,
    capPancakeSort,
    capShellSort,
    capOddEvenSort,
    capBitonicSort,
    capRadixSort,
    capHeapSort,
    capDoubleSelectionSort
  );

  OPERATION_SHORTCUTS: array[0..MAX_OPERATION] of Byte =(
    KEY_1,  //okKnuthShuffle,
    KEY_2,  //okFillAscendingWithShuffle
    KEY_3,  //okFillAscending,
    KEY_4,  //okFillDescending,
    KEY_5,  //okFillPyramid,
    KEY_6,  //okFillInterlaced,
    KEY_I,  //okInsertionSort,
    KEY_S,  //okSelectionSort,
    KEY_Q,  //okQuickSort,
    KEY_M,  //okMergeSort,
    KEY_B,  //okBubbleSort,
    KEY_C,  //okCoctailSort,
    KEY_G,  //okGnomeSort,
    KEY_L,  //okCircleSort,
    KEY_O,  //okCombSort,
    KEY_P,  //okPancakeSort,
    KEY_E,  //okShellSort,
    KEY_V,  //okOddEvenSort,
    KEY_T,  //okBitonicSort,
    KEY_R,  //okRadixSort,
    KEY_H,  //okHeapSort,
    KEY_D   //okDoubleSelectionSort
  );

  OPERATION_SHORTCUT_TEXTS: array[0..MAX_OPERATION] of Char =(
    '1'~*,  //okKnuthShuffle,
    '2'~*,  //okFillAscendingWithShuffle
    '3'~*,  //okFillAscending,
    '4'~*,  //okFillDescending,
    '5'~*,  //okFillPyramid,
    '6'~*,  //okFillInterlaced,
    'I'~*,  //okInsertionSort,
    'S'~*,  //okSelectionSort,
    'Q'~*,  //okQuickSort,
    'M'~*,  //okMergeSort,
    'B'~*,  //okBubbleSort,
    'C'~*,  //okCoctailSort,
    'G'~*,  //okGnomeSort,
    'L'~*,  //okCircleSort,
    'O'~*,  //okCombSort,
    'P'~*,  //okPancakeSort,
    'E'~*,  //okShellSort,
    'V'~*,  //okOddEvenSort,
    'T'~*,  //okBitonicSort,
    'R'~*,  //okRadixSort,
    'H'~*,  //okHeapSort,
    'D'~*   //okDoubleSelectionSort
  );

var
  workingMode: TWorkingMode;
  demo: Boolean;
  operationCount: Byte;
  operationIndex: Byte;
  operationKind: TOperationKind;
  demoShuffleMethod: TOperationKind;
  aborted: Boolean;
  quit: Boolean;

implementation

initialization
  workingMode := wmMainMenu;
  demo := False;
  aborted := False;
  quit := False;
end.