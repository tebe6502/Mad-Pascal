uses crt;


procedure beep; keep;
var a,b : byte;
begin

 b:=117;

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

