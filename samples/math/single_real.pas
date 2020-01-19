
// compare single (ieee754, 32bit), real (Q24.8 fixed-point, 32bit)

uses crt;

var
	f, f0, f1: single;
	r, r0, r1: real;

	i: byte;

begin

 for i:=0 to 22 do begin
  f:=single(i)*pi/180;
  f:=sin(f)*96;

  r:=real(i)*pi/180;
  r:=sin(r)*96;

  writeln(f:8:8 ,' , ', r:8:8);
 end;

repeat until keypressed;

end.

