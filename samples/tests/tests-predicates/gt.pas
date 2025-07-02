// 711 bytes	9

var
	i: cardinal;

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

	if a > 0 then inc(i, 1);
	if b > 0 then inc(i, 2);
	if c > 0 then inc(i, 4);

	if d > 0 then inc(i, 8);
	if e > 0 then inc(i, 16);
	if f > 0 then inc(i, 32);


	if a > 7 then inc(i, 64);

	if b > $12 then inc(i, 128);
	if b > $1234 then inc(i, 256);

	if c > $11 then inc(i, 512);
	if c > $1122 then inc(i, 1024);
	if c > $112233 then inc(i, 2048);
	if c > $11223344 then inc(i, 4096);

	if d > 17 then inc(i, 8192);
	if e > 1117 then inc(i, 16384);
	if f > 11117 then inc(i, 32768);

	if a > High(byte) then inc(i, 65536);
	if b > High(word) then inc(i, 131072);
	if c > High(cardinal) then inc(i, 262144);

	if d > High(shortint) then inc(i, 524288);
	if e > High(smallint) then inc(i, 1048576);
	if f > High(integer) then inc(i, 2097152);

	writeln(i);

	while true do;
end.
