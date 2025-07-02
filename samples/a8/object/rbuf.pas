unit rbuf;

interface

type

   reader=object
      buff : PByte;
      filled : word;
      pos : word;
      input : file;

      _eof: Boolean;

      constructor fopen(infile:TString);
      function fread: byte;
      function feof:boolean;
      procedure fillBuffer;
      destructor fclose;
   end;


implementation

constructor reader.fopen(infile:TString);
begin
   GetMem(buff, 256);

   _eof:=false;
   pos := 0;
   filled:=0;
   assign(input,infile);
   reset(input,1);
   reader.fillBuffer;

end;

procedure reader.fillBuffer;
begin
   if (pos<filled) then exit;	{we haven't read the buffer completely}
   if _eof then exit;		{the last read reached the EOF!}

   blockRead(input,buff^,256,filled);

   if filled < 256 then _eof:=true;

   pos:=0;

end;

function reader.fread: byte;
begin
   if (pos>=filled) then
   begin
      Result := 10;
      exit;
   end;
   Result := buff[pos];
   inc(pos);
   if (pos=filled) then reader.fillBuffer;
end;

function reader.feof:boolean;
begin
   Result := true;
   if ((pos<filled) or (_eof = false)) then Result := false;
end;

destructor reader.fclose;
begin
   close(input);
   FreeMem(buff, 256);
end;

end.
