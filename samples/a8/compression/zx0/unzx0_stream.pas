
// !!! CLASSIC FILE FORMAT -c !!!
// zx0 -c inputfile outputfile

uses crt, zx0, graph;

var fn: Pstring;

begin

 InitGraph(15+16);

 fn:='D:SILENTS.ZX0';

 unZX0C(fn, pointer(dpeek(88)) );

 repeat until keypressed;

end.
