// 8

uses crt;

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

  OPERATION_CAPTIONS: array[0..21] of Byte = (
    ord(capKnuthShuffle),
    ord(capFillAscendingWithShuffle),
    ord(capFillAscending),
    ord(capFillDescending),
    ord(capFillPyramid),
    ord(capFillInterlaced),
    ord(capInsertionSort),
    ord(capSelectionSort),
    ord(capQuickSort),
    ord(capMergeSort),
    ord(capBubbleSort),
    ord(capCoctailSort),
    ord(capGnomeSort),
    ord(capCircleSort),
    ord(capCombSort),
    ord(capPancakeSort),
    ord(capShellSort),
    ord(capOddEvenSort),
    ord(capBitonicSort),
    ord(capRadixSort),
    ord(capHeapSort),
    ord(capDoubleSelectionSort)
  );


procedure PutCaption(caption: TCaption);
begin

 writeln(ord(caption));

end;


begin

PutCaption(TCaption(OPERATION_CAPTIONS[5]));

repeat until keypressed;

end.
