// zx0 -c inputfile outputfile

uses crt, zx0, graph;

{$r unzx0.rc}

const
	zx0pic = $3000;

begin

 InitGraph(15+16);

 unZX0C(pointer(zx0pic), pointer(dpeek(88)) );		// unZX0C -> CLASSIC FILE MODE -c

 repeat until keypressed;

end.
