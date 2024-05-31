
// http://wiki.freepascal.org/Bubble_sort
// http://pascal-programming.info/articles/sorting.php

// The Bubble Sort algorithm is simple, inefficient sorting algorithm. It is not recommended for use,
// since its performance at sorting a list of items is terribly slow.
// It is best at sorting a small list of items, but not for large ones.

// The sorting time complexity of the Bubble Sort is O(n2).

uses crt, sysutils, dos;

const 
	max = 256;
	
type
	TItemBubbleSort = byte;
	field = array [0..max-1] of TItemBubbleSort;

var
	i: word;
	s: cardinal;

	tb: field;

 
procedure BubbleSort( a: field );
var
  n, newn, i: word;
  temp: TItemBubbleSort;
begin
  n := high( a );
  repeat
    newn := 0;
    for i := 1 to n do
      begin
        if a[ i - 1 ] > a[ i ] then
          begin
            temp := a[ i - 1 ];
	    a[ i - 1 ] := a[ i ];
	    a[ i ] := temp;

            newn := i ;
          end;
      end ;
    n := newn;
  until n = 0;

end;


Procedure BubbleSort2( numbers : field );
Var
	i, j, size : word;
	temp: TItemBubbleSort;

Begin
	size := High(numbers);

	For i := size DownTo 0 do
		For j := 1 to i do
			If (numbers[j-1] > numbers[j]) Then
			Begin
				temp := numbers[j-1];
				numbers[j-1] := numbers[j];
				numbers[j] := temp;
			End;
end;


begin

 for i:=0 to max-1 do tb[i]:=max-i-1;

 write('Bubble sort, ',max,' elements');
 s:=GetTickCount; BubbleSort(tb); writeln(', ',GetTickCount-s,' ticks');

 write('Bubble sort2, ',max,' elements');
 s:=GetTickCount; BubbleSort2(tb); writeln(', ',GetTickCount-s,' ticks');
 
 repeat until keypressed;

end.
