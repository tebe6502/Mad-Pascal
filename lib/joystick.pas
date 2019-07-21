unit joystick;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Joystick memory registers (Atari XE/XL)

 @version: 1.1

 @description:
 *)


{


}

interface

var
	joy_1 : byte absolute $278;	// The value of joystick 0
	joy_2 : byte absolute $279;	// The value of joystick 1

	stick: array [0..1] of byte absolute $278;

	stick0 : byte absolute $278;
	stick1 : byte absolute $279;

	strig: array [0..1] of byte absolute $284;

	strig0 : byte absolute $284;	// Stick trigger 0
	strig1 : byte absolute $285;	// Stick trigger 1

	paddl: array [0..7] of byte absolute $270;

	paddl0 : byte absolute $270;	// The value of paddle 0
	paddl1 : byte absolute $271;	// The value of paddle 1
	paddl2 : byte absolute $272;	// The value of paddle 2
	paddl3 : byte absolute $273;	// The value of paddle 3
	paddl4 : byte absolute $274;	// The value of paddle 4
	paddl5 : byte absolute $275;	// The value of paddle 5
	paddl6 : byte absolute $276;	// The value of paddle 6
	paddl7 : byte absolute $277;	// The value of paddle 7

	ptrig: array [0..7] of byte absolute $27c;

	ptrig0 : byte absolute $27c;	// Paddle trigger 0
	ptrig1 : byte absolute $27d;	// Paddle trigger 1
	ptrig2 : byte absolute $27e;	// Paddle trigger 2
	ptrig3 : byte absolute $27f;	// Paddle trigger 3
	ptrig4 : byte absolute $280;	// Paddle trigger 4
	ptrig5 : byte absolute $281;	// Paddle trigger 5
	ptrig6 : byte absolute $282;	// Paddle trigger 6
	ptrig7 : byte absolute $283;	// Paddle trigger 7

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

implementation



end.

