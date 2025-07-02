
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

var
	tab: array [0..3] of TPrc;


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


procedure print(x, y: byte);
begin

 writeln( tab[0](x,y) );
 writeln( tab[1](x,y) );
 writeln( tab[2](x,y) );
 writeln( tab[3](x,y) );

end;


begin

 tab[0]:=@_add;
 tab[1]:=@_sub;
 tab[2]:=@_mul;
 tab[3]:=@_div;

 print(176,43);

 repeat until keypressed;

end.
