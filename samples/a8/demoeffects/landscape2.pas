(*
* This is a part of Quatari 256B intro
* <https://demozoo.org/productions/280623>
*)
program Landscape;

uses crt, graph;

var
  cursor_y : byte absolute $e0;
  prev_y   : byte absolute $e1;
  color    : byte absolute $e2;
  x        : byte absolute $e3;
  y        : byte absolute $e4;
  rnd      : byte absolute $d20a;

  color_height: array[0..13] of byte = (
    170,150,144,144,122,122,110,110,94,94,86,86,82,80
  );

begin
  InitGraph(9);
  SetBKColor($b0);

  for x := 79 downto 0 do begin
    prev_y := 1;
    for color := 13 downto 0 do begin
      SetColor(color);
      cursor_y := color_height[color];
      if rnd < $80 then dec(color_height[color]);
      if rnd < $80 then inc(color_height[color]);
      for y := prev_y to cursor_y do PutPixel(x,y);
      prev_y := cursor_y;
    end;
  end;

  ReadKey;
end.
