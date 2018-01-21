
{

Bar
Bar3D
Circle
ClipLine
GetMaxX
GetMaxY
GetX
GetY
Ellipse
FillEllipse
FillRect
FloodFill
MoveRel
Rectangle
SetClipRect

}


function GetX: smallint;
begin

 Result := CurrentX;

end;


function GetY: smallint;
begin

 Result := CurrentY;

end;


procedure MoveRel(Dx, Dy: smallint);
begin
     CurrentX := CurrentX + Dx;
     CurrentY := CurrentY + Dy;
end;


function GetMaxX: word;
begin

 Result := ScreenWidth;

end;


function GetMaxY: word;
begin

 Result := ScreenHeight;

end;


procedure Circle(x0,y0,radius: word);
//----------------------------------------------------------------------------------------------
// Bresenham Circle
//----------------------------------------------------------------------------------------------
var	x,y, txp, typ, txm, tym: word;
	d: smallint;

	procedure DrawCircle;
	begin
		PutPixel( txp, typ);
		PutPixel( txp, tym);
		PutPixel( txm, typ);
		PutPixel( txm, tym);
	end;

begin

	x := 0;
	y := radius;
	d := 3 - (radius shl 1);			// Decision criterion

	while (x <= y) do begin

		if d < 0 then begin			// d<0

			//d := d + (x shl 2) + 6	// Change in decision criterion for y -> y+1

//			inc(d, x shl 2);
			inc(d, 6);

		end else begin

			//d := d + (x - y) shl 2 + 10;	// Change for y -> y+1, x -> x-1
			//inc(d, (x - y) shl 2);

//			inc(d, x shl 2);
			dec(d, y shl 2);

			inc(d, 10);
			dec(y);

		end;

		inc(d, x shl 2);

	txp := x0+x;  typ := y0+y;
	txm := x0-x;  tym := y0-y;

	DrawCircle;

	txp := x0+y;  typ := y0+x;
	txm := x0-y;  tym := y0-x;

	DrawCircle;

	inc(x);

	end;

end;


procedure Ellipse(x0, y0, a, b: word);
//----------------------------------------------------------------------------------------------
// Ellipse
//----------------------------------------------------------------------------------------------
var	a2, b2, error, stopx, stopy: integer;
	x, y: word;

	procedure DrawEllipse;
	var txp, typ, txm, tym: word;
	begin
		txp := x0 + x;	typ := y0 + y;
		txm := x0 - x;	tym := y0 - y;

		PutPixel(txp, typ);
		PutPixel(txm, typ);
		PutPixel(txm, tym);
		PutPixel(txp, tym);
	end;

begin
			if (a = 0) or (b = 0) then exit;

			a2 := (a * a) shl 1;
			b2 := (b * b) shl 1;
			error := a*a*b;
			x := 0;
			y := b;
			stopy := 0;
			stopx := word(a2) * b ;

			while (stopy <= stopx) do begin

				DrawEllipse;

				error := error - word(b2) * x;
				inc(x);
				stopy := stopy + b2;
				if (error <= 0) then begin
					dec(y);
					error := error + word(a2) * y;
					stopx := stopx - a2;
				end;
			end;

			error := b*b*a;
			x := a;
			y := 0;
			stopy := word(b2) * a;
			stopx := 0;
			while (stopy >= stopx) do begin

				DrawEllipse;

				error := error - word(a2) * y;
				inc(y);
				stopx := stopx + a2;
				if (error < 0) then begin
					dec(x);
					error := error + word(b2) * x;
					stopy := stopy - b2;
				end;
			end;
end;


procedure FillEllipse(x0, y0, a, b: word);
//----------------------------------------------------------------------------------------------
// Fill Ellipse
//----------------------------------------------------------------------------------------------
var	a2, b2, error, stopx, stopy: integer;
	x, y: word;

	procedure DrawEllipse;
	begin
		Line(x0 - x, y0 + y, x0 + x, y0 + y);
		Line(x0 - x, y0 - y, x0 + x, y0 - y);
	end;

begin
			if (a = 0) or (b = 0) then exit;

			a2 := (a * a) shl 1;
			b2 := (b * b) shl 1;
			error := a*a*b;
			x := 0;
			y := b;
			stopy := 0;
			stopx := word(a2) * b ;

			while (stopy <= stopx) do begin

				DrawEllipse;

				error := error - word(b2) * x;
				inc(x);
				stopy := stopy + b2;
				if (error <= 0) then begin
					dec(y);
					error := error + word(a2) * y;
					stopx := stopx - a2;
				end;
			end;

			error := b*b*a;
			x := a;
			y := 0;
			stopy := word(b2) * a;
			stopx := 0;
			while (stopy >= stopx) do begin

				DrawEllipse;

				error := error - word(a2) * y;
				inc(y);
				stopx := stopx + a2;
				if (error < 0) then begin
					dec(x);
					error := error + word(b2) * x;
					stopy := stopy - b2;
				end;
			end;
