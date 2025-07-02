
{
  Expected result:

219
133
7568
4

}

uses crt;

type
	TPrc = function (a,b: byte): word;


function _add(a,b: byte): word; StdCall;
begin

 Result := a + b;

end;


function _sub(a,b: byte): word; StdCall;
begin

 Result := a - b;

end;


function _mul(a,b: byte): word; StdCall;
begin

 Result := a * b;

end;


function _div(a,b: byte): word; StdCall;
begin

 Result := a div b;

end;


procedure print(p: TPrc);
var x,y: byte;
begin

 x:=176;
 y:=43;

 writeln( p(x,y) );

end;


begin

 print(@_add);
 print(@_sub);
 print(@_mul);
 print(@_div);


 repeat until keypressed;

end.

