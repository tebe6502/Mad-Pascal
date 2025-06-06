{ Buffered reading and writing for char/string type files
  to make processing them faster.
  A Danson 2013 }

unit buffer;

interface

type 
   charBuffer    = array[0..4096] of char;
   bufferptr = ^charBuffer;

   reader=object
      buff : bufferptr;
      filled : word;
      pos : word;
      input : file;
      constructor open(infile:string);
      function readChar:char;
      function readLine:string;
      function eof:boolean;
      procedure fillBuffer;
      destructor fclose;
   end;
   writer=object
      buff : bufferptr;
      pos : word;
      output : file;
      constructor open(outfile:string);
      procedure writeChar(o : char);
      procedure writeLine(o : string);
      procedure flush;
      destructor fclose;
   end;
   
implementation

constructor reader.open(infile:string);
begin
   //new(buff);
   GetMem(buff, 8192);
   pos := 0;
   filled:=0;
   assign(input,infile);
   reset(input,1);
   reader.fillBuffer;
end;

procedure reader.fillBuffer;
begin
   if (pos<filled) then exit; {we haven't read the buffer completely}
   if (system.eof(input)) then exit; {the last read reached the EOF!}
   blockRead(input,buff^,4096,filled);
   pos:=0;
end;

function reader.readChar:char;
begin
   if (pos>=filled) then
   begin
      Result := chr(10);
      exit;
   end;
   Result := buff[pos];
   inc(pos);
   if (pos=filled) then reader.fillBuffer;
end;

function reader.readLine: string;
var
   i	  : char;
begin
   i := reader.readChar;
   result := '';
   while  ( (i<>chr(13)) and (i<>chr(10)) ) do
   begin
      result := result + i;
      i := reader.readChar;
   end;
   Result := result;
   if (buff^[pos] = chr(10) ) then inc(pos)
      else if (buff^[pos] = chr(13) ) then inc(pos);
   if (pos>=filled) then reader.fillBuffer;
end;

function reader.eof:boolean;
begin
   Result := true;
   if ((pos<filled) or (not(system.eof(input)))) then Result := false;
end;
   
destructor reader.fclose;
begin
   system.close(input);
   dispose(buff);
end;


constructor writer.open(outfile:string);
begin
   pos:=0;
   //new(buff);
   GetMem(buff, 8192);
   assign(output,outfile);
   rewrite(output,1);
end;

procedure writer.writeChar(o : char);
begin
   buff^[pos] := o;
   inc(pos);
   if (pos=4097) then flush;
end;

procedure writer.writeLine(o : string);
var
   i : word;
begin
   for i:=1 to length(o) do
      writeChar(o[i]);
   writeChar(chr(13));
   writeChar(chr(10));
end;

procedure writer.flush;
begin
   if (pos=0) then exit;
   blockwrite(output,buff^,pos);
   pos := 0;
end;

destructor writer.fclose;
begin
   flush;
   dispose(buff);
   system.close(output);
end;
      
end.
