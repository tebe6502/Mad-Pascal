uses crt, zx0, graph;

{$r unzx0.rc}

const
	zx0pic = $9000;

begin

 InitGraph(15+16);

 unzx0(pointer(zx0pic), pointer(dpeek(88)) );

 repeat until keypressed;

end.
