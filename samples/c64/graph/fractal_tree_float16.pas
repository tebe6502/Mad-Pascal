
program FractalTree;

uses crt, graph;

const	SplitProportion: float16 =0.22;
	cosphi         =0.939692620791;
	sinphi         =0.342020143326;

	maxlevel       =8;
	maxtab         =20;
	Xmax           =float16(319);
	Ymax           =float16(191);

var   i     :byte;
      mx    ,
      my    ,
      dx    ,
      dy    : float16;
      tab   : array [0..maxtab] of float16;

      GraphDriver, GraphMode : smallint;


procedure split(sx, sy, ex, ey:float16; level:byte );

  var midx    ,
      midy    ,
      oldlen  ,
      newlen  ,
      a1,b1,a2,b2,
      costheta,
      sintheta	: float16;

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

 GraphDriver := VGA;
 GraphMode := VGAHi;
 InitGraph(GraphDriver,GraphMode,'');

 SetColor(15);


 tab[0] := 3 * 150;

 for i := 1 to maxtab do tab[i]:=SplitProportion*tab[0];

 mx := Xmax * 0.5;
 my := Ymax * 0.5;

 split(mx, 0, mx, my, 1);

 repeat until keypressed;

end.
