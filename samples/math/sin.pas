
uses crt, fastgraph;

var i: word;

begin

 Initgraph(8 + 16);

 SetColor(1);

 for i:=0 to 319 do
  PutPixel(i, round(sin(i*pi/180.0)*95.0)+96);

 repeat until keypressed;

end.


