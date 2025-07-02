// 508

var
	x,y: shortint;

	a,b,c,d: boolean;

begin

	x:=-1;
	y:=-1;

	if x < y then writeln(TRUE) else writeln(FALSE);
	if x > y then writeln(TRUE) else writeln(FALSE);
	if x >= y then writeln(TRUE) else writeln(FALSE);
	if x <= y then writeln(TRUE) else writeln(FALSE);

	writeln;

	a:= x < y ;
	b:= x > y ;
	c:= x >= y ;
	d:= x <= y ;

	writeln(a);
	writeln(b);
	writeln(c);
	writeln(d);

	while true do;
end.
