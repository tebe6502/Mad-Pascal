//
// Example datamatrix library usage in text mode
// by bocianu '2017
//

program dataTxtMode;
uses datamatrix, crt;

const
    DM_DATA = $8400;
    DM_SIZE = 24;
    DM_SYMBOL = DM_DATA + $100;

procedure ShowMatrix;
var data:word = 0;
begin
    poke(710, 15);
    poke(712, 15);
    poke(709, 0);
    repeat
        if data mod DM_SIZE = 0 then Writeln;
        if (peek(DM_SYMBOL + data) = 1) then Write(' '*)
        else Write(' ');
        Inc(data);
    until data = DM_SIZE * DM_SIZE;
end;

begin
    SetMessage('http://atari.pl/HSC/?x=10000000001', DM_DATA);
    CalculateMatrix;
    ShowMatrix;
    CursorOff;
    Readkey;
end.
