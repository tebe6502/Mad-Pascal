program case_test;
uses crt;
var
    i: byte;

begin
    i := 128;

    case i of
        128..128: Writeln('Ok');
    else
     Writeln('bleh');
    end;
    Readkey;
end.
