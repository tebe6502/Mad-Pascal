{ TEXURE_P.PAS                                                      }
{ Vykresli texturu a otacajuci sa stvorec.                          }
{                                                                   }
{ Datum:07.11.2000                             http://www.trsek.com }

program texure_poly;

{$f $3b}	// fastmul -> $3b00

uses crt, graph, fastmath;

const
  c0 = $00;
  c1 = $55;
  c2 = $aa;

Var
  Left_x: array [0..255] of byte;// absolute $7000;
  Left_px: array [0..255] of byte;// absolute $7100;
  Left_py: array [0..255] of byte;// absolute $7200;

  Right_x: array [0..255] of byte;// absolute $7300;
  Right_px: array [0..255] of byte;// absolute $7400;
  Right_py: array [0..255] of byte;// absolute $7500;

  Bitmap :Array[0..16*16-1] of Byte = (
  c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c2,
  c2,c0,c0,c1,c1,c1,c1,c1,c1,c1,c1,c1,c1,c0,c0,c2,c2,c0,c1,c0,c1,c1,c1,c1,c1,c1,c1,c1,c0,c1,c0,c2,
  c2,c0,c1,c1,c0,c1,c1,c1,c1,c1,c1,c0,c1,c1,c0,c2,c2,c0,c1,c1,c1,c0,c1,c1,c1,c1,c0,c1,c1,c1,c0,c2,
  c2,c0,c1,c1,c1,c1,c0,c1,c1,c0,c1,c1,c1,c1,c0,c2,c2,c0,c1,c1,c1,c1,c1,c0,c0,c1,c1,c1,c1,c1,c0,c2,
  c2,c0,c1,c1,c1,c1,c1,c0,c0,c1,c1,c1,c1,c1,c0,c2,c2,c0,c1,c1,c1,c1,c0,c1,c1,c0,c1,c1,c1,c1,c0,c2,
  c2,c0,c1,c1,c1,c0,c1,c1,c1,c1,c0,c1,c1,c1,c0,c2,c2,c0,c1,c1,c0,c1,c1,c1,c1,c1,c1,c0,c1,c1,c0,c2,
  c2,c0,c1,c0,c1,c1,c1,c1,c1,c1,c1,c1,c0,c1,c0,c2,c2,c0,c0,c1,c1,c1,c1,c1,c1,c1,c1,c1,c1,c0,c0,c2,
  c2,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c0,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2,c2);

  yMin, yMax : byte;

  Count : byte absolute $e0;
  Count2 : byte absolute $e1;

  XVal : word absolute $e2;
  XStep : word absolute $e4;
  pxVal : word absolute $e6;
  pxStep : word absolute $e8;
  pyVal : word absolute $ea;
  pyStep : word absolute $ec;


{ -------------------------------------------------------------------------- }
Procedure TextureHLine;
const
    tand: array [0..3] of byte = ($c0, $30, $0c, $03);

var b: byte;

    px1, py1, px2, py2: Byte;

    ptr: PByte register;

    x1: Byte register;
    x2: Byte register;

Begin

  ptr:=Scanline(yMin);

  For Count := yMin to yMax do begin

    If Left_x[Count] < Right_x[Count] Then Begin

      X1 := Left_x[Count];
      X2 := Right_x[Count];
      px1 := Left_px[Count];
      py1 := Left_py[Count];
      px2 := Right_px[Count];
      py2 := Right_py[Count];

    End Else Begin

      X1 := Right_x[Count];
      X2 := Left_x[Count];
      px1 := Right_px[Count];
      py1 := Right_py[Count];
      px2 := Left_px[Count];
      py2 := Left_py[Count];

    End;

    pxStep := fastdivS(word((px2-px1) Shl 8), byte(x2-x1+1));
    pyStep := fastdivS(word((py2-py1) Shl 8), byte(x2-x1+1));

    pxVal := px1 shl 8;
    pyVal := py1 shl 8;


    for Count2 := X1 to X2 do begin

     b := Bitmap[Hi(pxVal) + (Hi(pyVal)) Shl 4];
     b := b and tand[Count2 and 3];

     ptr[Count2 shr 2] := ptr[Count2 shr 2] or b;

     inc(pxVal, pxStep);
     inc(pyVal, pyStep);

    end;

    inc(ptr, 40);

  end;

End;


Procedure Swap(Var A, B : byte); register;
Var t : byte;
Begin
 t := a;
 a := b;
 b := t;
End;


Procedure Texture4Poly(X1, Y1, X2, Y2, X3, Y3, X4, Y4 : byte);
Const
    Dim = 64;

Var
    xStart, xEnd : byte;
    yStart, yEnd : byte;
    pxStart, pxEnd : byte;
    pyStart,pyEnd  : byte;

Begin

{
  Line(X1,Y1,X2,Y2);
  Line(X2,Y2,X3,Y3);
  Line(X3,Y3,X4,Y4);
  Line(X4,Y4,X1,Y1);
}

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
  pyEnd := 0;
  pxEnd := Dim-1;

  If yStart > yEnd Then Begin
    Swap(xStart, xEnd);
    Swap(yStart, yEnd);
    Swap(pxStart, pxEnd);

//    Side := @Left;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pxVal := pxStart Shl 8;
    pxStep := fastdivS(word((pxEnd-pxStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Left_x [Count] := XVal Shr 8;
        Left_px[Count] := pxVal Shr 8;
        Left_py[Count] := 0;//pyStart;

        XVal := XVal + XStep;
        pxVal := pxVal + pxStep;
      End;

  End Else begin
//    Side := @Right;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pxVal := pxStart Shl 8;
    pxStep := fastdivS(word((pxEnd-pxStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Right_x [Count] := XVal Shr 8;
        Right_px[Count] := pxVal Shr 8;
        Right_py[Count] := 0;//pyStart;

        XVal := XVal + XStep;
        pxVal := pxVal + pxStep;
      End;

  End;


  xStart := X2;
  yStart := Y2;
  xEnd := X3;
  yEnd := Y3;

  pyStart := 0;
  pxStart := Dim-1;
  pxEnd := Dim-1;
  pyEnd := Dim-1;

  If yStart > yEnd Then Begin
    Swap(xStart, xEnd);
    Swap(yStart, yEnd);
    Swap(pyStart, pyEnd);

//    Side := @Left;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pyVal := pyStart Shl 8;
    pyStep := fastdivS(word((pyEnd-pyStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Left_x [Count] := XVal Shr 8;
        Left_py[Count] := pyVal Shr 8;
        Left_px[Count] := Dim-1;//pxStart;

        XVal := XVal + XStep;
        pyVal := pyVal + pyStep;
      End;

  End Else Begin
//    Side := @Right;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pyVal := pyStart Shl 8;
    pyStep := fastdivS(word((pyEnd-pyStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Right_x [Count] := XVal Shr 8;
        Right_py[Count] := pyVal Shr 8;
        Right_px[Count] := Dim-1;//pxStart;

        XVal := XVal + XStep;
        pyVal := pyVal + pyStep;
      End;

  end;


  xStart := X3;
  yStart := Y3;
  xEnd := X4;
  yEnd := Y4;

  pxStart := Dim-1;
  pyStart := Dim-1;
  pyEnd := Dim-1;
  pxEnd := 0;

  If yStart > yEnd Then Begin
    Swap(xStart, xEnd);
    Swap(yStart, yEnd);
    Swap(pxStart, pxEnd);

    //Side := @Left;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pxVal := pxStart Shl 8;
    pxStep := fastdivS(word((pxEnd-pxStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Left_x [Count] := XVal Shr 8;
        Left_px[Count] := pxVal Shr 8;
        Left_py[Count] := Dim-1;//pyStart;

        XVal := XVal + XStep;
        pxVal := pxVal + pxStep;
      End;

  End Else Begin
//    Side := @Right;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pxVal := pxStart Shl 8;
    pxStep := fastdivS(word((pxEnd-pxStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Right_x [Count] := XVal Shr 8;
        Right_px[Count] := pxVal Shr 8;
        Right_py[Count] := Dim-1;//pyStart;

        XVal := XVal + XStep;
        pxVal := pxVal + pxStep;
      End;

  End;


  xStart := X4;
  yStart := Y4;
  xEnd := X1;
  yEnd := Y1;

  pyStart := Dim-1;
  pxStart := 0;
  pxEnd := 0;
  pyEnd := 0;

  If yStart > yEnd
    Then Begin
      Swap(xStart, xEnd);
      Swap(yStart, yEnd);
      Swap(pyStart, pyEnd);

//      Side := @Left;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pyVal := pyStart Shl 8;
    pyStep := fastdivS(word((pyEnd-pyStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Left_x [Count] := XVal Shr 8;
        Left_py[Count] := pyVal Shr 8;
        Left_px[Count] := 0;//pxStart;

        XVal := XVal + XStep;
        pyVal := pyVal + pyStep;
      End;

   End Else Begin
//      Side := @Right;

    XVal := xStart Shl 8;
    XStep := fastdivS(word((xEnd-xStart) Shl 8), byte(yEnd-yStart+1));
    pyVal := pyStart Shl 8;
    pyStep := fastdivS(word((pyEnd-pyStart) Shl 8), byte(yEnd-yStart+1));

    For Count := yStart to yEnd do
      Begin
        Right_x [Count] := XVal Shr 8;
        Right_py[Count] := pyVal Shr 8;
        Right_px[Count] := 0;//pxStart;

        XVal := XVal + XStep;
        pyVal := pyVal + pyStep;
      End;

  End;


  TextureHLine;

End;


begin

  InitGraph(15+16);

  texture4poly (10,15, 120,30, 90,178, 30,75);

//  texture4poly (16,16, 44,36, 67,72, 21, 93);

  repeat until keypressed;

end.

// 6608