unit chessboard;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

{$codealign proc = $100}

//---------------------- IMPLEMENTATION ----------------------------------------

procedure benchmark;
var
  zc        : byte absolute counterLms + $25;
  zd        : byte absolute counterLms + $26;
  ze        : byte absolute counterLms + $27;
  i1b       : byte absolute $e2;
  i2b       : byte absolute $e3;
  i3b       : byte absolute $e4;
  p         : PByte absolute $e0;
begin
  mode8;
  FillChar(pointer(counterLms + $23), 5, 0);
  rtclok := 0;
  while rtclok < 200 do begin
    p := pointer(lms);
    for i3b := 7 downto 0 do begin
      for i2b := 23 downto 0 do begin
        for i1b := 3 downto 0 do begin
            p[0] := 255; p[1] := 255; p[2] := 255;
            inc(p,6);
        end;
        inc(p,16);
      end;
      if (i3b and %1) = 0 then dec(p,3) else inc(p,3);
    end;
    inc(ze);
    if ze = 10 then begin inc(zd); ze := 0 end;
    if zd = 10 then begin inc(zc); zd := 0 end;
  end;
end;

{$codealign proc = 0}

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5c'Chessboard GR8 200 frames'~;
  isRewritable := true;
end.
