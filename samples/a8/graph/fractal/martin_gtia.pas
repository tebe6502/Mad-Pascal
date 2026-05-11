
PROGRAM Martin_fractal;

Uses Crt, atari, gr10pp, graph;

const

xmax = 80;
ymax = 60;

cx = xmax div 2;
cy = ymax div 2;

tcmax = 100;

	DISPLAY_LIST_ADDRESS = $9800;
	VIDEO_RAM_ADDRESS = $a000;

VAR t, tc:smallint;
    sa,sav,sb,sc:real;
    ch:char;
    clr: byte;

{ Autodetect graphics hardware and initialize .bgi driver }

Procedure Init_graphics;
var i: byte;
Begin

 Gr10Init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 60, 4, 0);

 fillchar(pointer(VIDEO_RAM_ADDRESS), 60*40, 0);

 Palette[0] := $00;	// 704
 Palette[1] := $18;	// 705
 Palette[2] := $ba;	// 706
 Palette[3] := $24;	// 707
 Palette[4] := $54;	// 708
 Palette[5] := $74;	// 709
 Palette[6] := $3c;	// 710
 Palette[7] := $0c;	// 711
 Palette[8] := $f6;	// 712

End;

{ Return sign of x: -1, 0, or +1 }

Function sign(x:real):smallint;

Begin
   sign:=0;
   If x<>0 Then Begin
      If x<0 Then sign:=-1
      Else sign:=1;
      End;
End;

{ Plot coordinate with real x,y Values }

Procedure Plot(x,y:real; clr:byte);
var px, py: smallint;
Begin
   px := round(x) + cx;
   py := round(y) + cy;

   if (px >= 0) and (py >= 0) then
    if (px < xmax) and (py < ymax) then begin

     SetColor(clr and $0f);
     PutPixel(px, py);
    end;
End;

{ Cycle a given fractal until a key is pressed,
   with a counter for incrementing display color.
  "a", "b", and "c" are random Values constant for a
   given fractal, "s" is a scaling factor. }

Procedure Martin(a,b,c,s:real);

Var xold, yold, xnew, ynew:real;

Begin
   xold:=0;
   yold:=0;
   clr:=3+byte(round(int(random*7)));
   t:=0;
   tc:=0;
   ch:='a';
   Repeat
      Plot(xold*s,yold*s, clr);
      xnew:=yold-sign(xold)*sqrt(Abs(b*xold-c)); { <- This is it! These two }
      ynew:=a-xold;                              { <- lines generate the }
      xold:=xnew;                                {     entire fractal! }
      yold:=ynew;
      Inc(t);
      If t>1000 Then Begin
         Inc(tc);
         Inc(clr);
         If clr>7 Then clr:=1;
         t:=0;
         End;
   Until KeyPressed or ((tc>(tcmax-1)) and (tcmax>0));

   fillchar(pointer(VIDEO_RAM_ADDRESS), 60*40, 0);

   If KeyPressed Then ch:=ReadKey;
End;

{ Main loop. Cycle until ESC or Q is typed. }

Begin

   Init_graphics;
   Repeat
      sa:=random*30.0-15.0;
      sb:=random*30.0-15.0;
      sc:=random*30.0-15.0;
      sav:=(Abs(sa)+Abs(sb)+Abs(sc))/3.0;
      Martin(sa,sb,sc,5-Abs(sav/10.0));
   Until (ord(ch)=27) or (ch='q') or (ch='Q');

End.
