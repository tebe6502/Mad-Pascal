// sprites 12x21 px

uses sprites;

{$r soft.rc}

const
	charset = $c000;
	scrdata = $d800;

	shp0 = $b000;
	shp1 = shp0+12*64;
	shp2 = shp1+3*64;

	SprSize = 64;	// the size of a single sprite frame

	spr0: array of word = [shp0, shp0+SprSize, shp0+SprSize*2, shp0+SprSize*3, 
	                       shp0+SprSize*4, shp0+SprSize*5, shp0+SprSize*6, shp0+SprSize*7, 
			       shp0+SprSize*8, shp0+SprSize*9, shp0+SprSize*10, shp0+SprSize*11, 0];

	spr1: array of word = [shp1, shp1+SprSize, shp1+SprSize*2, 0];

	spr2: array of word =  [shp2, shp2+SprSize, shp2+SprSize*2, shp2+SprSize*3, 
	                        shp2+SprSize*4, shp2+SprSize*5, shp2+SprSize*6, shp2+SprSize*7 ,0];



procedure UserProc; assembler;
asm

; lda $d20a
; sta $d01a
 
end;


procedure moveSprites(var spr: TSprite);
begin

  inc(spr.x, spr.adx);
  if (spr.x < 4) or (spr.x > 160+8) then spr.adx:=-spr.adx;
  
  inc(spr.y, spr.ady);
  if (spr.y < 4) or (spr.y > 24*8+24) then spr.ady:=-spr.ady;

end;


begin

 Sprites.init;
 
 colbaks := 6;
 
 fillByte(color0, sizeof(color0), $0a);
 fillByte(color1, sizeof(color0), $00);
 fillByte(color2, sizeof(color0), $fe);
 fillByte(color3, sizeof(color0), $0e);
 
 sprite0.bitmaps:=@spr0;
 sprite0.x:=50;
 sprite0.y:=41;
 sprite0.adx:=1;
 sprite0.ady:=2;
 sprite0.new:=true;

 sprite1.bitmaps:=@spr1;
 sprite1.x:=9;
 sprite1.y:=141;
 sprite1.adx:=1;
 sprite1.ady:=-2;
 sprite1.new:=true;

 sprite2.bitmaps:=@spr2;
 sprite2.x:=95;
 sprite2.y:=71;
 sprite2.adx:=-1;
 sprite2.ady:=2;
 sprite2.new:=true;


 sprite3.bitmaps:=@spr2;
 sprite3.x:=10*4;
 sprite3.y:=24*8;
 sprite3.adx:=0;
 sprite3.ady:=2;
 sprite3.new:=true;

 sprite4.bitmaps:=@spr0;
 sprite4.x:=15*4;
 sprite4.y:=77;
 sprite4.adx:=0;
 sprite4.ady:=-2;
 sprite4.new:=true;

 sprite5.bitmaps:=@spr1;
 sprite5.x:=20*4;
 sprite5.y:=61;
 sprite5.adx:=1;
 sprite5.ady:=0;
 sprite5.new:=true;



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


 while true do begin
 
  pause;
 
  Sprites.update(@UserProc);
  
  moveSprites(sprite0);
  moveSprites(sprite1);
  moveSprites(sprite2);

  moveSprites(sprite3);
  moveSprites(sprite4);
  moveSprites(sprite5);

 end;
 
end.
