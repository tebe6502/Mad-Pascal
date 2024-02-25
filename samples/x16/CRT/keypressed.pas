uses crt;

var ch: char;

begin
ClrScr;
writeln('press any key');

repeat until keypressed;
ch:=readkey();

writeln('1:', ch);

repeat until keypressed;
ch:=readkey();

writeln('2:', ch);

repeat until keypressed;
ch:=readkey();

writeln('3:',ch);

repeat until keypressed;
ch:=readkey();

writeln('4:',ch);

repeat until keypressed;
end.