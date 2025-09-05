program Function_Type_Example;

uses crt;

type Function_Type = function(In1, In2, In3 : integer) : integer;

var Number1, Number2, Number3 : integer;
    Final_Result              : integer;
    Do_Math                   : Function_Type;


   function Add(In1, In2, In3 : integer) : integer; StdCall;
      var Temp : integer;
   begin
      Temp := In1 + In2 + In3;
      Writeln('The sum of the numbers is    ',Temp:6);
      Add := Temp;
   end;

   function Mult(In1, In2, In3 : integer) : integer; StdCall;
      var Temp : integer;
   begin
      Temp := In1 * In2 * In3;
      Writeln('The product of the numbers is',Temp:6);
      Mult := Temp;
   end;

   function Average(In1, In2, In3 : integer) : integer; StdCall;
      var Temp : integer;
   begin
      Temp := (In1 * In2 * In3) div 3;
      Writeln('The Average of the numbers is',Temp:6);
      Average := Temp;
   end;

begin
   Number1 := 10;
   Number2 := 15;
   Number3 := 20;

   Do_Math := @Add;
   Final_Result := Do_Math(Number1, Number2, Number3);

   Do_Math := @Mult;
   Final_Result := Do_Math(Number1, Number2, Number3);

   Do_Math := @Average;
   Final_Result := Do_Math(Number1, Number2, Number3);

   repeat until keypressed;
end.


{ Result of execution

The sum of the numbers is        45
The product of the numbers is  3000
The average of the numbers is  1000

}
