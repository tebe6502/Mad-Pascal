program three_d;

uses
    atari, crt, fastgraph;

const
    BUILD_DATE = {$INCLUDE %DATE%};

const
    sz                  : byte = 16;
    cx                  : byte = 79;
    cy                  : byte = 50;
var
    angle               : float16 = 0.0;

    pts                 : array[0..7, 0..3] of shortint;
    rzp                 : array[0..7, 0..3] of float16;
    ryp                 : array[0..7, 0..3] of float16;
    rxp                 : array[0..7, 0..3] of float16;

    X1, X2, Y1, Y2      : byte;
    A, B                : byte;

    var	buf1, buf2      : TDisplayBuffer;

    rtc: byte absolute 20;

procedure init_points;
begin
    pts[0,0] := -1; pts[0,1] := -1; pts[0,2] := -1;
    pts[1,0] :=  1; pts[1,1] := -1; pts[1,2] := -1;
    pts[2,0] :=  1; pts[2,1] :=  1; pts[2,2] := -1;
    pts[3,0] := -1; pts[3,1] :=  1; pts[3,2] := -1;
    pts[4,0] := -1; pts[4,1] := -1; pts[4,2] :=  1;
    pts[5,0] :=  1; pts[5,1] := -1; pts[5,2] :=  1;
    pts[6,0] :=  1; pts[6,1] :=  1; pts[6,2] :=  1;
    pts[7,0] := -1; pts[7,1] :=  1; pts[7,2] :=  1;
end;

procedure rotate_points;
var
    n: byte;
    sn, cs: float16;
begin
    sn := sin(angle);
    cs := cos(angle);

    for n := 0 To 7 do begin
        rzp[n,0] := -cs * pts[n,0] + sn * pts[n,1];
        rzp[n,1] :=  sn * pts[n,0] + cs * pts[n,1];
        rzp[n,2] :=  pts[n,2];
        ryp[n,0] :=  cs * rzp[n,0] +  sn * rzp[n,2];
        ryp[n,1] :=  rzp[n,1];
        ryp[n,2] := -sn * rzp[n,0] +  cs * rzp[n,2];
        rxp[n,0] :=  ryp[n,0];
        rxp[n,1] :=  cs * ryp[n,1] - sn * ryp[n,2];
        rxp[n,2] :=  sn * ryp[n,1] + cs * ryp[n,2];
    end;

end;

procedure draw_lines;
begin
    X1 := Trunc(ryp[0,0] * sz + cx);
    Y1 := Trunc(ryp[0,1] * sz + cy);
    X2 := Trunc(ryp[1,0] * sz + cx);
    Y2 := Trunc(ryp[1,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[1,0] * sz + cx);
    Y1 := Trunc(ryp[1,1] * sz + cy);
    X2 := Trunc(ryp[2,0] * sz + cx);
    Y2 := Trunc(ryp[2,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[2,0] * sz + cx);
    Y1 := Trunc(ryp[2,1] * sz + cy);
    X2 := Trunc(ryp[3,0] * sz + cx);
    Y2 := Trunc(ryp[3,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[3,0] * sz + cx);
    Y1 := Trunc(ryp[3,1] * sz + cy);
    X2 := Trunc(ryp[0,0] * sz + cx);
    Y2 := Trunc(ryp[0,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[4,0] * sz + cx);
    Y1 := Trunc(ryp[4,1] * sz + cy);
    X2 := Trunc(ryp[5,0] * sz + cx);
    Y2 := Trunc(ryp[5,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[5,0] * sz + cx);
    Y1 := Trunc(ryp[5,1] * sz + cy);
    X2 := Trunc(ryp[6,0] * sz + cx);
    Y2 := Trunc(ryp[6,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[6,0] * sz + cx);
    Y1 := Trunc(ryp[6,1] * sz + cy);
    X2 := Trunc(ryp[7,0] * sz + cx);
    Y2 := Trunc(ryp[7,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[7,0] * sz + cx);
    Y1 := Trunc(ryp[7,1] * sz + cy);
    X2 := Trunc(ryp[4,0] * sz + cx);
    Y2 := Trunc(ryp[4,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[0,0] * sz + cx);
    Y1 := Trunc(ryp[0,1] * sz + cy);
    X2 := Trunc(ryp[4,0] * sz + cx);
    Y2 := Trunc(ryp[4,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[1,0] * sz + cx);
    Y1 := Trunc(ryp[1,1] * sz + cy);
    X2 := Trunc(ryp[5,0] * sz + cx);
    Y2 := Trunc(ryp[5,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[2,0] * sz + cx);
    Y1 := Trunc(ryp[2,1] * sz + cy);
    X2 := Trunc(ryp[6,0] * sz + cx);
    Y2 := Trunc(ryp[6,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[3,0] * sz + cx);
    Y1 := Trunc(ryp[3,1] * sz + cy);
    X2 := Trunc(ryp[7,0] * sz + cx);
    Y2 := Trunc(ryp[7,1] * sz + cy);

    fLine(X1,Y1,X2,Y2);

end;

begin
    NewDisplayBuffer(buf1, 7 + 16, $c0);		// ramtop = $c0
    NewDisplayBuffer(buf2, 7 + 16, $a0);		// ramtop = $a0

    SetColor(1);

    init_points;

    repeat
        pause;
        SwitchDisplayBuffer(buf1, buf2);
        rotate_points;
        draw_lines;
        angle := angle + 0.1;
    until keypressed;

end.

// 7773