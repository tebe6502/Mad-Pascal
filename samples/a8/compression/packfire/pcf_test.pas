uses crt, packfire, graph;

{$r koronis.rc}

var
	p: pointer;

begin

 InitGraph(15+16);

 GetResourceHandle(p, 'pack');
 
 unPCF(p, pointer(dpeek(88)));

 
 repeat until keypressed;

end.