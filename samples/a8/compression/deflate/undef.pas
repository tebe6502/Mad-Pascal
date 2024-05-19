uses crt, deflate, graph;

{$r undef.rc}

const
	defpic = $9000;

begin

 InitGraph(15+16);
 
 unDef(pointer(defpic), pointer(dpeek(88)) );
 
 repeat until keypressed;

end.
