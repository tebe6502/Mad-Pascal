{

 309
 34

4483 KORONIS.MIC

}

uses crt, sysutils, graph, lzrw1kh;

{$r pack.rc}

var
	src: array [0..8*1024-1] of byte absolute $6000;
	dst: array [0..8*1024-1] of byte absolute $8000;

	ln, pack, unpack: word;

	tick: cardinal;


begin

 InitGraph(15);

 ln:=7684;

 write('Compress ', ln, 'b -> ');

 tick:=GetTickCount;
 pack := Compression(@src, @dst, ln);

 writeln(pack, 'b (',GetTickCount-tick,' ticks)');


 write('Decompress ', pack, 'b -> ');

 tick:=GetTickCount;
 unpack := Decompression(@dst, pointer(dpeek(88)), pack);

 writeln(unpack,'b (', GetTickCount-tick,' ticks)'); 


 repeat until keypressed;

end.

// 11547