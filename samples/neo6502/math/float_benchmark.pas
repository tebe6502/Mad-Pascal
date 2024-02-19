program match_benchmark;

uses crt, neo6502, neo6502math;

var
    time1      : cardinal absolute $60;
    time2      : cardinal absolute $64;
    i          : word absolute $68;
    f0, f1, sf : float;
    i0, i1, si : integer;

begin

    f0 := 6502.0;
    f1 := 666.777;
    i0 := 6502;
    i1 := 666;

    clrscr;

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    write('Add (f) ',f0,' + ',f1,' = ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathStack(f0,0);
        SetMathStack(f1,1);
        DoMathOnStack(MATHAdd);
    end;
    time2 := NeoGetTimer;
    writeln(GetMathStackFloat(0));
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        sf := f0 + f1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 time : ', time2 - time1, NEO_ENTER);

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    write('Mul (f) ', f0,' * ', f1, ' = ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathStack(f0, 0);
        SetMathStack(f1, 1);
        DoMathOnStack(MATHMul);
    end;
    time2 := NeoGetTimer;
    writeln(GetMathStackFloat(0));
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        sf := f0 * f1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 time : ', time2 - time1, NEO_ENTER);

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    write('Div (f) ',f0,' / ',f1,' = ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathStack(f0,0);
        SetMathStack(f1,1);
        DoMathOnStack(MATHFDiv)
    end;
    time2 := NeoGetTimer;
    writeln(GetMathStackFloat(0));
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        sf := f0 / f1;
    end;
    time2 := NeoGetTimer;
    writeln('65c02 time : ', time2 - time1, NEO_ENTER);

//--------------------------------------------------

    writeln(1024 * 8, ' reps.');
    Write('Sqr (f) ',f0,'  -> ');

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        SetMathVar(f0);
        DoMathOnVar(MATHSqr);
    end;
    time2 := NeoGetTimer;
    writeln(m_float);
    writeln('API time   : ', time2 - time1);

    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := (1024 * 8 - 1) downto 0 do begin
        sf := Sqrt(f0);
    end;
    time2 := NeoGetTimer;
    writeln('65c02 time : ', time2 - time1, NEO_ENTER);

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


    writeln('32 reps. for 65c02');
    NeoWaitForVblank;
    time1 := NeoGetTimer;
    for i := 31 downto 0 do begin
        sf := Sin(f0);
    end;
    time2 := NeoGetTimer;
    writeln('65c02 time : ', time2 - time1, NEO_ENTER);

    repeat until false;

end.