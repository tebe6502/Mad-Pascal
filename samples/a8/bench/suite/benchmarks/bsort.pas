unit bsort;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

procedure benchmark;
var
  i         : byte absolute $f0;
  a         : byte absolute $f1;
  size      : byte absolute $f2;
  sorttable : array[0..254] of byte absolute $a000;
begin
  for i := 0 to 254 do
    sorttable[i] := $ff - i;

  for size := 253 downto 0 do begin
    for i := 0 to 253 do begin
      if sorttable[i+1] < sorttable[i] then begin
        a := sorttable[i+1];
        sorttable[i+1] := sorttable[i];
        sorttable[i] := a;
      end;
    end;
  end;
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Bubble Sort: 255 elements'~;
end.
