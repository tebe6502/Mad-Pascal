
uses crt;

var	col: byte = 20;
	row: byte = 15;
	i: byte = 1;
	j: byte;


begin
	clrscr;

	while i <= row do begin

		gotoxy(col - i, i);

		write('*');

		j:=1;
		while j <= byte(i*2-2) do begin

			write('*');

			inc(j);
		end;

		inc(i);
	end;


 repeat until keypressed;

end.

