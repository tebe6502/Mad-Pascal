uses crt, aplib, graph;

{$r unapl.rc}

const
	aplpic = $9000;

begin

 InitGraph(15+16);

 unapl(pointer(aplpic), pointer(dpeek(88)) );

 repeat until keypressed;

end.
