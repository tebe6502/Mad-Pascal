Program Frac3d1;

Uses crt, fastgraph;

Const
   ZInc = 25;
   ZOfs = 256;
   ZScale = 256;
   Sc = 0.5;

   cx = 160;
   cy = 96;

Type
      TFloat = float16;

	PPoint = ^TPoint;
	ArrayPoints = array [0..7] of PPoint;

      Triangle =
      Record
      	X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3 : TFloat;
        Color : Byte;
      End;

Var
   Tris : Array[0..100] Of ^Triangle;
   ytopclip,
   ybotclip : smallint;
   Trin, l, n, hn : Word;
   db : Pointer;
   Ch : Char;
   poly : array [0..199,0..1] of smallint;

   vertices: ArrayPoints;

   Tmp: Triangle;

   gd,gm:smallint;


(*
Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:smallint);
  { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
    in color col }
var i, miny,maxy:smallint;
    loop1:smallint;

Procedure doside (x1,y1,x2,y2:smallint);
  { This scans the side of a polygon and updates the poly variable }
VAR temp:smallint;
    x,xinc:smallint;
    loop1:smallint;
BEGIN
  if y1=y2 then exit;
  if y2<y1 then BEGIN
    temp:=y2;
    y2:=y1;
    y1:=temp;
    temp:=x2;
    x2:=x1;
    x1:=temp;
  END;
  xinc:=((x2-x1) shl 7) div (y2-y1);
  x:=x1 shl 7;
  for loop1:=y1 to y2 do BEGIN
    if (loop1>ytopclip-1) and (loop1<ybotclip+1) then
	 BEGIN
      if (x shr 7<poly[loop1,0]) then poly[loop1,0]:=x shr 7;
      if (x shr 7>poly[loop1,1]) then poly[loop1,1]:=x shr 7;
    END;
    x:=x+xinc;
  END;
END;


begin


 for i:=0 to 199 do begin

 poly[i, 0] := 32766;
 poly[i, 1] := -32767;

 end;


  miny:=y1;
  maxy:=y1;
  if y2<miny then miny:=y2;
  if y3<miny then miny:=y3;
  if y4<miny then miny:=y4;
  if y2>maxy then maxy:=y2;
  if y3>maxy then maxy:=y3;
  if y4>maxy then maxy:=y4;
  if miny<ytopclip then miny:=ytopclip;
  if maxy>ybotclip then maxy:=ybotclip;
  if (miny>199) or (maxy<0) then exit;
  if miny=maxy then exit;

  Doside (x1,y1,x2,y2);
  Doside (x2,y2,x3,y3);
  Doside (x3,y3,x4,y4);
  Doside (x4,y4,x1,y1);

  for loop1:= miny to maxy do
    hline (poly[loop1,0],poly[loop1,1],loop1);
end;
*)


Procedure AddTris(n : Word);
Var
	OX1, OY1, OZ1, OX2, OY2, OZ2, OX3, OY3, OZ3 : TFloat;
   	OC : Byte;
Begin

	Tmp:=Tris[n]^;
   	With Tmp Do
      	Begin
         	OX1 := X1;
         	OY1 := Y1;
         	OZ1 := Z1;
         	OX2 := X2;
         	OY2 := Y2;
         	OZ2 := Z2;
         	OX3 := X3;
         	OY3 := Y3;
         	OZ3 := Z3;
            OC := Color + 24;
         End;

	Tmp:=Tris[Trin]^;
   	With Tmp Do
      	Begin
            X1 := OX1;
            Y1 := OY1;
            Z1 := OZ1+ZInc;
            X2 := OX1*2/3+OX2/3;
            Y2 := OY1*2/3+OY2/3;
            Z2 := OZ2+ZInc;
            X3 := OX1*2/3+OX3/3;
            Y3 := OY1*2/3+OY3/3;
            Z3 := OZ3+ZInc;
            Color := OC;
         End;
	 Tris[Trin]^ := Tmp;

	Tmp:=Tris[Trin+1]^;
   	With Tmp Do
      	Begin
         	X1 := OX2*2/3+OX1/3;
         	Y1 := OY2*2/3+OY1/3;
         	Z1 := OZ1+ZInc;
         	X2 := OX2;
         	Y2 := OY2;
         	Z2 := OZ2+ZInc;
         	X3 := OX2*2/3+OX3/3;
         	Y3 := OY2*2/3+OY3/3;
         	Z3 := OZ3+ZInc;
            Color := OC;
         End;
	 Tris[Trin+1]^ := Tmp;

	Tmp:=Tris[Trin+2]^;
   	With Tmp Do
      	Begin
         	X1 := OX3*2/3+OX1/3;
         	Y1 := OY3*2/3+OY1/3;
         	Z1 := OZ1+ZInc;
         	X2 := OX3*2/3+OX2/3;
         	Y2 := OY3*2/3+OY2/3;
         	Z2 := OZ2+ZInc;
         	X3 := OX3;
         	Y3 := OY3;
         	Z3 := OZ3+ZInc;
            Color := OC;
         End;
	 Tris[Trin+2]^ := Tmp;

      Trin := Trin + 3;
