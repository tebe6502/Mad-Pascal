uses crt, graph;

var
	P: PByteArray;


begin

 InitGRaph(12);


 P:=Scanline(9) ;


 P[8]:=12;
 P[9]:=13;
 P[10]:=14;


 repeat until keypressed;


end.
