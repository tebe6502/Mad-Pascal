{
 489
 56
}

uses crt, sysutils, graph, lzrw1kh;

{$r pack.rc}

var
	src: array [0..8*1024-1] of byte absolute $4000;
	dst: array [0..8*1024-1] of byte absolute $6000;

	f:file;
	ln, pack, unpack: word;

	tick: cardinal;


begin

 InitGraph(15);

 //move(src, pointer(dpeek(88)), 192*40);

{
 assign(f, 'koronis.mic'); reset(f,1);
 blockread(f, src, sizeof(src), ln);
 close(f);
 }

 ln:=7684;

 write('Compress ', ln, 'b -> ');

 tick:=GetTickCount;
 pack := Compression(@src, @dst, ln);

 writeln(pack, 'b (',GetTickCount-tick,' ticks)');


 write('Decompress ');

 tick:=GetTickCount;
 unpack := Decompression(@dst, pointer(dpeek(88)), pack);

 writeln(unpack,'b (', GetTickCount-tick,' ticks)');


 {
 assign(f, 'koronis.lzw'); rewrite(f,1);
 blockwrite(f, dst, pack);
 close(f);

 assign(f, 'koronis.dat'); rewrite(f,1);
 blockwrite(f, tst, unpack);
 close(f);
}


 repeat until keypressed;

end.

// 11604