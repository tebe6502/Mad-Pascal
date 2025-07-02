program test;

{$r loadlib.rc}

uses crt, objects;


	procedure prc(a,b,c: integer); external;


	function dodaj(a,b: integer): integer; external 'TEST_LIB';


const
	lib0=0;

var
	w: integer;

procedure print(value: dword); keep; register;
begin

 writeln(value);

end;


{$link test_link.obx}


begin

 prc(11, 347, 321785);

 w := dodaj(4512,23345);

 writeln(W);

 repeat until keypressed;

end.