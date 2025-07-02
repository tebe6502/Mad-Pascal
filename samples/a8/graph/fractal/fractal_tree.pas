// 2951

program FractalTree;

uses crt, graph;

const	SplitProportion=0.22;
	cosphi         =0.939692620791;
	sinphi         =0.342020143326;
	maxlevel       =8;
	maxtab         =20;
	Xmax           =319;
	Ymax           =191;

var   i     :byte;
      mx    ,
      my    ,
      dx    ,
      dy    : real;
      tab   : array [0..maxtab] of real;

procedure split(sx, sy, ex, ey:real; level:byte );

  var midx    ,
      midy    ,
      oldlen  ,
      newlen  ,
      a1,b1,a2,b2,
      costheta,
      sintheta : real;

  begin
    midx    :=(sx+ex)*0.5;
    midy    :=(sy+ey)*0.5;
    dx      :=ex-sx;
    dy      :=ey-sy;
    oldlen  :=tab[level-1];
    newlen  :=tab[level];
    costheta:=dx/oldlen;
    sintheta:=dy/oldlen;

    MoveTo(trunc(sx  ),trunc(ymax-sy  ));
    LineTo(trunc(midx),trunc(ymax-midy));

    if level < maxlevel then begin

     a1:=costheta*cosphi;
     b1:=sintheta*sinphi;
     a2:=sintheta*cosphi;
     b2:=costheta*sinphi;

      split(midx, midy
         ,newlen*(a1-b1)+midx
         ,newlen*(a2+b2)+midy
         ,level+1);

      split(midx, midy
         ,newlen*(a1+b1)+midx
         ,newlen*(a2-b2)+midy
         ,level+1);
      end;
  end;

begin

  InitGraph(8+16);

  SetColor(1);

  tab[0] := 3 * 150;

  for i := 1 to maxtab do tab[i]:=SplitProportion*tab[0];

  mx := Xmax shr 1;
  my := Ymax shr 1;

  split(mx, 0, mx, my, 1);

  repeat until keypressed;

end.
