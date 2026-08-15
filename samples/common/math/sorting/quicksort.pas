
// http://www.pp4s.co.uk/main/tu-ss-sort-quick.html

// This algorithm seems pretty fast in performance as its name suggests,
// though it's not easy to implement even if getting the gist of how the sorting algorithm works is not that difficult.

// This sorting algorithm uses recursion extensively, so make sure you are quite familiar with recursion,
// and have used it a lot before trying to understand the algorithm. The quick sort works by using a "pivot".
// The pivot is an index pointer just like the ones used in previous sorting algorithms.
// The purpose of the pivot is to divide the list in two halves, one with elements greater than the pivot and the other
// with elements smaller than the pivot. The pivot is usually chosen to be the left-most element of the list, however
// it is not necessary and one may choose any random element from the list to be the pivot. Up till now, we have got
// the array list divided into two halves. Now, we do the same procedure over this two halves just like we did to the whole
// list - and this is what we call recursion. The longer the list, the more recursion there will be - thus
// more resources are requested i.e. memory space.

// Quick-sort's worst case is when the list is already sorted and choosing the left-most element as the pivot - this will
// obviously be a very lengthy process which turns out to be inefficient for sorting an already sorted list using a quick sort.
// One may think of keeping a state variable which keeps track whether a list is already sorted or not and avoid using
// quick sort to check if an algorithm is sorted or not. Also, if the list to be sorted has got only 1 or less elements, the function returns.

uses crt, sysutils;

const
	size = 256;

type
	field = array [0..size-1] of byte;

var
	i: word;
	s: cardinal;

	numbers: field;


procedure QuickSort(Left, Right: word);
var
  Pivot, Temp: byte;
  ptrLeft, ptrRight: smallint;
begin

  ptrLeft := Left;
  ptrRight := Right;
  Pivot := numbers[word(Left + Right) shr 1];

  repeat

    while (ptrLeft < Right) and (numbers[ptrLeft] < Pivot) do inc(ptrLeft);
    while (ptrRight > Left) and (numbers[ptrRight] > Pivot) do dec(ptrRight);

    if ptrLeft <= ptrRight then
      begin
        if ptrLeft < ptrRight then
          begin
            Temp := numbers[ptrLeft];
            numbers[ptrLeft] := numbers[ptrRight];
            numbers[ptrRight] := Temp;
          end;
        inc(ptrLeft);
        dec(ptrRight);
     end;

  until ptrLeft > ptrRight;

  if ptrRight > Left then QuickSort(Left, ptrRight);
  if ptrLeft < Right then QuickSort(ptrLeft, Right);

end;


begin

 for i:=0 to size-1 do begin 
  numbers[i] := //random(255);
                size-i-1;
  
  write(numbers[i],',');
 end; 
 
 writeln;
 writeln;

 write('Quick sort, ',size,' elements');

 s:=GetTickCount;

 QuickSort(0, size-1);

 writeln(', ',GetTickCount-s,' ticks');

 writeln;
 for i:=0 to size-1 do write(numbers[i],',');

 repeat until keypressed;

end.
