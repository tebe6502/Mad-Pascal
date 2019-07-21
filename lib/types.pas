unit types;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Various types

 @version: 1.0

 @description:
 <https://www.freepascal.org/docs-html/rtl/types/index-5.html>
*)


{

Bounds
CenterPoint
EqualRect
InflateRect
IntersectRect
IsRectEmpty
OffsetRect
Point
PointsEqual
PtInEllipse
PtInRect
Rect
RectWidth
RectHeight
UnionRect

}

interface

	function Bounds(ALeft, ATop, AWidth, AHeight: smallint): TRect;
	function CenterPoint(const Rect: TRect): TPoint;
	function EqualRect(const r1,r2 : TRect) : Boolean;
	function InflateRect(var Rect: TRect; dx, dy: smallint): Boolean;
	function IntersectRect(var Rect : TRect;const R1,R2 : TRect) : Boolean;
	function IsRectEmpty(const Rect : TRect) : Boolean;
	procedure NormalizeRect(var Rect: TRect); overload;
	procedure NormalizeRect(var left,top, right,bottom : smallint); overload;
	function OffsetRect(var Rect : TRect; DX, DY : smallint) : Boolean;
	function Point(AX, AY: smallint): TPoint;
	function PointsEqual(const P1, P2: TPoint): Boolean;
	function PtInEllipse(const Rect: TRect; const p : TPoint): Boolean;
	function PtInRect(const Rect : TRect; const p : TPoint) : Boolean;
	function Rect(ALeft, ATop, ARight, ABottom: smallint): TRect;
	function RectWidth(const Rect: TRect): word;
	function RectHeight(const Rect: TRect): word;
	function Size(AWidth, AHeight: smallint): TSize; overload;
	function Size(const ARect: TRect): TSize; overload;
	function UnionRect(var Rect : TRect;const R1,R2 : TRect) : Boolean;


implementation


function Point(AX, AY: smallint): TPoint;
(*
@description:
Create a point

@param: ax - position x
@param: ay - position y

@returns: TPoint record
*)
begin
  Result.X := AX;
  Result.Y := AY;
end;


function Rect(ALeft, ATop, ARight, ABottom: smallint): TRect;
(*
@description:
Create a rectangle record

@param: ALeft, ATop - left corner
@param: ARight, ABottom - right corner

@returns: TRect record
*)
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;


function Bounds(ALeft, ATop, AWidth, AHeight: smallint): TRect;
(*
@description:
Create a rectangle, given a position and size

@param: ALeft, ATop - position
@param: AWidth, AHeigh - size

@returns: TRect record
*)
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ALeft + AWidth;
  Result.Bottom :=  ATop + AHeight;
end;


function EqualRect(const r1,r2 : TRect) : Boolean;
(*
@description:
Check if two rectangles are equal

@param: R1, R2 - rectangles

@returns: TRUE if the rectangles R1 and R2 are equal
*)
begin
  Result:=(r1.left=r2.left) and (r1.right=r2.right) and (r1.top=r2.top) and (r1.bottom=r2.bottom);
end;


function PointsEqual(const P1, P2: TPoint): Boolean;
(*
@description:
Check if two points are equal

@param: P1, P2 - points

@returns: TRUE if the points P1 and P2 are equal
*)
begin
  { lazy, but should work }
  result:=cardinal(P1.x + P1.y shl 16) = cardinal(P2.x + P2.y shl 16);
end;


function RectWidth(const Rect: TRect): word;
(*
@description:

*)
begin
 Result:=abs(Rect.right - Rect.left);
end;


function RectHeight(const Rect: TRect): word;
(*
@description:

*)
begin
 Result:=abs(Rect.bottom - Rect.top);
end;


function PtInEllipse(const Rect: TRect; const p : TPoint): Boolean;
(*
@description:
Check whether a point is inside a ellipse

@param: Rect - TRect record
@param: p - TPoint record

@returns: TRUE if p is located inside ellipse defined by Rect
*)
begin

  Result := false;

  if (RectWidth(Rect) = 0) or (RectHeight(Rect) = 0) then
    Exit;

  Result := (Sqr(single(p.X * 2 - Rect.Left - Rect.Right) / single(Rect.Right - Rect.Left))
            + Sqr(single(p.Y * 2 - Rect.Top - Rect.Bottom) / single(Rect.Bottom - Rect.Top))) <= single(1);
end;


function PtInRect(const Rect : TRect;const p : TPoint) : Boolean;
(*
@description:
Check whether a point is inside a rectangle

@param: Rect - TRect record
@param: p - TPoint record

@returns: TRUE if p is located inside Rect
*)
begin
  Result:=(p.y>=Rect.Top) and
	  (p.y<Rect.Bottom) and
	  (p.x>=Rect.Left) and
	  (p.x<Rect.Right);
end;


function Avg(a, b: integer): integer;
(*
@description:

*)
begin
  if a < b then
    Result := a + ((b - a) shr 1)
  else
    Result := b + ((a - b) shr 1);
end;


