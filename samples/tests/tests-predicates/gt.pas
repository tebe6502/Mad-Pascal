// 708 bytes	9

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

	if a > 0 then inc(i);
	if b > 0 then inc(i);
	if c > 0 then inc(i);

	if d > 0 then inc(i);
	if e > 0 then inc(i);
	if f > 0 then inc(i);


	if a > 7 then inc(i);

	if b > $12 then inc(i);
	if b > $1234 then inc(i);
	
	if c > $11 then inc(i);
	if c > $1122 then inc(i);
	if c > $112233 then inc(i);
	if c > $11223344 then inc(i);

	if d > 17 then inc(i);
	if e > 1117 then inc(i);
	if f > 11117 then inc(i);

	if a > High(byte) then inc(i);
	if b > High(word) then inc(i);
	if c > High(cardinal) then inc(i);

	if d > High(shortint) then inc(i);
	if e > High(smallint) then inc(i);
	if f > High(integer) then inc(i);

	writeln(i);
	
	while true do;
end.
