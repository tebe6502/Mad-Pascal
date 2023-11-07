program SplineDemo;
{****************************************************************************
** Demonstration of drawing a Catmull-Rom spline, a curved line that       **
** passes through a number of control points.                              **
**  by Steven H Don                                                        **
**                                                                         **
** For questions, feel free to e-mail me.                                  **
**                                                                         **
**    shd@earthling.net                                                    **
**    https://www.shdon.com/                                               **
**                                                                         **
****************************************************************************}

uses Crt, Graph;

const
  NumPts = 9;
  Resolution = 10;

type

TFloat = real;

PointType = record
             x,y: TFloat;
	    end;


var
  {Catmull-rom coefficients}
  A, B, C, D : PointType;
  {Control points}
  Px, Py : Array [0..NumPts + 1] of TFloat;

  GraphDriver,GraphMode : smallint;


procedure SplinePoint (t : TFloat; var Point : PointType);
var
  t2, t3 : TFloat;

begin

  {Square and cube of t}
  t2 := t * t;
  t3 := t2 * t;
  {Calculate coordinates}
  Point.x := ((A.x * t3) + (B.x * t2) + (C.x * t) + D.x) / 2;
  Point.y := ((A.y * t3) + (B.y * t2) + (C.y * t) + D.y) / 2;
end;

{Computes coefficients for point n.
This is a matrix transform:
  -1  3 -3  1
   2 -5  4 -1
  -1  0  1  0
   0  2  0  0
}
procedure ComputeCoeffs (n : byte);
begin
  {x-coefficients}
  A.x :=    -Px [n - 1] + 3 * Px [n] - 3 * Px [n + 1] + Px [n + 2];
  B.x := 2 * Px [n - 1] - 5 * Px [n] + 4 * Px [n + 1] - Px [n + 2];
  C.x :=    -Px [n - 1]                  + Px [n + 1];
  D.x :=                  2 * Px [n];

  {y-coefficients}
  A.y :=    -Py [n - 1] + 3 * Py [n] - 3 * Py [n + 1] + Py [n + 2];
  B.y := 2 * Py [n - 1] - 5 * Py [n] + 4 * Py [n + 1] - Py [n + 2];
  C.y :=    -Py [n - 1]                  + Py [n + 1];
  D.y :=                  2 * Py [n];
end;

procedure DrawSpline (Points : byte; Colour : Byte);
var
  Point, Segment: Byte;
  Current, Next : PointType;
  a,b: TFloat;

begin
  Px [0]          := Px [1];
  Py [0]          := Py [1];

  Px [Points + 1] := Px [Points];
  Py [Points + 1] := Py [Points];

  SetColor(Colour);

  {Loop along all the points, drawing a line to the next point}
  for Point := 1 To Points - 1 do begin
    {Calculate coefficients for this point}
    ComputeCoeffs (Point);
    {Calculate the start point for the first segment}
    SplinePoint (0, Current);
    {Split into smaller segments}
    for Segment := 1 To Resolution Do Begin
      {Calculate end point}
      SplinePoint (Segment / Resolution, Next);
      {Draw segment}
      Line (smallint(round (Current.x)), smallint(Round (Current.y)), smallint(Round (Next.x)), smallint(Round (Next.y)) );
      {Next part}
      Current := Next;
    end;
  end;
end;

var
  Point : Byte;

begin
  Randomize;

  GraphDriver := VGA;
  GraphMode := VGAHi;
  InitGraph(GraphDriver,GraphMode,'');

  repeat

    {Get random points}
    for Point := 1 to NumPts do begin
      Px [Point] := Random (300)+10;
      Py [Point] := Random (180)+10;
    end;

    {Draw the spline along those points}
    DrawSpline (NumPts, 15);

    {Draw the points themselves}
 //   for Point := 1 to NumPts do
 //     PutPixel (Round (Px [Point]), Round (Py [Point]), 1);

  until ReadKey = Chr (27);
end.