program main;

uses crt, graph;

var i,j,k,l: byte;
    x: word;

begin

 InitGraph(8);

 SetColor(1);
 Line(0,159,319,159);

 for i:=2 to 5 do
  for j:=2 to 159 do begin
   k:=i and 3;
   l:=j and 3;

   if ((k=l) and (k<2)) or (k*l=6) then begin

     x:=i;
     while x<320 do begin

      PutPixel(x, j);

      inc(x, 4);
     end;

   end;

  end;


 FloodFill(0,0, 1);

 //FloodFillH(0,0, 1);

 writeln('Done.');

 repeat until keypressed;

end.

