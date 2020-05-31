
uses crt, graph, image;

var f: file;
    ch: char;

begin

 InitGraph(15+16);

 LoadMIC('D:CLOUDS.MIC', pointer(dpeek(88)) );
 
 repeat until keypressed;
 ch:=readkey;


 LoadPIC('D:RENDER.PIC', pointer(dpeek(88)) );

 repeat until keypressed;

end.

