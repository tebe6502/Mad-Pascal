program madStrap;
{$librarypath blibs'}
uses atari, crt, fastgraph;

const
{$i const.inc}
{$r resources.rc}
{$i types.inc}
{$i interrupts.inc}

var
    b,o,oc: byte;
    c: shortint;
    borderlinePos,bcolor:byte;
    w: word;
    s: TString;
    borderlines: array [0..1023] of byte;
    roadOffsets: array [0..63] of byte;

    //msx: TRMT;
    //oldvbl,oldsdli:pointer;
    //strings:array [0..0] of word absolute STRINGS_ADDRESS;

procedure setDliOffset;
var v,dl:word;
begin
    v:=VIDEO_RAM_ADDRESS;
    dl:=DISPLAY_LIST_ADDRESS+4;
    for b:=0 to 63 do begin
        v:=v+roadOffsets[b];
        DPoke(dl,v);
        inc(dl,3);
        inc(v,40);
    end;
end;


begin
    //chbas := Hi(CHARSET_ADDRESS); // set custom charset
    //savmsc := VIDEO_RAM_ADDRESS;  // set custom video address
    InitGraph(15);

(*  set custom display list  *)
    Pause;
    SDLSTL := DISPLAY_LIST_ADDRESS;

    frameBuffer(VIDEO_RAM_ADDRESS);

(*  set and run vbl interrupt *)
    //GetIntVec(iVBL, oldvbl);
    //SetIntVec(iVBL, @vbl);
    //nmien := $40;

(*  set and run display list interrupts *)
    //SGetIntVec(iDLI, oldsdli);
    SetIntVec(iDLI, @dli);
    nmien := $c0; // set $80 for dli only (without vbl)

(*  your code goes here *)

    color1:=$f;
    color2:=$0;
    color4:=$74;



    for b:=0 to 63 do begin

        SetColor(2);
        o:=1 + (b shr 4);
        fLine(80-b-o,b,80+b+o,b);

        SetColor(1);
        fLine(80-b,b,80+b,b);

        roadOffsets[b]:=0;

    end;
    // SetColor(2);
    // fLine(1,1,30,30);

    w:=0;
    o:=8;
    oc:=0;
    repeat
        c:=o;
        bcolor:=oc and 1;
        for b:=0 to 63 do begin
            if c=0 then begin
                inc(bcolor);
                c:= 8 - ((b * 10) div 70);
                if c<0 then c:=0;
            end else dec(c);

            if bcolor and 1 <> 0 then borderlines[w]:=$f
                else borderlines[w]:=$24;
            inc(w);

	    w:=w mod 1024;
        end;
        if o>0 then dec(o)
            else begin
                o:=8;
                inc(oc);
            end;

    until oc=2;

    setDliOffset;

    borderlinePos:=0;
    repeat
        pause;
        inc(borderlinePos);
    until false;

    ReadKey;




(*  restore system interrupts *)
    //SetIntVec(iVBL, @oldvbl);
    //SetIntVec(iDLI, oldsdli);
    //nmien := $40; // turn off dli

end.
