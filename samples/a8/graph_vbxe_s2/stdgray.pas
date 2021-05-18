// Graphics VBXE 3
// 320x192x128 shadess

uses crt, s2, graph;

{$define romoff}

var     
    x, x1, y1, x2, y2, c: word;
    i: byte;
    ch: char;

begin

SetGraphMode(3 + 64);



for i:=1 to 127 do begin
 x:=i shl 1;
 setcolor(x);
 circle(x,x shr 1,x shr 1); 
end;


Font.Color:=100;
Font.Style:=fsNormal;
TextOut(0,170, 'VBXE 3: 320 x 192 x 128s');

 
repeat until keypressed;
ch:=readkey;

ClearDevice;

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

repeat until keypressed;
ch:=readkey;

ClearDevice;

x1:=0; x2:=319; y1:=0; y2:=191; c:=256;

while c > 0 do begin
 SetColor(c);

 MoveTo(x1, y1);
 LineTo(x2, y1); LineTo(x2, y2);
 LineTo(x1, y2); LineTo(x1, y1); 
 
 dec(c, 2);
 
 inc(x1); dec(x2);
 inc(y1); dec(y2);

end;

repeat until keypressed;


CloseGraph;

end.