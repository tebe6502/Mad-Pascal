program Diamond;

uses graph, crt;

const
	m = 6;
      
procedure D(x: word; y,s: byte);
begin

    SetColor(1);

    if s >= m then
      begin
        s := s shr 1;

        MoveTo(x  , y+s);
        LineTo(x+s, y);
        LineTo(x  , y-s);
        LineTo(x-s, y);
        LineTo(x  , y+s);

       D(x+s, y, s);
       D(x-s, y, s);
       D(x, y-s, s);
       D(x, y+s, s);
     end
end;


begin

  InitGraph(8 + 16);
  
  D(ScreenWidth shr 1, ScreenHeight shr 1, ScreenHeight shr 1);

  repeat until keypressed;

end.
