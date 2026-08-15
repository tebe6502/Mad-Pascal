// https://www.geeksforgeeks.org/iterative-quick-sort/?fbclid=IwAR1-ip0eXA89pLlpHtxM_sy-OLy2p04_jvLeGeluKRu9lDM81BEpE02nBK8

uses crt, sysutils;

const
	size = 256;

var
	arr: array [0..0] of byte absolute __BUFFER;// = [ 4, 3, 5, 2, 1, 3, 2, 3 ];

	stack: array [0..255] of byte;

	i: byte;

	s: cardinal;


function partition(l,h: smallint): smallint;
(*
    This function takes last element as pivot, 
    places the pivot element at its correct 
    position in sorted array, and places all 
    smaller (smaller than pivot) to left of 
    pivot and all greater elements to right 
    of pivot
*)
var i, j: smallint;
    temp, pivot: byte;
begin

	pivot := arr[h]; 

        // index of smaller element 
	i := l - 1;
 
	for j:=l to h-1 do 

            // If current element is smaller 
            // than or equal to pivot 
	    if arr[j] <= pivot then begin
		inc(i);
	    
                // swap arr[i] and arr[j] 
                temp := arr[i]; 
                arr[i] := arr[j]; 
                arr[j] := temp;     
	    end;
 
        // swap arr[i+1] and arr[high] 
        // (or pivot) 

        temp := arr[i + 1]; 
        arr[i + 1] := arr[h]; 
        arr[h] := temp; 
    
	Result := i + 1; 
 end;


procedure quickSortIterative(l,h: smallint);
var top: smallint;
    p: smallint;
begin

        // push initial values of l and h to 
        // stack 
        stack[0] := l; 
        stack[1] := h; 

        // initialize top of stack 
	top := 1;
  
        // Keep popping from stack while 
        // is not empty 
        while (top >= 0) do begin

            // Pop h and l 
            h := stack[top]; dec(top);
            l := stack[top]; dec(top);
  
            // Set pivot element at its 
            // correct position in 
            // sorted array 
            p := partition(l, h); 
  
            // If there are elements on 
            // left side of pivot, then 
            // push left side to stack 
            if (p - 1 > l) then begin 
		inc(top); stack[top] := l; 
		inc(top); stack[top] := p - 1; 
            end;
  
            // If there are elements on 
            // right side of pivot, then 
            // push right side to stack 
            if (p + 1 < h) then begin
                inc(top); stack[top] := p + 1; 
                inc(top); stack[top] := h; 
            end;
	    
        end;
  
end;


begin

 for i:=0 to size-1 do begin 
  arr[i] := //random(255);
                size-i-1;
  
  //write(numbers[i],',');
 end; 
 
 writeln;
 writeln;

 write('Quick sort, ',size,' elements');

 s:=GetTickCount;

        // Function calling 
        quickSortIterative(0, size - 1); 

 writeln(', ',GetTickCount-s,' ticks');

 writeln;

 for i:=0 to size-1 do write(arr[i],',');


	repeat until keypressed;

end.

