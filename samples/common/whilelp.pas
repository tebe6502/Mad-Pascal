program While_Loop_Example;

uses crt;

var Counter : integer;

begin
   Counter := 4;
   while Counter < 20 do begin
      Write('In the while loop, waiting ');
      Write('for the counter to reach 20. It is',Counter:4);
      Writeln;
      Counter := Counter + 2;
   end;

   repeat until keypressed;
end.


{ Result of execution

In the while loop, waiting for the counter to reach 20. It is   4
In the while loop, waiting for the counter to reach 20. It is   6
In the while loop, waiting for the counter to reach 20. It is   8
In the while loop, waiting for the counter to reach 20. It is  10
In the while loop, waiting for the counter to reach 20. It is  12
In the while loop, waiting for the counter to reach 20. It is  14
In the while loop, waiting for the counter to reach 20. It is  16
In the while loop, waiting for the counter to reach 20. It is  18

}