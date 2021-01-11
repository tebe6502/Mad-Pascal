program YoshBenchPlus;

var
{$ifdef c64} 
    i	: word absolute $70;
    a	: word absolute $72;
    b	: word absolute $74;
    clock : byte absolute $a2;
{$else}
    i	: word absolute $e0;
    a	: word absolute $e2;
    b	: word absolute $e4;
    clock : byte absolute $14;
{$endif}

procedure vbsync;
var tmp: byte;
begin
  tmp := clock;
  while clock = tmp do;
end;

begin
	i:=0; a:=0; b:=0;
	vbsync; clock := 0;

	while clock < 100 do begin
		Inc(a); b := a;
		Inc(b); a := b;
		Inc(i);
	end;

  writeln('YOSHPLUS - ITERATIONS IN 100 FRAMES.');
  {$ifdef c64}   
  writeln('MAD PASCAL 1.6.4 ON C64');
  {$else}
  writeln('MAD PASCAL 1.6.4 ON ATARI 800XL');
  {$endif}
  writeln('COUNTER = ', i);
	while true do;
end.
