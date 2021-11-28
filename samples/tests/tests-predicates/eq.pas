// 720 bytes	6

var
	i: cardinal;

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

	if a = 0 then inc(i);
	if b = 0 then inc(i, 2);
	if c = 0 then inc(i, 4);

	if d = 0 then inc(i, 8);
	if e = 0 then inc(i, 16);
	if f = 0 then inc(i, 32);


	if a = 7 then inc(i, 64);
	if b = 7 then inc(i, 128);
	if c = 7 then inc(i, 256);

	if d = 7 then inc(i, 512);
	if e = 7 then inc(i, 1024);
	if f = 7 then inc(i, 2048);

	if a = a_ then inc(i, 4096);
	if b = b_ then inc(i, 8192);
	if c = c_ then inc(i, 16384);

	if d = d_ then inc(i, 32768);
	if e = e_ then inc(i, 65536);
	if f = f_ then inc(i, 131072);

	writeln(i);

	while true do;
end.
