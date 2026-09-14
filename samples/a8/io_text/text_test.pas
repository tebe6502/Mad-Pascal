
uses crt;

var
    a, i: integer;

    t: text;


procedure test(var f: text);
var s: string;
begin

 while ioresult=1 do begin
 readln(f, s);

 writeln(s);
 end;

end;


begin

assign(t, 'D:PGSHOW.ASM'); reset(t);

test(t);

close(t);


repeat until keypressed;

end.
