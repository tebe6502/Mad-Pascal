program madStrap;
{$ librarypath '../blibs/'}
uses atari, crt, aplib, rmt; 

const
{$i const.inc}
{$i memory.inc}
{$i packed/memory_pak.inc}
{$r assets/resources.rc}
{$r packed/resources_pak.rc}
{$i types.inc}
{$i pmg.inc}
{$i creatures.inc}

var
    msx: TRMT;
    strings:array [0..0] of ^Tstring absolute STRINGS_ADDRESS;
    //mul_40: array of word = [ {$EVAL 110,":1*40"} ];

{$i interrupts.inc}

{$define _ClearScreen := FillByte(pointer(VIDEO_RAM_ADDRESS),40*32,0) }

var 
    oldvbl,olddli:pointer;

begin
    TextMode(0);
    chbas := Hi(CHARSET_ADDRESS); // set custom charset
    savmsc := VIDEO_RAM_ADDRESS;  // set custom video address

(*  initialize RMT player  *)
    msx.player := pointer(RMT_PLAYER_ADDRESS);
    msx.modul := pointer(RMT_MODULE_ADDRESS);
    msx.Init(0);

(*  set custom display list  *)
    SDLSTL := DISPLAY_LIST_ADDRESS;

(*  set and run vbl interrupt *)
    GetIntVec(iVBL, oldvbl);
    SetIntVec(iVBL, @vbl_os);
    //nmien := $40;

(*  set and run display list interrupts *)
    GetIntVec(iDLI, olddli);
    SetIntVec(iDLI, @dli);
    nmien := $c0; // set $80 for dli only (without vbl)

(*  your code goes here *)
    _ClearScreen;
    Writeln(strings[0]);
    Writeln;
    Writeln(strings[1]);
    InitCreatures;
    PMGInit;

    repeat 
        //msx.Play;  // play here only if not played in vbl already
        ShowCreature;
        PMGDraw;        
        Pause;
    until keypressed;
            
(*  restore system interrupts *)
    SetIntVec(iVBL, oldvbl);
    SetIntVec(iDLI, olddli);
    nmien := $40; // turn off dli
    sdmctl := %00000010;  
    gractl := %00000000;  
end.
