uses crt;

{$define romoff}

//{$define noromfont}		// remove '//{$def...' if you want to see how READKEY enables ROM

var
    ch: char;

begin

 writeln('CHARSET moved from ROM to RAM ($E000)');
 writeln;
 writeln('READKEY disables ROMOFF');
 writeln;


 writeln('Hello ROMOFF');
 writeln;

 writeln('Press any key');

 repeat until keypressed;

 while true do
 begin
  ch:=readkey;

  write(ch);

  if ch=#27 then Break;
 end;


 repeat until keypressed;

end.

