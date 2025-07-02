uses crt, joystick, fastgraph;

type

TColision = (left=1, right, top, bottom);

 TTile = record
	 width, height, centerX, centerY: byte;
	end;	
	
var 
 A,B: TTile;
 
 Hero: record x,y, _x, _y: byte end;
 
 hit: byte;
 
 
function CollisionTile(var B: TTile): byte;
var w,h: byte;
    dx,dy,wy,hx: smallint;
begin

Result:=0;
 
w := (A.width + B.width) shr 1;
h := (A.height + B.height) shr 1;
dx := A.centerX - B.centerX;
dy := A.centerY - B.centerY;

if (abs(dx) <= w) and (abs(dy) <= h) then begin

    (* collision! *)
    wy := w * dy;
    hx := h * dx;

    if (wy > hx) then begin
    
        if (wy > -hx) then
            (* collision at the bottom *)
	    Result := ord(bottom)
        else
            (* on the left *)
	    Result := ord(left);
	    
    end else 
        if (wy < -hx) then
            (* on the right *)
	    Result := ord(top)
        else
            (* at the top *)
	    Result := ord(right);

end; 
  
end; 
 
 
procedure DrawTile(var a: TTile; color: Byte);
var px,py,x,y,w,h: byte;
begin
 
  w:=A.width;
  h:=A.height;
 
  x:=w shr 1;
  y:=h shr 1;
  
  px:=A.CenterX - x;
  py:=A.CenterY - y;
 
  SetColor(color);
  
  fRectangle(px,py,px+w,py+h); 
 
end;


procedure HeroMovement;
begin

 case joy_1 of
   joy_left: dec(Hero.X);
  joy_right: inc(Hero.X);
     joy_up: dec(Hero.Y);
   joy_down: inc(Hero.Y); 
 end;
 
 if (Hero.x <> Hero._x) or (Hero.y <> Hero._y) then begin
 
  DrawTile(A, 0);
  
  A.CenterX := Hero.X;
  A.CenterY := Hero.Y;
  
  DrawTile(A, 1);

  Hero._x := Hero.x; 
  Hero._y := Hero.y; 
  
  DrawTile(B, 3);
 
 end;
 
end;


begin

InitGraph(7);

A.width:=8; 
A.height:=8;
A.CenterX:=84;
A.CenterY:=53;

Hero.X:=A.CenterX;
Hero.Y:=A.CenterY;

B.width:=32; 
B.height:=16;
B.CenterX:=93;
B.CenterY:=45;


repeat

 HeroMovement;
 
 hit:=CollisionTile(B);
 
 case hit of
    ord(left): writeln('left');
   ord(right): writeln('right');
     ord(top): writeln('top');
  ord(bottom): writeln('bottom');
 else
  writeln;
 end;

until false;

end.
