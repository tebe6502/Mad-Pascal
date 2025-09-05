uses crt, graph, joystick;

const
	draw: array [0..25] of byte = (
	4,5,3,6,3,6,0,6,3,6,4,5,3,4,1,5,
	1,10,1,10,1,9,2,8,3,7 );

var
	a: byte = 80;
	v0: byte = 10;
	z: byte = 20;
	j,c,y,r: byte;
	
	t,s,n,x,m: real;


procedure Duck;
var o, p, b, k, l: byte;
begin

 o:=random(100)+40;
 p:=random(16)+120;
 
 SetColor(2);
 
 for b:=0 to 12 do begin
  k:=draw[b shl 1];
  l:=draw[b shl 1+1];
 
  MoveTo(o+k, p+b);
  LineTo(o+l, p+b);
 end; 

 SetColor(0);
 
 PutPixel(O+4,P+2);

end;


procedure Title;
begin

 if r=0 then 
  exit
 else begin
  writeln(' *** DUCK-HUNT BY MGR INZ. RAFAL ***');
  r:=0;
 end;

end;


procedure Status;
begin
 writeln ('SHOTS ',Z);
 writeln ('SCORE ',J);
end; 


procedure Gun;
var v, g, px: byte;
    q,i: real;
begin

 IF A>90 then A:=90;
 IF A<38 then A:=38;

 IF V0<5 then V0:=5;
 IF V0>16 then V0:=16;
 
 SetColor(c);
 MoveTo(round(x),y);
 
 i:=1.0;
 while i<t do begin
  X:=N*I;
  
  px:=round(x);
  
  Y:=150-round(M*I-((0.91*i*i)/2.0));

  v:=GetPixel(px,y);
  LineTo(px,y);
  
  if y>160 then i:=t;
  
  if v=2 then begin
   SetColor(1);
   PutPixel(px,y);
   PutPixel(px,y+1);

   FillEllipse(px,y, 13, 13);
   
   i:=t;
   inc(j);

   writeln;
   Status;
   
   Duck;
  end;
 
  i:=i+s;
 end;

end;


begin
 randomize;
 
 InitGraph(15);
 
 Duck;
 
 r:=1;

 Title;

 Status;

 repeat
 
  if z=0 then Break;
 
  X:=0.0;
  Y:=150;
  N:=Real(V0)*COS(Real(A)*d_pi_180);
  M:=Real(V0)*SIN(Real(A)*d_pi_180);
  C:=1;
  T:=4.0;
  S:=1.0;
  
  Gun;
  
//  delay(5);
  
  c:=0;
  x:=0.0;
  y:=150;

  Gun;
 
  case joy_1 of
   joy_right: dec(a);
    joy_left: inc(a);
    joy_down: dec(v0);
      joy_up: inc(v0);
  end;
 
 if strig0 = 0 then begin
  dec(z);
  
  writeln;
  Status;
  
  c:=3;
  t:=50.0;
  s:=0.2;
  
  Gun;
 end;
  
 until false;

end.
