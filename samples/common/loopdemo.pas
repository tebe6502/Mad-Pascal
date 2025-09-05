program Demonstrate_Loops;

uses crt;

var Count  : integer;
    Start  : integer;
    Ending : integer;
    Total  : integer;
    Alphabet : char;

begin
   Start := 1;
   Ending := 7;
   for Count := Start to Ending do      (* Example 1 *)
      Writeln('This is a count loop and we are in pass',Count:4);

   Writeln;
   Total := 0;
   for Count := 1 to 10 do begin        (* Example 2 *)
      Total := Total + 12;
      Write('Count =',Count:3,'  Total =',Total:5);
      Writeln;
   end;

   Writeln;
   Write('The alphabet is ');
   for Alphabet := 'A' to 'Z' do         (* Example 3 *)
      Write(Alphabet);
   Writeln;

   Writeln;
   for Count := 7 downto 2 do            (* Example 4 *)
      Writeln('Decrementing loop ',Count:3);

  repeat until keypressed;
end.


{ Result of execution

This is a count loop and we are in pass   1
This is a count loop and we are in pass   2
This is a count loop and we are in pass   3
This is a count loop and we are in pass   4
This is a count loop and we are in pass   5
This is a count loop and we are in pass   6
This is a count loop and we are in pass   7

Count =  1  Total =   12
Count =  2  Total =   24
Count =  3  Total =   36
Count =  4  Total =   48
Count =  5  Total =   60
Count =  6  Total =   72
Count =  7  Total =   84
Count =  8  Total =   96
Count =  9  Total =  108
Count = 10  Total =  120

The alphabet is ABCDEFGHIJKLMNOPQRSTUVWXYZ

Decrementing loop   7
Decrementing loop   6
Decrementing loop   5
Decrementing loop   4
Decrementing loop   3
Decrementing loop   2

}
