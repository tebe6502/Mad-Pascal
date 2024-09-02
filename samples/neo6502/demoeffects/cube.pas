program wired_cube;

//------------------------------------------------------------------------------

uses crt, neo6502system, neo6502;

//------------------------------------------------------------------------------

const
    scale   : byte = 65;
    originX : byte = 160;
    originY : byte = 120;

    vertecs : array[0..7, 0..2] of shortint = (
        (-1,-1,-1),
        ( 1,-1,-1),
        ( 1, 1,-1),
        (-1, 1,-1),
        (-1,-1, 1),
        ( 1,-1, 1),
        ( 1, 1, 1),
        (-1, 1, 1)
    );

//------------------------------------------------------------------------------

var
    cube             : array[0..7, 0..2] of word;
    angle            : single = 0.0;

//------------------------------------------------------------------------------

{*
    RotationMatrix (Gimbal Lock effect)
*}
procedure rotatePoints;
var
    n          : byte;
    s, c       : single;
    tmp1, tmp2 : single;
    v0, v1, v2 : shortint;
begin
    s := sin(angle);
    c := cos(angle);

    for n := 0 To 7 do begin
        v0 := vertecs[n,0];
        v1 := vertecs[n,1];
        v2 := vertecs[n,2];
        tmp1 := s * v0 + c * v1;
        tmp2 := s * (c * v0 - s * v1) + c * v2;
        cube[n,0] := Trunc((c * (-c * v0 + s * v1) + s * v2) * scale + originX);
        cube[n,1] := Trunc((c * tmp1 - s * tmp2) * scale + originY);
        cube[n,2] := Trunc((s * tmp1 + c * tmp2) * scale);       
    end;
end;

//------------------------------------------------------------------------------

begin
    repeat
        rotatePoints;
        angle := angle + 0.02;

        NeoWaitForVblank; clrscr;
        NeoDrawLine(cube[0,0],cube[0,1],cube[1,0],cube[1,1]);
        NeoDrawLine(cube[1,0],cube[1,1],cube[2,0],cube[2,1]);
        NeoDrawLine(cube[2,0],cube[2,1],cube[3,0],cube[3,1]);
        NeoDrawLine(cube[3,0],cube[3,1],cube[0,0],cube[0,1]);
        NeoDrawLine(cube[4,0],cube[4,1],cube[5,0],cube[5,1]);
        NeoDrawLine(cube[5,0],cube[5,1],cube[6,0],cube[6,1]);
        NeoDrawLine(cube[6,0],cube[6,1],cube[7,0],cube[7,1]);
        NeoDrawLine(cube[7,0],cube[7,1],cube[4,0],cube[4,1]);
        NeoDrawLine(cube[0,0],cube[0,1],cube[4,0],cube[4,1]);
        NeoDrawLine(cube[1,0],cube[1,1],cube[5,0],cube[5,1]);
        NeoDrawLine(cube[2,0],cube[2,1],cube[6,0],cube[6,1]);
        NeoDrawLine(cube[3,0],cube[3,1],cube[7,0],cube[7,1]);       
    until false;
end.