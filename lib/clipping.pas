unit clipping;
(*
 @type: unit
 @author: FPC
 @name: Common procedures for line clipping in defined rectangle area

 @version: 1.0

 @description:

*)


{

CheckLineClipping
CheckRectClipping

}

interface

uses types;


procedure CheckLineClipping (ClipRect:TRect; var x1,y1, x2,y2 : smallint);
(*
@description:

*)

procedure CheckRectClipping (ClipRect:TRect; var x1,y1, x2,y2 : smallint); overload;
(*
@description:

*)

procedure CheckRectClipping (ClipRect:TRect; var Rect:Trect); overload;
(*
@description:

*)


implementation


procedure CheckRectClipping (ClipRect:TRect; var x1,y1, x2,y2 : smallint); overload;

  procedure ClearRect;
  begin
    x1 := -1;
    x2 := -1;
    y1 := -1;
    y2 := -1;
  end;

begin
  NormalizeRect (ClipRect);
  NormalizeRect (x1,y1, x2,y2);

  if ( x1 < ClipRect.Left ) then	// left side needs to be clipped
    x1 := ClipRect.left;
  if ( x2 > ClipRect.right ) then	// right side needs to be clipped
    x2 := ClipRect.right;
  if ( y1 < ClipRect.top ) then		// top side needs to be clipped
    y1 := ClipRect.top;
  if ( y2 > ClipRect.bottom ) then	// bottom side needs to be clipped
    y2 := ClipRect.bottom;
  if (x1 > x2) or (y1 < y2) then
    ClearRect;

end;


procedure CheckRectClipping (ClipRect:TRect; var Rect:Trect); overload;
begin
    CheckRectClipping (ClipRect, ClipRect.left, ClipRect.top, ClipRect.right, ClipRect.bottom);
end;


procedure CheckLineClipping (ClipRect:TRect; var x1,y1, x2,y2 : smallint);
var a,b : real;
    Calculated : boolean;
    xdiff,n : smallint;
  procedure CalcLine;
    begin
    if not Calculated then
      begin
      xdiff := (x1-x2);
      a := real(y1-y2) / real(xdiff);
      b := real(x1*y2 - x2*y1) / real(xdiff);
      Calculated := true;
      end;
    end;
  procedure ClearLine;
    begin
    x1 := -1;
    y1 := -1;
    x2 := -1;
    y2 := -1;
    end;
begin
  Calculated := false;
  NormalizeRect (ClipRect);
  xdiff := (x1-x2);

    if xdiff = 0 then
      begin  // vertical line
      if y1 > ClipRect.bottom then
        y1 := ClipRect.bottom
      else if y1 < ClipRect.top then
        y1 := ClipRect.top;
      if y2 > ClipRect.bottom then
        y2 := ClipRect.bottom
      else if y2 < ClipRect.top then
        y2 := ClipRect.top;
      end
    else if (y1-y2) = 0 then
      begin  // horizontal line
      if x1 < ClipRect.left then
        x1 := ClipRect.left
      else if x1 > ClipRect.right then
        x1 := ClipRect.right;
      if x2 < ClipRect.left then
        x2 := ClipRect.left
      else if x2 > ClipRect.right then
        x2 := ClipRect.right;
      end
    else
      if ( (y1 < ClipRect.top) and (y2 < ClipRect.top) ) or
         ( (y1 > ClipRect.bottom) and (y2 > ClipRect.bottom) ) or
         ( (x1 > ClipRect.right) and (x2 > ClipRect.right) ) or
         ( (x1 < ClipRect.left) and (x2 < ClipRect.left) ) then
        ClearLine // completely outside ClipRect
      else
        begin
        if (y1 < ClipRect.top) or (y2 < ClipRect.top) then
          begin
          CalcLine;
          n := round ((real(ClipRect.top) - b) / a);
          if (n >= ClipRect.left) and (n <= ClipRect.right) then
            if (y1 < ClipRect.top) then
              begin
              x1 := n;
              y1 := ClipRect.top;
              end
            else
              begin
              x2 := n;
              y2 := ClipRect.top;
              end;
          end;
        if (y1 > ClipRect.bottom) or (y2 > ClipRect.bottom) then
          begin
          CalcLine;
          n := round ((real(ClipRect.bottom) - b) / a);
          if (n >= ClipRect.left) and (n <= ClipRect.right) then
            if (y1 > ClipRect.bottom) then
              begin
              x1 := n;
              y1 := ClipRect.bottom;
              end
            else
              begin
              x2 := n;
              y2 := ClipRect.bottom;
              end;
          end;
        if (x1 < ClipRect.left) or (x2 < ClipRect.left) then
          begin
          CalcLine;
          n := round ((real(ClipRect.left) * a) + b);
          if (n <= ClipRect.bottom) and (n >= ClipRect.top) then
            if (x1 < ClipRect.left) then
              begin
              x1 := ClipRect.left;
              y1 := n;
              end
            else
              begin
              x2 := ClipRect.left;
              y2 := n;
              end;
          end;
        if (x1 > ClipRect.right) or (x2 > ClipRect.right) then
          begin
          CalcLine;
          n := round ((real(ClipRect.right) * a) + b);
          if (n <= ClipRect.bottom) and (n >= ClipRect.top) then
            if (x1 > ClipRect.right) then
              begin
              x1 := ClipRect.right;
              y1 := n;
              end
            else
              begin
              x2 := ClipRect.right;
              y2 := n;
              end;
          end;
        end;
end;

end.
