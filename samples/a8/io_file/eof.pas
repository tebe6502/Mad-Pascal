// SDX

uses crt, sysutils;

var f: file;

    a: cardinal;

    s: string[15];

begin

s:='D:TEST.TMP';

//s:='test.tmp';

 if not FileExists(s) then begin
  writeln('File ''',s,''' not found');
  halt;
 end;

 assign(f, s);

 reset(f, sizeof(cardinal));

 Seek(f, 3);
 
 a:=11;
 blockwrite(f, a, 1);
 
 seek(f, 0);

 while not eof(f) do begin

  blockread(f, a, 1);

  writeln(a);

 end;

 close(f);
 
 repeat until keypressed;

end.

