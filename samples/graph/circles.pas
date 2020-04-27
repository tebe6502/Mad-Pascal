//
// Graphics 8 Circles Demonstration
// by Bostjan Gorisek 2015
//
// Developed in Mad-Pascal by Tebe / Madteam
//

uses crt, fastgraph;

var
  i : byte;
begin
  InitGraph(8);


  Poke(710, 0); Poke(712, 0);
  Poke(752,1);
  SetColor(1);
  WriteLn('1... Core circle first, alt. one next');

  Circle(30,20,20);
  Circle(72,20,20);
  Line(0,42,319,42);
 
  WriteLn('Press any key to continue!');
  repeat until KeyPressed;
  WriteLn('2... Core circle first, alt. one next');  
  Circle(40,74,30);
  Circle(120,74,30);
  WriteLn('Press any key to continue!');  
  repeat until keypressed;
  WriteLn('3... Core circle first, alt. one next');

  for i := 0 to 23 do
   Circle(70+i,100+i,20+i);

  for i := 0 to 23 do
   Circle(164+i,100+i,20+i);
  
  readkey;
  repeat until keypressed;  
end.
