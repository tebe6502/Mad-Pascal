uses crt, cio;

var ch: char;

begin

writeln('Press any key');

repeat until keypressed;
ch:=readkey;


xio(40,1,0,0,'D:PORAZKA.OBX');


TextMode(0);

writeln('Done.');

repeat until keypressed;

end.

