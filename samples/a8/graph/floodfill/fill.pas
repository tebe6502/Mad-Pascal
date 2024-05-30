// 112 ticks	horizontal
// 239 ticks	diamond

program main;

uses crt, sysutils, fastgraph;

{$define horizontal}

var	ticks: cardinal;

begin

 InitGraph(7);

 pause;
 ticks := GetTickCount;


 SetColor(1); Circle(40,38, 38);

 SetColor(2); Circle(50,20, 8);

 SetColor(3); Circle(35,56, 10);


 {$ifdef horizontal}

 FloodFillH(20,40, 2);

 FloodFillH(50,20, 3);

 FloodFillH(35,50, 1);

 {$else}


 FloodFill(20,40, 2);

 FloodFill(50,20, 3);

 FloodFill(35,50, 1);

 {$endif}


 ticks:=GetTickCount - ticks;
 writeln(ticks,' ticks');

 repeat until keypressed;

end.

