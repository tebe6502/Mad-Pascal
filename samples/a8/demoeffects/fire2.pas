(*
* Fire by koalka/bbsl/karzelki
*)
// 378
// volatile psuje optymaslizacje o kilka bajtow


program Fire;

uses atari;

const
  screen  = $6400;
  charset = $6000;
  dl: array [0..25] of byte = (
    $42,lo(screen),hi(screen),
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    $41,lo(word(@dl)),hi(word(@dl))
  );

var
  b0i		: byte;
  b1i, tmp	: byte;

  row0: array [0..255] of byte absolute screen - 31;
  row1: array [0..255] of byte absolute screen - 31 + $100;
  row2: array [0..255] of byte absolute screen - 31 + $200;

  row3: array [0..255] of byte absolute screen + $2e0;

begin
  color4 := $20;
  sdlstl := word(@dl); chbas := hi(charset);
  gprior := $40; sdmctl := $21;

  tmp := 0;

  for b0i := 0 to $f do begin
    for b1i := 7 downto 0 do poke(charset + b1i + b0i * 8, tmp);
    inc(tmp,$11);
  end;

//  FillChar(pointer(screen), $400, 0);

  for b0i := 3 downto 0 do
   for b1i := 0 to 255 do poke(screen + b1i + b0i * 256, 0);


  while true do begin

    for b0i := 0 to 255 do begin

      row0[b0i] := byte(row0[30+b0i] + row0[31+b0i]+ row0[32+b0i]+ row0[63+b0i]) shr 2;
      row1[b0i] := byte(row1[30+b0i] + row1[31+b0i]+ row1[32+b0i]+ row1[63+b0i]) shr 2;
      row2[b0i] := byte(row2[30+b0i] + row2[31+b0i]+ row2[32+b0i]+ row2[63+b0i]) shr 2;

    end;

    for b0i := $1f downto 0 do row3[b0i] := rnd and 15;
  end;
end.
