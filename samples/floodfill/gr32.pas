program gr23;

uses crt,fastgraph;

begin

  initgraph (23);
  setcolor (1);

  moveto (0,79);
  lineto (50,50);
  lineto (159,50);
  lineto (159,79);
  lineto (0,79);
  
  FloodFillH(80,78,2);

  repeat until keypressed;

end.
