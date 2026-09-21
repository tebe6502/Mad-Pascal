// Micropainter - MIC

uses crt, graph, image;

//{$define romoff}

{$r mic2.rc}

const
	pic = $4000;


begin

 InitGraph(15+16);

 move(pointer(pic), pointer(dpeek(88)), 7680);


 repeat until keypressed;

end.

