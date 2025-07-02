program mathTest;
uses crt, neo6502, neo6502math;
var 
    f0,f1:float;
    i0,i1:integer;
    s:TString;
    bcd: array[0..7] of byte;
    count: byte;
begin
    f0 := 6502.0;
    f1 := 666.777;
    i0 := 6502;
    i1 := 666;

    // BINARY 
    ClrScr;
    Writeln('Binary operations:');
    Writeln;
    // ------------------- add
    Write('Add (f) ',f0,' + ',f1,' = ');
    SetMathStack(f0,0);
    SetMathStack(f1,1);
    DoMathOnStack(MATHAdd);
    Writeln(GetMathStackFloat);

    Write('Add (i) ',i0,' + ',i1,' = ');
    SetMathStack(i0,0);
    SetMathStack(i1,1);
    DoMathOnStack(MATHAdd);
    Writeln(GetMathStackInt);

    // ------------------- sub
    Write('Sub (f) ',f0,' - ',f1,' = ');
    SetMathStack(f0,0);
    SetMathStack(f1,1);
    DoMathOnStack(MATHSub);
    Writeln(GetMathStackFloat);

    Write('Sub (i) ',i0,' - ',i1,' = ');
    SetMathStack(i0,0);
    SetMathStack(i1,1);
    DoMathOnStack(MATHSub);
    Writeln(GetMathStackInt);

    // ------------------- mul
    Write('Mul (f) ',f0,' * ',f1,' = ');
    SetMathStack(f0,0);
    SetMathStack(f1,1);
    DoMathOnStack(MATHMul);
    Writeln(GetMathStackFloat);

    Write('Mul (i) ',i0,' * ',i1,' = ');
    SetMathStack(i0,0);
    SetMathStack(i1,1);
    DoMathOnStack(MATHMul);
    Writeln(GetMathStackInt);

    // ------------------- div
    Write('Div (f) ',f0,' / ',f1,' = ');
    SetMathStack(f0,0);
    SetMathStack(f1,1);
    DoMathOnStack(MATHFDiv);
    Writeln(GetMathStackFloat);

    Write('Div (i) ',i0,' / ',i1,' = ');
    SetMathStack(i0,0);
    SetMathStack(i1,1);
    DoMathOnStack(MATHIDiv);
    Writeln(GetMathStackInt);

    // ------------------- mod
    Write('Mod (i) ',i0,' % ',i1,' = ');
    SetMathStack(i0,0);
    SetMathStack(i1,1);
    DoMathOnStack(MATHMod);
    Writeln(GetMathStackInt);
    
    // ------------------- cmp
    Write('Cmp (f) ',f0,' > ',f1,' = ');
    SetMathStack(f0,0);
    SetMathStack(f1,1);
    DoMathOnStack(MATHCmp);
    Writeln(NeoMessage.params[0]=1);
    
    Write('Cmp (f) ',f0,' < ',f1,' = ');
    SetMathStack(f1,0);
    SetMathStack(f0,1);
    DoMathOnStack(MATHCmp);
    Writeln(NeoMessage.params[0]=1);

    Write('Cmp (i) ',i0,' > ',i1,' = ');
    SetMathStack(i0,0);
    SetMathStack(i1,1);
    DoMathOnStack(MATHCmp);
    Writeln(NeoMessage.params[0]=1);

    Write('Cmp (i) ',i0,' < ',i1,' = ');
    SetMathStack(i1,0);
    SetMathStack(i0,1);
    DoMathOnStack(MATHCmp);
    Writeln(NeoMessage.params[0]=1);

    Writeln;
    Writeln('Press any key to continue.');
    Readkey;

    // UNARY
    ClrScr;
    Writeln('Unary operations:');
    Writeln;
    // ------------------- negate
    Write('Negate (f) ',f0,'  -> ');
    SetMathVar(f0);
    DoMathOnVar(MATHNeg);
    Writeln(m_float);

    Write('Negate (i) ',i1,'  -> ');
    SetMathVar(i1);
    DoMathOnVar(MATHNeg);
    Writeln(m_integer);

    // ------------------- floor
    Write('Floor (f) ',f1,'  -> ');
    SetMathVar(f1);
    DoMathOnVar(MATHFlr);
    Writeln(m_integer);

    // ------------------- square root
    Write('Sqr (f) ',f0,'  -> ');
    SetMathVar(f0);
    DoMathOnVar(MATHSqr);
    Writeln(m_float);

    // ------------------- sine
    Write('Sin (f) 180  -> ');
    SetMathVar(float(180.0));
    DoMathOnVar(MATHSin);
    Writeln(m_float);

    // ------------------- cosine
    Write('Cos (f) 180  -> ');
    SetMathVar(float(180.0));
    DoMathOnVar(MATHCos);
    Writeln(m_float);

    // ------------------- tan
    Write('Tan (f) 180  -> ');
    SetMathVar(float(180.0));
    DoMathOnVar(MATHTan);
    Writeln(m_float);

    // ------------------- atan
    Write('Atan (f) 180  -> ');
    SetMathVar(float(180.0));
    DoMathOnVar(MATHATan);
    Writeln(m_float);

    // ------------------- exp
    Write('Exp (f) 10 -> ');
    SetMathVar(float(10));
    DoMathOnVar(MATHExp);
    Writeln(m_float);

    // ------------------- log
    Write('Log (f) 10 -> ');
    SetMathVar(float(10));
    DoMathOnVar(MATHLog);
    Writeln(m_float);

    // ------------------- abs
    Write('Abs (f) ',-f0,' -> ');
    SetMathVar(-f0);
    DoMathOnVar(MATHAbs);
    Writeln(m_float);

    Write('Abs (i) ',-i1,' -> ');
    SetMathVar(-i1);
    DoMathOnVar(MATHAbs);
    Writeln(m_integer);

    // ------------------- sgn
    Write('Sgn (f) ',-f0,' -> ');
    SetMathVar(-f0);
    DoMathOnVar(MATHSgn);
    Writeln(m_integer);

    Write('Sgn (i) ',i1,' -> ');
    SetMathVar(i1);
    DoMathOnVar(MATHSgn);
    Writeln(m_integer);

    Write('Sgn (i) 0 -> ');
    SetMathVar(0);
    DoMathOnVar(MATHSgn);
    Writeln(m_integer);

    // ------------------- rnd
    Writeln('Random floats:');
    for count:=0 to 4 do Write(NeoFloatRandom,' ');
    Writeln;

    Writeln('Random Integers in range 0..9999:');
    for count:=0 to 7 do Write(NeoIntRandom(10000),' ');
    Writeln;

    Writeln;
    Writeln('Press any key to continue.');
    Readkey;

    // OTHER
    ClrScr;
    Writeln('Other operations:');
    Writeln;

    // ------------------- add frac bcd
    bcd[0] := $12;
    bcd[1] := $3f;
    Writeln('Add Fractional from BCD code: ');
    Writeln('num = ',f0);
    Writeln('BCD = ',HexStr(bcd[0],2),HexStr(bcd[1],2));
    Writeln('Result: ',AddFractionalBCD(f0,@bcd));
    Writeln;

    // ------------------- String to Number
    s:='12345.678';
    Writeln('String to number:');
    Writeln('Parse float: ',s,' -> ',NeoParseFloat(s));
    Writeln('Parse int: ',s,' -> ',NeoParseInt(s));
    Writeln;

    // ------------------- Number to String
    Writeln('Number to String:');
    NeoStr(i0,s);
    Writeln('Int to Str: ',i0,' -> ',s);
    NeoStr(f1,s);
    Writeln('Float to Str: ',f1,' -> ',s);
    Writeln;

    Writeln('Press any key to continue.');
    Readkey;
end.
