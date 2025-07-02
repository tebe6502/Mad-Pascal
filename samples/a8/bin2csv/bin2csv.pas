uses crt, graph;

const
	pic: array of byte = [ {$bin2csv 'atari3d.mic'} ] ;

begin

  InitGraph(15+16);

  poke(712, pic[7680]);

  poke(708, pic[7681]);
  poke(709, pic[7682]);
  poke(710, pic[7683]);

  move(pic, pointer(dpeek(88)), 7680);

  repeat until keypressed;

end.
