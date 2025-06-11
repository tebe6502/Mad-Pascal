uses crt, graph, rbuf;

var
   loadFN  : reader;		// object READER
   infile  : TString;

   i: word;

begin
   InitGraph(15+16);

   infile:='D:KORONIS.MIC';

   loadFN.fopen(infile);

   i:=0;

   while not(loadFN.feof) do begin

    poke(dpeek(88) + i, loadFN.fread);

    inc(i);

   end;

   loadFN.fclose;

   repeat until keypressed;

end.
