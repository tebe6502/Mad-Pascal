uses crt, graph, curves, types;

var gd,gm: smallint;

    p1, p2, p3, p4, p5, p6, p7, p8: TPoint;
    
    pt: array [0..127] of ^TPoint;


begin

 gd := VGA;
 gm := VGAHi;
 InitGraph(gd,gm,'');

 SetColor(15);

// Curve(p1,p2,p3, 8);
// CubicBezierCurve(p1, p2, p3, p4, 8);

// Curve(Point(10,100), Point(60,40), Point(130,70), 8);
// CubicBezierCurve(Point(10,100), Point(60,40), Point(130,70), Point(150,80), 8);


P1:=Point(50,20);
P2:=Point(150,20);
P3:=Point(50,160);
P4:=Point(150,160);
P5:=Point(150,160);
P6:=Point(270,160);
P7:=Point(150,20);
P8:=Point(270,20);
 

 pt[0]:=@p1;
 pt[1]:=@p2;
 pt[2]:=@p3;
 pt[3]:=@p4;
 pt[4]:=@p5;
 pt[5]:=@p6;
 pt[6]:=@p7;
 pt[7]:=@p8;


 Curve(p1, p2, p3, 8);
 CubicBezierCurve(p1, p2, p3, p4, 8);

 Catmull_Rom_Spline(8, pt, 8);

 BSpline(8, pt, 8);

 repeat until keypressed;

end.