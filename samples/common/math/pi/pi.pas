(* source: CLSN PASCAL            *)
(* This program uses a mutually   *)
(* recursive routine to calculate *)
(* the number PI                  *)

uses crt;

function a(t: byte): single; forward;

function b(n: byte): single;
begin
  if (n=0) then
    b:=1/sqrt(2)
  else
    b:=sqrt(a(n-1)*b(n-1));
end;

function a(t:byte): single;
begin
  if (t=0) then
    a:=1
  else
    a:=(a(t-1)+b(t-1))*0.5;
end;

function d(n: byte): single;
var
  j: byte;
  s: single;
begin
  s:=0;

  for j:=1 to n do
    s:=s+(1 shl (j+1))*(sqr(a(j))-sqr(b(j)));

  d:=1-s;
end;

function x_pi: single;
const
  level=2;

begin
  x_pi:=4*a(level)*b(level)/d(level);
end;

begin
  writeln('PI=',x_pi);

  repeat until keypressed;
end.
