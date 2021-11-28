// 2315
// 1287

uses crt;

var

  tab: array [0..3] of byte = (11,9,7,5);

  p: pointer;


procedure test(var buffer);
var a: word absolute buffer;
begin

 writeln(a)

end;


begin

 test(tab);

 p:=@tab;

 inc(p, 2);

 test(p^);

 repeat until keypressed;


end.


