uses crt, Neo6502, graph;
type 
    TFloat =   real;

const 
    s =   0.7071; // sqrt(2) / 2;
    _sin: array [0..7] of TFloat =   (0, s, 1, s, 0, -s, -1, -s);
    _cos: array [0..7] of TFloat =   (1.0, s, 0.0, -s, -1.0, -s, 0.0, s);
    sep =   180;

var 
    gd, gm: smallint;
    c: byte;

procedure Dragon(n, a, t: byte; d, x, y: TFloat);
var a1, a2: byte;
begin
    if n <= 1 then
        begin
            SetColor(c and $f);
            MoveTo(Trunc(x + 0.5), Trunc(y + 0.5));
            LineTo(Trunc(x + d * _cos[a] + 0.5), Trunc(y + d * _sin[a] + 0.5));
            exit;
        end;

    d := d * s;
    a1 := (a - t) and 7;
    a2 := (a + t) and 7;
    Inc(c,3);
    dragon(n - 1, a1, 1, d, x, y);
    dragon(n - 1, a2, -1, d, x + d * _cos[a1], y + d * _sin[a1]);
end;

begin
    InitGraph(0);
    c := 0;
    dragon(14, 0, 1, sep, sep / 2, sep * 5 / 6);
    repeat until keypressed;
end.
