 uses crt, graph, pp;

{$r test.rc}

var
	p: pointer;

begin

InitGraph(15+16);

GetResourceHandle(p, 'mic');
unPP(p, pointer(dpeek(88)));

GetResourceHandle(p, 'mic2');
unPP(p, pointer(dpeek(88)));

GetResourceHandle(p, 'mic3');
unPP(p, pointer(dpeek(88)));

repeat until keypressed;

end.