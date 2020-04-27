uses crt, lz4, graph;

{$r unlz4.rc}

const
	lz4pic = $9000;

begin

 InitGraph(15+16);
 
 unlz4(pointer(lz4pic+11), pointer(dpeek(88)) );
 
 repeat until keypressed;


end.

