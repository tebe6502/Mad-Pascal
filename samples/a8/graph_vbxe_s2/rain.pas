// Graphics VBXE 2
// 160x192x256c

uses crt, s2, graph;

{$define romoff}

var     
    r1, r2, x, y, f, c: byte;
    ch: char;

begin

SetGraphMode(2);

randomize;

repeat

r1:=1; r2:=1;

x:=random(160);
y:=random(96)+95;

f:=random(2) + 1;

for c:=15 downto 7 do begin
 setcolor(c);
 ellipse(x,y,r1,r2); 
 
 setcolor(0);
 ellipse(x,y,r1,r2); 
 
 inc(r1, f shl 1);
 inc(r2, f);
 
end;
 
until keypressed;

CloseGraph;

end.