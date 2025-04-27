program madStrap;
{$librarypath '../blibs/'}
uses atari, crt, rmt, aplib, b_system, b_utils;

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
    strings:array [0..0] of word absolute STRINGS_ADDRESS;
    //mul_40: array of word = [ {$EVAL 110,":1*40"} ];

{$i interrupts.inc}

{$define _KeyPressed := ((skstat and 4) = 0) }
{$define _ReadKey := kbcode }
{$define _ClearScreen := FillByte(pointer(VIDEO_RAM_ADDRESS),40*32,0) }

begin
    //Move(pointer($e000),CHARSET_ADDRESS ,1024); // optional: backup system charset to custom charset
    SystemOff;
    SetCharset(Hi(CHARSET_ADDRESS)); // set custom charset

(*  initialize RMT player  *)
    msx.player := pointer(RMT_PLAYER_ADDRESS);
    msx.modul := pointer(RMT_MODULE_ADDRESS);
    msx.Init(0);

(*  set custom display list  *)
    SDLSTL := DISPLAY_LIST_ADDRESS;

(*  set and run vbl interrupt *)
    EnableVBLI(@vbl_nos);

(*  set and run display list interrupts *)
    EnableDLI(@dli);

(*  your code goes here *)
    _ClearScreen;
    move(pointer(strings[2]+1),pointer(VIDEO_RAM_ADDRESS+2),peek(strings[2]));
    move(pointer(strings[3]+1),pointer(VIDEO_RAM_ADDRESS+82),peek(strings[3]));
    InitCreatures;
    PMGInit;

    repeat 
        //msx.Play; // play here only if not played in vbl already
        ShowCreature;
        PMGDraw;
        WaitFrame;
    until _KeyPressed;
    
    SystemReset;
end.
