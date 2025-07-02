unit counter;

//---------------------- INTERFACE ---------------------------------------------

interface
  procedure init;
  procedure prepare(name: string[26]);
  procedure print;
  procedure overwrite;

var
  stop              : boolean absolute 0;
  vblk              : pointer;
  rtclok            : byte absolute $14;

//---------------------- IMPLEMENTATION ----------------------------------------

implementation

uses gr;

var
  benchName         : string[26];
  position          : word;
  i                 : byte;

procedure vblCounter; interrupt;
var
  a : byte absolute counterLms;
  b : byte absolute counterLms + 1;
  c : byte absolute counterLms + 2;
  d : byte absolute counterLms + 3;
  e : byte absolute counterLms + 4;
begin
  asm
    phr
  end;
  if not stop then begin
    inc(e);
    if e = 10 then begin inc(d); e := 0 end;
    if d = 10 then begin inc(c); d := 0 end;
    if c = 10 then begin inc(b); c := 0 end;
    if b = 10 then begin inc(a); b := 0 end;
  end;
  asm
    plr
  end;
end;

procedure init;
begin
  Move(pointer(charset), pointer(counterCharset), $400);
  Move(pointer(charset + $80), pointer(counterCharset), 80);
  for i := 0 to 7 do
    poke(counterCharset + $400 - 8 + i, peek(charset + $80 + i) xor $ff);
  FillChar(pointer(counterCharset + $400 - 16), 8, $ff);
end;

procedure prepare(name: string[26]);
begin
  pause; counterRow;
  chbas := hi(counterCharset);
  benchName := name;
  FillChar(pointer(counterLms), $28, $fe);
  FillChar(pointer(counterLms), 5, 0);
  for i := 2 to length(name) do
    if name[i] = chr(0) then name[i] := chr($fe);
  Move(name[2], pointer(counterLms + 6), length(name)-1);
  pause;
end;

procedure print;
var
  printRow    : word;
begin
  printRow := position;
  Move(benchName[2], pointer(printRow), length(benchName)-1);
  inc(printRow, 26);
  poke(printRow, byte(benchName[1]));
  inc(printRow, 2);
  for i := 0 to 4 do
    poke(printRow + i, peek(counterLms + i) + 16);
  inc(position,40);
end;

procedure overwrite;
begin
  Move(pointer(counterLms + $23), pointer(counterLms), 5);
end;

//---------------------- INITIALIZATION ----------------------------------------

initialization
  vblk := @vblCounter;
  stop := true;
  position := scoreLms;
end.
