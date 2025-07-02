program match_benchmark;

uses crt, neo6502system, neo6502, neo6502math;

var
    time1      : cardinal absolute $60;
    time2      : cardinal absolute $64;
    f, f0, f1  : float16;
    s, s0, s1  : float;
    r, r0, r1  : real;
    i          : word absolute $68;

begin

    r0 := 6502.0;
    r1 := 666.777;

    f0 := 6502.0;
    f1 := 666.777;

    s0 := 6502.0;
    s1 := 666.777;

    clrscr;

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    write('Add (f) ',f0,' + ',f1,' = ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathStack(s0,0);
        SetMathStack(s1,1);
        DoMathOnStack(MATHAdd);
    end;
    time2 := NeoGetTimer;
    writeln(GetMathStackFloat);
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        r := r0 + r1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 real time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        f := f0 + f1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float16 time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        s := s0 + s1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float time : ', time2 - time1, NEO_ENTER);

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    write('Mul (f) ', f0,' * ', f1, ' = ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathStack(s0, 0);
        SetMathStack(s1, 1);
        DoMathOnStack(MATHMul);
    end;
    time2 := NeoGetTimer;
    writeln(GetMathStackFloat);
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        r := r0 * r1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 real time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        f := f0 * f1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float16 time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        s := s0 * s1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float time : ', time2 - time1, NEO_ENTER);

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    write('Div (f) ',f0,' / ',f1,' = ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathStack(s0,0);
        SetMathStack(s1,1);
        DoMathOnStack(MATHFDiv)
    end;
    time2 := NeoGetTimer;
    writeln(GetMathStackFloat);
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        r := r0 / r1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 real time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        f := f0 / f1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float16 time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        s := s0 / s1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float time : ', time2 - time1, NEO_ENTER);

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    Write('Sqr (f) ',f0,'  -> ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathVar(s0);
        DoMathOnVar(MATHSqr);
    end;
    time2 := NeoGetTimer;
    writeln(m_float);
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        r := Sqrt(r0);
    end;
    time2 := NeoGetTimer;
    writeln('65c02 real time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        f := Sqrt(f0);
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float16 time : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        s := Sqrt(s0);
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float time : ', time2 - time1, NEO_ENTER);

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    Write('Sin (f) 180  -> ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathVar(float(180.0));
        DoMathOnVar(MATHSin);
    end;
    time2 := NeoGetTimer;
    writeln(m_float);
    writeln('API time   : ', time2 - time1, NEO_ENTER);

    writeln('256 reps. for 65c02');
    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := 255 downto 0 do begin
        r := Sin(real(180.0));
    end;
    time2 := NeoGetTimer;
    writeln('65c02 real time : ', time2 - time1);

    writeln('256 reps. for 65c02');
    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := 255 downto 0 do begin
        f := Sin(float16(180.0));
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float16 time : ', time2 - time1);
    
    writeln('1024 reps. for 65c02');
    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        s := Sin(float(180.0));
    end;
    time2 := NeoGetTimer;
    writeln('65c02 float time : ', time2 - time1, ' ', s, NEO_ENTER);

    repeat until false;

end.
