uses crt;

var ch: char;

begin
ClrScr;
writeln('press any key');

repeat until keypressed;
ch:=readkey();

writeln('1:', ch);
writeln('1:', byte(ch));

repeat until keypressed;
ch:=readkey();

writeln('2:', ch);
writeln('2:', byte(ch));

repeat until keypressed;
ch:=readkey();

writeln('3:',ch);
writeln('3:', byte(ch));

repeat until keypressed;
ch:=readkey();

writeln('4:',ch);
writeln('4:', byte(ch));

repeat until keypressed;
end.