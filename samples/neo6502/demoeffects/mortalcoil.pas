program mortal_coil;

{*
    Mortal Coil, for Outline 2k17, 128 bytes compo
    F#READY, May 2017
*}

//-----------------------------------------------------------------------------

uses crt, fastmath, neo6502, neo6502math;

//-----------------------------------------------------------------------------

const
intend = 30;
speed  = 1;

//-----------------------------------------------------------------------------

var
i         : byte absolute $54;
j         : byte absolute $55;
p         : byte absolute $56;
positions : array [0..255] of byte absolute $3000;
sinewave  : array [0..255] of byte absolute $3100;
colors    : array [0..255] of byte absolute $3200;

//-----------------------------------------------------------------------------

begin
    FillSinHigh(@sinewave);

    for i := 255 to 0 do begin
        j := byte(NeoIntRandom(256));
        colors[i] := j;
        positions[i] := j;
    end;

    repeat
        NeoWaitForVblank;
        ClrScr;
        for i := 255 downto 0 do begin
            p := (sinewave[positions[i]] + sinewave[i]) shr 1;
            NeoWritePixel(intend + p, byte(i + j), colors[i]);
            Inc(positions[i], speed);
        end;
        Dec(j);
    until false;
end.
