
// circle / ellipse speed test (record 74)

uses crt, graph, sysutils;

var
   ticks: word;
   i: byte;

   GraphDriver, GraphMode: smallint;

begin

 GraphDriver := VGA;
 GraphMode := VGAHi;
 InitGraph(GraphDriver,GraphMode,'');

 SetColor(15);

 pause;

 ticks:=GetTickCount;

 Ellipse(160,100,155,114);

 for i:=0 to 9 do Circle(160,96,i shl 1+78);

 TextMode(0);

 ticks:=word(GetTickCount)-ticks;
 writeln(ticks, ' ticks');

 repeat until keypressed;

end.

