(*)--[ Pascal Support ]-------------------------------------------------------
   Fractal tree.
 by Victor Shantar (2:5054/26@FidoNet)
---------------------------------------------------------------------------(*)

Uses crt, Graph;

var

gd,gm: smallint;

Procedure Fractal_Tree(x,y, angle,len: smallint);
{ x, y - coordinates.  angle - angle.  len - length }

const k=pi/180;
      c1=37; { Fullness. The smaller it is, the fuller it looks }
      c2=60; { Barrel thickness ratio. The lower the ratio, the thicker the barrel }
      c3=3;  { Leaf thickness coefficient. The higher the value, the more triangular the leaves are :}
      colors:array[0..20] of byte =
              (0, 2,3, 1,1,1,1,1, 2,2,2,2,2,2,2,2,2,2,2,2,2 );

{ leaf color -    ^^^^   ^^^^^^^^^   ^^^^^^^^^^^^^^^^^^^^^^^^^ - thick branches
                       thin branches
}

var x1,y1,i,p,a1: smallint;
begin

  if len<5 then exit;

  x1:=round(x+len*cos(angle*k)); y1:=round(y+len*sin(angle*k));

  if len>140 then p:=140 else p:=len;

  i:=colors[p div 5];

  if random(2)=0 then begin
    if i=colors[1] then i:=colors[2] else
    if i=colors[2] then i:=colors[1];
  end;

  setcolor( i );

  if (i=colors[1]) or (i=colors[2]) then
    for i:=0 to c3 do Line(x+i-c3 div 2,y,x1,y1)
  else
    for i:=0 to p div c2 do Line(x+i-p div (c2*2),y,x1,y1);

  for i:=0 to 3-random(3) do begin

    p:=random(byte(len-len div 6))+len div 6;
    a1:=angle-random(55);
    x1:=round(x+p*cos(angle*k)); y1:=round(y+p*sin(angle*k));

    if len>140 then 
      Fractal_Tree(x1,y1,a1,140-random(15)-c1+random(c1))
    else
      Fractal_Tree(x1,y1,a1,len-random(15)-c1+random(c1));

    p:=random(byte(len-len div 6))+len div 6;

    a1:=angle+random(55);
    x1:=round(x+p*cos(angle*k)); 
    y1:=round(y+p*sin(angle*k));

    if len>140 then 
      Fractal_Tree(x1,y1,a1,140-random(15)-c1+random(c1))
    else
      Fractal_Tree(x1,y1,a1,len-random(15)-c1+random(c1));

  end;
end;

begin
  randomize;

  gd := VGA;
  gm := VGAMed;
  InitGraph(gd,gm,'');
 
  Fractal_Tree(getmaxx div 2, getmaxy, 290, 80);

  repeat until keypressed;

end.