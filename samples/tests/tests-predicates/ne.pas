// 720 bytes	12

var
	i: byte;

	a,a_: byte;
	b,b_: word;
	c,c_: cardinal;
	
	d,d_: shortint;
	e,e_: smallint;
	f,f_: integer;
	

begin
a:=10;
b:=100;
c:=1000;

d:=10;
e:=100;
f:=1000;

a_:=10;
b_:=100;
c_:=1000;

d_:=10;
e_:=100;
f_:=1000;

	if a <> 0 then inc(i);
	if b <> 0 then inc(i);
	if c <> 0 then inc(i);

	if d <> 0 then inc(i);
	if e <> 0 then inc(i);
	if f <> 0 then inc(i);


	if a <> 7 then inc(i);
	if b <> 7 then inc(i);
	if c <> 7 then inc(i);

	if d <> 7 then inc(i);
	if e <> 7 then inc(i);
	if f <> 7 then inc(i);

	if a <> a_ then inc(i);
	if b <> b_ then inc(i);
	if c <> c_ then inc(i);
	
	if d <> d_ then inc(i);
	if e <> e_ then inc(i);
	if f <> f_ then inc(i);

	writeln(i);
	
	while true do;
end.
