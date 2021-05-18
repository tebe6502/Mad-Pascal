
// vertical scrolling, simple stupid program (copy 192*40 bytes from extended memory)

uses crt, graph,  objects, atari;

{$r vscrol.rc}

const

	bitmap = 0;	// extended memory address 32bit

var
	m: TMemoryStream;

	tb: array [0..0] of byte;

	i: byte;

	l, d: smallint;

begin

 InitGraph(15 + 16);

 color0:=4;
 color1:=6;
 color2:=8;
 color4:=0;

 tb:=pointer(dpeek(88));

 m.create;

 d:=40;
 l:=0;

 repeat
	m.position := l + bitmap;
	m.ReadBuffer(tb, 192*40);

	inc(l, d);
	if (l = 586*40) or (l = 0) then d := -d;

 until keypressed;

end.