End;


Procedure DrawTris;
Var SX1, SY1, SX2, SY2, SX3, SY3, n : Word;
Begin

        //ClearDevice;

	fillByte(pointer(dpeek(88)), 40*192, 0);


   	n := 0;
   	Repeat

	Tmp := Tris[n]^;
      	With Tmp Do
         	Begin
		      	SX1 := Round((ZScale*X1)/(Z1-ZOfs));
		      	SY1 := Round((ZScale*Y1)/(Z1-ZOfs));
		      	SX2 := Round((ZScale*X2)/(Z2-ZOfs));
		      	SY2 := Round((ZScale*Y2)/(Z2-ZOfs));
		      	SX3 := Round((ZScale*X3)/(Z3-ZOfs));
		      	SY3 := Round((ZScale*Y3)/(Z3-ZOfs));

			vertices[0].x := cx+SX1;
			vertices[0].y := cy+SY1;
			vertices[1].x := cx+SX2;
			vertices[1].y := cy+SY2;
			vertices[2].x := cx+SX3;
			vertices[2].y := cy+SY3;
			vertices[3].x := cx+SX1;
			vertices[3].y := cy+SY1;

   		        FillPoly(4, vertices);
         	End;

         n := n + 1;
      Until n = Trin;

End;


Procedure Rotate(Var X, Y, ang : TFloat);
Var XX, YY : TFloat;
Begin
      XX := X*Cos(ang)+Y*Sin(ang);
      YY := Y*Cos(ang)-X*Sin(ang);
      X := XX;
      Y := YY;
End;


Procedure RotateTris(ang : TFloat);
Var n : Word;
Begin
      n := 0;
      Repeat

	Tmp := Tris[n]^;
      	With Tmp Do
            Begin
            	Rotate(X1, Z1, ang);
            	Rotate(X2, Z2, ang);
            	Rotate(X3, Z3, ang);
            End;
	Tris[n]^ := Tmp;

      	n := n + 1;
      Until n = Trin;
End;


Procedure RotateTrisb(ang : TFloat);
Var n : Word;
Begin
      n := 0;
      Repeat

	Tmp := Tris[n]^;
      	With Tmp Do
            Begin
            	Rotate(X1, Y1, ang);
            	Rotate(X2, Y2, ang);
            	Rotate(X3, Y3, ang);
            End;
	Tris[n]^ := Tmp;

      	n := n + 1;
      Until n = Trin;
End;


Procedure RotateTrisc(ang : TFloat);
Var n : Word;
Begin
      n := 0;
      Repeat

	Tmp := Tris[n]^;
      	With Tmp Do
            Begin
            	Rotate(Y1, Z1, ang);
            	Rotate(Y2, Z2, ang);
            	Rotate(Y3, Z3, ang);
            End;
	Tris[n]^ := Tmp;

      	n := n + 1;
      Until n = Trin;
End;


Procedure SortTris;
Var
   n : Word;

	Procedure Swap(Var a, b : TFloat);
   	Var t : TFloat;
   	Begin
      	 t := a;
         a := b;
         b := t;
        End;

	Procedure SwapByte(Var a, b : Byte);
   	Var t : Byte;
   	Begin
      	 t := a;
         a := b;
         b := t;
        End;

