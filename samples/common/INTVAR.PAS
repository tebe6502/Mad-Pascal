program Integer_Variable_Demo;

uses crt;

var Count     : integer;
    X,Y       : integer;

begin
   X := 12;
   Y := 13;
   Count := X + Y;
   Writeln('The value of X is',X:4);
   Writeln('The value of Y is',Y:5);
   Writeln('And Count is now ',Count:6);

   repeat until keypressed;
end.


{ Result of execution

The value of X is  12
The value of Y is   13
And Count is now     25

}
