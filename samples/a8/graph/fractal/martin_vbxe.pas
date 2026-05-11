
PROGRAM Martin_fractal;

Uses Crt, atari, Graph, vbxe;

const

xmax = 320;
ymax = 240;

cx = xmax div 2;
cy = ymax div 2;

tcmax = 100;


VAR t, tc:smallint;
    sa,sav,sb,sc:real;
    ch:char;
    clr: byte;

{ Autodetect graphics hardware and initialize .bgi driver }

Procedure Init_graphics;
var i: byte;
Begin

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 SetHorizontalRes(VBXE.VGAMed);
 ColorMapOff;

 SetOverlayPalette(0);

 VBXEControl(vc_xdl+vc_xcolor+vc_no_trans);

 SetTopBorder(1);
 SetXDLHeight(240);

 dmactl:=0;

 ClearDevice;

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

     vbxe.SetColor(clr shl 4 + 10);
     vbxe.PutPixel(px, py);
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
   clr:=9+round(int(random*7));
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
         If clr>15 Then clr:=9;
         t:=0;
         End;
   Until KeyPressed or ((tc>(tcmax-1)) and (tcmax>0));

   ClearDevice;
   If KeyPressed Then ch:=ReadKey;
End;

{ Main loop. Cycle until ESC or Q is typed. }

Begin

   Init_graphics;
   Repeat
      sa:=random*60.0-30.0;
      sb:=random*60.0-30.0;
      sc:=random*60.0-30.0;
      sav:=(Abs(sa)+Abs(sb)+Abs(sc))/2.0;
      Martin(sa,sb,sc,6-Abs(sav/10.0));
   Until (ord(ch)=27) or (ch='q') or (ch='Q');

End.
