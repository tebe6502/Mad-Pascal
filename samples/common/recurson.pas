program Try_Recursion;
uses crt;

var Count : integer;

procedure Print_And_Decrement(Index : integer);
begin
   Writeln('The value of the index is ',Index:3);
   Index := Index - 1;
   if Index > 0 then
      Print_And_Decrement(Index);
end;

begin  (* main program *)
   Count := 7;
   Print_And_Decrement(Count);

   repeat until keypressed;
end.  (* main program *)


{ Result of execution

The value of the index is   7
The value of the index is   6
The value of the index is   5
The value of the index is   4
The value of the index is   3
The value of the index is   2
The value of the index is   1

}
