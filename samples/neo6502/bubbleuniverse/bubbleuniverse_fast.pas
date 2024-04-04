uses crt,neo6502,neo6502math;
const
    n = 200;
    rad = float(180 / PI);
var
    r:float absolute($84);
    x:float absolute($88);
    y:float absolute($8c);
    v:float absolute($90);
    t:float absolute($94);
    u:float absolute($98);
    p:float absolute($9c);
    q:float absolute($a0);
    xx:float absolute($a4);
    yy:float absolute($a8);
    
    c,i,j,s:byte;
    time:cardinal;
    tmpstr:Tstring;
    col:array[0..n,0..n] of byte;
begin
    // prepare palette
    NeoSetDefaults(0,$ff,1,1,0);
    NeoSetPalette($ff,0,0,0);
    NeoSetColor($ff);
    NeoDrawRect(0,0,319,239);

    for i:=0 to n do 
        for j:=0 to n do begin
            c:=((i div 14) shl 4) or (j div 14);
            NeoSetPalette(c, i, j, 99);
            col[i,j] := c;
        end;

    // draw
    x:=0; y:=0; v:=0; t:=0; s:=60;
    r := (PI * 2) / 235;
    time := NeoGetTimer;
    //repeat
        for i:=0 to n do 
            for j:=0 to n do begin
                SetMathStack(i,0);
                SetMathStack(v,1);
                DoMathOnStack(MATHAdd);
                //SetMathStack(rad,1);
                //DoMathOnStack(MATHMul);
                p := GetMathStackFloat;
    
                SetMathStack(i,0);
                SetMathStack(r,1);
                DoMathOnStack(MATHMul);
                SetMathStack(x,1);
                DoMathOnStack(MATHAdd);
                //SetMathStack(rad,1);
                //DoMathOnStack(MATHMul);
                q := GetMathStackFloat; 
                
                SetMathVar(p);
                DoMathOnVar(MATHSin);
                SetMathStack(m_float,0);
                SetMathVar(q);
                DoMathOnVar(MATHSin);
                SetMathStack(m_float,1);
                DoMathOnStack(MATHAdd);
                u:=GetMathStackFloat;
                SetMathStack(s,1);
                DoMathOnStack(MATHMul);
                xx:=GetMathStackFloat;

                SetMathVar(p);
                DoMathOnVar(MATHCos);
                SetMathStack(m_float,0);
                SetMathVar(q);
                DoMathOnVar(MATHCos);
                SetMathStack(m_float,1);
                DoMathOnStack(MATHAdd);
                v:=GetMathStackFloat;
                SetMathStack(s,1);
                DoMathOnStack(MATHMul);
                yy:=GetMathStackFloat;
                
                x:=u+t;

                NeoWritePixel(Trunc(xx)+160,Trunc(yy)+120,col[i,j]);
            end;
        t:=t+0.025;
    //until false;
    time:=(NeoGetTimer - time) div 100;
    NeoSetSolidFlag(0);
    NeoSetColor($ee);
    Gotoxy(1,1);
    NeoStr(time,tmpstr);
    NeoDrawString(0,0,tmpstr);
    repeat until keypressed;    
end.
