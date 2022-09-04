unit SortingAlgorithms;

interface

procedure BubbleSort;
procedure InsertionSort;
procedure SelectionSort;
procedure QuickSort;
procedure MergeSort;
procedure CoctailSort;
procedure GnomeSort;
procedure CircleSort;
procedure CombSort;
procedure PancakeSort;
procedure ShellSort;
procedure OddEvenSort;
procedure BitonicSort;
procedure RadixSort;
procedure HeapSort;
procedure DoubleSelectionSort;
procedure SplashScreenSort;

implementation

uses ArrayAccess, Core, Operation;

procedure BubbleSort;
var
  last: Byte;
  i, j, k: Byte;
  v1, v2: Byte;
begin
  last := MAX_INDEX - 1;
  for i := 0 to MAX_INDEX - 1 do
  begin
    for j := 0 to last do
    begin
      if aborted then Exit;

      k := j + 1;
      v1 := GetValue(j);
      v2 := GetValue(k);
      if v1 > v2 then
      begin
        SetValue(j, v2);
        SetValue(k, v1);
      end;
    end;
    Dec(last);
  end;
end;

procedure InsertionSort;
var
  i, j: Byte;
  tmp, val: Byte;
begin
  for i := 1 to MAX_INDEX do
  begin
    if aborted then Exit;
    tmp := GetValue(i);
    j := i;
    while j > 0 do
    begin
      val := GetValue(j - 1);
      if val <= tmp then break;

      SetValue(j, val);
      Dec(j);
    end;
    SetValue(j, tmp);
  end;
end;

procedure SelectionSort;
var
  i, j: Byte;
  tmp, val: Byte;
begin
  for i := 0 to MAX_INDEX - 1 do
  begin
    tmp := i;
    val := GetValue(tmp);
    for j := i + 1 to MAX_INDEX do
    begin
      if aborted then Exit;
      if GetValue(j) < val then
      begin
        tmp := j;
        val := GetValue(tmp);
      end;
    end;
    SwapValues(i, tmp);
  end;
end;

procedure QuickSort;

  procedure InternalQuickSort(left, right: Byte);
  var
    i, j, mid: Byte;
    pivot: Byte;
  begin
    i := left;
    j := right;
    mid := left + (right - left) shr 1;
    pivot := GetValue(mid);
    repeat
      if aborted then Exit;
      while pivot > GetValue(i) do
      begin
        if i = MAX_INDEX then break;
        Inc(i);
      end;

      while pivot < GetValue(j) do
      begin
        if j = 0 then break;
        Dec(j);
      end;
      
      if i <= j then
      begin
        SwapValues(i, j);
        if i = MAX_INDEX then break;
        Inc(i);
        if j = 0 then break;
        Dec(j);
      end;
    until i > j;

    if left < j then
    begin
      InternalQuickSort(left, j);
    end;
    if i < right then
    begin
      InternalQuickSort(i, right);
    end;
  end;

begin
  InternalQuickSort(0, MAX_INDEX);
end;

procedure MergeSort;

  procedure Merge(left, mid, right: Byte);
  var
    left2, val, ind: Byte;
  begin
    left2 := mid + 1;
    if GetValue(mid) <= GetValue(left2) then Exit;

    while (left <= mid) and (left2 <= right) do
    begin
      if aborted then Exit;
      val := GetValue(left2);
      if GetValue(left) <= val then
      begin
        Inc(left);
      end
      else begin
        ind := left2;

        while ind <> left do
        begin
          SetValue(ind, GetValue(ind - 1));
          Dec(ind);
        end;
        SetValue(left, val);

        Inc(left);
        Inc(mid);
        Inc(left2);
      end;
    end;
  end;

  procedure InternalMergeSort(left, right: Byte);
  var
    mid: Byte;
  begin
    if aborted then Exit;
    if left < right then
    begin
      mid := left + (right - left) shr 1;
      InternalMergeSort(left, mid);
      InternalMergeSort(mid + 1, right);
      Merge(left, mid, right);
    end;
  end;

begin
  InternalMergeSort(0, MAX_INDEX);
end;

procedure CoctailSort;
var
  swapped: Boolean;
  i, j, v1, v2: Byte;
  left, right: Byte;
begin
  left := 0;
  right := MAX_INDEX;

  repeat

    swapped := False;

    for i := left to right - 1 do
    begin
      if aborted then Exit;
      j := i + 1;
      v1 := GetValue(i);
      v2 := GetValue(j);
      if v1 > v2 then
      begin
        SetValue(i, v2);
        SetValue(j, v1);
        swapped := True;
      end;
    end;

    if not swapped then Break;

    swapped := False;
    Dec(right);

    for i := right - 1 downto left do
    begin
      if aborted then Exit;
      j := i + 1;
      v1 := GetValue(i);
      v2 := GetValue(j);
      if v1 > v2 then
      begin
        SetValue(i, v2);
        SetValue(j, v1);
        swapped := True;
      end;
    end;

    Inc(left);

  until not swapped;
