                                (* Chapter 3 - Program 7 *)
program Char_Demonstration;

uses crt;

var Letter  : char;
    Number  : char;
    Dogfood : char;

begin
   Letter := 'P';
   Number := 'A';
   Dogfood := 'S';
   Write(Letter,Number,Dogfood);
   Letter := Number;             (* This is now the 'A' *)
   Number := 'L';
   Dogfood := 'C';
   Write(Dogfood,Letter,Number);
   Writeln;

   repeat until keypressed;
end.


{ Result of execution

PASCAL

}
