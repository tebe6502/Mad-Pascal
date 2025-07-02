uses crt, lz4, graph;

begin

 InitGraph(15+16);

 unlz4('D:KORONIS.LZ4', pointer(dpeek(88)) );

 repeat until keypressed;

end.
