{------------------------------------------------------------------------------
  Reading Micro Illustrator file and showing it on the screen
  Example 3: Fast solution
------------------------------------------------------------------------------}
uses crt, graph;

var
  f : file;        // File pointer
  s : string[15];  // Filename storage
  buf: ^byte;
  
begin
	InitGraph(15);
	s := 'D:CLOUDS.MIC';

	assign(f, s);
	reset(f, 1);

	buf:=pointer(dpeek(88));
	blockread(f, buf, 7680);

	buf:=pointer(712);
	blockread(f, buf, 1);

	buf:=pointer(708);
	blockread(f, buf, 3);

	close(f);

	repeat until keypressed;
end.
