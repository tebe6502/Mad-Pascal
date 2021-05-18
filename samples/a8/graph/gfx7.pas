// GFX 7 Lines
// pps 2015-08-11
// tebe 2015-09-30, 2015-12-12
 
uses fastgraph, crt;

var
	x1,y1,xx1,yy1     : byte;
	rx1,ry1,rxx1,ryy1 : Boolean;

	x2,y2,xx2,yy2     : byte;
	rx2,ry2,rxx2,ryy2 : Boolean;

	x3,y3,xx3,yy3     : byte;
	rx3,ry3,rxx3,ryy3 : Boolean;


procedure testX(var x: byte; var d: Boolean);
begin
	if not d then begin
		inc(x);
		if x >= ScreenWidth-1 then d:=true;
	end else begin
		dec(x);
		if x<1 then d:=false;
	end;
end;


procedure testY(var y: byte; var d: Boolean);
begin
	if not d then begin
		inc(y);
		if y >= ScreenHeight-1 then d:=true;
	end else begin
		dec(y);
		if y<1 then d:=false;
	end;
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

randomize;

x1:= Random(byte(ScreenWidth-1)); xx1:= Random(byte(ScreenWidth-1));
y1:= Random(byte(ScreenHeight-1)); yy1:=Random(byte(ScreenHeight-1));

x2:= Random(byte(ScreenWidth-1)); xx2:= Random(byte(ScreenWidth-1));
y2:= Random(byte(ScreenHeight-1)); yy2:=Random(byte(ScreenHeight-1));

x3:= Random(byte(ScreenWidth-1)); xx3:= Random(byte(ScreenWidth-1));
y3:= Random(byte(ScreenHeight-1)); yy3:=Random(byte(ScreenHeight-1));

rx2:=true;
ryy2:=true;

rx3:=true;
ry3:=true;

SetColor(1); fLine(x1,y1,xx1,yy1);
SetColor(2); fLine(x2,y2,xx2,yy2);
SetColor(3); fLine(x3,y3,xx3,yy3);

repeat
	SetColor(0); fLine(x1,y1,xx1,yy1);

	testX(x1, rx1);
	testX(xx1, rxx1);

	testY(y1, ry1);
	testY(yy1, ryy1);

	SetColor(1); fLine(x1,y1,xx1,yy1);

// 2nd line

	SetColor(0); fLine(x2,y2,xx2,yy2);

	testX(x2, rx2);
	testX(xx2, rxx2);

	testY(y2, ry2);
	testY(yy2, ryy2);

	SetColor(2); fLine(x2,y2,xx2,yy2);

// line 3

	SetColor(0); fLine(x3,y3,xx3,yy3);

	testX(x3, rx3);
	testX(xx3, rxx3);

	testY(y3, ry3);
	testY(yy3, ryy3);

	SetColor(3); fLine(x3,y3,xx3,yy3);

	poke(77,0);

until keypressed;

end.

