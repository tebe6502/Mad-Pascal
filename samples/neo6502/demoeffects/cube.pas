program wired_cube;

//------------------------------------------------------------------------------

uses crt, neo6502system, neo6502;

//------------------------------------------------------------------------------

const
    sz                  : byte = 50;
    cx                  : byte = 160;
    cy                  : byte = 120;

//------------------------------------------------------------------------------

var
    angle               : shortreal = 0.0;

    pts                 : array[0..7, 0..3] of shortint;
    rzp                 : array[0..7, 0..3] of shortreal;
    ryp                 : array[0..7, 0..3] of shortreal;
    rxp                 : array[0..7, 0..3] of shortreal;

    X1, X2, Y1, Y2      : byte;

//------------------------------------------------------------------------------

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
    sn, cs: shortreal;
begin
    sn := sin(angle);
    cs := cos(angle);

    for n := 0 To 7 do begin
        rzp[n,0] := -cs * pts[n,0] + sn * pts[n,1];
        rzp[n,1] :=  sn * pts[n,0] + cs * pts[n,1];
        rzp[n,2] :=  pts[n,2];
        
        ryp[n,0] :=  cs * rzp[n,0] + sn * rzp[n,2];
        ryp[n,1] :=  rzp[n,1];
        ryp[n,2] := -sn * rzp[n,0] + cs * rzp[n,2];
        
        rxp[n,0] :=  ryp[n,0];
        rxp[n,1] :=  cs * ryp[n,1] - sn * ryp[n,2];
        rxp[n,2] :=  sn * ryp[n,1] + cs * ryp[n,2];
    end;
end;

procedure draw_lines;
begin
    X1 := Trunc(rxp[0,0] * sz + cx);
    Y1 := Trunc(rxp[0,1] * sz + cy);
    X2 := Trunc(rxp[1,0] * sz + cx);
    Y2 := Trunc(rxp[1,1] * sz + cy);

    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[1,0] * sz + cx);
    Y1 := Trunc(rxp[1,1] * sz + cy);
    X2 := Trunc(rxp[2,0] * sz + cx);
    Y2 := Trunc(rxp[2,1] * sz + cy);

    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[2,0] * sz + cx);
    Y1 := Trunc(rxp[2,1] * sz + cy);
    X2 := Trunc(rxp[3,0] * sz + cx);
    Y2 := Trunc(rxp[3,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[3,0] * sz + cx);
    Y1 := Trunc(rxp[3,1] * sz + cy);
    X2 := Trunc(rxp[0,0] * sz + cx);
    Y2 := Trunc(rxp[0,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[4,0] * sz + cx);
    Y1 := Trunc(rxp[4,1] * sz + cy);
    X2 := Trunc(rxp[5,0] * sz + cx);
    Y2 := Trunc(rxp[5,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[5,0] * sz + cx);
    Y1 := Trunc(rxp[5,1] * sz + cy);
    X2 := Trunc(rxp[6,0] * sz + cx);
    Y2 := Trunc(rxp[6,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[6,0] * sz + cx);
    Y1 := Trunc(rxp[6,1] * sz + cy);
    X2 := Trunc(rxp[7,0] * sz + cx);
    Y2 := Trunc(rxp[7,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[7,0] * sz + cx);
    Y1 := Trunc(rxp[7,1] * sz + cy);
    X2 := Trunc(rxp[4,0] * sz + cx);
    Y2 := Trunc(rxp[4,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[0,0] * sz + cx);
    Y1 := Trunc(rxp[0,1] * sz + cy);
    X2 := Trunc(rxp[4,0] * sz + cx);
    Y2 := Trunc(rxp[4,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[1,0] * sz + cx);
    Y1 := Trunc(rxp[1,1] * sz + cy);
    X2 := Trunc(rxp[5,0] * sz + cx);
    Y2 := Trunc(rxp[5,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[2,0] * sz + cx);
    Y1 := Trunc(rxp[2,1] * sz + cy);
    X2 := Trunc(rxp[6,0] * sz + cx);
    Y2 := Trunc(rxp[6,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);

    X1 := Trunc(rxp[3,0] * sz + cx);
    Y1 := Trunc(rxp[3,1] * sz + cy);
    X2 := Trunc(rxp[7,0] * sz + cx);
    Y2 := Trunc(rxp[7,1] * sz + cy);
    NeoDrawLine(X1,Y1,X2,Y2);
end;

//------------------------------------------------------------------------------

begin
    init_points;

    repeat
        NeoWaitForVblank;
        clrscr;

        rotate_points;
        draw_lines;
        angle := angle + 0.02;
    until false;
end.