uses crt, lzjb, graph;

{$r lzjb.rc}

var
	dst: array [0..0] of byte absolute $6000;

	ln: word;
	p: pointer;


begin

 InitGraph(15);
 
 GetResourceHandle(p, 'mic');
 SizeOfResource(ln, 'mic');
 
 
 write('Compress ', ln, ' bytes into ');
 
 ln := lzjb_compress_mem(p, ln, @dst, ln);
 
 writeln(ln,' bytes');
 
 
 
 write('Decompress ');
 
 ln := lzjb_decompress_mem(@dst, ln, Pointer(dpeek(88)) );
 
 writeln(ln,' bytes');
 
 repeat until keypressed;


end.

// 12017