unit sprites;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Soft Sprites (NG Engine BUFx1, 12x21 px)
 @version: 1.3

 @description:
 $D8..$FF        memory used by the zero page
 $C000..$CFFF    charsets
 $D800..$DDFF    playfield
 $DE00..$FD7F    soft sprites engine

*)

interface

{$r sprites.rc}


const
	engine = $de00;

	PlayfieldWidth	= 48;
	PlayfieldHeight	= 32;  // 0..3   the top four rows outside the playing field
                               // 28..31 the four bottom rows outside the playing field
                               // -----------------------------------------------------
                               // 4..27  the visible playing field consists of 24 rows
                               // -----------------------------------------------------

	Charset0 = $c000;
	Charset1 = $c400;
	Charset2 = $c800;
	Charset3 = $cc00;

type

TSprite = record of hi(engine+$d00)

	x: byte;		// horizontal position x (if x=0 then 'sprite disabled')
	y: byte;		// vertical position y

	xOk: byte;		// uses the engine itself
	yOk: byte;		// uses the engine itself

	adx: byte;		// increase in the horizontal position x
	ady: byte;		// increase in vertical position y

	row: byte;		// uses the engine itself

	bitmaps: pointer;	// table of animation frame addresses (address = $0000 ends this array)

	index: byte;		// index for the BITMAPS array (uses the engine itself)
	delay: byte;		// delay counter for changing animation frames (uses the engine itself)

	new: Boolean;		// the first appearance of the Sprite frame
end;

var
	dlist: word absolute engine+$0B;		// ANTIC program adress
	dlivec: word absolute engine+$0D;		// DLI interrupt program address

	dmactls: byte absolute engine+$0F;		// DMACTL shadow
	colbaks: byte absolute engine+$10;		// COLBAK shadow

	Playfield: array [0..31, 0..47] of byte absolute engine-$600; // 32*48 = 1536 bytes ; Playfield [y,x]

	Color0: array [0..23] of byte absolute engine+$A0;
	Color1: array [0..23] of byte absolute engine+$A0+24;
	Color2: array [0..23] of byte absolute engine+$A0+24*2;
	Color3: array [0..23] of byte absolute engine+$A0+24*3;

	Sprite0: TSprite absolute engine+$D00;
	Sprite1: TSprite absolute engine+$D00+sizeof(TSprite);
	Sprite2: TSprite absolute engine+$D00+sizeof(TSprite)*2;
	Sprite3: TSprite absolute engine+$D00+sizeof(TSprite)*3;
	Sprite4: TSprite absolute engine+$D00+sizeof(TSprite)*4;
	Sprite5: TSprite absolute engine+$D00+sizeof(TSprite)*5;


procedure init; assembler;
procedure update(prc: pointer); assembler;



implementation


procedure update(prc: pointer); assembler;
asm
	stx @sp

	lda prc
	ldy prc+1
	jsr engine

	ldx @sp: #$00
end;


procedure init; assembler;
asm
	bit VCOUNT
	bmi *-3
	bit VCOUNT
	bpl *-3

	sei
	mva #0 nmien
	sta dmactl
	sta irqen

	mva #$fe portb

	txa:pha

	jsr engine+3

	pla:tax

	mva #$c0 nmien
end;


end.
