program More_Integer_Demos;
uses crt;

var X,Y      : integer;
    Count    : integer;

begin
   X := 12;
   Y := 13;
   Count := X + Y;
   Write('The value of X is');
   Writeln(X:4);
   Write('The value of Y is');
   Writeln(Y:5);
   Write('And Count is now ');
   Write(Count:6);
   Writeln;

   repeat until keypressed;
end.


{ Result of execution

The value of X is  12
The value of Y is   13
And Count is now     25

}