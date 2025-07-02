unit montecarlo;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

{$codealign proc = $100}

procedure benchmark;
var
  r         : word absolute $e0;
  x         : word absolute $e2;
  y         : word absolute $e4;
  bingo     : word absolute $e6;
  probe     : word absolute $e8;
  n         : byte absolute $ea;
  pi        : word absolute $ec;
begin
  bingo := 0;
  r := 127 * 127;
  for probe := 9999 downto 0 do begin
    n := rnd and 127;
    x := n * n;
    n := rnd and 127;
    y := n * n;
    if (x + y) <= r then inc(bingo);
  end;
  pi := 4 * bingo;
end;

{$codealign proc = 0}

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Monte Carlo Pi 10K'~;
end.
