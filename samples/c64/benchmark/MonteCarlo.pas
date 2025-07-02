program MonteCarloPi;

const
  probe = 10000;
  r = 127 * 127;

var
{$ifdef c64}
  stop      : word absolute $70;
  i         : word absolute $70;
  x         : word absolute $74;
  y         : word absolute $76;
  bingo     : word absolute $78;
  foundPi   : word absolute $7a;
  n         : byte absolute $7c;
  clock1    : byte absolute $a1;
  clock2    : byte absolute $a2;
  rndNumber : byte absolute $d41b;  
{$else}
  stop      : word absolute $e0;
  i         : word absolute $e0;
  x         : word absolute $e4;
  y         : word absolute $e6;
  bingo     : word absolute $e8;
  foundPi   : word absolute $ea;
  n         : byte absolute $ec;
  clock1    : byte absolute $13;
  clock2    : byte absolute $14;
  rndNumber : byte absolute $d20a;  
{$endif}

procedure vbsync;
begin
  n := clock2;
  while clock2 = n do;
end;

{$ifdef c64}
//SID's Random Number Generator
procedure c64Randomize; assembler;
asm
{
  lda #$ff  ; maximum frequency value
  sta $D40E ; voice 3 frequency low byte
  sta $D40F ; voice 3 frequency high byte
  lda #$80  ; noise waveform, gate bit off
  sta $D412 ; voice 3 control register
};
end;
{$endif}

begin
  bingo := 0;

  {$ifdef c64}
  c64Randomize;
  {$endif}
  vbsync; clock2 := 0; clock1 := 0;
  
  for i := 1 to probe do begin
    n := rndNumber and 127; x := n * n;
    n := rndNumber and 127; y := n * n;
    if (x + y) <= r then Inc(bingo);
  end;
  
  foundPi := 4 * bingo;
  stop := (clock1 * 256) + clock2;
  
  writeln('PROBE SIZE ', probe);
  writeln('POINTS IN CIRCLE ', bingo);
  writeln('FOUND PI APPROXIMATION ', foundPi / probe);
  writeln('FRAMES COUNTER = ', stop);
  while true do;
end.
