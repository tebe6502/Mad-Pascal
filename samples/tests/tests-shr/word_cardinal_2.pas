// 00093F92

uses crt;

var
	a: word;

	b, v, c: cardinal;

begin
	b:=$f7813Fa5;

	a := c or (b shr 1);
	inc(v, a);

	a := c or (b shr 2);
	inc(v, a);

	a := c or (b shr 3);
	inc(v, a);

	a := c or (b shr 4);
	inc(v, a);

	a := c or (b shr 5);
 	inc(v, a);

	a := c or (b shr 6);
 	inc(v, a);

	a := c or (b shr 7);
 	inc(v, a);

	a := c or (b shr 8);
 	inc(v, a);

	a := c or (b shr 9);
 	inc(v, a);

	a := c or (b shr 10);
 	inc(v, a);

	a := c or (b shr 11);
 	inc(v, a);

	a := c or (b shr 12);
 	inc(v, a);

	a := c or (b shr 13);
 	inc(v, a);

	a := c or (b shr 14);
 	inc(v, a);

	a := c or (b shr 15);
 	inc(v, a);

	a := c or (b shr 16);
 	inc(v, a);

	a := c or (b shr 17);
 	inc(v, a);

	a := c or (b shr 18);
 	inc(v, a);

	a := c or (b shr 19);
 	inc(v, a);

	a := c or (b shr 20);
 	inc(v, a);

	a := c or (b shr 21);
 	inc(v, a);

	a := c or (b shr 22);
 	inc(v, a);

	a := c or (b shr 23);
 	inc(v, a);

	a := c or (b shr 24);
 	inc(v, a);

	a := c or (b shr 25);
 	inc(v, a);

	a := c or (b shr 26);
 	inc(v, a);

	a := c or (b shr 27);
 	inc(v, a);

	a := c or (b shr 28);
 	inc(v, a);

	a := c or (b shr 29);
 	inc(v, a);

	a := c or (b shr 30);
	inc(v, a);

	a := c or (b shr 31);
	inc(v, a);

	writeln(hexStr(v,8));
	writeln(hexStr(b,8));

repeat until keypressed;

end.