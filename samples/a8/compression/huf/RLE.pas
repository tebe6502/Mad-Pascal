{ Run Length Encoder/Decoder for reading and writing files
  to make some very basic file compression.
  A Danson 2014 }

unit RLE;

interface

uses buffer; {we are going to use the buffered reader/writer to save on disk access routines.}

type
   RLDecoder = object
       r : reader;
       count: byte;
       data : char;
       constructor open_file(infile:string);
       function readChar:char;
       function readln:string;
       function eof:boolean;
       destructor close;
   end;
   RLEncoder=object
       w : writer;
       count : byte;
       data : char;
       constructor open_file(infile : string);
       procedure writeChar(o : char);
       procedure writeln(o : string);
       procedure flush; {will only flush underlying buffer!}
       destructor close;
   end;
       
implementation

constructor RLDecoder.open_file(infile :  string);
begin
   r.open(infile);
   count:= ord(r.readChar);
   data := r.readChar;
end;
       
function RLDecoder.readChar:char;
begin
   if (count>0) then
   begin
      dec(count);
      readChar := data;
   end
   else
   begin
      count := ord(r.readChar);
      data := r.readChar;
      dec(count);
      readChar := data;
   end;
end; { RLDecoder }

function RLDecoder.readLn:string;
var
   result : string;
   i	  : char;
begin
   i := Self.readChar;
   result := '';
   while  ( (i<>chr(13)) and (i<>chr(10)) ) do
   begin
      result := result + i;
      i := Self.readChar;
   end;
   readLn := result;
end; { RLDecoder }

function RLDecoder.eof:boolean;
begin
   eof:=false;
   if ((count = 0) and (r.eof)) then eof:=true;
end; { RLDecoder }

destructor RLDecoder.close;
begin
   r.close;
end; 

constructor RLEncoder.open_file(infile: string);
begin
   w.open(infile);
   count := 0;
   data := chr(0);
end;

procedure RLEncoder.writeChar(o	: char);
begin
   if (o = data) then
   begin {input the same as last time}
      inc(count);
      if (count = 255) then
      begin
	 w.writeChar(chr(count));
	 w.writeChar(data);
	 count := 0;
      end;
   end
   else
   begin {different!}
      if (count>0) then
      begin
	 w.writeChar(chr(count));
	 w.writeChar(data);
      end;
      data := o;
      count := 1;
   end;
end;

procedure RLEncoder.writeLn(o : string);
var
   i : word;
begin
   for i:=1 to length(o) do
      writeChar(o[i]);
   writeChar(chr(13));
   writeChar(chr(10));
end;

procedure RLEncoder.flush;
begin
   w.flush;
end; { RLEncoder }

destructor RLEncoder.close;
begin
   if (count>0) then
   begin
      w.writeChar(chr(count));
      w.writeChar(data);
   end;
   w.flush;
   w.close;
end;

end.