function CenterPoint(const Rect: TRect): TPoint;
(*
@description:
Return the center point of a rectangle

@param: Rect - TRect record

@returns: TPoint record
*)
begin
 Result.X := Avg(Rect.Left, Rect.Right);
 Result.Y := Avg(Rect.Top, Rect.Bottom);
end;


function IsRectEmpty(const Rect : TRect) : Boolean;
(*
@description:
Check whether a rectangle is empty

@param: TRect record

@returns: TRUE if the rectangle is empty
*)
begin
  Result:=(Rect.Right<=Rect.Left) or (Rect.Bottom<=Rect.Top);
end;


function IntersectRect(var Rect : TRect;const R1,R2 : TRect) : Boolean;
(*
@description:
Return the intersection of 2 rectangles

@param: Rect - destination TRect record
@param: R1, R2 - rectangles

@returns: TRUE if the operation was successfull
*)
var
  lRect: TRect;
begin
  lRect := R1;
  if R2.Left > R1.Left then
    lRect.Left := R2.Left;
  if R2.Top > R1.Top then
    lRect.Top := R2.Top;
  if R2.Right < R1.Right then
    lRect.Right := R2.Right;
  if R2.Bottom < R1.Bottom then
    lRect.Bottom := R2.Bottom;

  // The var parameter is only assigned in the end to avoid problems
  // when passing the same rectangle in the var and const parameters.
  // See http://bugs.freepascal.org/view.php?id=17722
  if IsRectEmpty(lRect) then
  begin
    FillChar(Rect,SizeOf(Rect),0);
    Result:=false;
  end
  else
  begin
    Rect := lRect;
    Result:=true;
  end;
end;


function UnionRect(var Rect : TRect;const R1,R2 : TRect) : Boolean;
(*
@description:
Return the union of 2 rectangles

@param: Rect - destination TRect record
@param: R1, R2 - rectangles

@returns: TRUE if the operation was successfull
*)
var
  lRect: TRect;
begin
  lRect:=R1;
  if R2.Left<R1.Left then
    lRect.Left:=R2.Left;
  if R2.Top<R1.Top then
    lRect.Top:=R2.Top;
  if R2.Right>R1.Right then
    lRect.Right:=R2.Right;
  if R2.Bottom>R1.Bottom then
    lRect.Bottom:=R2.Bottom;

  if IsRectEmpty(lRect) then
  begin
    FillChar(Rect,SizeOf(Rect),0);
    Result:=false;
  end
  else
  begin
    Rect:=lRect;
    Result:=true;
  end;
end;


function OffsetRect(var Rect : TRect; DX, DY : Smallint) : Boolean;
(*
@description:
Offset the rectangle

@param: Rect - TRect record
@param: offsets the rectangle Rect by a horizontal distance DX
@param: offsets the rectangle Rect by a vertical distance DY

@returns: TRUE if the operation was successfull
*)
begin

 if isRectEmpty(Rect) then
  Result := false
 else begin
  inc(Rect.Left,dx);
  inc(Rect.Top,dy);
  inc(Rect.Right,dx);
  inc(Rect.Bottom,dy);

  Result:=true;
 end;

end;


function InflateRect(var Rect: TRect; dx, dy: smallint): Boolean;
(*
@description:
Increase the rectangle in size, keeping it centered

@param: Rect - TRect record
@param: inflates the rectangle horizontally with DX pixels on each side
@param: inflates the rectangle verticaly with DY pixels on each side

@returns: TRUE if the operation was successfull
*)
begin

 if isRectEmpty(Rect) then
  Result := false
 else begin
  dec(Rect.Left, dx);
  dec(Rect.Top, dy);
  inc(Rect.Right, dx);
  inc(Rect.Bottom, dy);
  Result := True;
 end;

end;


procedure NormalizeRect(var Rect: TRect); overload;
(*
@description:

*)
var x: smallint;
begin
  if Rect.Top > Rect.Bottom then
  begin
    x := Rect.Top;
    Rect.Top := Rect.Bottom;
    Rect.Bottom := x;
  end;
  if Rect.Left > Rect.Right then
  begin
    x := Rect.Left;
    Rect.Left := Rect.Right;
    Rect.Right := x;
  end
end;


procedure NormalizeRect(var left,top, right,bottom : smallint); overload;
(*
@description:

*)
var x: smallint;
begin
  if Top > Bottom then
  begin
    x := Top;
    Top := Bottom;
    Bottom := x;
  end;
  if Left > Right then
  begin
    x := Left;
    Left := Right;
    Right := x;
  end
end;


function Size(AWidth, AHeight: smallint): TSize; overload;
(*
@description:
Return the size of the rectangle

@param: AWidth, AHeight

@returns: TSize record
*)
begin
  Result.cx := AWidth;
  Result.cy := AHeight;
end;


function Size(const ARect: TRect): TSize; overload;
(*
@description:
Return the size of the rectangle

@param: ARect - TRect

@returns: TSize record
*)
begin
  Result.cx := ARect.Right - ARect.Left;
  Result.cy := ARect.Bottom - ARect.Top;
end;


end.
