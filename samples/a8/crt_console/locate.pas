
uses graph, crt;

begin

 InitGraph(15);
 
 SetColor(1); PutPixel(5,5);
 SetColor(2); PutPixel(7,5);
 SetColor(3); PutPixel(9,5);
 
 writeln(GetPixel(5,5),',',GetPixel(7,5),',',GetPixel(9,5));
 
 repeat until keypressed;

end.



