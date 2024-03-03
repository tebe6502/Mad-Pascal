program pallete;
uses neo6502,crt;
const 
    CELL_H = 15;
    CELL_W = 20;
var y,i,j,c,rb,gb,bb:byte;
    x:word;
    h,s,v:real;

procedure HSVtoRGB(H, S, V: real);
{ Prevod HSV to RGB }
 
var
  R,G,B, p1, p2, p3, f: real;
  i: byte;
 
begin { HSVtoRGB }
  if H = 360 then
    H := 0;
  H := H / 60;
  i := trunc(H);
  f := h - i;
  p1 := V * (1 - S);
  p2 := V * (1 - (S * f));
  p3 := V * (1 - (S * (1 - f)));
  case i of
    0:
    begin
      R := V;
      G := p3;
      B := p1;
    end;
    1:
    begin
      R := p2;
      G := V;
      B := p1;
    end;
    2:
    begin
      R := p1;
      G := V;
      B := p3;
    end;
    3:
    begin
      R := p1;
      G := p2;
      B := V;
    end;
    4:
    begin
      R := p3;
      G := p1;
      B := V;
    end;
    5:
    begin
      R := V;
      G := p1;
      B := p2;
    end;
  end; { case i }
{ R:=R*63;
 G:=G*63;
 B:=B*63;}
    rb:=Round(R*256);
    gb:=Round(G*256);
    bb:=Round(B*256);
end;  { HSVtoRGB }

begin
    c:=0;
    NeoSetDefaults(0,0,1,1,0);
    for i:=0 to 15 do begin
        for j:=0 to 15 do begin
            x:=j*CELL_W;
            y:=i*CELL_H;
            NeoSetColor(c);
            NeoDrawRect(x,y,x+CELL_W,y+CELL_H);
            if i>0 then begin
                h:=(i-1)*24;
                s:=0.7+((j/16)*0.3); 
                v:=0.1+((j/16)*0.9);
                HSVtoRGB(h,s,v);
            end else begin
                rb:=j*17;
                gb:=j*17;
                bb:=j*17;
            end;
            NeoSetPalette(c,rb,gb,bb);
            Inc(c);
        end;
    end;

    repeat until keypressed;

end.