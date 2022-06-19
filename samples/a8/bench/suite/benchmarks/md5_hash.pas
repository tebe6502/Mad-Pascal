unit md5_hash;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

procedure benchmark;
var
  i0b       : byte absolute $e0;
  i0w       : word absolute $e1;
  md        : TMD5;
  someData  : array [0..511] of byte absolute $a000;
begin
  for i0w := 0 to 511 do someData[i0w] := i0w;
  for i0b := 0 to 4 do MD5Buffer(someData, 512, md);
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'MD5 512B 5x'~;
end.
