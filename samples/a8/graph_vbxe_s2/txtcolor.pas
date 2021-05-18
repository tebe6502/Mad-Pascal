// VBXE text mode

// 1: text mode 80x24 in 2 colors per character, this is like GR.0 in 80 columns and color.
// 5: text mode 80x25.
// 6: text mode 80x30.
// 7: text mode 80x32.

uses crt, s2;

{$define romoff}

const
    s = 'The quick brown fox jums over the lazy dog';

var     
    x, d: byte;
    ch: char;

begin

SetGraphMode(1);


Palette[5] := $0f;	// 709
Palette[6] := $72;	// 710


d:=Peek(711);

Position(18,8);

for x:=1 to length(s) do begin
 Poke(711,x);
 write(s[x]);
end;
 
Position(18,10);

for x:=1 to length(s) do begin
 Poke(711,x);
 write(chr(ord(s[x])+128));
end;

Poke(711,d);

Position(28,14); write('---------------------');
Position(28,15); write(' Press a key to exit '*);
Position(28,16); write('---------------------');


repeat until keypressed;

CloseGraph;

end.