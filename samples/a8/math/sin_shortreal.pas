
uses crt, fastgraph;

var i: word;
    f: shortreal;

begin

 Initgraph(8 + 16);

 SetColor(1);

 for i:=0 to 319 do begin
  f:=i*pi/180;
  f:=sin(f)*95;
  PutPixel(i, round(f)+96);
 end;

 repeat until keypressed;

end.


