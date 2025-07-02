// Graphics VBXE 3
// 320x192x256c
//
// SaveBitmap

uses crt, s2, graph;

{$define romoff}

var     
    x: word;
    i, c: byte;
    ch: char;

begin

SetGraphMode(3);


for i:=0 to 79 do begin
 x:=i shl 2;
 setcolor(c);
 MoveTo(160,96); LineTo(x,0); inc(c);
end;


for i:=0 to 47 do begin
 x:=i shl 2;
 setcolor(c);
 MoveTo(160,96); LineTo(319,x); inc(c);
end;

for i:=79 downto 0 do begin
 x:=i shl 2;
 setcolor(c);
 MoveTo(160,96); LineTo(x,191); inc(c);
end;

for i:=47 downto 0 do begin
 x:=i shl 2;
 setcolor(c);
 MoveTo(160,96); LineTo(0,x); inc(c);
end;


SaveBitmap('D:DUMP.BMP');


//LoadBitmap('D:AKIRA.BMP');


repeat until keypressed;

CloseGraph;

end.