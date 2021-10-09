uses crt, zx5, graph;

begin

 InitGraph(15+16);

 unZX5('D:KORONIS.ZX5', pointer(dpeek(88)) );

 repeat until keypressed;

end.
