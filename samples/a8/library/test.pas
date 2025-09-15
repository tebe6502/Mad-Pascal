// [1] compile TEST_LIB (create file .OBX, .HEA)
// [2] compile TEST.PAS -> TEST_LIB.OBX is loaded into RAM from disk (XIO)

program test;

uses crt, cio;

	function dodaj(a,b: integer): integer; external 'TEST_LIB';

var
	w: integer external tmp 'test_lib';

begin

 xio(40,1,0,0,'D:TEST_LIB.OBX');

// IOResult = 1 -> success

 w := dodaj(4512,23345);

 writeln(w);

 repeat until keypressed;

end.