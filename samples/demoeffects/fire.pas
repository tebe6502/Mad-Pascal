(*
* Fire by koalka/bbsl/karzelki
*)

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
  b0i    : byte absolute $e0;

  p0     : PByte absolute $e1;
  p1     : PByte absolute $e3;
  p2     : PByte absolute $e5;

  b1i, tmp    : byte;

begin
  color4 := $20; tmp := 0;
  sdlstl := word(@dl); chbas := hi(charset);
  gprior := $40; sdmctl := $21;

  for b0i := 0 to $f do begin
    for b1i := 0 to 7 do poke(charset + b1i + b0i * 8, tmp);
    inc(tmp,$11);
  end;

  FillChar(pointer(screen), $400, 0);

  while true do begin
    p0 := pointer(screen - 31);
    p1 := pointer(screen - 31 + $100);
    p2 := pointer(screen - 31 + $200);

    for b0i := 0 to 255 do begin
      p0^ := byte(p0[30] + p0[31]+ p0[32]+ p0[63]) shr 2;
      p1^ := byte(p1[30] + p1[31]+ p1[32]+ p1[63]) shr 2;
      p2^ := byte(p2[30] + p2[31]+ p2[32]+ p2[63]) shr 2;

      inc(p0); inc(p1); inc(p2);
    end;
    //colbk := 10; pause;

    p0 := pointer(screen + $2e0);
    for b0i := $1f downto 0 do p0[b0i] := rnd and 15;
  end;
end.
