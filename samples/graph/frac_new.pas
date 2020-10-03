// https://atariage.com/forums/topic/305526-fractals/?do=findComment&comment=4518410

uses crt, graph;
var i,j,c: byte;
    x0,y0,x,y,x2,y2: shortreal;

begin

 InitGraph(15+16);

 for i:=95 downto 0 do
  for j:=159 downto 0 do begin
  
   x0:=(j-100)*0.024;
   y0:=(i-95)*0.012;
   
   x:=x0;
   y:=y0;
   
   for c:=15 downto 1 do begin
    x2:=x*x;
    y2:=y*y;
    if x2+y2 > 4 then Break;
    y:=2*x*y+y0;
    x:=x2-y2+x0; 
   end;
  
   SetColor(1 + byte(c-1) and 3);
   PutPixel(j,i); 
   PutPixel(j,byte(190-i)); 
  end;
  
  repeat until keypressed;

end.
