program madStrap;
{ $librarypath '../blibs/'}
uses atari, crt, rmt; // b_utils;

const
{$i const.inc}
{ $r resources.rc}
{ $i types.inc}
{ $i interrupts.inc}

var
    b: byte = NONE;
    w: word;
    s: TString;

    //msx: TRMT;
    //oldvbl,oldsdli:pointer;
    //strings:array [0..0] of word absolute STRINGS_ADDRESS;

begin
    //chbas := Hi(CHARSET_ADDRESS); // set custom charset
    //savmsc := VIDEO_RAM_ADDRESS;  // set custom video address

(*  initialize RMT player  *)
    //msx.player := pointer(RMT_PLAYER_ADDRESS);
    //msx.modul := pointer(RMT_MODULE_ADDRESS);
    //msx.Init(0);

(*  set custom display list  *)
    //Pause;
    //SDLSTL := DISPLAY_LIST_ADDRESS;

(*  set and run vbl interrupt *)
    //GetIntVec(iVBL, oldvbl);
    //SetIntVec(iVBL, @vbl);
    //nmien := $40;

(*  set and run display list interrupts *)
    //GetIntVec(iDLI, oldsdli);
    //SetIntVec(iDLI, @dli);
    //nmien := $c0; // set $80 for dli only (without vbl)
    
(*  your code goes here *)
    //Writeln(NullTermToString(strings[0]));
    //Writeln(NullTermToString(strings[1]));
        
    
    ReadKey;

        
(*  restore system interrupts *)
    //SetIntVec(iVBL, @oldvbl);
    //SetIntVec(iDLI, oldsdli);
    //nmien := $40; // turn off dli

end.
