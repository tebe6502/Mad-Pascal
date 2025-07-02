// Micropainter - MIC

uses crt, graph, image;

var f: file;

begin

 InitGraph(15+16);

 LoadMIC('D:CLOUDS.MIC', pointer(dpeek(88)) );
 
 repeat until keypressed;

end.

