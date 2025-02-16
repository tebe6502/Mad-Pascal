Unit curves;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Curves
 @version: 1.0

 @description:
 various procedures gathered into one module
*)

Interface

Uses Graph, types;

type
	PPoint = ^TPoint;
	ArrayPoints = array of PPoint;

Procedure Curve (p1, p2, p3: TPoint; Segments: Byte);
Procedure CubicBezierCurve (p1, p2, p3, p4: TPoint; Segments: Byte);
Procedure Catmull_Rom_Spline (NumPoints: Byte; var Points: ArrayPoints; Segments: Byte);
Procedure BSpline (NumPoints: Byte; var Points: ArrayPoints; Segments: Byte);

{----------------------------------------------------------------------------}
Implementation


Procedure Curve (p1, p2, p3: TPoint; Segments: Byte);
{ Draw a curve from (x1,y1) through (x2,y2) to (x3,y3) divided in "Segments" segments }
Var
  lsteps: byte;
  ex, ey, fx, fy: LongInt;
  t1, t2: smallint;

Begin
  p2.x:=(p2.x SHL 1)-((p1.x+p3.x) SHR 1);
  p2.y:=(p2.y SHL 1)-((p1.y+p3.y) SHR 1);

  lsteps:=Segments;
  If (lsteps<2) then lsteps:=2;
  If (lsteps>128) then lsteps:=128;  { Clamp value to avoid overcalculation }

  ex:=(LongInt (p2.x-p1.x) SHL 17) DIV lsteps;
  ey:=(LongInt (p2.y-p1.y) SHL 17) DIV lsteps;
  fx:=(LongInt (p3.x-(p2.x shl 1)+p1.x) SHL 16) DIV (lsteps*lsteps);
  fy:=(LongInt (p3.y-(p2.y shl 1)+p1.y) SHL 16) DIV (lsteps*lsteps);
  Dec (lsteps);

  While lsteps > 0 Do Begin
    t1:=p3.x;
    t2:=p3.y;
    p3.x:=(((fx*lsteps+ex)*lsteps) SHR 16)+p1.x;
    p3.y:=(((fy*lsteps+ey)*lsteps) SHR 16)+p1.y;
    Line ( t1,t2,p3.x,p3.y );
    Dec (lsteps);
  End;

  Line ( p3.x,p3.y,p1.x,p1.y );
End;


Procedure CubicBezierCurve (p1, p2, p3, p4: TPoint; Segments: Byte);
{ Draw a cubic bezier-curve using the basis functions directly }
Var
  tx1, tx2, tx3, ty1, ty2, ty3, mu, mu2, mu3, mudelta: float16;
  xstart, ystart, xend, yend, n: smallint;

Begin
  If (Segments<1) then Exit;
  If Segments>128 then Segments:=128; { Clamp value to avoid overcalculation }

  mudelta:=1/Segments;
  mu:=0;
  tx1:=-p1.x+3*p2.x-3*p3.x+p4.x; ty1:=-p1.y+3*p2.y-3*p3.y+p4.y;
  tx2:=3*p1.x-6*p2.x+3*p3.x;	 ty2:=3*p1.y-6*p2.y+3*p3.y;
  tx3:=-3*p1.x+3*p2.x;		 ty3:=-3*p1.y+3*p2.y;

  xstart:=p1.x;
  ystart:=p1.y;
  mu:=mu+mudelta;

  For n:=1 to Segments Do Begin
    mu2:=mu*mu;
    mu3:=mu2*mu;
    xend:=Round (mu3*tx1+mu2*tx2+mu*tx3+p1.x);
    yend:=Round (mu3*ty1+mu2*ty2+mu*ty3+p1.y);

    Line ( xstart, ystart, xend, yend );

    mu:=mu+mudelta;
    xstart:=xend;
    ystart:=yend;
  End;
End;


Procedure Catmull_Rom_Spline (NumPoints: byte; var Points: ArrayPoints; Segments: byte);
{ Draw a spline approximating a curve defined by the array of points.	}
{ In contrast to the BSpline this curve will pass through the points	}
{ defining is except the first and the last point. The curve will only	}
{ pass through the first and the last point if these points are given	}
{ twice after eachother, like this:				        }
{ Array of points:						        }
{									}
{  First point defined twice	       Last point defined twice 	}
{   |-----|				   |----------| 		}
{ (0,0),(0,0),(100,100),....,(150,100),(200,200),(200,200)		}
{ the curve defined by these points will pass through all the points.	}
Function Calculate (mu: float16; p0, p1, p2, p3: smallint): smallint;

Var
  mu2, mu3: float16;
  tmp0, tmp1: smallint;

Begin
  mu2:=mu*mu;
  mu3:=mu2*mu;

  tmp0:=(-p0 + 3*p1 - 3*p2 + p3);
  tmp1:=(2*p0 - 5*p1 + 4*p2 - p3);

  Calculate:=Round ( (mu3 * tmp0 + mu2 * tmp1 + mu * (-p0+p2) + (2*p1) ) * 0.5 );
