uses crt, zx5, graph;

{$r unzx5.rc}

var
	p: pointer;

begin

 InitGraph(15+16);

 GetResourceHandle(p, 'zx5pic');

 unzx5(p, pointer(dpeek(88)) );

 repeat until keypressed;

end.
