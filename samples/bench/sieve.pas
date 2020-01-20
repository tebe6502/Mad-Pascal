// Eratosthenes Sieve benchmark
// 1 iter  = 1899 / 74 ticks
// 1 iter  = 1899 / 65 ticks	FAST
// 10 iter = 1899 / 737 ticks
// 10 iter = 1899 / 642 ticks	FAST

uses crt, sysutils;

{$define FAST}

const
 size = 8191;
 iter_max = 10;

var
  flags: array [0..size] of boolean;

  iter: byte;
  ticks: word;

{$ifdef FAST}
  i: word absolute $e0;
  k: word absolute $e2;
  prime: word absolute $e4;
  count: word absolute $e6;
{$else}
  i, k, prime, count: word;
{$endif}

begin

	writeln(iter_max,' iterations');
		
	pause;

	ticks := GetTickCount;

	iter := 1;
	while iter <= iter_max do begin

		fillchar(flags, sizeof(flags), true);

		i:=0;
		count := 0;

		while i <= size do begin

			if flags[i] then begin

				prime := i*2 + 3;
				k := prime + i;

				while (k <= size) do begin
					flags[k] := false;
					inc(k, prime);
				end;
				inc(count);
			end;

		inc(i);
		end;

	inc(iter);
	end;

 ticks:=word(GetTickCount)-ticks;
 
 writeln(count, ' primes');
 writeln(ticks, ' ticks');

 repeat until keypressed;

end.
