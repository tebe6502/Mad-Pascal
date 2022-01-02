// FFFE

uses crt;

var
	a, v: word;

	b: byte;

begin
	b:=1;

	a := b shl 1;
	inc(v, a);

	a := b shl 2;
	inc(v, a);

	a := b shl 3;
	inc(v, a);

	a := b shl 4;
	inc(v, a);

	a := b shl 5;
 	inc(v, a);

	a := b shl 6;
 	inc(v, a);

	a := b shl 7;
 	inc(v, a);

	a := b shl 8;
 	inc(v, a);

	a := b shl 9;
 	inc(v, a);

	a := b shl 10;
 	inc(v, a);

	a := b shl 11;
 	inc(v, a);

	a := b shl 12;
 	inc(v, a);

	a := b shl 13;
 	inc(v, a);

	a := b shl 14;
 	inc(v, a);

	a := b shl 15;
 	inc(v, a);

	a := b shl 16;
 	inc(v, a);

	a := b shl 17;
 	inc(v, a);

	a := b shl 18;
 	inc(v, a);

	a := b shl 19;
 	inc(v, a);

	a := b shl 20;
 	inc(v, a);

	a := b shl 21;
 	inc(v, a);

	a := b shl 22;
 	inc(v, a);

	a := b shl 23;
 	inc(v, a);

	a := b shl 24;
 	inc(v, a);

	a := b shl 25;
 	inc(v, a);

	a := b shl 26;
 	inc(v, a);

	a := b shl 27;
 	inc(v, a);

	a := b shl 28;
 	inc(v, a);

	a := b shl 29;
 	inc(v, a);

	a := b shl 30;
	inc(v, a);

	a := b shl 31;
	inc(v, a);

	writeln(hexStr(v,4));
	writeln(hexStr(b,2));

repeat until keypressed;

end.