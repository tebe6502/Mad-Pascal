// Eratosthenes Sieve benchmark 1899

const
 size = 8192;
 iter_max = 10;

var
  flags: array [0..size] of boolean;

  iter: byte;
  ticks: word = 0;

{$ifdef c4p}
  i: word absolute $70;
  k: word absolute $72;
  prime: word absolute $74;
  count: word absolute $76;
  clock1 : byte absolute $a4;
  clock2 : byte absolute $a5;
{$endif}
{$ifdef c64}
  i: word absolute $70;
  k: word absolute $72;
  prime: word absolute $74;
  count: word absolute $76;
  clock1 : byte absolute $a1;
  clock2 : byte absolute $a2;
{$endif}
{$ifdef atari}
  i: word absolute $e0;
  k: word absolute $e2;
  prime: word absolute $e4;
  count: word absolute $e6;
  clock1 : byte absolute $13;
  clock2 : byte absolute $14;
{$endif}

begin

	writeln(iter_max,' ITERATIONS');
	pause; clock2 := 0; clock1 := 0;

	for iter := iter_max-1 downto 0 do begin

		fillchar(flags, sizeof(flags), true);

		count := 0;

		for i:=0 to size do
			if flags[i] then begin

				prime := i*2 + 3;
				k := prime + i;

				while (k <= size) do begin
					flags[k] := false;
					inc(k, prime);
				end;
				inc(count);
			end;
	end;

 ticks := clock2 + (clock1 * 256);

 writeln(ticks, ' TICKS');
 writeln(count, ' PRIMES');

 while true do;

end.
