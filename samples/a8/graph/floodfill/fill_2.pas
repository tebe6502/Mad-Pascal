// 94

program gr23;

uses crt, fastgraph, sysutils;

var
	ticks: word;

begin

  initgraph (7);
  setcolor (1);

 pause;
 ticks := GetTickCount;

  moveto (0,79);
  lineto (50,50);
  lineto (159,50);
  lineto (159,79);
  lineto (0,79);

  FloodFillH(80,78,2);

 ticks:=GetTickCount - ticks;
 writeln(ticks,' ticks');


  repeat until keypressed;

end.
