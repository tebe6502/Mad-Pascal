unit joystick;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Joystick memory registers (Atari XE/XL)

 @version: 1.2

 @description:

 changes: 22-08-2022
 *)


{


}

interface

const
	joy_none	= 15;
	joy_up		= 14;
	joy_down	= 13;
	joy_left	= 11;
	joy_left_up	= 10;
	joy_left_down	= 9;
	joy_right	= 7;
	joy_right_up	= 6;
	joy_right_down	= 5;

var
	[volatile] joy_1 : byte absolute $278;	// The value of joystick 0
	[volatile] joy_2 : byte absolute $279;	// The value of joystick 1

	[volatile] stick: array [0..1] of byte absolute $278;

	[volatile] stick0 : byte absolute $278;
	[volatile] stick1 : byte absolute $279;

	[volatile] strig: array [0..1] of byte absolute $284;

	[volatile] strig0 : byte absolute $284;	// Stick trigger 0
	[volatile] strig1 : byte absolute $285;	// Stick trigger 1

	[volatile] paddl: array [0..7] of byte absolute $270;

	[volatile] paddl0 : byte absolute $270;	// The value of paddle 0
	[volatile] paddl1 : byte absolute $271;	// The value of paddle 1
	[volatile] paddl2 : byte absolute $272;	// The value of paddle 2
	[volatile] paddl3 : byte absolute $273;	// The value of paddle 3
	[volatile] paddl4 : byte absolute $274;	// The value of paddle 4
	[volatile] paddl5 : byte absolute $275;	// The value of paddle 5
	[volatile] paddl6 : byte absolute $276;	// The value of paddle 6
	[volatile] paddl7 : byte absolute $277;	// The value of paddle 7

	[volatile] ptrig: array [0..7] of byte absolute $27c;

	[volatile] ptrig0 : byte absolute $27c;	// Paddle trigger 0
	[volatile] ptrig1 : byte absolute $27d;	// Paddle trigger 1
	[volatile] ptrig2 : byte absolute $27e;	// Paddle trigger 2
	[volatile] ptrig3 : byte absolute $27f;	// Paddle trigger 3
	[volatile] ptrig4 : byte absolute $280;	// Paddle trigger 4
	[volatile] ptrig5 : byte absolute $281;	// Paddle trigger 5
	[volatile] ptrig6 : byte absolute $282;	// Paddle trigger 6
	[volatile] ptrig7 : byte absolute $283;	// Paddle trigger 7

	[volatile] trig0 : byte absolute $d010;	// (R)
	[volatile] trig1 : byte absolute $d011;	// (R)

	[volatile] pot0 : byte absolute $d200;		// (R)
	[volatile] allpot : byte absolute $d208;	// (R)

	[volatile] potgo: byte absolute $d20b;	// (W) Start the POT scan sequence. You must read your POT values first and then start the scan sequence,
						// since POTGO resets the POT registers to zero. Written by the stage two VBLANK sequence.


	function paddle0: byte; assembler;	// call only on begining VBL
	function fire2: byte;			// call only on begining VBL

implementation


function paddle0: byte; assembler;
(*
@description:
*)
asm
	ldy pot0

	lda allpot
	and #1
	sne

	dta $2c		; bit*
	ldy #1
	sty Result

	sta potgo
end;


function fire2: byte;
(*
@description:
Second FIRE

<https://github.com/ascrnet/Joy2Bplus>

author:
Abel Carrasco (ascrnet)

@returns: 0		FIRE2 Button not pressed
	  $8f..$0e	FIRE2 Button pressed

example:

 pause;       //                    !!! wait for VBL
 if fire2 > 30 then fire2_pressed;  !!! then read FIRE2
*)
begin

 paddle0;

 asm
	cpy #$e4
	beq pressed

	lda exists: #$00
	ora #$02
	sta exists

	lda #0
	beq setvol
pressed
	lda exists
	and #$02
	beq next

	lda vol_b1: #$00
	bne decay
	lda #$8f
	bne setvol
decay
	cmp #$f
	bcc next
	sbc #1
setvol
	sta vol_b1
next
	lda vol_b1
	sta Result
 end;

end;

end.
