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


const

DISPLAY_LIST_ADDRESS	= $CF80;

VIDEO_RAM_ADDRESS	= $c800;

CHARSET_RAM_ADDRESS	= $d800;

var
	ad: array [0..3] of byte;



procedure vbl; interrupt; assembler;
asm
// own code


 plr
end;


procedure initEngine;
var p: pointer;
begin

 doInitEngine(@vbl, DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 24);		// disable OS, PORTB = $FE

 doInitCharsets(CHARSET_RAM_ADDRESS);

 fillchar(pointer(VIDEO_RAM_ADDRESS), $500, 0);

 GetResourceHandle(p, 'chr0');
 move(p, pointer(CHARSET_RAM_ADDRESS), 1024);

 GetResourceHandle(p, 'chr1');
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

   if a<>$ff then begin

    a:=a shl 1;

    v[0]:=a;
    v[1]:=a+1;

    v[32]:=a;
    v[33]:=a+1;

   end;

   inc(v, 2);
   inc(p);
 end;

 inc(v, 32);

 end;

end;


{$link assets\font0.obx}


procedure addShapes; assembler;
asm
 mwa #shp0._01 shanti.shape_tab01
 mwa #shp0._23 shanti.shape_tab23

 mwa #shp1._01 shanti.shape_tab01+2
 mwa #shp1._23 shanti.shape_tab23+2

 mwa #shp2._01 shanti.shape_tab01+4
 mwa #shp2._23 shanti.shape_tab23+4

 mwa #shp3._01 shanti.shape_tab01+6
 mwa #shp3._23 shanti.shape_tab23+6

end;


procedure addSprite(num, col0, col1, shp, x, y, spd: byte); assembler;
asm
	ldy num

	mva col0	shanti.adr.spr_0,y
	mva col1	shanti.adr.spr_1,y
	mva shp		shanti.adr.spr_s,y
	mva x		shanti.adr.spr_x,y
	mva y		shanti.adr.spr_y,y
	mva spd		shanti.adr.spr_v,y	; anim speed
	mva #$fc	shanti.adr.spr_a,y	; 'number of frames' xor $ff (default = $ff -> 1 frame)

end;



begin

 initEngine;

 doLevel;

 addShapes;					// all shapes

 addSprite(0, $54,$a, 0, 100, 34, 15);		// sprite #0
 addSprite(1, $14,$7a, 0, 100, 74, 15);		// sprite #1
 addSprite(2, $c4,$3a, 0, 70, 100 , 15);	// sprite #2

 ad[0]:=1;
 ad[1]:=1;
 ad[2]:=1;
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

 end;

end.

