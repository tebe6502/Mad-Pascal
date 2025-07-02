program case_test;
uses crt;
var
    i: byte;

begin
    i := 100;

    case i of
        0..127: Writeln('Ok');
    else
     Writeln('bleh');
    end;
    Readkey;
end.
