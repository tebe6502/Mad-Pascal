uses crt, graph, types;

type
	PPoint = ^TPoint;
	ArrayPoints = array [0..127] of PPoint;

var
  i : byte;

  pt: ArrayPoints;

begin

 for i:=0 to High(pt)-1 do
  GetMem(pt[i], sizeof(TPoint));

 InitGraph(8);
 SetColor(1);


 // shape
 
{
 pt[0]^:=Point(63,17);
 pt[1]^:=Point(78, 47);
 pt[2]^:=Point(119,50);
 pt[3]^:=Point(80,70);
 pt[4]^:=Point(109,90);
 pt[5]^:=Point(60,91);
 pt[6]^:=Point(51,110);
 pt[7]^:=Point(45,88);
 pt[8]^:=Point(29,70);
 pt[9]^:=Point(59,50);
 }
 
 
 pt[0].x:=63;
 pt[0].y:=17;

 pt[1].x:=78;
 pt[1].y:=47;

 pt[2].x:=119;
 pt[2].y:=50;

 pt[3].x:=80;
 pt[3].y:=70;

 pt[4].x:=109;
 pt[4].y:=90;

 pt[5].x:=60;
 pt[5].y:=91;

 pt[6].x:=51;
 pt[6].y:=110;

 pt[7].x:=45;
 pt[7].y:=88;

 pt[8].x:=29;
 pt[8].y:=70;

 pt[9].x:=59;
 pt[9].y:=50; 

 DrawPoly(10, pt);

 FillPoly(10, pt);


// triangle

 pt[0].x:=150;
 pt[0].y:=17;

 pt[1].x:=198;
 pt[1].y:=97;

 pt[2].x:=111;
 pt[2].y:=117;

 DrawPoly(3, pt);

 FillPoly(3, pt);


 repeat until keypressed;

end.
