unit countdown_for;

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
  for za := 1 downto 0 do
    for zb := 9 downto 0 do
      for zc := 9 downto 0 do
        for zd := 9 downto 0 do
          for ze := 9 downto 0 do
            for zf := 9 downto 0 do
              for zg := 9 downto 0 do;
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Countdown 2ML: FOR'~;
end.
