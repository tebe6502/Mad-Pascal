program main;

uses crt, fastgraph;

{$define horizontal}

begin

 InitGraph(7+16);

 SetColor(1); Circle(40,40, 40);

 SetColor(2); Circle(50,22, 8);

 SetColor(3); Circle(35,58, 10);
 

 {$ifdef horizontal}

 FloodFillH(20,40, 2);

 FloodFillH(50,20, 3);

 FloodFillH(35,50, 1);

 {$else}


 FloodFill(20,40, 2);

 FloodFill(50,20, 3);

 FloodFill(35,50, 1);

 {$endif}


 repeat until keypressed;

end.

