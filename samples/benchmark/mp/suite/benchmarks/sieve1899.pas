unit sieve1899;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

{$codealign proc = $100}

procedure benchmark;
var
  count     : word absolute $e0;
  i         : word absolute $e2;
  k         : word absolute $e4;
  prime     : word absolute $e6;
  bi        : byte absolute $e8;
  flags     : array [0..8191] of boolean absolute $a000;
begin
  for bi := 9 downto 0 do begin
    fillchar(@flags, sizeof(flags), true);
    i:=0; count := 0;
    while i <= 8191 do begin
      if flags[i] then begin
        prime := (i * 2) + 3;
        k := prime + i;
        while (k <= 8191) do begin
          flags[k] := false;
          inc(k, prime);
        end;
        inc(count);
      end;
      inc(i);
    end;
  end;
end;

{$codealign proc = 0}

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Sieve 1899 10x'~;
end.