end;


procedure Rectangle(x1, y1, x2, y2: Smallint); overload;
//----------------------------------------------------------------------------------------------
// Draws a rectangle with corners at (X1,Y1) and (X2,Y2), using the current color
//----------------------------------------------------------------------------------------------
begin

 MoveTo(x1,y1);
 LineTo(x2,y1);
 LineTo(x2,y2);
 LineTo(x1,y2);
 LineTo(x1,y1);

end;


procedure Rectangle(Rect: TRect); overload;
//----------------------------------------------------------------------------------------------
// Draws a rectangle with corners at (X1,Y1) and (X2,Y2), using the current color
//----------------------------------------------------------------------------------------------
begin

 MoveTo(Rect.Left, Rect.Top);
 LineTo(Rect.Right, Rect.Top);
 LineTo(Rect.Right, Rect.Bottom);
 LineTo(Rect.Left, Rect.Bottom);
 LineTo(Rect.Left, Rect.Top);

end;


procedure FloodFill(a,b: smallint; newcolor: byte);
//----------------------------------------------------------------------------------------------
// Fill an area with a given color, seed fill algorithm
//----------------------------------------------------------------------------------------------
var ir, nf: word;
    c: cardinal;
    oldcolor: byte;
    FloodFillStack: array [0..0] of cardinal;


procedure FloodFillExec;
var i: byte;
    xr,yr: smallint;
    yes: Boolean;
begin

 for i:=0 to 3 do begin

  case i of

   0: begin
	xr:=a+1;
	yr:=b;

	yes:=(xr<smallint(ScreenWidth));
      end;

   1: begin
	xr:=a-1;
//	yr:=b;

	yes:=(xr>=0);
      end;

   2: begin
	xr:=a;
	yr:=b+1;

	yes:=(yr<smallint(ScreenHeight));
      end;

   3: begin
//	xr:=a;
	yr:=b-1;

	yes:=(yr>=0);
      end;

  end;


  if yes then
   if GetPixel(xr,yr) = oldcolor then begin

    PutPixel(xr, yr);

    inc(nf);

    FloodFillStack[nf]:= word(xr) shl 16 + word(yr);
   end;

 end;

end;


begin

 FloodFillStack:=pointer(dpeek(560)-2048);

 SetColor(newcolor);

 oldcolor:=GetPixel(a,b);

 nf := 1;
 ir := 1;
 FloodFillStack[nf] := word(a) shl 16 + word(b);

 FloodFillExec;

 while nf>ir do begin

  inc(ir);

  c:=FloodFillStack[ir];

  a := hi(c);
  b := lo(c);

  FloodFillExec;

  if (nf>500) then begin

   nf := nf-ir;

   if nf>500 then exit;

   move(FloodFillStack[ir+1], FloodFillStack[1], nf shl 2);

//   for i := 1 to nf do fill[i] := fill[ir+i];

   ir := 0;

  end;

 end;

end;


procedure Bar(x1, y1, x2, y2: Smallint);
//----------------------------------------------------------------------------------------------
// Draw filled rectangle
//----------------------------------------------------------------------------------------------
var i: smallint;
begin

 for i:=y1 to y2 do Line(x1,i, x2, i);

end;


procedure FillRect(Rect: TRect);
//----------------------------------------------------------------------------------------------
// Draw filled rectangle
//----------------------------------------------------------------------------------------------
var i: smallint;
begin

 NormalizeRect(Rect);

 for i:=Rect.Top to Rect.Bottom do Line(Rect.Left, i, Rect.Right, i);

end;


procedure Bar3D(x1, y1, x2, y2 : smallint;depth : word;top : boolean);
//----------------------------------------------------------------------------------------------
// Draw filled 3-dimensional rectangle
//----------------------------------------------------------------------------------------------
var
 origwritemode : smallint;
 OldX, OldY : smallint;
begin

  if x1 > x2 then
  begin
    OldX := x1;
    x1 := x2;
    x2 := OldX;
  end;
  if y1 > y2 then
  begin
    OldY := y1;
    y1 := y2;
    y2 := OldY;
  end;

  Bar(x1,y1,x2,y2);
  Rectangle(x1,y1,x2,y2);

  { Current CP should not be updated in Bar3D }
  { therefore save it and then restore it on  }
  { exit.                                     }
  OldX := CurrentX;
  OldY := CurrentY;

  if top then begin
    Moveto(x1,y1);
    Lineto(x1+depth,y1-depth);
    Lineto(x2+depth,y1-depth);
    Lineto(x2,y1);
  end;
  if Depth <> 0 then
    Begin
      Moveto(x2+depth,y1-depth);
      Lineto(x2+depth,y2-depth);
      Lineto(x2,y2);
    end;
  { restore CP }
  CurrentX := OldX;
  CurrentY := OldY;