end;

procedure GnomeSort;
var
  i, j: Byte;
  v1, v2: Byte;
begin
  i := 1;
  j := 2;
  while i < TABLE_SIZE do
  begin
    if aborted then Exit;
    v1 := GetValue(i - 1);
    v2 := GetValue(i);
    if v1 <= v2 then
    begin
      i := j;
      Inc(j);
    end
    else begin
      SetValue(i - 1, v2);
      SetValue(i, v1);
      Dec(i);
      if i = 0 then
      begin
        i := j;
        Inc(j);
      end;
    end;
  end;
end;

procedure CircleSort;
var
  swaps: Integer;

  procedure CircleSortInternal(left, right: Byte);
  var
    l, r, mid: Byte;
    v1, v2: Byte;
  begin
    if left < right then
    begin
	    l := left;
	    r := right;
	 
      while l < r do
	    begin
        if aborted then Exit;
        v1 := GetValue(r);
        v2 := GetValue(l);
	      if v1 < v2 then
	      begin
          SetValue(r, v2);
          SetValue(l, v1);
          Inc(swaps);
  	    end;
	      Inc(l);
	      Dec(r);
	    end;

	    if l = r then
      begin
        v1 := GetValue(l + 1);
        v2 := GetValue(l);
        if v1 < v2 then
	      begin
          SetValue(l, v1);
          SetValue(l + 1, v2);
          Inc(swaps);
        end;
      end;

	    mid := (l + r) shr 1;
	 
      CircleSortInternal(left, mid);
	    CircleSortInternal(mid + 1, right);
    end
  end;

begin
  swaps := 1;
  while swaps > 0 do
  begin
    if aborted then Exit;
    swaps := 0;
    CircleSortInternal(0, MAX_INDEX);
  end
end;

procedure CombSort;
var
  i, gap: Byte;
  swapped: Boolean;
  v1, v2: Byte;
begin
  gap := TABLE_SIZE;
  swapped := True;

  while (gap > 1) or swapped do
  begin
    gap := Trunc(gap / 1.3);
    if gap < 1 then
    begin
      gap := 1;
    end;

    swapped := False;
    for i := 0 to MAX_INDEX - gap do
    begin
      if aborted then Exit;
      v1 := GetValue(i);
      v2 := GetValue(i + gap);
      if v1 > v2 then
      begin
        SetValue(i, v2);
        SetValue(i + gap, v1);
        swapped := True;
      end;
    end;
  end;
end;

procedure PancakeSort;

  procedure Flip(last: Byte);
  var
    i, h: Byte;
  begin
    h := (last - 1) shr 1;
    for i := 0 to h do
    begin
      if aborted then Exit;
      SwapValues(i, last - i);
    end;
  end;

var
  i, j, maxPos, val: Byte;
begin
  for i := TABLE_SIZE downto 1 do
  begin
    maxPos := 0;
    val := GetValue(maxPos);
    for j := 0 to i - 1 do
    begin
      if aborted then Exit;
      if GetValue(j) > val then
      begin
        maxPos := j;
        val := GetValue(maxPos);
      end;
    end;

    if maxPos = i - 1 then
    begin
      continue;
    end;

    if maxPos > 0 then
        Flip(maxPos);

    Flip(i - 1);
  end;
end;

procedure ShellSort;
var
  i, j, step, tmp, val: Byte;
begin
  step := TABLE_SIZE shr 1;

  while step > 0 do
  begin
    for i := step to MAX_INDEX do
    begin
      if aborted then Exit;
      tmp := GetValue(i);
      j := i;

      while j >= step do
      begin
        val := GetValue(j - step);
        if val <= tmp then break;

        SetValue(j - step, GetValue(j));
        SetValue(j, val);
        Dec(j, step);
      end;

      SetValue(j, tmp);
    end;

    step := step shr 1;
  end;
end;

procedure OddEvenSort;
var
  i, v1, v2: Byte;
  sorted: Boolean;
begin
  sorted := False;

  while not sorted do
  begin
    sorted := True;

    i := 1;
    while i < MAX_INDEX do
    begin
      if aborted then Exit;
      v1 := GetValue(i);
      v2 := GetValue(i + 1);
      if v1 > v2 then
      begin
        SetValue(i, v2);
        SetValue(i + 1, v1);
        sorted := False;
      end;
      Inc(i, 2);
    end;

    i := 0;
    while i < MAX_INDEX do
    begin
      if aborted then Exit;
      v1 := GetValue(i);
      v2 := GetValue(i + 1);
      if v1 > v2 then
      begin
        SetValue(i, v2);
        SetValue(i + 1, v1);
        sorted := False;
      end;
      Inc(i, 2);
    end;
  end;
end;

