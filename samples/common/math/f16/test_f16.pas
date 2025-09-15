{
This is an example of using Float16 support through the F16 unit.

'Mad Pascal' has built-in faster Float16 support, so using the F16 unit is not necessary.

F16 unit and the example below can be compiled using the 'Free Pascal Compiler' (FPC).
}

uses crt, f16;

var

	f0,f1,f2 : word;


begin

 f0:=FloatToHalf(723.653);
 f1:=FloatToHalf(45.1287); 

 writeln('f0 = ', HalfToFloat(f0):4:16);
 writeln('f1 = ', HalfToFloat(f1):4:16);
 
 writeln;
 
 f2:=f16_add(f0,f1); 
 writeln('f0 + f1 = ', HalfToFloat(f2):4:16);
 
 f2:=f16_sub(f0,f1);
 writeln('f0 - f1 = ', HalfToFloat(f2):4:16);
 
 f2:=f16_mul(f0,f1);
 writeln('f0 * f1 = ', HalfToFloat(f2):4:16);

 f2:=f16_div(f0,f1);
 writeln('f0 / f1 = ', HalfToFloat(f2):4:16);
 
 writeln;
 writeln('f0 >= f1 ', f16_gte(f0,f1));
 writeln('f0 > f1  ', f16_gt(f0,f1));
 writeln('f0 = f1  ', f16_eq(f0,f1));
 writeln('f0 <= f1 ', f16_lte(f0,f1));
 writeln('f0 < f1  ', f16_lt(f0,f1));
 writeln('f0 <> f1 ', f16_neq(f0,f1));
 
 repeat until keypressed;

end.
