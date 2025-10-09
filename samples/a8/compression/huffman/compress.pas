{ Compression program using the huffman encoder I built recently
  A Danson 2015}

program compress;

uses buffer, huffenc;

var
   rFile   : reader;
   infile  : string;
   outfile : string;

begin
{
   if (paramCount <> 2) then
   begin
      writeln(' usage: compress infile outfile ');
      halt(0);
   end;
   infile := paramstr(1);
   outfile := paramstr(2);
 }

{$ifdef atari}
   infile:='D:KORONIS.MIC';
   outfile:='D:KOR.HUF';   
{$else}
   infile:='KORONIS.MIC';
   outfile:='KOR.HUF';   
{$endif}   

   rFile.fopen(infile);
   openOutput(outfile);

   while not(rFile.feof) do
      writeChar(rFile.readChar);

   huffenc.closeOutput;
   rFile.fclose;

end.

// 5906