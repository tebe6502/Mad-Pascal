{ Compression program using the huffman encoder I built recently
  A Danson 2015}

program compress;

uses buffer, huffenc;

var
   input   : reader;
   infile  : string;
   outfile : string;

begin
   if (paramCount <> 2) then
   begin
      writeln(' usage: compress infile outfile ');
      halt(0);
   end;
   infile := paramstr(1);
   outfile := paramstr(2);

   input.open(infile);
   openOutput(outfile);
   while not(input.eof) do
      writeChar(input.readChar);
   input.fclose;
   huffenc.closeOutput;

end.
