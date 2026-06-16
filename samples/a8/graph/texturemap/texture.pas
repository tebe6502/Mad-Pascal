{ TEXURE_P.PAS                                                      }
{ Vykresli texturu a otacajuci sa stvorec.                          }
{                                                                   }
{ Datum:07.11.2000                             http://www.trsek.com }

program texure_poly;

uses crt, graph;

const
  c0 = $00;
  c1 = $55;
  c2 = $aa;

Type
  TE = Record  X, px, py : Byte; End;

  Table = Array[0..199] of ^TE;
  PTable = ^Table;

Var
  Left : Table;
  Right : Table;

  pxVal, pxStep : word;
  pyVal, pyStep : word;

  gd, gm: smallint;

  Bitmap :Array[0..16*16-1] of Byte = (
  c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c2,
  c2,c0,c0,c1,c1,c1,c1,c1,c1,c1,c1,c1,c1,c0,c0,c2,c2,c0,c1,c0,c1,c1,c1,c1,c1,c1,c1,c1,c0,c1,c0,c2,
  c2,c0,c1,c1,c0,c1,c1,c1,c1,c1,c1,c0,c1,c1,c0,c2,c2,c0,c1,c1,c1,c0,c1,c1,c1,c1,c0,c1,c1,c1,c0,c2,
  c2,c0,c1,c1,c1,c1,c0,c1,c1,c0,c1,c1,c1,c1,c0,c2,c2,c0,c1,c1,c1,c1,c1,c0,c0,c1,c1,c1,c1,c1,c0,c2,
  c2,c0,c1,c1,c1,c1,c1,c0,c0,c1,c1,c1,c1,c1,c0,c2,c2,c0,c1,c1,c1,c1,c0,c1,c1,c0,c1,c1,c1,c1,c0,c2,
  c2,c0,c1,c1,c1,c0,c1,c1,c1,c1,c0,c1,c1,c1,c0,c2,c2,c0,c1,c1,c0,c1,c1,c1,c1,c1,c1,c0,c1,c1,c0,c2,
  c2,c0,c1,c0,c1,c1,c1,c1,c1,c1,c1,c1,c0,c1,c0,c2,c2,c0,c0,c1,c1,c1,c1,c1,c1,c1,c1,c1,c1,c0,c0,c2,
  c2,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2);


{ -------------------------------------------------------------------------- }
Procedure TextureHLine(X1, X2, px1, py1, px2, py2, Y : byte);
var b, Count: byte;
Begin

  pxStep := smallint((px2-px1) Shl 8) Div byte(x2-x1+1);
  pyStep := smallint((py2-py1) Shl 8) Div byte(x2-x1+1);

  pxVal := px1 shl 8;
  pyVal := py1 shl 8;


  for Count := X1 to X2 do begin

   b:=Bitmap[Hi(pxVal)+(Hi(pyVal)) Shl 4];

   PutPixel(count, y, b);

   inc(pxVal, pxStep);
   inc(pyVal, pyStep);

  end;

End;


Procedure Swap(Var A, B : byte);
Var t : byte;
Begin
 t := a;
 a := b;
 b := t;
End;


Procedure Texture4Poly(X1, Y1, X2, Y2, X3, Y3, X4, Y4 : byte);
Var yMin, yMax : byte;
    xStart, xEnd : byte;
    yStart, yEnd : byte;
    pxStart, pxEnd : byte;
    pyStart,pyEnd  : byte;
    Count, Dim: byte;
    XVal, XStep : word;
    Side : PTable;

    pTmp: ^TE;
Begin

{
  Line(X1,Y1,X2,Y2);
  Line(X2,Y2,X3,Y3);
  Line(X3,Y3,X4,Y4);
  Line(X4,Y4,X1,Y1);
}

  Dim:=64;

  yMin := Y1; yMax := Y1;

  If Y2 > yMax Then yMax := Y2; If Y3 > yMax Then yMax := Y3;
  If Y4 > yMax Then yMax := Y4; If Y2 < yMin Then yMin := Y2;
  If Y3 < yMin Then yMin := Y3; If Y4 < yMin Then yMin := Y4;

  xStart := X1;
  yStart := Y1;
  xEnd := X2;
  yEnd := Y2;

  pxStart := 0;
  pyStart := 0;
  pxEnd := Dim-1;
  pyEnd := 0;

  If yStart > yEnd Then Begin
    Swap(xStart, xEnd);
    Swap(yStart, yEnd);
    Swap(pxStart, pxEnd);

    Side := @Left;
  End Else
    Side := @Right;

  XVal := xStart Shl 8;
  XStep := smallint((xEnd-xStart) Shl 8) Div byte(yEnd-yStart+1);
  pxVal := pxStart Shl 8;
  pxStep := smallint((pxEnd-pxStart) Shl 8) Div byte(yEnd-yStart+1);


  For Count := yStart to yEnd do
    Begin
      pTmp:=GetMem(sizeof(TE));

      pTmp.x := XVal Shr 8;
      pTmp.px := pxVal Shr 8;
      pTmp.py := pyStart;

      Side^[Count]:=pTmp;

      XVal := XVal + XStep;
      pxVal := pxVal + pxStep;
    End;


  xStart := X2;
  yStart := Y2;
  xEnd := X3;
  yEnd := Y3;

  pxStart := Dim-1;
  pyStart := 0;
  pxEnd := Dim-1;
  pyEnd := Dim-1;

  If yStart > yEnd Then Begin
    Swap(xStart, xEnd);
    Swap(yStart, yEnd);
    Swap(pyStart, pyEnd);

    Side := @Left;
  End Else
    Side := @Right;

  XVal := xStart Shl 8;
  XStep := smallint((xEnd-xStart) Shl 8) Div byte(yEnd-yStart+1);
  pyVal := pyStart Shl 8;
  pyStep := smallint((pyEnd-pyStart) Shl 8) Div byte(yEnd-yStart+1);


  For Count := yStart to yEnd do
    Begin
      pTmp:=GetMem(sizeof(TE));

      pTmp.x := XVal Shr 8;
      pTmp.py := pyVal Shr 8;
      pTmp.px := pxStart;

      Side^[Count]:=pTmp;

      XVal := XVal + XStep;
      pyVal := pyVal + pyStep;
    End;


  xStart := X3;
  yStart := Y3;
  xEnd := X4;
  yEnd := Y4;

  pxStart := Dim-1;
  pyStart := Dim-1;
  pxEnd := 0;
  pyEnd := Dim-1;

  If yStart > yEnd Then Begin
    Swap(xStart, xEnd);
    Swap(yStart, yEnd);
    Swap(pxStart, pxEnd);
    Side := @Left;
  End Else
    Side := @Right;

  XVal := xStart Shl 8;
  XStep := smallint((xEnd-xStart) Shl 8) Div byte(yEnd-yStart+1);
  pxVal := pxStart Shl 8;
  pxStep := smallint((pxEnd-pxStart) Shl 8) Div byte(yEnd-yStart+1);

  For Count := yStart to yEnd do
    Begin
      pTmp:=GetMem(sizeof(TE));

      pTmp.x := XVal Shr 8;
      pTmp.px := pxVal Shr 8;
      pTmp.py := pyStart;

      Side^[Count] := pTmp;

      XVal := XVal + XStep;
      pxVal := pxVal + pxStep;
    End;


  xStart := X4;
  yStart := Y4;
  xEnd := X1;
  yEnd := Y1;

  pxStart := 0;
  pyStart := Dim-1;
  pxEnd := 0;
  pyEnd := 0;

  If yStart > yEnd
    Then Begin
      Swap(xStart, xEnd);
      Swap(yStart, yEnd);
      Swap(pyStart, pyEnd);

      Side := @Left;
    End Else
      Side := @Right;


  XVal := xStart Shl 8;
  XStep := smallint((xEnd-xStart) Shl 8) Div byte(yEnd-yStart+1);
  pyVal := pyStart Shl 8;
  pyStep := smallint((pyEnd-pyStart) Shl 8) Div byte(yEnd-yStart+1);

  For Count := yStart to yEnd do
    Begin
      pTmp:=GetMem(sizeof(TE));

      pTmp.x := XVal Shr 8;
      pTmp.py := pyVal Shr 8;
      pTmp.px := pxStart;

      Side^[Count] := pTmp;

      XVal := XVal + XStep;
      pyVal := pyVal + pyStep;
    End;


  For Count := yMin to yMax do
    If Left[Count].x < Right[Count].x Then
      TextureHLine(Left[Count].x, Right[Count].x, Left[Count].px, Left[Count].py, Right[Count].px, Right[Count].py, Count)
    Else
      TextureHLine(Right[Count].x, Left[Count].x, Right[Count].px, Right[Count].py, Left[Count].px, Left[Count].py, Count);

End;


procedure init_texture;
var p,q, c: byte;
begin

  for p := 0 to 16-1 do
    for q := 0 to 16-1 do begin
      c := ((q shr 2) shl 1) + p shr 2;
      Bitmap [p*16+q] := c and $03;
    end;

end;


begin

  gd := VGA;
  gm := VGAMed;
  InitGraph(gd,gm,'');

//  init_texture;

  SetColor(15);

  texture4poly (10,15, 120,30, 90,178, 30,75);

  repeat until keypressed;

end.

// 5259