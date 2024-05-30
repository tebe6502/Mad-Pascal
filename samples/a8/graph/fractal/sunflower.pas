// https://rosettacode.org/wiki/Sunflower_fractal#FreeBASIC

uses crt, fastgraph, math;

type
	TFloat = real;


procedure sunflower(seeds: word);
var i: integer;

    r, angle, x, y: TFloat;

    px, py, pr: byte;

const
	c: TFloat = 1.618033988749895;
	_pi: TFloat = 2*pi*c;

begin

    angle := _pi;

    For i := 1 To seeds do begin

        SetColor(i and 3);

        r := power(TFloat(i), c) / seeds;

        x := r * Sin(angle);
        y := r * Cos(angle);

	px := round(x) + 80;
	py := round(y) + 96;

	pr := round(i / seeds * 2);

        Ellipse (px, py, pr, pr shl 1);

	angle := angle + _pi;

     end;

end;


begin

 InitGraph(15+16);

 SetColor(1);

 sunflower(800);

 repeat until keypressed;

end.