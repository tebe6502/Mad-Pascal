uses crt;

var p: PChar;


procedure test(var a: pointer);
begin

 a:=pointer(125);

end;


begin

test(p);

writeln(word(p));

repeat until keypressed;

end.


