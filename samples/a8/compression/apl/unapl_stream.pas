uses crt, aplib, graph;

begin

 InitGraph(15+16);

 unAPL('D:KORONIS.APL', pointer(dpeek(88)) );

 repeat until keypressed;

end.