procedure BitonicSort;

  function GetHalfAsPowerOfTwo(size: Byte): Word;
  begin
    Result := 1;
    while Result < size do
    begin
      Result := Result shl 1;
    end;

    Result := Result shr 1;
  end;

  procedure BitonicMerge(left, size: Byte; dir: Boolean);
  var
    half, i, right: Byte;
    v1, v2: Byte;
  begin
    if size > 1 then
    begin
      half := GetHalfAsPowerOfTwo(size);
      right := (size - 1 - half) + left;
      for i := left to right do
      begin
        if aborted then Exit;
        v1 := GetValue(i);
        v2 := GetValue(i + half);
        if dir = (v1 > v2) then
        begin
          SetValue(i, v2);
          SetValue(i + half, v1);
        end;
      end;

      BitonicMerge(left, half, dir);
	    BitonicMerge(left + half, size - half, dir);
    end;
  end;

  procedure BitonicSortInternal(left, size: Byte; dir: Boolean);
  var
    half: Byte;
  begin
    if aborted then Exit;
    if size > 1 then
    begin
      half := size shr 1;
      BitonicSortInternal(left, half, not dir);
      BitonicSortInternal(left + half, size - half, dir);
      BitonicMerge(left, size, dir);
    end;
  end;

begin
  BitonicSortInternal(0, TABLE_SIZE, True);
end;

procedure RadixSort;

  procedure RadixSortInternal(mask, first, last: Byte);
  var
    v1, v2: Byte;
    i, j: Byte;
  begin
    if first >= last then Exit;

    i := first;
    j := last;
    while i < j do
    begin
      if aborted then Exit;
      v1 := GetValue(i);
      if v1 and mask = 0 then
      begin
        Inc(i);
      end
      else begin
        v2 := GetValue(j);
        SetValue(i, v2);
        SetValue(j, v1);
        Dec(j);
      end;
    end;

    if mask = %00000001 then Exit;

    v1 := GetValue(i);
    if v1 and mask = 0 then Inc(j)
    else Dec(i);

    mask := mask shr 1;

    RadixSortInternal(mask, first, i);
    RadixSortInternal(mask, j, last);
  end;

begin
  RadixSortInternal(%10000000, 0, MAX_INDEX);
end;

procedure HeapSort;
var
  i, j, k: Byte;
  v1, v2: Byte;

  procedure BuildHeap;
  begin
    for i := 1 to MAX_INDEX do
    begin
      k := (i - 1) shr 1;
      v1 := GetValue(i);
      v2 := GetValue(k);
      if v1 > v2 then
      begin
        j := i;
        while v1 > v2 do
        begin
          if aborted then Exit;

          SetValue(k, v1);
          SetValue(j, v2);

          if k = 0 then break;

          j := k;
          k := (j - 1) shr 1;

          v1 := GetValue(j);
          v2 := GetValue(k);
        end;
      end;
    end; 
  end;

begin
  BuildHeap;
  if aborted then Exit;

  for i := MAX_INDEX downto 1 do
  begin
    SwapValues(0, i);
    j := 0;

    while True do
    begin
      if aborted then Exit;

      if j >= 127 then break;
      k := (j shl 1) + 1;
      if k + 1 < i then
      begin
        v1 := GetValue(k);
        v2 := GetValue(k + 1);
        if v1 < v2 then
        begin
          Inc(k);
        end;
      end;

      if k < i then
      begin
        v1 := GetValue(j);
        v2 := GetValue(k);
        if v1 < v2 then
        begin
          SetValue(j, v2);
          SetValue(k, v1);
        end;
      end;

      j := k;
      if k >= i then break;
    end;
  end;
end;

procedure DoubleSelectionSort;
var
  i, left, right, val: Byte;
  minInd, maxInd: Byte;
  minVal, maxVal: Byte;
  leftVal, rightVal: Byte;
begin
  left := 0;
  right := MAX_INDEX;

  while left < right do
  begin
    leftVal := GetValue(left);
    rightVal := GetValue(right);

    minInd := left;
    maxInd := left;
    minVal := leftVal;
    maxVal := leftVal;

    for i := left to right do
    begin
      if aborted then Exit;
      val := GetValue(i);
      
      if val > maxVal then
      begin
        maxInd := i;
        maxVal := val;
      end
      else if val < minVal then
      begin
        minInd := i;
        minVal := val;
      end;
    end;

    SwapValues(left, minInd);

    if GetValue(minInd) = maxVal then
    begin
      SwapValues(right, minInd);
    end
    else begin
      SwapValues(right, maxInd);
    end;

    Inc(left);
    Dec(right);
  end;
end;

procedure SplashScreenSort;
const
  MAX_LINE = SPLASH_LINES - 1;
var
  last: Byte;
  i, j, k: Byte;
  v1, v2: Byte;
begin
  last := MAX_LINE - 1;
  for i := 0 to MAX_LINE - 1 do
  begin
    for j := 0 to last do
    begin
      k := j + 1;
      v1 := GetValueSilent(j);
      v2 := GetValueSilent(k);
      if v1 > v2 then
      begin
        SetValueSilent(j, v2);
        SetValueSilent(k, v1);
      end;
    end;
    Dec(last);
  end;
end;

end.