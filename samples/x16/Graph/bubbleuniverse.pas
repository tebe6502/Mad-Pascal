uses crt, graph, x16_sysutils;

const n = 200;
var r,x,y,v,t,u:shortreal;
    i,j,s:byte;
    seconds:cardinal;
    time:TDateTime;
    // tmpStr:TString;
begin
    InitGraph(X16_MODE_320x240);
    
    // prepare palette
    // NeoSetDefaults(0,$ff,1,0,0);
    // NeoSetPalette($ff,0,0,0);
    // for i:=0 to 14 do 
        // for j:=0 to 14 do 
            // NeoSetPalette((i shl 4) or j,i*16,j*16,100);
    // draw
    x:=0; y:=0; v:=0; t:=0; s:=60;
    r:=(PI * 2)/235;
    seconds:=CurrentSecondOfDay;
    //repeat
        SetColor($ff);
        // Box(0,0,319,239);
        for i:=0 to n do 
            for j:=0 to n do begin
                u:=sin(i+v)+sin((r*i)+x);
                v:=cos(i+v)+cos((r*i)+x);
                x:=u+t;
                PutPixel(Round(u*s)+160,Round(v*s)+120,((i div 14) shl 4) or (j div 14));
            end;
        t:=t+0.025;
    seconds:=(CurrentSecondOfDay - seconds);
    SecondsToTime(seconds, time.h, time.m, time.s);
    //until false;
    // NeoSetSolidFlag(0);
    TextColor($ee);
    Gotoxy(1,1);
    write('TIME=',TimeToStr(time));
    repeat until keypressed;
end.