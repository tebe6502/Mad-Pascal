// 507  bytes	12

var
	i: byte;

	a: byte;
	b: word;
	c: cardinal;
	
	d: shortint;
	e: smallint;
	f: integer;
	

begin
a:=10;
b:=100;
c:=1000;

d:=10;
e:=100;
f:=1000;

	if a >= 0 then inc(i);
	if b >= 0 then inc(i);
	if c >= 0 then inc(i);

	if d >= 0 then inc(i);
	if e >= 0 then inc(i);
	if f >= 0 then inc(i);

	if a >= 7 then inc(i);
	if b >= 7 then inc(i);
	if c >= 7 then inc(i);

	if d >= 7 then inc(i);
	if e >= 7 then inc(i);
	if f >= 7 then inc(i);

	writeln(i);
	
	while true do;
end.
