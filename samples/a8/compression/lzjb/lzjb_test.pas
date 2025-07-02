{

107
43

}

uses crt, lzjb, graph, sysutils;

{$r lzjb.rc}

var
	dst: array [0..0] of byte absolute $6000;

	ln: word;
	p: pointer;

	tick: cardinal;


begin

 InitGraph(15);

 GetResourceHandle(p, 'mic');
 SizeOfResource(ln, 'mic');

 write('Compress ', ln, 'b -> ');

 tick:=GetTickCount;
 ln := lzjb_compress_mem(p, ln, @dst, ln);

 writeln(ln,'b (',GetTickCount-tick,' ticks)');


 write('Decompress ');

 tick:=GetTickCount;
 ln := lzjb_decompress_mem(@dst, ln, Pointer(dpeek(88)) );

 writeln(ln,'b (', GetTickCount-tick,' ticks)');

 repeat until keypressed;


end.

// 12327