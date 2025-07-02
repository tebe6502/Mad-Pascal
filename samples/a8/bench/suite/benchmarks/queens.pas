unit queens;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

const
  qSize  = 8;

var
  ze         : byte absolute counterLms + $25;
  zf         : byte absolute counterLms + $26;
  zg         : byte absolute counterLms + $27;
  i          : byte absolute $e0;
  qBoard     : array [0..qSize] of byte absolute $e1;

function check(n, c : byte): boolean;
begin
  check := true;
  for i := 1 to (n - 1) do
    if (qBoard[i] = c) or
       (byte(qBoard[i] - i) = byte(c - n)) or
       (byte(qBoard[i] + i) = byte(c + n))
    then exit(false);
end;

procedure generate(n: byte);
var
  c          : byte;
begin

  if n > qSize then begin
        inc(zg);
        if zg = 10 then begin inc(zf); zg := 0 end;
        if zf = 10 then begin inc(ze); zf := 0 end;
  end else
    for c := 1 to qSize do
      if check(n, c) then begin
        qBoard[n] := c;
        generate(n + 1);
      end;

end;

procedure benchmark;
begin
  FillChar(pointer(counterLms + $23), 5, 0);
  FillChar(qBoard, 8, 0);
  generate(1);
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Recur.: Eight queens'~;
end.
