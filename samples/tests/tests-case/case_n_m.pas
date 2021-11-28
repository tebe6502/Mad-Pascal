program case_test;
uses crt;
var
    i: byte;

begin
    i := 230;

    case i of
        64..192: Writeln('64..192');
        200..245: Writeln('200..245');
    else
     Writeln('bleh');
    end;
    Readkey;
end.
