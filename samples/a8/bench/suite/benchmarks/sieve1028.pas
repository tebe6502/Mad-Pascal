unit sieve1028;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

{$codealign proc = $100}

procedure benchmark;
var
  flags     : array [0..8191] of boolean absolute $a000;
  n         : byte absolute $e0;
  k         : word absolute $e2;
  bi        : byte absolute $e4;
  count     : word absolute $e6;
begin
  for bi := 9 downto 0 do begin
    count := 0;
    fillchar(@flags, sizeof(flags), true);
    for n := 2 to 91 do begin
      if flags[n] then begin
        k := n shl 1;
        while k <= 8191 do begin
          flags[k] := false;
          inc(k,n);
        end;
      end;
    end;
  end;

  for k := 2 to 8191 do
    if flags[k] then inc(count);
end;

{$codealign proc = 0}

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Sieve 1028 10x'~;
end.
