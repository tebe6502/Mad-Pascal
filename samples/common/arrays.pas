program Simple_Arrays;

uses crt;

var Count,Index : integer;
    Automobiles : array[0..12] of integer;

begin
   for Index := 1 to 12 do
      Automobiles[Index] := Index + 10;
   Writeln('This is the first program with an array');
   Writeln;
   for Index := 1 to 12 do
      Writeln('automobile number',Index:3,' has the value',
                                        Automobiles[Index]:4);
   Writeln;
   Writeln('End of program');

   repeat until keypressed;
end.


{ Result of execution

This is the first program with an array

automobile number  1 has the value  11
automobile number  2 has the value  12
automobile number  3 has the value  13
automobile number  4 has the value  14
automobile number  5 has the value  15
automobile number  6 has the value  16
automobile number  7 has the value  17
automobile number  8 has the value  18
automobile number  9 has the value  19
automobile number 10 has the value  20
automobile number 11 has the value  21
automobile number 12 has the value  22

End of program

}