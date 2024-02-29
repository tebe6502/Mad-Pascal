uses x16_vera, x16, crt;


begin
  writeln('hello world !');
  repeat until keypressed;

  veraInit;
  veraDirectLoad('splash.img');

  repeat until keypressed;

end.
