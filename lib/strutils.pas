unit strutils;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Various string handling routines
 @version: 1.1

 @description:
 https://www.freepascal.org/docs-html/rtl/strutils/index-5.html
*)


{

AddChar
AddCharR
PadLeft
PadRight

}

interface

	function AddChar(C: Char; var S: string; N: Byte): ^string;
	function AddCharR(C: Char; var S: string; N: Byte): ^string;
	function PadLeft(var S: string; N: Byte): ^string;
	function PadRight(var S: string; N: Byte): ^string;

implementation


function AddChar(C: Char; var S: string; N: Byte): ^string;
(*
@description:
AddChar adds characters (C) to the left of S till the length N is reached, and returns the resulting string.
If the length of S is already equal to or larger than N, then no characters are added.
The resulting string can be thought of as a right-aligned version of S, with length N.

@param: C - Char to be added
@param: S - The string to be treated
@param: N - The minimal length the string should have

@result: Pointer to string with length N
*)
begin

 Result^ := S;

 while length(Result^) < N do Result^ := Concat(C, Result^);

end;


function AddCharR(C: Char; var S: string; N: Byte): ^string;
(*
@description:
AddCharR adds characters (C) to the right of S till the length N is reached, and returns the resulting string.
If the length of S is already equal to or larger than N, then no characters are added.
The resulting string can be thought of as a left-aligned version of S, with length N .

@param: C - Char to be added
@param: S - The string to be treated
@param: N - The minimal length the string should have

@result: Pointer to string with length N
*)
begin

 Result^ := S;

 while length(Result^) < N do Result^ := Concat(Result, C);

end;


function PadLeft(var S: string; N: Byte): ^string;
(*
@description: Add spaces to the left of a string till a certain length is reached.

@param: S - String to pad
@param: N - Minimal length of the resulting string.

@result: Pointer to string with length N
*)
begin

 Result^ := S;

 while length(Result^) < N do Result^ := Concat(' ', Result);

end;


function PadRight(var S: string; N: Byte): ^string;
(*
@description: Add spaces to the right of a string till a certain length is reached.

@param: S - String to pad
@param: N - Minimal length of the resulting string.

@result: Pointer to string with length N
*)
begin

 Result^ := S;

 while length(Result^) < N do Result^ := Concat(Result, ' ');

end;

end.

