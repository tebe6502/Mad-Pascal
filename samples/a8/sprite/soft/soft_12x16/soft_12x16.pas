// sprites 12x16 px

uses atari, sprites12x16, joystick;

{$r soft_12x16.rc}

const
	charset = $c000;
	scrdata = $d800;
	
	delay_value = 6;

	SprSize = 64;

	shp0 = $b000;
	shp1 = shp0 + SprSize*2;
	shp2 = shp1 + SprSize*2;
	shp3 = shp2 + SprSize*2;

	shp4 = shp3 + SprSize*2;

	shp5 = shp4 + SprSize*2;
	shp6 = shp5 + SprSize*2;
	shp7 = shp6 + SprSize*2;
	shp8 = shp7 + SprSize*2;

	spr0: array of word = [shp0, 0, shp0+SprSize, 0];
	spr1: array of word = [shp1, 0, shp1+SprSize, 0];
	spr2: array of word = [shp2, 0, shp2+SprSize, 0];
	spr3: array of word = [shp3, 0, shp3+SprSize, 0];

	spr_stand: array of word = [shp4, 0, shp4+SprSize, 0];

	spr0_l: array of word = [shp5, 0, shp5+SprSize, 0];
	spr1_l: array of word = [shp6, 0, shp6+SprSize, 0];
	spr2_l: array of word = [shp7, 0, shp7+SprSize, 0];
	spr3_l: array of word = [shp8, 0, shp8+SprSize, 0];


	walk_r: array [0..3] of pointer = (@spr0, @spr1, @spr2, @spr3);
	walk_l: array [0..3] of pointer = (@spr0_l, @spr1_l, @spr2_l, @spr3_l);


var
	frm: byte;
	tim: byte;

        joy: byte;
	joydelay: byte;
        fireBtn: Boolean;

	walk: array [0..0] of pointer;


procedure UserProc; assembler;
asm

; lda $d20a
; sta $d01a
 
end;




Procedure JoyScan;
var onKey: byte = $80;
    a: byte;

BEGIN
	fireBtn:= Boolean(trig0);

	a:=porta and $0f;
	
	
	if a = joy then begin

	  if joyDelay >= 1 then begin dec(joyDelay) ; exit end;

	  joy:=$ff;

	end else begin
	  joyDelay:=delay_value;
	  joy:=a;
	  
	end;

//        case a of
//	     joy_left: ;
//	    joy_right: ;
  //      end;
end;







procedure moveSprite;
begin

  inc(tim);

  
//  if tim and 3 = 0 then begin


   if tim and 7 = 0 then begin

   frm:=(frm + 1) and 3;
   
   sprite0.bitmaps:=walk[frm];
   
   sprite1.bitmaps:=sprite0.bitmaps+4;
   
   end; 
  

//   if tim and 3 = 0 then begin
    
    inc(sprite0.x, sprite0.adx);
    if (sprite0.x < 4) or (sprite0.x > 160+8) then sprite0.adx:=-sprite0.adx;

//   end; 
  
//  inc(sprite0.y, sprite0.ady);
//  if (sprite0.y < 4) or (sprite0.y > 24*8+24) then sprite0.ady:=-sprite0.ady;
  
  sprite1.x := sprite0.x;
  
  sprite1.y := sprite0.y+16;

//  end;

end;



procedure stand;
begin
 sprite0.bitmaps:=@spr_stand;
 sprite1.bitmaps:=@spr_stand[2];
end;




begin

 sprites12x16.init;
 
 colbaks := $00;
 
 fillByte(color0, sizeof(color0), $04);
 fillByte(color1, sizeof(color0), $08);
 fillByte(color2, sizeof(color0), $0c);
 fillByte(color3, sizeof(color0), $0e);
 
 sprite0.bitmaps:=@spr0;
 sprite0.x:=160;
 sprite0.y:=174;
 sprite0.adx:=-1;
 sprite0.ady:=2;
 sprite0.new:=true;

 sprite1.bitmaps:=@spr0[2];
 sprite1.x:=sprite0.x;
 sprite1.y:=sprite0.y+16;
 sprite1.new:=true;

{
 sprite2.bitmaps:=@spr0[4];
 sprite2.new:=true;

 sprite3.bitmaps:=@spr0[6];
 sprite3.new:=true;
 }
 
 
{
 color0[21]:=$12;	// change the colors of the last three rows of the playing field
 color0[22]:=$14;
 color0[23]:=$16;

 color1[3]:=$e2;	// color changes to the platforms
 color2[3]:=$98;

 color1[7]:=$e2;
 color2[7]:=$98;

 color1[11]:=$e2;
 color2[11]:=$98;

 color1[13]:=$e2;
 color2[13]:=$98;

 color1[15]:=$e2;
 color2[15]:=$98;
 
 
 Playfield[4, 4]:=$d;	// y=4 ; x=4	upper-left corner of the playing field
 
 Playfield[4, 43]:=$d;	// y=4 ; x=43	top-right corner of the playing field

 Playfield[27, 4]:=$d;	// y=27 ; x=4	lower-left corner of the playing field

 Playfield[27, 43]:=$d;	// y=27 ; x=43	lower-right corner of the playing field
}


 while true do begin
 
  pause;
 
  sprites12x16.update(@UserProc);

  joyscan;
  
  case joy of
   joy_right: begin walk:=@walk_r; sprite0.adx:=1; moveSprite end;
    joy_left: begin walk:=@walk_l; sprite0.adx:=-1; moveSprite end;
    
    joy_none: begin frm:=0; joy:=$ff; stand end;
  end;    


 end;
 
 
end.