End;

Var
  mu, mudelta: float16;
  x1, y1, x2, y2, h: smallint;
  pt0, pt1, pt2, pt3: PPoint;
  n: byte;

Begin
  If (NumPoints<4) Or (NumPoints>31) then Exit;
  mudelta:=1/Segments;

  For n:=3 to NumPoints-1 Do Begin
    mu:=0;

    pt0:=Points[n-3];
    pt1:=Points[n-2];
    pt2:=Points[n-1];
    pt3:=Points[n];

    x1:=Calculate (mu,pt0.x,pt1.x,pt2.x,pt3.x);
    y1:=Calculate (mu,pt0.y,pt1.y,pt2.y,pt3.y);

    mu:=mu+mudelta;
    For h:=1 to Segments Do Begin
      pt0:=Points[n-3];
      pt1:=Points[n-2];
      pt2:=Points[n-1];
      pt3:=Points[n];

      x2:=Calculate (mu,pt0.x,pt1.x,pt2.x,pt3.x);
      y2:=Calculate (mu,pt0.y,pt1.y,pt2.y,pt3.y);

      Line ( x1, y1, x2, y2 );
      mu:=mu+mudelta;
      x1:=x2;
      y1:=y2;
    End;
  End;
End;


Procedure BSpline (NumPoints: Byte; var Points: ArrayPoints; Segments: Byte);

type Rmas = array[0..10] of single;

Var i, j: byte;
    newx,newy,oldy,oldx,x,y: smallint;
    part,t,xx,yy: single;

    pt: PPoint;

    dx,dy,wx,wy,px,py,xp,yp,temp,path,zc,u: Rmas;

Function f(g: single): single;
begin
      f:=g*g*g-g;
end;

Begin
    if NumPoints>10 then exit;

    zc[0]:=0.0;

    pt:=Points[0];

    for i:=1 to NumPoints do
    begin
       oldx:=pt.x;
       oldy:=pt.y;
       
       inc(pt);
       
       x:=pt.x;
       y:=pt.y;
       
       xx:=oldx - x;
       yy:=oldy - y;

       t:=sqrt(xx*xx+yy*yy);

       zc[i]:=zc[i-1] + t;     {establish a proportional linear progression}
    end;


 {Calculate x & y matrix stuff}
    for i:=1 to NumPoints-1 do
    begin
       dx[i]:=2*(zc[i+1]-zc[i-1]);
       dy[i]:=2*(zc[i+1]-zc[i-1]);
    end;

    for i:=0 to NumPoints-1 do
    begin
       u[i]:=zc[i+1]-zc[i];
    end;


    pt:=Points[0];

    for i:=1 to NumPoints-1 do
    begin

       oldx:=pt.x;
       oldy:=pt.y;
       
       inc(pt);

       x:=pt.x;
       y:=pt.y;
       
       inc(pt);

       newx:=pt.x;
       newy:=pt.y;

       dec(pt);
 
       wy[i] := 6 * ((newy - y) / u[i] - (y - oldy) / u[i-1]);
       wx[i] := 6 * ((newx - x) / u[i] - (x - oldx) / u[i-1]);
    end;

    py[0]:=0.0;
    px[0]:=0.0;
    px[1]:=0.0;
    py[1]:=0.0;

    py[NumPoints]:=0.0;
    px[NumPoints]:=0.0;

    for i:=1 to NumPoints-2 do
    begin
       wy[i+1]:=wy[i+1]-wy[i]*u[i]/dy[i];
       dy[i+1]:=dy[i+1]-u[i]*u[i]/dy[i];
       wx[i+1]:=wx[i+1]-wx[i]*u[i]/dx[i];
       dx[i+1]:=dx[i+1]-u[i]*u[i]/dx[i];
    end;

    for i:=NumPoints-1 downto 1 do
    begin
       py[i]:=(wy[i]-u[i]*py[i+1])/dy[i];
       px[i]:=(wx[i]-u[i]*px[i+1])/dx[i];
    end;

 { Draw spline	}
    oldx:=999;

    for i:=0 to NumPoints-2 do
    begin
       for j:=0 to Segments-1 do
       begin
	  part:=zc[i]-(((zc[i]-zc[i+1]) / Segments)*j);
	  t:=(part-zc[i]) / u[i];

	  pt:=Points[i];

	  x:=pt.x;
	  y:=pt.y;

	  inc(pt);

	  newx:=pt.x;
	  newy:=pt.y;

	  yy:=t*newy+(1-t)*y+u[i]*u[i]*(f(t)*py[i+1]+f(1-t)*py[i]) * 0.166666667;	//   /6.0 -> *0,166666667

	  xx:=t*newx+(1-t)*x+u[i]*u[i]*(f(t)*px[i+1]+f(1-t)*px[i]) * 0.166666667;

	  x:=round(xx);
	  y:=round(yy);

	  if oldx <> 999 then line(oldx,oldy,x,y);
	  oldx:=x;
	  oldy:=y;
	end;
     end;
  end;


END.