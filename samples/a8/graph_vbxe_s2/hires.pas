// Graphics VBXE 4
// 640x192x16c

uses crt, s2, graph;

{$define romoff}

var     
    x, x1, y1, x2, y2, c: word;
    i: byte;
    ch: char;

begin

SetGraphMode(4);


Font.Color:=15;
Font.Style:=fsNormal;
TextOut(0,160, 'VBXE 4: 640 x 192 x 16c');



for i:=0 to 127 do begin
 x:=i shl 1;
 setcolor(x and $0f);
 ellipse(x*2,x shr 1,x,x shr 1); 
end;


TextOut(460,180, 'Press any key');

repeat until keypressed;
ch:=readkey;

ClearDevice;


for i:=0 to 79 do begin
 x:=i shl 3;
 setcolor(c and $0f);
 MoveTo(320,96); LineTo(x,0);
 inc(c);
end;

for i:=0 to 47 do begin
 x:=i shl 2;
 setcolor(c and $0f);
 MoveTo(320,96); LineTo(639,x);
 inc(c);
end;

for i:=79 downto 0 do begin
 x:=i shl 3;
 setcolor(c and $0f);
 MoveTo(320,96); LineTo(x,191);
 inc(c);
end;

for i:=47 downto 0 do begin
 x:=i shl 2;
 setcolor(c and $0f);
 MoveTo(320,96); LineTo(0,x);
 inc(c);
end;


repeat until keypressed;
ch:=readkey;

ClearDevice;


x1:=0; x2:=639; y1:=0; y2:=191; c:=256;

while c > 0 do begin
 SetColor(c and $0f);

 MoveTo(x1, y1);
 LineTo(x2, y1); LineTo(x2, y2);
 LineTo(x1, y2); LineTo(x1, y1); 
 
 dec(c, 2);
 
 inc(x1, 2); dec(x2, 2);
 inc(y1); dec(y2);

end;


repeat until keypressed;

CloseGraph;

end.