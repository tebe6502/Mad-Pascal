unit time;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Time unit
 @version: 1.0

 @description:
*)


{

CurrentMinuteOfDay
CurrentSec100OfDay
CurrentSecondOfDay
MinuteOfDay
MinutesToTime
SecondOfDay
SecondsToTime

}

interface

	function CurrentMinuteOfDay: Word;
	function CurrentSecondOfDay: cardinal;
	function CurrentSec100OfDay: Cardinal;
	function MinuteOfDay (Hour24, Minute: Word): Word;
	function SecondOfDay (Hour24, Minute, Second: Word): cardinal;
	procedure MinutesToTime (Md: cardinal; Var Hour24, Minute: Word);
	procedure SecondsToTime (Sd: cardinal; Var Hour24, Minute, Second: Word);


implementation

uses Dos;


FUNCTION CurrentMinuteOfDay: Word;
(*
@description:
Returns the number of minutes since midnight of a current system time.

@returns: word (Range: 0 - 1439)
*)
VAR Hour, Minute, Second, Sec100: Word;
BEGIN
   GetTime(Hour, Minute, Second, Sec100);		{ Get current time }
   Result := (Hour * 60) + Minute;			{ Minute from midnight }
END;


FUNCTION CurrentSecondOfDay: cardinal;
(*
@description:
Returns the number of seconds since midnight of current system time.

@returns: cardinal (Range: 0 - 86399)
*)
VAR Hour, Minute, Second, Sec100: Word;
BEGIN
   GetTime(Hour, Minute, Second, Sec100);		{ Get current time }
   Result := (Hour * 3600) +  (Minute * 60) + Second;	{ Second from midnight }
END;


FUNCTION CurrentSec100OfDay: Cardinal;
(*
@description:
Returns the 1/100ths of a second since midnight of current system time.

@returns: cardinal (Range: 0 - 8639999)
*)
VAR Hour, Minute, Second, Sec100: Word;
BEGIN
   GetTime(Hour, Minute, Second, Sec100);		{ Get current time }
   Result := (Hour * 360000) + (Minute * 6000) + (Second*100) + Sec100; { Sec100 from midnight }
END;


FUNCTION MinuteOfDay (Hour24, Minute: Word): Word;
(*
@description:
Returns the number of minutes since midnight of a valid given time.

@returns: word (Range: 0 - 1439)
*)
BEGIN
   Result := (Hour24 * 60) + Minute;			{ Minute from midnight }
END;


FUNCTION SecondOfDay (Hour24, Minute, Second: Word): cardinal;
(*
@description:
Returns the number of seconds since midnight of a valid given time.

@returns: cardinal (Range: 0 - 86399)
*)
BEGIN
   Result := (Hour24 * 3600) + (Minute * 60) + Second;	{ Second from midnight }
END;


PROCEDURE MinutesToTime (Md: cardinal; Var Hour24, Minute: Word);
(*
@description:
Returns the time in hours and minutes of a given number of minutes.

@param: Md - minutes
@param: Hour24 - hour variable
@param: Minute - minute variable
*)
BEGIN
   Hour24 := Md DIV 60;					{ Hours of time }
   Minute := Md MOD 60;					{ Minutes of time }
END;


PROCEDURE SecondsToTime (Sd: cardinal; Var Hour24, Minute, Second: Word);
(*
@description:
Returns the time in hours, mins and secs of a given number of seconds.

@param: Sd - seconds
@param: Hour24 - hour variable
@param: Minute - minute variable
@param: Second - second variabler
*)
BEGIN
   Hour24 := Sd DIV 3600;				{ Hours of time }
   Minute := Sd MOD 3600 DIV 60;			{ Minutes of time }
   Second := Sd MOD 60;					{ Seconds of time }
END;

end.
