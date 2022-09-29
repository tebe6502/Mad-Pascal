// Barnsley fern
// https://rosettacode.org/wiki/Barnsley_fern

uses graph, crt;

var
  gd, gm: smallint;


procedure fern(w: word; h: byte);
var r, x, y,
    tmpx, tmpy: float16;
    i: word;
begin

    x := 0;
    y := 0;

    randomize();

    for i := 0 to high(word) do begin

        r := randomF16;

        if r <= 0.01 then begin
            tmpx := 0;
            tmpy := 0.16 * y;
        end
        else if r <= 0.08 then begin
            tmpx := 0.2 * x - 0.26 * y;
            tmpy := 0.23 * x + 0.22 * y + 1.6;
        end
        else if r <= 0.15 then begin
            tmpx := -0.15 * x + 0.28 * y;
            tmpy := 0.26 * x + 0.24 * y + 0.44;
        end
        else begin
            tmpx := 0.85 * x + 0.04 * y;
            tmpy := -0.04 * x + 0.85 * y + 1.6;
        end;

        x := tmpx;
        y := tmpy;

        PutPixel(round(float16(w) * 0.5 + x * w * 0.090909090), round(h - y * h * 0.090909090));
    end;

    repeat until keypressed;

end;



begin

 gd := D8bit;
 gm := m640x400;

 InitGraph(gd,gm,'');

 SetColor(15);

 fern(320, 192);

 repeat until keypressed;

end.