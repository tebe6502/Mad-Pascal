//-------- Bitmap Quadrangle Deformation
//-------- PALDACCI Antony ------ spatul@hotmail.com
//-------- 06/10/2008
//-------- Mad Pascal / FPC (04-08-2025)

uses crt, graph;

type

{$IFDEF ATARI}
  TFloat = float16;
{$ELSE}
  TFloat = real;
{$ENDIF}

  TPoint = record x,y: byte end;

  TQuadrangle = record A,B,C,D : TPoint; end;

var
  gd, gm: smallint;

  Quadrangle: tquadrangle;

  BmpOrigin: array [0..63, 0..63] of byte;


function Min(x, y: byte): byte;
(*
@description: Min returns the smallest value of X and Y.
*)
begin
if x < y then Result := x else Result := y;
end;


function Max(x, y: byte): byte;
(*
@description: Max returns the maximum of X and Y.

*)
begin
if x > y then Result := x else Result := y;
end;


procedure Distorsion(AQuadrangle:TQuadrangle);
var
// xd, yd,
 v, u, x, y, c : byte;
 RQWidth, RQHeight : byte;

 Ox, Oy, Fx, Fy ,
 DistAB, DistDC, DistAD, DistBC: byte;

 TauxY, TauxX, TauxY_Add, TauxX_Add,
 PosXAB, PosXDC, PosYAD, PosYBC : TFloat;

begin

//--calculation of the area of the rectangle (master rectangle) containing the quadrangle
 Ox := min(min(AQuadrangle.A.X,AQuadrangle.B.X),min(AQuadrangle.C.X,AQuadrangle.D.X));
 Oy := min(min(AQuadrangle.A.Y,AQuadrangle.B.Y),min(AQuadrangle.C.Y,AQuadrangle.D.Y));
 Fx := max(max(AQuadrangle.A.X,AQuadrangle.B.X),max(AQuadrangle.C.X,AQuadrangle.D.X));
 Fy := max(max(AQuadrangle.A.Y,AQuadrangle.B.Y),max(AQuadrangle.C.Y,AQuadrangle.D.Y));

 RQWidth := Fx-Ox;
 RQHeight := Fy-Oy;

//--Transfer pixels to the right place

  DistAD := AQuadrangle.D.Y-AQuadrangle.A.Y;
  DistBC := AQuadrangle.C.Y-AQuadrangle.B.Y;

  DistAB := AQuadrangle.B.X-AQuadrangle.A.X;
  DistDC := AQuadrangle.C.X-AQuadrangle.D.X;

  TauxY_Add := 1 / RQHeight;

  TauxX_Add := 1 / RQWidth;

 { For each pixel, calculate the positioning rate of x and y }
 For v:=1 to RQHeight-1 do begin
  TauxY := v * TauxY_Add;

  PosYAD := AQuadrangle.A.Y+(DistAD*TauxY);
  PosYBC := AQuadrangle.B.Y+(DistBC*TauxY);

  For u := 1 to RQWidth-1 do begin
   TauxX := u * TauxX_Add;

   PosXAB := AQuadrangle.A.X+(DistAB*TauxX);
   PosXDC := AQuadrangle.D.X+(DistDC*TauxX);

   x := trunc(PosXAB+(PosXDC-PosXAB)*TauxY);
   y := trunc(PosYAD+(PosYBC-PosYAD)*TauxX);

//   xd := Round(Frac(PosXAB+(PosXDC-PosXAB)*TauxY));
//   yd := Round(Frac(PosYAD+(PosYBC-PosYAD)*TauxX));

  { transfers the pixels to the correct location }

   c:=BmpOrigin[v and $3f, u and $3f];

   PutPixel(x,y, c);

{
   //to fill in the gaps..."
   if (x < RQWidth-2) and (xd > 0) then PutPixel(x+1, y, c);
   if (y < RQHeight-2) and (yd > 0) then PutPixel(x, y+1, c);
}

  end;

 end;


 SetColor(1);
 Line(AQuadrangle.A.X, AQuadrangle.A.Y , AQuadrangle.B.X, AQuadrangle.B.Y);
 Line(AQuadrangle.B.X, AQuadrangle.B.Y , AQuadrangle.C.X, AQuadrangle.C.Y);
 Line(AQuadrangle.C.X, AQuadrangle.C.Y , AQuadrangle.D.X, AQuadrangle.D.Y);
 Line(AQuadrangle.D.X, AQuadrangle.D.Y , AQuadrangle.A.X, AQuadrangle.A.Y);


end;


procedure init_texture;
var p,q,c: byte;
begin

  for p := 0 to 64-1 do
    for q := 0 to 64-1 do begin
      c := ((q shr 4) shl 1) + p shr 4;
      BmpOrigin [p, q] := c and $03;
    end;

end;


begin

 gd := VGA;
 gm := VGAMed;
 InitGraph(gd,gm,'');

 init_texture;

 // 30,20, 120,50, 60,140, 20,100);
 Quadrangle.A.x:=23;
 Quadrangle.A.y:=15;

 Quadrangle.B.x:=147;
 Quadrangle.B.y:=43;

 Quadrangle.C.x:=120;
 Quadrangle.C.y:=140;

 Quadrangle.D.x:=54;
 Quadrangle.D.y:=170;

 Distorsion(Quadrangle);

 //show;

 repeat until keypressed;

end.