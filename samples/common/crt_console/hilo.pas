program hilo;

var
	playing : Boolean;


procedure getname;
	var
		name : string[32];

	begin
		writeln;
		writeln('Hi there! I''m written in Pascal.'#$9b'Before we start, what is your name?');
		writeln;
		write('>'); ReadLn(name);
		writeln;
		write('Hello, ',name);

		randomize;
		writeln('! ');
	end;

procedure game;
	var
		Number, Attempts, guess : integer;

	begin
		writeln('See if you can guess my number.');
		Number := random(100);
		Attempts := 0;

		guess := -1;
		while guess <> Number do
			begin
				Attempts := Attempts + 1;
				write('>');
				readln(guess);
		
				if guess < Number then
					begin
						writeln;
						writeln('Try a bit higher.');
					end;
			
				if guess > Number then
					begin
						writeln;
						writeln('Try a bit lower.');
					end;
			end;

		writeln;
		write('You got it right in only ', Attempts, ' ');
		if Attempts = 1 then
			write('go')
		else
			write('goes');
		writeln('!');
	end;

function question: Boolean;
	var
		response: char;

	begin
		write('>');
		readln(response);

		Result := not ((response = 'n') or (response = 'N')); 
	end;

begin
	getname;

	playing := TRUE;
	while playing do
		begin
			game;
			writeln;
			writeln('Would you like another go?');
			playing := question;

			writeln;
			if playing then
				writeln('Excellent! ')
			else
				writeln('Thanks for playing --- goodbye!');
		end;
end.
