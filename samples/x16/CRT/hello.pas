uses crt;

begin
  writeln('hello world !');
  repeat until keypressed;

  // write(X16_SWAP_CHARSET);
  write(X16_ISO_ON);
  writeln('hello world with small letters.');
  writeln('HELLO WORLD IN CAPITALS');
  write(X16_REVERSE_ON);
  writeln('   HELLO WORLD !   ');
  write(X16_REVERSE_OFF);
end.
