// GFX 7 Lines
// pps 2015-08-11
// tebe 2016-01-17

uses fastgraph, crt;

const	buf1 = $4000;
	buf2 = $5000;

type	TLine = record
		  x0, y0, x1, y1: byte;
		  dx0, dy0, dx1, dy1: byte;
		 end;

var	l0, l1, l2: TLine;
	b1_l0, b1_l1, b1_l2: TLine;
	b2_l0, b2_l1, b2_l2: TLine;

	w, h: byte;

	dl: word;


procedure test(var a: TLine);
begin

	if (a.x0 > w) or (a.x0 < 1) then a.dx0 := -a.dx0;
	inc(a.x0, a.dx0);

	if (a.x1 > w) or (a.x1 < 1) then a.dx1 := -a.dx1;
	inc(a.x1, a.dx1);

	if (a.y0 > h) or (a.y0 < 1) then a.dy0 := -a.dy0;
	inc(a.y0, a.dy0);

	if (a.y1 > h) or (a.y1 < 1) then a.dy1 := -a.dy1;
	inc(a.y1, a.dy1);

end;


procedure Draw(var old, a: TLine; color: byte);
begin
	SetColor(0); fLine(old.x0, old.y0, old.x1, old.y1);

	test(a);

	SetColor(color); fLine(a.x0, a.y0, a.x1, a.y1);

	old.x0 := a.x0;
	old.y0 := a.y0;
	old.x1 := a.x1;
	old.y1 := a.y1;
end;


procedure Rnd(var a: TLine);
begin
	a.x0 := Random(w);
	a.y0 := Random(h);

	a.x1 := Random(w);
	a.y1 := Random(h);

	a.dx0 := 1;
	a.dx1 := -1;
	a.dy0 := 1;
	a.dy1 := -1;
end;


begin

writeln;
writeln;
writeln;
writeln;
writeln;
writeln('       Pascal Lines by PPs');
writeln;
writeln;
writeln('   done with Mad  Pascal by TeBe');
writeln;
writeln;
writeln;
writeln;
writeln;
write('        Strike SPACE bar! ');
repeat until keypressed;
readkey;

InitGraph(7 + 16);

fillbyte(pointer(buf1), 40*96, 0);
fillbyte(pointer(buf2), 40*96, 0);

dl:=dpeek($230);

randomize;

w := ScreenWidth - 2;
h := ScreenHeight - 2;

rnd(l0);
rnd(l1);
rnd(l2);

repeat
	pause;

	dpoke(dl+4, buf2);
	SetActiveBuffer(buf1);

	Draw(b1_l0, l0, 1);
	Draw(b1_l1, l1, 2);
	Draw(b1_l2, l2, 3);

	pause;

	dpoke(dl+4, buf1);
	SetActiveBuffer(buf2);

	Draw(b2_l0, l0, 1);
	Draw(b2_l1, l1, 2);
	Draw(b2_l2, l2, 3);

until keypressed;

end.

