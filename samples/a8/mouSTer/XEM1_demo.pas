program XEM1_demo;

{$librarypath 'blibs'}

uses atari, crt, pokey, b_pmg;

{
;
; *** NEW MODE ***
;  XEM1 - XE Mouse 1
; It is just an analog mouse mode for Atari 8bit, Including all 3 buttons and wheel.
; 
;
; ****************************************  ****************************************
; * Port 1                               *  * Port 2                               *
; * POT0  - X relative coordinate change *  * POT2  - X relative coordinate change *
; * POT1  - Y relative coordinate change *  * POT3  - Y relative coordinate change *
; * TRIG0 - LMB state                    *  * TRIG1 - LMB state                    *
; * PORTA - bit:  3  |  2  |  1  |  0    *  * PORTA - bit:  7  |  6  |  5  |  4    *
; *              MMB | RMB | WH1 | WH0   *  *              MMB | RMB | WH1 | WH0   *
; ****************************************  ****************************************
;  
; LMB - Left Mouse Button   - 0 pressed
; MMB - Middle Mouse Button - 0 pressed
; RMB - Right Mouse Button  - 0 pressed
; WH0 and WH1 are wheel encoder signals. This is well known, simple quadrature encoder. 
; These 2 signals change state no more often than every 50 miliseconds (20 times per sec)
; sampling once per VBL is enough. 
; The relative coordinate may be a number from -64 to +63 , or 64 to 192 with the offset of 128
; The lowest bit should be considered noise and shifted out. (see example)
; position check once per VBL is more than enough. Every 2nd VBL should also be OK. 
;
}

//Settings
{$define port1} 		//use mouse in joy port #1
{$define useShadows} 	//use pot shadows and do not write to potgo.
{$define debug}			//print some debug info
{$define useAsmMovement}

type

  Tgadget = record
	x:byte;
	y:byte;
	lasty:byte;
	offset:word;
end;

const
PMGBASE 		= $3000;
cursor_offset	= $200;
cursor_height	= $08;

cursor_minX		= 44;
cursor_maxX		= 208;

cursor_minY		= 15;
cursor_maxY		= 115;

slider_offset	= $280;
slider_height	= $10;

slider_xpos		= 200;
slider_minY		= 16;
slider_maxY		= 96;
 
{$ifdef port1} 
	wheelMask	= %00000011;
	wheelDirMsk	= %00000001;
	rmbMask		= %00000100;
	mmbMask		= %00001000;
{$else}
	{$ifdef port2}
	wheelMask	= %00110000;
	wheelDirMsk	= %00010000;
	rmbMask		= %01000000;
	mmbMask		= %10000000;
	{$else}
		{$error You must define PORT1 or PORT2!} //as for today, $error is not working, but drop syntax error. So, good enough.
	{$endif}
{$endif}

 
cursor_data: array [0..cursor_height-1] of byte = (
 
 %00100000,
 %00110000,
 %00111000,
 %00111100,
 %00111110,
 %00110000,
 %00100000,
 %00000000
);

slider_data: array [0..slider_height-1] of byte = (

 %00111100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00100100,
 %00111100
);

var
{$ifdef port1} 
	{$ifdef useShadows}
		potx: byte absolute $0270;   
		poty: byte absolute $0271;
		lmb : byte absolute $0284;
	{$else}
		potx: byte absolute $d200;   //have no ide how to assign to pot0 value defined in pokey unit.
		poty: byte absolute $d201;
		lmb : byte absolute $d010;
	{$endif}
{$else}
	{$ifdef port2}
	{$ifdef useShadows}
		potx: byte absolute $0272;   
		poty: byte absolute $0273;
		lmb : byte absolute $0285;
	{$else}
		potx: byte absolute $d202;   //have no ide how to assign to pot0 value defined in pokey unit.
		poty: byte absolute $d203;
		lmb : byte absolute $d011;
	{$endif}
	{$else}
		{$error You must define PORT1 or PORT2!} //as for today, $error is not working, but drop syntax error. So, good enough.
	{$endif}
{$endif}

	cursor: Tgadget;
	slider: Tgadget;
	oldVBL: pointer;
	mmb:	byte;
	rmb:	byte;
	tmp:	byte;
	
{$ifdef debug}	
	debugpx:	byte;
	debugpy:	byte;
	debugWheel:	byte;
	debugWheelDelta:	byte;
{$endif}


	
procedure vbl; interrupt; assembler;

{$I vbl.asm}

//main 

begin
	
	cursor.x := 80;
	cursor.y := 20;
	cursor.lasty :=0;
	cursor.offset := cursor_offset;


	slider.x := 202;
	slider.y := (slider_minY+slider_maxY) div 2;
	slider.lasty :=0;
	slider.offset := slider_offset;



	
	PMG_Init (Hi(PMGBASE));
	PMG_Clear;

	PMG_pcolr0_S := 15;
	PMG_pcolr1_S := 15;
	
	
	color0:=15;
	PMG_hpos0:=cursor.x;
	PMG_hpos1:=slider.x;


{$ifdef useShadows}
	GetIntVec(iVBL, oldVBL);
	SetIntVec(iVBL, @vbl);
{$else}
	GetIntVec(iVBLI, oldVBL);
	SetIntVec(iVBLI, @vbl);
{$endif}

	ClrScr;
	CursorOff;
	gotoxy  (12,6);
	writeln ('XE Mouse ONE (XEM1)');
	gotoxy	(17,8);
	writeln('Tech Demo');
	
	repeat
{$ifdef debug}	
		gotoxy	(10,22);
		write 	('px: ', debugpx, '  ');	//potx
		gotoxy	(20,22);
		write	('py: ', debugpy,'  ');		//poty
		gotoxy 	(10,23);
		write  	('ws: ', debugWheel); 		//wheel state
		gotoxy 	(20,23);
		write	('wd: ', debugWheelDelta, '  ');	//wheel Delta
{$endif}
		gotoxy	(10,20);
		write 	('cx: ', cursor.x, '  ');
		gotoxy	(20,20);
		write	('cy: ', cursor.y,'  ');
		gotoxy 	(10,19);
		write	('slider: ', slider.y ,'  '); 

		//get mmb and rmb		
		asm
				lda portA
				and #mmbMask
				beq @+
				lda #$01
			@:	sta mmb
		
				lda portA
				and #rmbMask
				beq @+
				lda #$01
			@:	sta rmb
		end;
		
		gotoxy (10,18);
		write  ('LMB: ', lmb);
		gotoxy (20,18);
		write  ('MMB: ', mmb);
		gotoxy (30,18);
		write  ('RMB: ', rmb);

{$ifndef useAsmMovement}
		//move cursor
		if (cursor.y <> cursor.lasty) then
			begin
				tmp := cursor.y; //interrupt warning!!
				FillChar(pointer(PMGBASE+cursor.offset+cursor.lasty), cursor_height, 0);
				move (@cursor_data, pointer(PMGBASE+cursor.offset+tmp), cursor_height);
				cursor.lasty := tmp;	
			end;
			
		//move slider
		if (slider.y <> slider.lasty) then
			begin
				tmp := slider.y; //interrupt warning!!
				FillChar(pointer(PMGBASE+slider.offset+slider.lasty), slider_height, 0);
				move (@slider_data, pointer(PMGBASE+slider.offset+tmp), slider_height);
				slider.lasty := tmp;	
			end;
{$endif}
	until keypressed;

{$ifdef useShadows}	
	SetIntVec(iVBL, oldVBL);
{$else}
	SetIntVec(iVBLI, oldVBL);
{$endif}	

end.
