uses crt;

begin
  writeln('hello world !');
  repeat until keypressed;

  write(X16_SWAP_CHARSET);
  writeln('hello world !');
  writeln('HELLO WORLD !');
  write(X16_REVERSE_ON);
  writeln('   HELLO WORLD !   ');
  write(X16_REVERSE_OFF);
end.
