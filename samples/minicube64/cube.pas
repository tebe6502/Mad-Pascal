{*
    https://aeriform.itch.io/minicube64
    https://github.com/aeriform-io/minicube64
    https://aeriform.gitbook.io/minicube64
*}

//-----------------------------------------------------------------------------

program cube;

//-----------------------------------------------------------------------------

const
    VIDEO_PAGE  = $e;
    SCREEN      = VIDEO_PAGE * $1000;
    SCREEN_SIZE = 63;
    PAGE        = $100;
    WHITE       = 63;

//-----------------------------------------------------------------------------

const
    sz                  : byte = 15;
    cx                  : byte = SCREEN_SIZE shr 1;
    cy                  : byte = SCREEN_SIZE shr 1;

//-----------------------------------------------------------------------------

var
    video       : byte absolute $100;
    colors      : byte absolute $101;    
    nmi_irq     : byte absolute $10c;
    vblank_irq  : word absolute $10e;
    frame_count : byte absolute $ff;
    scr         : array [0..SCREEN_SIZE, 0..SCREEN_SIZE] of byte absolute SCREEN;

//-----------------------------------------------------------------------------

var
    angle               : shortreal = 0.0;

    pts                 : array[0..7, 0..3] of shortint;
    rzp                 : array[0..7, 0..3] of shortreal;
    ryp                 : array[0..7, 0..3] of shortreal;
    rxp                 : array[0..7, 0..3] of shortreal;

    X1, X2, Y1, Y2      : byte;

//-----------------------------------------------------------------------------

procedure plot(x, y:byte); inline;
begin
    scr[y,x] := WHITE;
end;

//-----------------------------------------------------------------------------

procedure drawLine(x0, y0, x1, y1: byte);
var
    x, y, dx, dy, sx, sy : byte;
    err, e2              : shortint;
begin
    x := x0;
    y := y0;
    dx := abs(x1 - x0);
    dy := abs(y1 - y0);
    if x0 < x1 then sx := 1 else sx := -1; // $ff
    if y0 < y1 then sy := 1 else sy := -1; // $ff
    err := dx - dy;

    while true do
    begin
        plot(x, y);

        if (x = x1) and (y = y1) then break;

        e2 := err shl 1;
        if e2 > -dy then
        begin
            dec(err, dy);
            inc(x, sx);
        end;
        if e2 < dx then
        begin
            inc(err, dx);
            inc(y, sy);
        end;
    end;
end;
//-----------------------------------------------------------------------------

procedure clrscr; inline;
begin
    FillByte(pointer(SCREEN), $1000, 0);
end;


//-----------------------------------------------------------------------------

procedure vbi; assembler; interrupt;
asm
  ;phr
  inc frame_count
  ;plr
end;

//-----------------------------------------------------------------------------

procedure waitVBL; assembler;
asm
    lda frame_count
@   cmp frame_count
    beq @-
end;

//-----------------------------------------------------------------------------

procedure init;
begin
    asm { sei };
        vblank_irq := word(@vbi);
        video      := VIDEO_PAGE; 
    asm { cli };   
end;

//-----------------------------------------------------------------------------

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

    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[1,0] * sz + cx);
    Y1 := Trunc(ryp[1,1] * sz + cy);
    X2 := Trunc(ryp[2,0] * sz + cx);
    Y2 := Trunc(ryp[2,1] * sz + cy);

    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[2,0] * sz + cx);
    Y1 := Trunc(ryp[2,1] * sz + cy);
    X2 := Trunc(ryp[3,0] * sz + cx);
    Y2 := Trunc(ryp[3,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[3,0] * sz + cx);
    Y1 := Trunc(ryp[3,1] * sz + cy);
    X2 := Trunc(ryp[0,0] * sz + cx);
    Y2 := Trunc(ryp[0,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[4,0] * sz + cx);
    Y1 := Trunc(ryp[4,1] * sz + cy);
    X2 := Trunc(ryp[5,0] * sz + cx);
    Y2 := Trunc(ryp[5,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[5,0] * sz + cx);
    Y1 := Trunc(ryp[5,1] * sz + cy);
    X2 := Trunc(ryp[6,0] * sz + cx);
    Y2 := Trunc(ryp[6,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[6,0] * sz + cx);
    Y1 := Trunc(ryp[6,1] * sz + cy);
    X2 := Trunc(ryp[7,0] * sz + cx);
    Y2 := Trunc(ryp[7,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[7,0] * sz + cx);
    Y1 := Trunc(ryp[7,1] * sz + cy);
    X2 := Trunc(ryp[4,0] * sz + cx);
    Y2 := Trunc(ryp[4,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[0,0] * sz + cx);
    Y1 := Trunc(ryp[0,1] * sz + cy);
    X2 := Trunc(ryp[4,0] * sz + cx);
    Y2 := Trunc(ryp[4,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[1,0] * sz + cx);
    Y1 := Trunc(ryp[1,1] * sz + cy);
    X2 := Trunc(ryp[5,0] * sz + cx);
    Y2 := Trunc(ryp[5,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[2,0] * sz + cx);
    Y1 := Trunc(ryp[2,1] * sz + cy);
    X2 := Trunc(ryp[6,0] * sz + cx);
    Y2 := Trunc(ryp[6,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);

    X1 := Trunc(ryp[3,0] * sz + cx);
    Y1 := Trunc(ryp[3,1] * sz + cy);
    X2 := Trunc(ryp[7,0] * sz + cx);
    Y2 := Trunc(ryp[7,1] * sz + cy);
    drawline(X1,Y1,X2,Y2);
end;

//-----------------------------------------------------------------------------

begin
    init;
    init_points;

    repeat
        waitVBL;
        clrscr;

        rotate_points;
        draw_lines;
        angle := angle + 0.1;
    until false;
end.

//-----------------------------------------------------------------------------
