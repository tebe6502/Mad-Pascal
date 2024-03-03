program diamond;
uses graph, crt; 
const m = 2;
var col: byte;

procedure Draw(x: word; y,s: byte);
begin
    SetColor(col);
    if s >= m then
        begin
            s := s shr 1;
            MoveTo(x, y+s);
            LineTo(x+s, y);
            LineTo(x, y-s);
            LineTo(x-s, y);
            LineTo(x, y+s);
            Draw(x+s, y, s);
            Draw(x-s, y, s);
            Draw(x, y-s, s);
            Draw(x, y+s, s);
        end;
    col := (col + 1) and 15;
end;

begin
    InitGraph(0);
    col := 1;
    Draw(ScreenWidth shr 1, ScreenHeight shr 1, ScreenHeight shr 1);
    repeat until keypressed;
    ClrScr;
    asm jmp $800 end;    
end.
