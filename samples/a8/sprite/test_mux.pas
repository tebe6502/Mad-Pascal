uses crt, shanti;

(*

SHANTI - memory layout

$c000..$c2ff	- multiplexer arrays
$c300..$c7ff	- PM graphics
$c800..$cf7f	- video ram address
$cf80..$cfff	- display list

$d800..$dfff	- charsets

*)

{$r test_mux.rc}

	procedure monster(a: byte); external;
	procedure face(a: byte); external;
	procedure thing(a: byte); external;


const

DISPLAY_LIST_ADDRESS	= $CF80;

VIDEO_RAM_ADDRESS	= $c800;

CHARSET_RAM_ADDRESS	= $d800;

var
	ad: array [0..3] of byte;

	spd_face, spd_thing: byte;

	scr0: array [0..127] of byte absolute $0600;
	scr1: array [0..127] of byte absolute $0680;



procedure vbl; interrupt; assembler;
asm
// user program code

 plr
end;


procedure initEngine;
var p: pointer;
begin

 doInitEngine(@vbl, DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 24);		// disable OS, PORTB = $FE

 doInitCharsets(CHARSET_RAM_ADDRESS);

 fillchar(pointer(VIDEO_RAM_ADDRESS), $500, 0);

 GetResourceHandle(p, 'fnt0');
 move(p, pointer(CHARSET_RAM_ADDRESS), 1024);

 GetResourceHandle(p, 'fnt1');
 move(p, pointer(CHARSET_RAM_ADDRESS+1024), 1024);

 HPalette[pal_color0] := $e2;
 HPalette[pal_color1] := $16;
 HPalette[pal_color2] := $08;

end;


procedure doLevel;
var p: PByte register;
    v: PByte register;
    a, i, j: byte;
begin

 GetResourceHandle(p, 'lvl0');

 v:=pointer(VIDEO_RAM_ADDRESS);

 for j:=0 to 7 do begin

  for i:=0 to 15 do begin

   a:=p[0];

   if a <> $ff then begin

    a:=(a) shl 1;

    v[0]:=scr0[a];
    v[1]:=scr0[a+1];

    v[32]:=scr1[a];
    v[33]:=scr1[a+1];

   end;

   inc(v, 2);
   inc(p);
 end;

 inc(v, 32);

 end;

end;


{$link assets\monster.obx}
{$link assets\face.obx}
{$link assets\thing.obx}


procedure addShapes;
begin

 monster(0);		// monster	->	shapes 0..7	8 frames
 face(8);		// face		->	shapes 8..20	13 frames
 thing(8+13);		// thing	->	shapes 21..23	3 frames

end;


procedure addSprite(num, col0, col1, shp, x, y, spd, cnt: byte); assembler;
asm
	ldy num

	mva col0	shanti.adr.spr_0,y
	mva col1	shanti.adr.spr_1,y
	mva shp		shanti.adr.spr_s,y
	mva x		shanti.adr.spr_x,y
	mva y		shanti.adr.spr_y,y
	mva spd		shanti.adr.spr_v,y	; anim speed
	mva cnt		shanti.adr.spr_a,y	; 'number of frames' -1, -2, -4, -8, -16

end;



begin

 initEngine;

 doLevel;

 addShapes;					// all shapes

 addSprite(0, $54,$a, 0, 100, 34, 3, -8);		// sprite #0
 addSprite(1, $14,$7a, 8+13, 100, 74, 3, -1);		// sprite #1
 addSprite(2, $c4,$3a, 8, 70, 100 , 3, -1);		// sprite #2

 ad[0]:=2;
 ad[1]:=1;
 ad[2]:=2;
 ad[3]:=1;

 while true do begin

 pause;

   asm
	txa:pha

  	jsr shanti.multi.show_sprites
	jsr shanti.multi.animuj

	pla:tax
   end;

 spr_y[0] := spr_y[0] + ad[0]; if (spr_y[0] > 100) or (spr_y[0] < 20) then ad[0]:=-ad[0];

 spr_x[1] := spr_x[1] + ad[1]; if (spr_x[1] > 200) or (spr_x[1] < 60) then ad[1]:=-ad[1];

 spr_y[2] := spr_y[2] + ad[2]; if (spr_y[2] > 140) or (spr_y[2] < 20) then ad[2]:=-ad[2];


 inc(spd_thing, 16);
 if spd_thing = 0 then begin
  inc(spr_s[1]); if spr_s[1] = 8+13+3 then spr_s[1] := 8+13;
 end;


 inc(spd_face, 64);
 if spd_face = 0 then begin
  inc(spr_s[2]); if spr_s[2] = 8+13 then spr_s[2] := 8;
 end;

 end;

end.

