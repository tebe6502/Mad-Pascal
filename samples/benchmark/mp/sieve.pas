// Eratosthenes Sieve benchmark
// 1899
//  1 iter 49 ticks
//  1 iter 43 ticks	FAST
// 10 iter 491 ticks
// 10 iter 434 ticks	FAST

uses crt, sysutils;

{$define FAST}

const
 size = 8191;
 iter_max = 10;

var
  flags: array [0..size] of boolean absolute $4000;	// !!! at page begining lo=$00 !!!

  iter: byte;
  ticks: word;

{$ifdef FAST}
  i: word register;
  k: word register;
  prime: word register;
  count: word register;
{$else}
  i, k, prime, count: word;
{$endif}


begin

	writeln(iter_max,' iterations');

	pause;

	ticks := GetTickCount;

	for iter:=iter_max-1 downto 0 do begin

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

 ticks:=word(GetTickCount)-ticks;

 writeln(ticks, ' ticks');
 writeln(count, ' primes');

 repeat until keypressed;

end.
