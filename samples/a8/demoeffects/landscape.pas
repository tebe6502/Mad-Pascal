(*
* This is a part of Quatari 256B intro
* <https://demozoo.org/productions/280623>
*)
program Landscape;

var
  cursor_y : byte absolute $54;
  cursor_x : byte absolute $55;
  prev_y   : byte absolute $5a;
  prev_x   : byte absolute $5b;
  color4   : byte absolute $02c8;
  color    : byte absolute $02fb;
  rnd      : byte absolute $d20a;
  i        : byte absolute $e0;

  color_height: array[0..13] of byte = (
    170,150,144,144,122,122,110,110,94,94,86,86,82,80
  );

procedure openmode(m : byte); assembler;
asm {
  lda m
  jsr $ef9c
};
end;

procedure drawto; assembler;
asm {
  jsr $f9c2
};
end;

begin
  openmode(9); color4 := $b0;

  for i := 0 to 79 do begin
    cursor_x := i; prev_x := i;
    prev_y := 1; color := 13;

    while color <> $ff do begin
      cursor_y := color_height[color];

      if rnd < $80 then inc(color_height[color]);
      if rnd < $80 then dec(color_height[color]);

      drawto; dec(color);
    end;
  end;

  repeat until false;
end.
