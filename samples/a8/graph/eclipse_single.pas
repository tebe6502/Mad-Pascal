uses crt, graph;

{
1 GRAPHICS 31:DPOKE 708,$2E0F:POKE 710,$34:DEG
3 FOR I=0 TO 359:COLOR 1:PLOT 80+25*SIN(I),96-50*COS(I)
5   FOR J=1 TO 3:COLOR J:R=55+RAND(J*J*4.5):DRAWTO 80+(R/2)*SIN(I),96-R*COS(I)
7   NEXT J:NEXT I:DO :LOOP
}

procedure eclipse;
var i: word;
    j,x,y: byte;
    r, ia, sina, cosa: single;
begin

 for i:=0 to 359 do begin
  SetColor(1);

  ia:=i*pi/180;			// DEG
  sina:=sin(ia);
  cosa:=cos(ia);


  x:=round(80+sina*25);
  y:=round(96-cosa*50);

  MoveTo(x,y);

  for j:=1 to 3 do begin
   SetColor(j);

   r:=randomF*j*j*8.5+55;

   x:=round(80+(r/2)*sina);
   y:=round(96-r*cosa);

   LineTo(x,y);

  end;

 end;

end;


begin

 InitGraph(15+16);

 Palette[pal_Color0]:=$0f;
 Palette[pal_Color1]:=$2e;
 Palette[pal_Color2]:=$34;

 eclipse;

 repeat until keypressed;

end.
