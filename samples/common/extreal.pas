program Extended_Real_Types;

uses crt;

(* Note: If you are using TURBO Pascal Version 5.0  or newer    *)
(*       and you do not have a Math Co_Processor, you can       *)
(*       still compile and run this program by using the        *)
(*       compiler directive as explained in the User's Guide.   *)

var Number       : real;
    Small_Number : single;

begin
   Number       := 100000000000000.0;
   Small_Number := 100000000000000.0;

   Writeln('Number       = ',Number      :40:3);
   Writeln('Small_Number = ',Small_Number:40:3);

   repeat until keypressed;
end.


{ Result of execution

Number       =         -8388608.0000
Small_Number =         276824064.000000

}