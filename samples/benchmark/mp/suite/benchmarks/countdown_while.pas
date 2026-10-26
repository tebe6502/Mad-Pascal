unit countdown_while;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

procedure benchmark;
var
  za         : byte absolute counterLms + $21;
  zb         : byte absolute counterLms + $22;
  zc         : byte absolute counterLms + $23;
  zd         : byte absolute counterLms + $24;
  ze         : byte absolute counterLms + $25;
  zf         : byte absolute counterLms + $26;
  zg         : byte absolute counterLms + $27;
begin
  zb := 9; zc := 9; zd := 9;
  ze := 9; zf := 9; zg := 9;

  za:=1;
  while za <> $ff do begin
    zb := 9;
    while zb <> $ff do begin
      zc := 9;
      while zc <> $ff do begin
        zd := 9;
        while zd <> $ff do begin
          ze := 9;
          while ze <> $ff do begin
            zf := 9;
            while zf <> $ff do begin
              zg := 9;
              while zg <> $ff do begin
                dec(zg);
              end;
              dec(zf);
            end;
            dec(ze);
          end;
          dec(zd);
        end;
        dec(zc);
      end;
      dec(zb);
    end;
    dec(za);
  end;
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Countdown 2ML: WHILE'~;
end.
