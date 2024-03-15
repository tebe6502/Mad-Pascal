uses x16_vera, x16, crt;

var
    i: byte;
    d: word;

begin
  // writeln('loading image... press any key');
  // repeat until keypressed;
  VPoke(1,VERA_text+158,$23);
  i:=VPeek(1,VERA_text+158);
  writeln('SREEN = $',HexStr(i,2));
  writeln('PETSCII = $',HexStr(Scr2Petscii(i),2));
  repeat until keypressed;


end.
