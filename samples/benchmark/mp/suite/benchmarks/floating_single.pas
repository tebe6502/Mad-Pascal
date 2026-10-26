unit floating_single;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

procedure benchmark;
var
  a         : single absolute $e0;
  s         : single absolute $e4;
  n         : byte absolute $e8;
  i         : byte absolute $e9;
begin
  s := 0;
  for n := 1 to 100 do begin
    a := n;
    for i := 1 to 10 do
      a := sqrt(a);
    for i := 1 to 10 do
      a := sqr(a);
    s := s + a;
  end;
  s := abs(5050 - s);
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Floating Point SINGLE'~;
end.
