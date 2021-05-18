// 181
// 175	FAST

program MonteCarloPi;

uses crt;

{$define FAST}

var
	rtClock1	: byte absolute 19;
	rtClock2	: byte absolute 20;
	rndNumber	: byte absolute $D20A;
	stop		: word;

{$ifdef FAST}
 	i			: word absolute $e0;
	r			: word absolute $e2;
	x			: word absolute $e4;
	y			: word absolute $e6;
	bingo			: word absolute $e8;
	probe			: word absolute $ea;
	foundPi			: word absolute $ec;
	n			: byte absolute $ee;
{$else}
	i, r, x, y,
	bingo, probe, foundPi	: word;
	n			: byte;
{$endif}

begin
	bingo := 0;
	r := 127 * 127;
	probe := 10000;

	Pause(1);
	rtClock1 := 0; rtClock2 := 0;

	for i := 0 to probe do begin
		n := rndNumber and 127;
		x := n * n;
		n := rndNumber and 127;
		y := n * n;
		if (x + y) <= r then Inc(bingo);
	end;

	foundPi := 4 * bingo;
	stop := (rtClock1 * 256) + rtClock2;

	{$ifdef FAST}
	WriteLn('Variables on zero page');
	{$endif}

	WriteLn('Probe size ', probe);
	WriteLn('Points in circle ', bingo);
	WriteLn('Found pi approximation ', foundPi / probe);
	WriteLn('Frames counter = ', stop);
	ReadKey;
end.
