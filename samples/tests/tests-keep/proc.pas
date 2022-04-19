uses crt;


function test: byte;
begin

 result:=117;

end;


procedure beep; keep;
var a,b : byte;
begin

 b:=test;

 writeln('ok');

 a:=b+31;

 writeln(a);

 end;


begin

  asm
   jsr beep
  end;

 repeat until keypressed;

end.

