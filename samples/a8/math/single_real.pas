
// compare single (ieee754, 32bit), real (Q24.8 fixed-point, 32bit)

uses crt;

var
	f: single;
	f16: float16;
	r: real;

	i: byte;

begin

 clrscr;

 writeln('    ',' single    float16     real'*);

 for i:=1 to 22 do begin
  f:=single(i)*pi/180;
  f:=sin(f);

  f16:=i*pi/180;
  f16:=sin(f16);

  r:=real(i)*pi/180;
  r:=sin(r);

  gotoxy(1,i+1);

  writeln('sin_',i,' ',f:8:8, ' , ', f16:8:8, ' , ', r:8:8);
 end;

repeat until keypressed;

end.

