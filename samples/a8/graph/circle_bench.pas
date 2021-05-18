//
// Graphics 8 Circles Demonstration
// by Bostjan Gorisek 2015
//
// Developed in Mad-Pascal by Tebe / Madteam
//
// record 78 ticks

uses crt, fastgraph, sysutils;

var
  i : byte;
  ticks: word;

begin
  InitGraph(8);

  Poke(710, 0); Poke(712, 0);
  Poke(752,1);
  SetColor(1);

  WriteLn('           Visual effect :)');

 pause;

 ticks:=GetTickCount;

  for i := 0 to 18 do begin
    Circle(87+i,60+i,20+i*2);
    Circle(193+i,60+i,20+i*2);
  end;

 ticks:=word(GetTickCount)-ticks;
 writeln(ticks, ' ticks');

 repeat until keypressed;

end.
