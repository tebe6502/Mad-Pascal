(*
* this is a part of quatari 256b intro
* <https://demozoo.org/productions/280623>
*)
program landscapeslideshow;

uses atari, crt;

const
  lms = $8010;
  dl8: array [0..201] of byte = (
    $70,$70,$70,
    $4f,lo(lms),hi(lms),
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,
    $4f,0,hi(lms)+$10,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,
    $41,lo(word(@dl8)),hi(word(@dl8))
  );
  base: array[0..13] of byte = (
    170,150,144,144,122,122,110,110,94,94,86,86,82,80
  );

var
  stop     : byte absolute $e0;
  start    : byte absolute $e1;
  c        : byte absolute $e2;
  x        : byte absolute $e3;
  i        : byte absolute $e4;
  p        : pbyte absolute $e5;
  rnd      : byte absolute $d20a;

  colheight: array[0..13] of byte = (
    170,150,144,144,122,122,110,110,94,94,86,86,82,80
  );

begin
  sdlstl := word(@dl8);
  gprior := $40;
  color4 := $b0;

  repeat
    sdmctl := 0;
    fillchar(pointer(lms), $2000, 0);
    for x := 39 downto 0 do begin
      for i := 1 downto 0 do begin
        p := pointer(lms + x); start := 0;
        for c := 13 downto 0 do begin
          stop := colheight[c];
          if start > stop then begin
            dec(p,(start - stop) * 40);
            stop := start;
            start := colheight[c];
          end;
          while start < stop do begin
            if i = 1 then
              p^ := c
              //p[0] := (p[0] and %11110000) or c
            else
              p^ := (p[0] and %00001111) or (c shl 4);
            inc(p,40);
            inc(start);
          end;
          start := stop;
          if boolean(rnd and 1) then dec(colheight[c]);
          if boolean(rnd and 1) then inc(colheight[c]);
        end;
      end;
    end;
    sdmctl := $22;
    move(@base, @colheight, 14);
    pause(150);
  until keypressed;
  textmode(0);
end.
