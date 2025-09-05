(**************************************************************)
(*       Centigrade to Farenheight temperature conversion     *)
(*                                                            *)
(*  This program generates a list of temperature conversions  *)
(*  with a note at the freezing point of water, and another   *)
(*  note at the boiling point of water.                       *)
(**************************************************************)

program Temperature_Conversion;

uses crt;

var Count,Centigrade,Farenheight : integer;

begin
   Writeln('Centigrade to farenheight temperature table');
   Writeln;
   for Count := -2 to 12 do begin
      Centigrade := 10*Count;
      Farenheight := 32 + Centigrade*9 div 5;
      Write('  C =',Centigrade:5);
      Write('    F =',Farenheight:5);
      if Centigrade = 0 then
         Write('  Freezing point of water');
      if Centigrade = 100 then
         Write('  Boiling point of water');
      Writeln;
   end;

   repeat until keypressed;
end.


{ Result of execution

Centigrade to farenheight temperature table

  C =   -20    F =   -4
  C =   -10    F =   14
  C =     0    F =   32  Freezing point of water
  C =    10    F =   50
  C =    20    F =   68
  C =    30    F =   86
  C =    40    F =  104
  C =    50    F =  122
  C =    60    F =  140
  C =    70    F =  158
  C =    80    F =  176
  C =    90    F =  194
  C =   100    F =  212  Boiling point of water
  C =   110    F =  230
  C =   120    F =  248

}
