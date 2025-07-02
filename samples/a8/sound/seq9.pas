{mp seq9.pas && mads seq9.a65 -x -i:c:/temp/atari/mp/base}
program seq9;
uses pokey;

procedure wait(frames : byte); assembler;
asm
{
    rtclock = $12
    lda frames
    add rtclock+2
    cmp rtclock+2
    rne
};
end;

const
    _ = 0;
    track_size = 32;
    track : array [0 .. track_size - 1] of byte =
    (
        126,_,126,_,61,_,126,_,105,93,83,_,93,_,170,_,
        126,_,126,_,61,_,126,_,191,_,191,_,93,_,191,_
    );

    bass_size = 6;
    bass : array [0 .. bass_size - 1] of byte = (140,158,211,188,158,140);
    bass_duration : array [0 .. bass_size - 1] of byte = (32,32,24,6,2,32);

var
    i : byte = 0;
    j : byte = 0;
    k : byte = bass_duration[0];
    a : byte = 7;
    da : byte = 1;
    b : byte = 1;
    db : byte = 1;

procedure next;
begin
    i := i + 1;
    if i = track_size then
        i := 0;

    a := a + da;
    if (a = 9) or (a = 3) then
        da := -da;

    b := b + db;
    if (b = 5) or (b = 1) then
        db := -db;

    k := k - 1;
    if k = 0 then begin
        j := j + 1;
        if j = bass_size then
            j := 0;

        k := bass_duration[j];
    end
end;

var
    f : byte;

label loop;

begin
    writeln('seq9/2017-08-17');
    writeln;
    writeln('Gen Waveform');
    writeln('------------');
    writeln('  1 p31');
    writeln('  2 auto pwm');
    writeln('  3 p62 sub');
    writeln('  4 p2 sub');

    skctl := 3;
    audctl := 64 + 32 + 4 + 2 + 1;
    audc2 := 165;
    audc4 := 164;

    loop:
        f := track[i];
        if boolean(f) then begin
            audf1 := f;
            audf3 := f;
            stimer := 0;
            audc1 := a or $20;
            audc3 := b or $20;
        end;

        f := bass[j];
        audf2 := f;
        audf4 := f + 1;
        wait(4);
        audc1 := $20;
        audc3 := $21;
        next;
        wait(2);
    goto loop;
end.
