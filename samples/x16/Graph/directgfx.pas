uses x16_vera, x16, crt;


begin
  writeln('hello world !');
  repeat until keypressed;

  veraInit;
  // veraDirectLoad('test.img');
  veraDirectLoad('SPLASH.IMG');
  repeat until keypressed;

end.