Begin
      n := 0;
      Repeat
      	If Tris[n].z1 > Tris[n+1].z1 Then
         	Begin
            	Swap(Tris[n].x1, Tris[n+1].x1);
            	Swap(Tris[n].y1, Tris[n+1].y1);
            	Swap(Tris[n].z1, Tris[n+1].z1);
            	Swap(Tris[n].x2, Tris[n+1].x2);
            	Swap(Tris[n].y2, Tris[n+1].y2);
            	Swap(Tris[n].z2, Tris[n+1].z2);
            	Swap(Tris[n].x3, Tris[n+1].x3);
            	Swap(Tris[n].y3, Tris[n+1].y3);
            	Swap(Tris[n].z3, Tris[n+1].z3);
            	SwapByte(Tris[n].Color, Tris[n+1].Color);
            End;
         n := n + 1;
      Until n = Trin;
   End;

Procedure ExpandTris;
	Const Scd = 0.95;
	Var n : Word;
	Begin
   	n := 0;
      Repeat

	Tmp := Tris[n]^;
      	With Tmp Do
         	Begin
            	X1 := X1 * Scd;
            	Y1 := Y1 * Scd;
            	X2 := X2 * Scd;
            	Y2 := Y2 * Scd;
            	X3 := X3 * Scd;
            	Y3 := Y3 * Scd;
            End;
	Tris[n]^ := Tmp;

         n := n + 1;
      Until n = Trin;
   End;


Begin
  ytopclip:=0;
  ybotclip:=199;

{$IFDEF ATARI}
 InitGraph(8+16);


{$ELSE}
  gd := VGA;
  gm := VGAHi;
  InitGraph(gd,gm,'');
{$ENDIF}

  SetColor(15);

  for Trin:=Low(vertices) to High(vertices) do vertices[Trin] := GetMem(sizeof(TPoint));

  for Trin:=Low(Tris) to High(Tris) do Tris[Trin] := GetMem(sizeof(Triangle));


{
     X1



  X3    X2

  a    c    b  . c = a*2/3 + b/3
  a    c    b  . c = a/3 + b*2/3
}

   Tmp := Tris[0]^;

   With Tmp Do
   	Begin
      	X1 := 0;
      	Y1 := 86;
      	Z1 := 0;
      	X2 := 100;
      	Y2 := -86;
      	Z2 := 0;
      	X3 := -100;
      	Y3 := -86;
      	Z3 := 0;

      	X1 := X1 * Sc;
      	Y1 := Y1 * Sc;
      	Z1 := Z1 * Sc;
      	X2 := X2 * Sc;
      	Y2 := Y2 * Sc;
      	Z2 := Z2 * Sc;
      	X3 := X3 * Sc;
      	Y3 := Y3 * Sc;
      	Z3 := Z3 * Sc;

   	Color := 24;
      End;

   Tris[0]^ := Tmp;


   Trin := 1;
   l := 3;
   hn:=0;


   Repeat
      n := hn;
      hn := Trin;
   	Repeat
      	AddTris(n);
      	n := n + 1;
      Until n = hn;
   	l := l - 1;
   Until l = 0;

   Repeat
   	n := 0;
   	Repeat
	 DrawTris;
	 RotateTris(Pi/72);
         SortTris;
         n := n + 1;
      Until KeyPressed Or (n = 144);

   	n := 0;
   	Repeat
	 DrawTris;
	 RotateTrisb(Pi/72);
         n := n + 1;
      Until KeyPressed Or (n = 144);

   	n := 0;
   	Repeat
	 DrawTris;
	 RotateTrisc(Pi/72);
         SortTris;
         n := n + 1;
      Until KeyPressed Or (n = 144);

   Until KeyPressed;

//   Halt(0);

   n := 150;
   Repeat
      DrawTris;
      ExpandTris;
      RotateTris(Pi/72);
      RotateTrisb(Pi/72);
      RotateTrisc(Pi/72);
      n := n - 1;
   Until n = 0;
   Repeat Ch := ReadKey Until Not KeyPressed;

End.