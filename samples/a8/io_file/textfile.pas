uses crt;

var
 t: text;

 f: file;

 s: string;

begin

 s:='qwerty';

 assign(t, 'D:TEXT.TXT');
 append(t);

 writeln(t, 'ATARI');

 writeln(t, 'C64');

 write(t, 'Amstrad');

// write(t, s);
// writeln(t, s);

 close(t);




{
 assign(t, 'D:TEXT.TXT');
 reset(t);

 while IOResult=1 do begin

 readln(t, s );
 writeln(s);

 end;

 close(t);
}

 repeat until keypressed;

end.
