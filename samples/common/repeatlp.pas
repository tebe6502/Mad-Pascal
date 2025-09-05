program Repeat_Loop_Example;

uses crt;

var Count : integer;

begin
   Count := 4;
   repeat
      Write('This is in the ');
      Write('repeat loop, and ');
      Write('the index is',Count:4);
      Writeln;
      Count := Count + 2;
   until Count = 20;
   Writeln(' We have completed the loop ');

   repeat until keypressed;
end.

{ Result of execution

This is in the repeat loop, and the index is   4
This is in the repeat loop, and the index is   6
This is in the repeat loop, and the index is   8
This is in the repeat loop, and the index is  10
This is in the repeat loop, and the index is  12
This is in the repeat loop, and the index is  14
This is in the repeat loop, and the index is  16
This is in the repeat loop, and the index is  18
 We have completed the loop

}
