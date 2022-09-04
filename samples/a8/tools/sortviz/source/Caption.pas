unit Caption;

interface

uses
  Core;

type
  TCaption = (
    capDemo1,
    capDemo2,
    capReads,
    capWrites,
    capDelay,
    capFillAscending,
    capFillDescending,
    capFillPyramid,
    capFillInterlaced,
    capKnuthShuffle,
    capFillAscendingWithShuffle,
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
    capDoubleSelectionSort,
    capMainMenuCaption,
    capDemoMethodCaption,
    capPausedCaption,
    capQuitCaption,
    capMainMenuKeys,
    capDemoMethodKeys,
    capProcessingKeys,
    capPausedKeys,
    capQuitKeys
  );

var
  CAPTIONS: array[0..CAPTIONS_COUNT - 1] of Word absolute CAPTIONS_ADDR;
  CAPTIONS_LENGTHS: array[0..CAPTIONS_COUNT - 1] of Byte absolute CAPTIONS_LENGTHS_ADDR;

implementation

end.