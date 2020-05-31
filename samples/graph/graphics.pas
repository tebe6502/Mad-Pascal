uses crt, fastgraph, types;

var	r: TRect;
	i: byte;

begin

 InitGraph(15 + 16);
 
 SetColor(1);
 
 fRectangle(0,0,159,191);
 
 SetColor(2);
 fLine(0,0,159,191);

 SetColor(3);
 fLine(159,0,0,191);
 
 for i:=0 to 2 do begin
	r:=Rect(40+i*30,80,40+i*30+20,100);
 
	SetColor(i+1);
	FillRect(r);
 end;
 
 Palette[4] := COLOR_VIOLET;	// 708
 Palette[5] := COLOR_RED;	// 709
 PAlette[6] := COLOR_YELLOW;	// 710

 repeat until keypressed;

end.


