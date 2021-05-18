uses sysutils;

var f: file;

    a: cardinal;
    
    s: string[15];

begin

 s:='D:TEST.TMP';
 
 if not FileExists(s) then begin 
  writeln('File ''',s,''' not found');
  halt;
 end;
 
 assign(f, s);

 reset(f, sizeof(cardinal));

 while not eof(f) do begin

  blockread(f, a, 1);

  writeln(a);

 end;

 close(f);

end.

