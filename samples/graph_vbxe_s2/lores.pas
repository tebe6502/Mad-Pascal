// Graphics VBXE 2
// 160x192x256c

uses crt, s2, graph;

{$define romoff}

var     
    x: byte;
    ch: char;

begin

SetGraphMode(2);


Font.Color:=105;
Font.Style:=fsUnderline;
TextOut(0,10, 'VBXE 4: 160x192x256c');


for x:=0 to 15 do begin
 setcolor(x);
 ellipse(x*7,x*10,x*2,x*4);
end;


repeat until keypressed;
ch:=readkey;

ClearDevice;

for x:=0 to 159 do begin
 setcolor(x);
 MoveTo(80,96); LineTo(x,0);
end;

for x:=0 to 191 do begin
 setcolor(x);
 MoveTo(80,96); LineTo(159,x);
end;

for x:=159 downto 0 do begin
 setcolor(x);
 MoveTo(80,96); LineTo(x,191);
end;

for x:=191 downto 0 do begin
 setcolor(x);
 MoveTo(80,96); LineTo(0,x);
end;

repeat until keypressed;

CloseGraph;

end.