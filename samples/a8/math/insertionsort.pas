
// http://pascal-programming.info/articles/sorting.php

// Insertion Sort algorithm is a bit more efficient sorting algorithm than Bubble Sort.
// As it name implies, the insertion sort algorithm inserts an unsorted item in an already sorted item list.
// This makes you think of the use of two seperated arrays - one unsorted and the other sorted.
// However, to save space one uses the same array and uses a pointer to separate the sorted and unsorted elements of the list.

// The sorting time complexity of the Insertion Sort is O(n2).
// Although this exactly the same to Bubble Sort's, the Insertion Sort algorithm is twice more efficient, yet inefficient for large lists.


uses crt, sysutils;

const 
	max = 256;
	
type
	TItemSort = byte;
	field = array [0..max-1] of TItemSort;

var
	i: word;
	s: cardinal;

	tb: field;

 
Procedure InsertionSort( numbers : field );
Var
	i, j, index, size : word;

Begin
	size := high(numbers);

	For i := 1 to size do
	Begin
		index := numbers[i];
		j := i;
		While ((j > 0) AND (numbers[j-1] > index)) do
		Begin
			numbers[j] := numbers[j-1];
			dec(j);
		End;
		numbers[j] := index;
	End;
	
end;


begin

 for i:=0 to max-1 do tb[i]:=max-i-1;

 write('Insertion sort, ',max,' elements');
 s:=GetTickCount;

 InsertionSort(tb);

 writeln(', ',GetTickCount-s,' ticks');
 
 repeat until keypressed;

end.
