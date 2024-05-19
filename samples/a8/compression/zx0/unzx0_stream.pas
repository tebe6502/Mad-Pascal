uses crt, zx0, graph;

var fn: Pstring;

begin

 InitGraph(15+16);

 fn:='D:KORONIS.ZX0';

 unZX0(fn, pointer(dpeek(88)) );

 repeat until keypressed;

end.
