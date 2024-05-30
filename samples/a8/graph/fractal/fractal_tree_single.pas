
program FractalTree;

uses crt, graph;

const	SplitProportion	: single = 0.22;
	cosphi		: single = 0.939692620791;
	sinphi		: single = 0.342020143326;

	maxlevel	=8;
	maxtab		=20;
	Xmax		= single(319);
	Ymax		= single(191);

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
      sintheta,
      hlp0, hlp1: single;

  begin
    midx    :=(sx+ex)*0.5;
    midy    :=(sy+ey)*0.5;
    dx      :=ex-sx;
    dy      :=ey-sy;
    oldlen  :=tab[level-1];
    newlen  :=tab[level];
    costheta:=dx/oldlen;
    sintheta:=dy/oldlen;

    MoveTo(round(sx  ),round(ymax-sy  ));
    LineTo(round(midx),round(ymax-midy));

    if level < maxlevel then begin

     a1:=costheta*cosphi;
     b1:=sintheta*sinphi;
     a2:=sintheta*cosphi;
     b2:=costheta*sinphi;

     hlp0:=newlen*(a1-b1)+midx;
     hlp1:=newlen*(a2+b2)+midy;

      split(midx, midy
         ,hlp0
         ,hlp1
         ,level+1);

      hlp0:=newlen*(a1+b1)+midx;
      hlp1:=newlen*(a2-b2)+midy;

      split(midx, midy
         ,hlp0
         ,hlp1
         ,level+1);
      end;
  end;

begin

  InitGraph(8+16);

  SetColor(1);

  tab[0]:=3.0 * 150.0;

  for i := 1 to maxtab do tab[i]:=SplitProportion*tab[0];

  mx := Xmax * 0.5;
  my := Ymax * 0.5;

  split(mx, 0.0, mx, my, 1);

  repeat until keypressed;

end.
