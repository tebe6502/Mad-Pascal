unit shanti;
(*
 @type: unit
 @author: Janusz Chabowski (Shanti77), Tomasz Biela (Tebe)
 @name: Shanti Sprites Multiplexer
 @version: 1.0

 @description:
 <http://www.atari.org.pl/forum/viewtopic.php?id=17775>
*)


{

doInitEngine
doInitCharsets

}


interface

var
	spr_x: array [0..15] of byte external sprite_x;
	spr_y: array [0..15] of byte external sprite_y;
	spr_s: array [0..15] of byte external sprite_shape;
	spr_0: array [0..15] of byte external sprite_c0;
	spr_1: array [0..15] of byte external sprite_c1;
	spr_a: array [0..15] of byte external sprite_anim;
	spr_v: array [0..15] of byte external sprite_anim_speed;

	chrts: array [0..29] of byte external charsets;


procedure doInitEngine(vbl: pointer; DListAddress: word; VRamAddress: word; lines: byte);
(*
@description:
*)
procedure doInitCharsets(a: word);
(*
@description:
*)


implementation

uses atari;

{$codealign link = $100}

{$link shanti\engine.obx}

{$codealign link = 0}



procedure doInitCharsets(a: word);
var i: byte;
begin

 for i:=0 to High(chrts) do begin
  chrts[i] := hi(a);

  a:=a xor $0400;
 end;

end;



procedure doInitEngine(vbl: pointer; DListAddress: word; VRamAddress: word; lines: byte);
var dList: ^byte register;


procedure DLPoke(b: byte);
begin
    dList[0] := b;
    Inc(dList);
end;

procedure DLPokeW(w: word);
begin
    dList[0] := Lo(w);
    dList[1] := Hi(w);
    Inc(dList, 2);
end;


procedure BuildDisplayList;

const
    DL_BLANK8 = %01110000; // 8 blank lines
    DL_DLI = %10000000; // Order to run DLI
    DL_LMS = %01000000; // Order to set new memory address
    DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
    DL_MODE_320x192G2 = $F;
    DL_JVB = %01000001; // Jump to begining

begin
    dList := pointer(DListAddress);

    DLPoke(DL_BLANK8 + DL_DLI);

    DLPoke($40+$04+$80);
    DLPokeW(VRamAddress);

    while (lines > 1) do begin
        DLPoke($84);
        dec(lines);
    end;

    DLPoke(DL_JVB);
    DLPokeW(DListAddress);
end;


begin
    asm
	txa:pha

	multi.init_engine vbl

	pla:tax
    end;

    BuildDisplayList;

    SDLSTL := DListAddress;

    sdmctl := ord(TDMACtl(narrow + missiles + players + oneline + enable));

    savmsc := VRamAddress;

    nmien := $c0;
end;


end.
