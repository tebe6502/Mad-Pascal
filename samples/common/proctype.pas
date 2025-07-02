program Procedure_Type_Example;
uses crt;

type Procedure_Type = procedure(In1, In2, In3 : integer;
                                var Result    : integer);

var Number1, Number2, Number3 : integer;
    Final_Result              : integer;
    Do_Math                   : Procedure_Type;


   procedure Add(In1, In2, In3 : integer;
                 var Result    : integer); StdCall;
   begin
      Result := In1 + In2 + In3;
      Writeln('The sum of the numbers is    ',Result:6);
   end;

   procedure Mult(In1, In2, In3 : integer;
                  var Result    : integer); StdCall;
   begin
      Result := In1 * In2 * In3;
      Writeln('The product of the numbers is',Result:6);
   end;

   procedure Average(In1, In2, In3 : integer;
                     var Result    : integer); StdCall;
   begin
      Result := (In1 * In2 * In3) div 3;
      Writeln('The Average of the numbers is',Result:6);
   end;

begin
   Number1 := 10;
   Number2 := 15;
   Number3 := 20;

   Do_Math := @Add;
   Do_Math(Number1, Number2, Number3, Final_Result);

   Do_Math := @Mult;
   Do_Math(Number1, Number2, Number3, Final_Result);

   Do_Math := @Average;
   Do_Math(Number1, Number2, Number3, Final_Result);

   repeat until keypressed;
end.


{ Result of execution

The sum of the numbers is        45
The product of the numbers is  3000
The average of the numbers is  1000

}