end;


procedure SetClipRect(x0,y0,x1,y1: smallint); overload;
begin
	WIN_LEFT := x0;
	WIN_RIGHT := x1;
	WIN_TOP := y0;
	WIN_BOTTOM := y1;
end;


procedure SetClipRect(Rect: TRect); overload;
begin
	WIN_LEFT := Rect.Left;
	WIN_RIGHT := Rect.Right;
	WIN_TOP := Rect.Top;
	WIN_BOTTOM := Rect.Bottom;
end;


function calcRegCode(x, y: smallint): byte;
begin
   result := 0;

   if (x < WIN_LEFT)   then result := (result or 1);
   if (x > WIN_RIGHT)  then result := (result or 2);
   if (y > WIN_BOTTOM) then result := (result or 4);
   if (y < WIN_TOP)    then result := (result or 8);
end;


procedure ClipLine(x1, y1, x2, y2: smallint);
// Cohen_Sutherland
var
   rcode1, rcode2, rcode: byte;
   x, y: smallint;
begin

   // Algorytm Cohena-Sutherlanda
   // 1. Zakoduj koñce odcinka zgodnie z kodami obszarów
   rcode1 := calcRegCode(x1, y1);
   rcode2 := calcRegCode(x2, y2);
   // 2. Je¿eli iloczyn logiczny (AND) tych kodów <>0,
   // to odcinek mo¿e byæ pominiêty (w ca³oœci poza
   // oknem) - zaznacz go na czerwono
//   if ((rcode1 and rcode2) <> 0) then
//   begin
//      Image1.Canvas.Pen.Color := clRed;
//      Image1.Canvas.MoveTo(x1, y1);
//      Image1.Canvas.LineTo(x2, y2);
//   end
   // 3. Je¿eli suma logiczna (OR)tych kodów = 0,
   // to odcinek w ca³oœci mieœci siê w okienku
   // - zaznacz go na zielono
//   else
   if ((rcode1 or rcode2) = 0) then
   begin
//      Image1.Canvas.Pen.Color := clGreen;
      fLine(x1, y1, x2, y2);
   end
   else
   begin
      // pozostale przypadki - przeciecie z krawedzia okna
      repeat
         if (rcode1 <> 0) then
            rcode := rcode1
         else
            rcode := rcode2;

         // pozostale przypadki - przeciecie z krawedzia okna
         if (rcode and 1) <> 0 then
         begin
            y := y1+smallint(smallint(y2-y1)*smallint(WIN_LEFT-x1)) div smallint(x2-x1);
            x := WIN_LEFT;
         end
         else if (rcode and 2) <> 0 then
         begin
            y := y1+smallint(smallint(y2-y1)*smallint(WIN_RIGHT-x1)) div smallint(x2-x1);
            x := WIN_RIGHT;
         end
         else if (rcode and 4) <> 0 then
         begin
            x := x1+smallint(smallint(x2-x1)*smallint(WIN_BOTTOM-y1)) div smallint(y2-y1);
            y := WIN_BOTTOM;
         end
         else if (rcode and 8) <> 0 then
         begin
            x := x1+smallint(smallint(x2-x1)*smallint(WIN_TOP-y1)) div smallint(y2-y1);
            y := WIN_TOP;
         end;

         if (rcode = rcode1) then
         begin
//            Image1.Canvas.Pen.Color := clYellow;
//            Image1.Canvas.MoveTo(x1, y1);
//            Image1.Canvas.LineTo(x, y);
            x1 := x;
            y1 := y;
            rcode1 := calcRegCode(x1, y1);
         end
         else
         begin
//            Image1.Canvas.Pen.Color := clYellow;
//            Image1.Canvas.MoveTo(x2, y2);
//            Image1.Canvas.LineTo(x, y);
            x2 := x;
            y2 := y;
            rcode2 := calcRegCode(x2, y2);
         end;
      until (((rcode1 and rcode2) <> 0) or ((rcode1 or rcode2) = 0));

      if ((rcode1 or rcode2) = 0) then
      begin
//         Image1.Canvas.Pen.Color := clBlue;
         fLine(x1, y1, x2, y2);
      end
//      else
//      begin
//         Image1.Canvas.Pen.Color := clYellow;
//         Image1.Canvas.MoveTo(x1, y1);
//         Image1.Canvas.LineTo(x2, y2);
//      end;
   end;
end;
