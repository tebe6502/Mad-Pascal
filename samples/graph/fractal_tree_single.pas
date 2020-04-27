
program FractalTree;

uses crt, graph;

const	SplitProportion	: single = 0.22;
	cosphi		: single = 0.939692620791;
	sinphi		: single = 0.342020143326;

	maxlevel	=8;
	maxtab		=20;
	Xmax		=319;
	Ymax		=191;

var   i     :byte;
      mx    ,
      my    ,
      dx    ,
      dy    : single;
      tab   : array [0..maxtab] of single;

procedure split(sx, sy, ex, ey:single; level:byte );

  var midx    ,
      midy    ,
      oldlen  ,
      newlen  ,
      a1,b1,a2,b2,
      costheta,
      sintheta: single;

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

  tab[0]:=3.0 * 150.0;

  for i := 1 to maxtab do tab[i]:=SplitProportion*tab[0];

  mx := real(Xmax) * 0.5;
  my := real(Ymax) * 0.5;

  split(mx, 0.0, mx, my, 1);

  repeat until keypressed;

end.

