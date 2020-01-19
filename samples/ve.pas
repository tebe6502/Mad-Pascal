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
  WriteLn('           Visual effect :)');

  for i := 0 to 18 do begin
    Circle(87+i,60+i,20+i*2);
    Circle(193+i,60+i,20+i*2);
  end;

  repeat until keypressed;  
end.
