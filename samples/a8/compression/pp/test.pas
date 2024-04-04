uses crt, graph, pp;

//{$define NOROMFONT}
{$define romoff}

{$r test.rc}

const
	mic = $e000;
	mic2 = $4000;
begin

InitGraph(15+16);

unPP(pointer(mic), pointer(dpeek(88)));
unPP(pointer(mic2), pointer(dpeek(88)));

repeat until keypressed;

end.