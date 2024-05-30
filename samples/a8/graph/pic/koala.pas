// Koala Microilustrator - PIC

uses crt, graph, image;

var f: file;

begin

 InitGraph(15+16);

 LoadPIC('D:RENDER.PIC', pointer(dpeek(88)) );

 repeat until keypressed;

end.

