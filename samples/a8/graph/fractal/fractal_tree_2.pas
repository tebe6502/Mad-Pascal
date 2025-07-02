// 2110

program FractalTree;

uses crt, graph, sysutils;

var

GraphDriver, GraphMode: smallint;

ticks: cardinal;


procedure draw(x,y,a,s: real);
var tx, ty: real;
begin
	if (s < 6.0) then exit;

	tx := x + cos(a) * s;
	ty := y + sin(a) * s;

	Line(x, y, tx, ty);

	draw(tx, ty, a + 0.3, s * 0.9);
	draw(tx, ty, a - 0.4, s * 0.8);
end;


begin

  GraphDriver := VGA;
  GraphMode := VGAHi;
  InitGraph(GraphDriver,GraphMode,'');

  SetColor(1);

  pause;
  ticks:=GetTickCount;

  draw(140, 199, PI * 1.5, 32);

  ticks:=GetTickCount-ticks;

  writeln(ticks,' TICKS');

  repeat until keypressed;

end.
