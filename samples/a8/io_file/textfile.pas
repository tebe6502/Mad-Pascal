uses crt;

var
 t: text;

 f: file;

 s: string;

begin


 assign(t, 'D:TEXT.TXT');
 rewrite(t);

 writeln(t, 'ATARI');

 writeln(t, 'C64');

 writeln(t, 'Amstrad');

 close(t);



 assign(t, 'D:TEXT.TXT');
 reset(t);

 while IOResult = 1 do begin

 readln(t, s);
 writeln(s);

 end;

 close(t);


 repeat until keypressed;

end.
