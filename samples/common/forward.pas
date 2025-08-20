program Forward_Reference_Example;
uses crt;

var Number_Of_Times : integer;

procedure Write_A_Line(var Count : integer); forward;

procedure Decrement(var Index : integer);
begin
   Index := Index - 1;
   if Index > 0 then
      Write_A_Line(Index);
end;

procedure Write_A_Line;
begin
   Writeln('The value of the count is now ',Count:4);
   Decrement(Count);
end;

begin  (* main program *)
   Number_Of_Times := 7;
   Decrement(Number_Of_Times);
   Writeln;
   Number_Of_Times := 7;
   Write_A_Line(Number_Of_Times);

   repeat until keypressed;
end.  (* of main program *)


{ Result of execution

The value of the count is now    6
The value of the count is now    5
The value of the count is now    4
The value of the count is now    3
The value of the count is now    2
The value of the count is now    1

The value of the count is now    7
The value of the count is now    6
The value of the count is now    5
The value of the count is now    4
The value of the count is now    3
The value of the count is now    2
The value of the count is now    1

}
