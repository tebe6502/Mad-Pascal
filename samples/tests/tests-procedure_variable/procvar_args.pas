
{
  Expected result:

 1
 3
 24

}

uses crt;

type
	TPrc = function (a, b: byte): word;


var
	p: TPrc;
	i: byte;


function test(a,b,c,d: integer): word; StdCall;
begin

 writeln(a);

 Result := a shl 3;

end;


begin

 p:=@test;

 i := p(1, 3);

 writeln( p(3,5) );

 repeat until keypressed;

end.

