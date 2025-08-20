(*
900 REM GRAVITEN by jeff.piepmeier@gmail.com
901 REM Written March 22 2016
902 REM for the 2016 NOMAM 10-line
903 REM programming contest
904 REM Program notes at
905 REM jeffpiepmeier.blogspot.com
*)

uses crt, atari, joystick, graph;

const
	c = 580;

	s1: single = 0.39269908;
	s2: single = 0.0174532925;

	pmg = $ac00;

	data: array [0..79] of byte = (
	4,4,14,14,31,1,3,7,15,3,1,6,30,12,4,1,
	62,28,24,0,32,56,63,56,32,24,28,62,1,0,
	4,12,30,6,1,3,15,7,3,1,31,14,14,4,4,12,
	15,14,12,8,4,6,15,12,16,6,14,31,32,0,
	1,7,63,7,1,32,31,14,6,0,16,12,15,6,4,
	8,12,14,15,12
	);

var
	tsin: array [0..1, 0..15] of single;

	d, e, n, o, k, l: single;

	b: word;

	h: cardinal;

	r, s, t, x, i, j, m, p, q, u: byte;


begin

 for x:=0 to 15 do begin
  tsin[0, x] := sin(s1*single(x));
  tsin[1, x] := cos(s1*single(x));
 end;

 InitGraph(5);

 color0:=3*16+4;
 color2:=4;

 SetColor(1); Bar(0,0,ScreenWidth,39);
 SetColor(0);

 write('Stand by ');

 b:=0;
 while b<c do begin

  d:=38*single(B)/single(C)*COS(single(B)*s2);
  e:=25*single(B)/single(C)*SIN(single(B)*s2);

  FillEllipse(round(d)+45,round(e)+15,5,4);

  write('.');

  inc(b, 9);
 end;

 clrscr;

 SetColor(1);
 Line(0,0,ScreenWidth,0);
 Line(19, 39, ScreenWidth, 39);

 SetColor(2);
 Rectangle(45,14,47,16);


 move(data, pointer(pmg), 80);
 pcolr0:=15;
 pmbase := hi(pmg);
 gractl := 3;
 sdmctl:=46;


 repeat

 writeln;
 write(#$7f,'press FIRE to start');


 while strig0<>0 do;

 clrscr;

 h:=1000;
 i:=0;
 j:=3;
 k:=70;
 l:=18;
 m:=8;
 n:=0;
 o:=0;

 write(i,#$7f,j);

 while j<>0 do begin

  txtcol:=22;
  write(h,' ');

  pause;

  fillchar(pointer(pmg+512), 127, 0);

  move(pointer(pmg+m*5), pointer(pmg+512+trunc(l)), 5);

  hposp0:=round(k);

  p:=q;

  q:=stick0;

  r:=ord(q and 4=4) - ord(q and 8=8);

  s:=ord((p and 2=2)) and ord((q and 2=0));

  t:=ord(q and 1=0);

  m:=(m+16+r+s*8) and $0f;

  if t<>0 then begin
   sound(0,250,10,10);

   n:=tsin[0,m]*0.05+n;
   o:=tsin[1,m]*0.05+o;
  end;

  if i mod 2=0 then begin
   n:=n-0.01*n;
   o:=o-0.01*o;
  end;

  n:=single(i shr 1)*0.00002*(135-k)+n;
  o:=o-single(i shr 1)*0.00002*(44-l);
  k:=k+n;
  l:=l-o;

  hitclr:=1;

  pause(2);

  u:=hposm0;

  if u<>0 then begin

   k:=70;
   l:=18;
   m:=8;
   n:=0;
   o:=0;

   Sound(0,50,u*8-6,15);

   pause(9);

   clrscr;

   if u=1 then begin
    dec(j);

    if j=0 then writeln('TRY AGAIN');

   end;

   if u=2 then begin

//    h:=(i+1)*1000+h;
    inc(h, 1000*word(i+1));

    if i=7 then begin
     writeln('MISSION COMPLETE!');
     Break;
    end;

    inc(i);
    inc(j);

   end;

   write(i,#$7f,j,#$7f,h);
  end;

  NoSound;

  dec(h);

 end;


 write(#$7f'SCORE: ',h);

 NoSound;

 until false;

end.
