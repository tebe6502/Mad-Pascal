uses crt, zx0, graph;

begin

 InitGraph(15+16);

 unZX0('D:KORONIS.ZX0', pointer(dpeek(88)) );

 repeat until keypressed;

end.
