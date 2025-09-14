// [1] compile TEST_LIB.PAS (address $4000..$7FFF) -> create files .OBX, .HEA
// [2] compile LOADLIB.PAS
// TEST_LIB is loaded to external RAM (PORTB) as resource LIBRARY -> lib0 = 0 -> BANK #1

program test;

{$r loadlib.rc}

uses crt, objects;


	function dodaj(a,b: integer): integer;  external 'TEST_LIB';


const
	lib0=0;		// PORTB BANK #1

var
	w: integer;


begin

 w := dodaj(4512,23345);

 writeln(W);
 
 repeat until keypressed;

end.