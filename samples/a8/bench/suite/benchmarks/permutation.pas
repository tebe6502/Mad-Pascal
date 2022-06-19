unit permutation;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

const
  pSize  = 7;

var
  zc         : byte absolute counterLms + $23;
  zd         : byte absolute counterLms + $24;
  ze         : byte absolute counterLms + $25;
  zf         : byte absolute counterLms + $26;
  zg         : byte absolute counterLms + $27;
  tmp        : byte absolute $e0;
  i          : byte absolute $e1;
  board      : array [0..pSize] of byte absolute $e2;

procedure generate(n: byte);
var
  i          : byte;
begin

  if n = 0 then
    begin
        inc(zg);
        if zg = 10 then begin inc(zf); zg := 0 end;
        if zf = 10 then begin inc(ze); zf := 0 end;
        if ze = 10 then begin inc(zd); ze := 0 end;
        if zd = 10 then begin inc(zc); zd := 0 end;
    end
  else
    begin
      for i := 0 to n do begin
        tmp := board[i]; board[i] := board[n]; board[n] := tmp;
        generate(n-1);
        tmp := board[i]; board[i] := board[n]; board[n] := tmp;
      end;
    end;

end;

procedure benchmark;
begin
  for i := 0 to pSize do board[i] := i;
  FillChar(pointer(counterLms + $23), 5, 0);
  generate(pSize);
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Recur.: Permutation 8 el.'~;
end.
