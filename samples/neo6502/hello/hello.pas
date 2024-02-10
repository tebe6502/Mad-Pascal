program hello;
uses crt;

var c:char;
    s:TString;

procedure CallBasic; assembler; inline;
asm
    jmp $800
end;

begin
    TextBackground(10);
    TextColor(15);
    ClrScr;

    Writeln('Hello Neo6502!');
    Writeln('This time in Mad-Pascal.');
    Writeln;
    
    s:='Enter your name:';
    Writeln(s);
    Readln(s);
    Writeln('Hi ',s,'!');
    Writeln;
    Writeln('Press any key to return to basic');
    Readkey;
    TextBackground(0);
    TextColor(2);
    ClrScr;
    CallBasic;    
end.
