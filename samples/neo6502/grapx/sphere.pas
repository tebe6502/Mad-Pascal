uses crt, graph;

var 
    turn: single =   0.0;
    rx: SmallInt;

const 
    radians =   3.14 / 180;
    midw =   160;
    midh =   120;
    step_angle =   12;

procedure doDotsSphere;
var sx, sy: smallint;
    latitude, longitude: SmallInt;
    cr1, sr1, x, y, z, x1, z1, y1, x2, y2, z2, lr, lrx, current_radius, xz, yz: single;

begin
    rx := 80;
    // just draw a sphere and shoot some lines through it

    turn := turn + 0.125;
    if turn > 44 then turn := 0.0;

    for latitude := -90 to 90 do
        begin
            for longitude := 0 to 359 do
                begin
                    // these determine how many spines you get
                    if (latitude mod step_angle = 0) and (longitude mod step_angle = 0) then
                        begin
                            cr1 := Cos(turn);
                            sr1 := Sin(turn);

                            lr := latitude * radians;
                            current_radius := Cos(lr) * rx;
                            z := Sin(lr) * rx;

                            lrx := longitude * radians;
                            x := Sin(lrx) * current_radius;
                            y := Cos(lrx) * current_radius;

                            x1 := cr1 * x - sr1 * z;
                            y1 := cr1 * y - sr1 * x1;
                            z1 := sr1 * x + cr1 * z;

                            z2 := cr1 * z1 - sr1 * y1;

                            if z2 > 0 then
                                begin
                                    x2 := cr1 * x1 + sr1 * y;
                                    y2 := sr1 * z1 + cr1 * y1;

                                    z2 := 1 / (z2 - 400);

                                    xz := x2 * z2;
                                    yz := y2 * z2;

                                    sx := trunc(-500 * xz) + midw;
                                    sy := trunc(-500 * yz) + midh;

                                    PutPixel(sx,sy , 15);
                                end;
                        end;
                end;
        end;
end;

begin
    InitGraph(0);
    doDotsSphere;
    repeat until keypressed;
end.
