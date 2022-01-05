{
Evaluation of function arguments, from right to left

Expected result: 9, 5

}

uses crt;

var i: byte;

function ran(a: smallint): byte;
begin

 ran := i;

 inc(i, 3+a);

end;

procedure kefrens(a,b: byte);
begin

 writeln(a);
 writeln(b);

end;


begin

Kefrens(ran(5)+3, ran(3)+5);

repeat until keypressed;

end.
