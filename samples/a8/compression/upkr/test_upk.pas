uses crt, graph, upk;

{$r test_upk.rc}

const
  mic = $6000;


begin

 InitGraph(15+16);


 unUPK(pointer(mic), pointer(Dpeek(88)));


 repeat until keypressed;

end.