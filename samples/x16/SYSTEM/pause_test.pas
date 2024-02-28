uses crt;

var x: byte;

begin
    pause;
    writeln('hej!');;

    for x := 1 to 60 do begin
        write(x, ', ');
        pause(60);
    end;

    writeln;
    writeln('minute of your life gone...');
end.
