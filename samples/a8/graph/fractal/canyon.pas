{

10 GRAPHICS 15+16
20 SETCOLOR 1,6,4:SETCOLOR 2,6,6:SETCOLOR 3,6,1:SETCOLOR 4,1,0
30 XM=105:YM=105:XC=1:YC=0:T=20:S=60
35 XL=-0.15:XR=0.26:YO=0.47:YU=0.9
40 DX=(XR-XL)/XM:DY=(YU-YO)/YM
50 FOR N=0 TO YM:Y1=YO+N*DY:FOR M=0 TO XM:X=XL+M*DX:Y=Y1:K=0
60 X2=X*X:Y2=Y*Y:Y=2*X*Y-YC:X=X2-Y2-XC:K=K+1
65 IF (K<T) AND (X2+Y2<S) THEN 60
70 U=M+53-N/2:U1=U+1:V=N+80:V1=V-3*(K-1)
75 COLOR 3:PLOT U,V:DRAWTO U,V1:COLOR 2:PLOT U1,V:DRAWTO U1,V1:COLOR 1:PLOT U,V1:DRAWTO U1,V1
80 NEXT M:NEXT N
90 IF PEEK(764)=255 THEN 90

}


program canyon;

uses
  Crt, Graph;

type
  TFloat = real;

const
  XM = 105;
  YM = 105;
  T  = 20;
  S  = 60;

var
  N, M, K: byte;
  U, U1, V, V1: byte;

  X, Y, X2, Y2: TFloat;
  Y1, DX, DY: TFloat;
  XL, XR, YO, YU: TFloat;
  XC, YC: TFloat;

  GD, GM: smallint;

begin
  { tryb graficzny }
  GD := VGA;
  GM := VGAMed;
  InitGraph(GD, GM, '');

  XC := 1;
  YC := 0;

  XL := -0.15;
  XR := 0.26;
  YO := 0.47;
  YU := 0.9;

  DX := (XR - XL) / XM;
  DY := (YU - YO) / YM;

  for N := 0 to YM do
  begin
    Y1 := YO + N * DY;

    for M := 0 to XM do
    begin
      X := XL + M * DX;
      Y := Y1;
      K := 0;

      repeat
        X2 := X * X;
        Y2 := Y * Y;

        Y := 2 * X * Y - YC;
        X := X2 - Y2 - XC;

        Inc(K);

      until not ((K < T) and ((X2 + Y2) < S));

      U  := M + 53 - N div 2;
      U1 := U + 1;
      V  := N + 80;
      V1 := V - 3 * (K - 1);

      { COLOR 3 }
      SetColor(3);
      MoveTo(U, V);
      LineTo(U, V1);

      { COLOR 2 }
      SetColor(2);
      MoveTo(U1, V);
      LineTo(U1, V1);

      { COLOR 1 }
      SetColor(1);
      MoveTo(U, V1);
      LineTo(U1, V1);
    end;
  end;

  ReadKey;
  CloseGraph;
end.

