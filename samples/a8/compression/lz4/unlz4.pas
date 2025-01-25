uses crt, lz4, graph;

{$r unlz4.rc}

var
	p: pointer;

begin

 InitGraph(15+16);

 GetResourceHandle(p, 'lz4pic');

 unlz4(p, pointer(dpeek(88)) );


 repeat until keypressed;

end.
