uses crt;


type
	TField = packed record
			a: byte;
			b: word;
			c: cardinal;
		end;

var
	data: TField;
	f: file;

	tb: array [0..255] of byte absolute $bc40;

begin
	assign(f, 'D:BASE.DAT'); reset(f, 1);

	blockread(f, tb, sizeof(data));

	close(f);

	move(tb, data, sizeof(data));


	writeln(data.a);
	writeln(data.b);
	writeln(data.c);

	repeat until keypressed;
end.