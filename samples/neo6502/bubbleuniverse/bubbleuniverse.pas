uses crt,neo6502,neo6502math;
const n = 200;
var r,x,y,v,t,u:float;
    i,j,s:byte;
    time:cardinal;
    tmpStr:TString;
begin
    // prepare palette
    NeoSetDefaults(0,$ff,1,0,0);
    NeoSetPalette($ff,0,0,0);
    for i:=0 to 14 do 
        for j:=0 to 14 do 
            NeoSetPalette((i shl 4) or j,i*16,j*16,100);
    // draw
    x:=0; y:=0; v:=0; t:=0; s:=60;
    r:=(PI * 2)/235;
    time:=NeoGetTimer;
    //repeat
        NeoSetColor($ff);
        NeoDrawRect(0,0,319,239);
        for i:=0 to n do 
            for j:=0 to n do begin
                u:=sin(i+v)+sin((r*i)+x);
                v:=cos(i+v)+cos((r*i)+x);
                x:=u+t;
                NeoSetColor(((i div 14) shl 4) or (j div 14));
                NeoDrawPixel(Round(u*s)+160,Round(v*s)+120);
            end;
        t:=t+0.025;
    time:=(NeoGetTimer - time) div 100;
    //until false;
    NeoSetSolidFlag(0);
    NeoSetColor($ee);
    Gotoxy(1,1);
    NeoStr(time,tmpstr);
    NeoDrawString(0,0,tmpstr);
    repeat until keypressed;
end.
