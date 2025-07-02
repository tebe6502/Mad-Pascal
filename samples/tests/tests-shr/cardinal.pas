// $F7813F92

uses crt;

var
	a, b, v: cardinal;

begin
	b:=$f7813Fa5;

	a := b shr 1;
	inc(v, a);

	a := b shr 2;
	inc(v, a);

	a := b shr 3;
	inc(v, a);

	a := b shr 4;
	inc(v, a);

	a := b shr 5;
 	inc(v, a);

	a := b shr 6;
 	inc(v, a);

	a := b shr 7;
 	inc(v, a);

	a := b shr 8;
 	inc(v, a);

	a := b shr 9;
 	inc(v, a);

	a := b shr 10;
 	inc(v, a);

	a := b shr 11;
 	inc(v, a);

	a := b shr 12;
 	inc(v, a);

	a := b shr 13;
 	inc(v, a);

	a := b shr 14;
 	inc(v, a);

	a := b shr 15;
 	inc(v, a);

	a := b shr 16;
 	inc(v, a);

	a := b shr 17;
 	inc(v, a);

	a := b shr 18;
 	inc(v, a);

	a := b shr 19;
 	inc(v, a);

	a := b shr 20;
 	inc(v, a);

	a := b shr 21;
 	inc(v, a);

	a := b shr 22;
 	inc(v, a);

	a := b shr 23;
 	inc(v, a);

	a := b shr 24;
 	inc(v, a);

	a := b shr 25;
 	inc(v, a);

	a := b shr 26;
 	inc(v, a);

	a := b shr 27;
 	inc(v, a);

	a := b shr 28;
 	inc(v, a);

	a := b shr 29;
 	inc(v, a);

	a := b shr 30;
	inc(v, a);

	a := b shr 31;
	inc(v, a);

	writeln(hexStr(v,8));

repeat until keypressed;

end.