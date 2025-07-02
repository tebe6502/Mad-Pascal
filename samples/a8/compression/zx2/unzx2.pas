uses crt, zx2, graph;

{$r unzx2.rc}

const
	zx2pic = $9000;

begin

 InitGraph(15+16);

 unzx2(pointer(zx2pic), pointer(dpeek(88)) );

 repeat until keypressed;

end.
