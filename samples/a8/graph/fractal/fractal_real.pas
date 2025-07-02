program fraktal;

//rework from original PurePascal programme I wrote 1995

uses graph,crt,sysutils;


var jn:char;
    mx:BYTE;
    c1,c2,xd,yd,xmax,ymax,xmin,ymin: real;
    xin,yin: string;

procedure apfel(add,iter:byte);
var z3,z4,z5,z1,z2,ze1,ze2: real;
    raus,xpkt,ypkt,i:byte;

begin
 ypkt:=1;
 repeat
  xpkt:=1;
  repeat
   z1:=0.0;
   z2:=0.0;
   i:=0;
   raus:=0;
   repeat
    ze1:=(z1*z1)-(z2*z2)+c1;
    ze2:=(2.0*z1*z2)+c2;
    inc(i);
    z1:=ze1;
    z2:=ze2;
    z3:=z1*z1;
    z4:=z2*z2;
    z5:=z3+z4;
	setcolor(i);
	putpixel(xpkt,ypkt);
	poke(77,0);
    if z5 > 4.0 then raus:=1
      else if i > iter then raus:=1;
   until raus=1;
   if i > iter then SetColor(0)
     else begin
     	SetColor((i mod 3)+1)
     end;
   PutPixel(xpkt,ypkt);
   if add = 2 then PutPixel(xpkt+1,ypkt+1);
   c1:=c1+xd;
   xpkt:=xpkt+add;
  until xpkt>160;
  c1:=xmin;
  c2:=c2-yd;
  ypkt:=ypkt+add;
 until ypkt>96;
 i:=0;
 repeat
 setbkcolor(i);
  inc(i);
  delay(2);
 until i=255;
 setbkcolor(0);
end;

procedure vorschau;
begin

 InitGraph(7);
 yd:=(ymax-ymin)/48.0;
 xd:=(xmax-xmin)/80.0;
 c1:=xmin;
 c2:=ymax;
 apfel(2,7);
 repeat until keypressed;

end;



begin
 initgraph(0);
 writeln('************************************');
 writeln('*  Mandelbrot for MADPascal with   *');
 writeln('*    preview, based on an old      *');
 writeln('*PurePascal programme, I did for ST*');
 writeln('***************************PPs 2015*');
 writeln;
 write('XMIN (-2): ');
 readln(xin);
 xmin:=StrToFloat(xin);
 write('XMAX  (2): ');
 readln(xin);
 xmax:=StrToFloat(xin);
 write('YMIN (-2): ');
 readln(yin);
 ymin:=StrToFloat(yin);
 write('YMAX  (2): ');
 readln(yin);
 ymax:=StrToFloat(yin);
 write('Preview (iteration is 7) (y/n): ');
 readln(jn);
 if (jn='y') or (jn='Y') then begin
  vorschau;
  clrscr;
 end;
 poke(764,255);
 write('Really compute (y/n): ');
 readln(jn);
 if (jn='y') or (jn='Y') then begin
   write('Iteration: ');
   readln(xin);
   mx:=strtoint(xin);
   initgraph(7 + 16);
   yd:=(ymax-ymin)/96.0;
   xd:=(xmax-xmin)/160.0;
   c1:=xmin;
   c2:=ymax;
   apfel(1,mx);
   repeat until keypressed;
 end;

end.
