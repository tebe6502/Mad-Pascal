program All_Simple_Variable_Types;

uses crt;

var  A,B         : integer;
     C,D         : byte;
     Dog_Tail    : real;
     Puppy       : boolean;
     Animal_Cookies : char;

begin
   A := 4;
   B := 5;
   C := 212;
   D := C + 3;
   Dog_Tail := 345.12456;
   Puppy := B > A;  (* since B is greater than A, Puppy
                       will be assigned the value TRUE *)
   Animal_Cookies := 'R';  (* this is a single character *)

   Writeln('The integers are',A:5,B:5);
   Writeln('The bytes are',   C:5,D:5); (* notice that the spaces
                                           prior to the C will be
                                           ignored on output *)
   Writeln('The real value is',Dog_Tail:12:2,Dog_Tail:12:4);
   Writeln;
   Writeln('The boolean value is ',Puppy,Puppy:13);
   Writeln('The char variable is an ',Animal_Cookies);

   repeat until keypressed;
end.


{ Result of execution

The integers are    4    5
The bytes are  212  215
The real value is      345.12    345.1246

The boolean value is TRUE         TRUE
The char variable is an R

}