unit ludolphian;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

procedure benchmark;
var
  lud       : single absolute $e0;
  tmp       : single absolute $e4;
  m         : word absolute $e8;
  i         : word absolute $ea;
begin
  lud := 1.0; m := 3; i := 1;
  repeat
    tmp := 1 / m;
    if (i and 1) <> 0 then
      lud := lud - tmp
    else
      lud := lud + tmp;
    inc(m,2); inc(i);
  until i = 5000;
  lud := lud * 4;
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Ludolphian number 5K'~;
end.
