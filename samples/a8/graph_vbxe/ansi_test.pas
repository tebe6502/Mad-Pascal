uses crt, vbxe;

var s: string;

    i: byte;

begin

 EnableAnsiMode;

 AnsiString(#27'[2J'#27'[H');		// clrscr

 writeln('ANSI 80 COLUMN MODE');

 repeat until keypressed;

 while true do begin

  TextColor(i and $0f);

  write('ANSI 80 COLUMN MODE ');

  inc(i);
 end;

end.