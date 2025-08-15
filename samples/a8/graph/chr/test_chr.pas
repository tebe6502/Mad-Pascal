uses crt, graph, bfont;

var
   gd, gm: smallint;

begin

 gd := D8bit;
 gm := m640x400;

 InitGraph(gd,gm,'');

 loadFont('D:GOTH.CHR');

 textxy(10,0, 1.0, 15, 'ATARI');
 textxy(10,30, 1.1, 15, 'ATARI');
 textxy(10,100, 1.0, 15, '0123456789');
 textxy(10,130, 0.9, 15, '0123456789');

 repeat until keypressed;
end.