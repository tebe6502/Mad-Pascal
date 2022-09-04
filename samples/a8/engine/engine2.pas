// Platform Engine 1.3
// with acceleration right/left

uses crt, joystick, fastgraph, math;

{$f $80}

type

TColision = (left=1, right=2, top=4, bottom=8);

 TTile = record
	 width, height, centerX, centerY: byte;
	 dx, dy, status: byte;
	end;

TPlayer = record
	  x,y, _x,_y: byte;
	  dx, ddx: shortreal;
	  left, right, up: Boolean;
	  end;

var
 A, B: TTile;

 C:^TTile;

 B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10: TTile;

 Player: TPlayer;

 hit, tmpX, tmpY: byte;

 jump, fall, dy: byte;

 jumpAllowed, falling: Boolean;

 tJump: array [0..18] of byte = (0,-4,-4,0,-3,-3,0,-2,-1,-1,0,0,0,0,0,0,0,1,2);

 tFall: array [0..16] of byte = (1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3);

 Tiles: array [0..7] of ^TTile;

 const
	maxdx: shortreal = 1.2;

	friction_default = 1/8;
	accel_default = 1/10;


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


procedure Init;
begin

A.width:=4;
A.height:=4;
A.CenterX:=94;
A.CenterY:=13;

Player.X:=A.CenterX;
Player.Y:=A.CenterY;

Player.dx:=0;


B0.width:=16;			// left / right
B0.height:=8;
B0.CenterX:=93;
B0.CenterY:=62;
B0.dx:=1;

B1.width:=16;
B1.height:=8;
B1.CenterX:=63;
B1.CenterY:=50;

B2.width:=24;
B2.height:=8;
B2.CenterX:=76;
B2.CenterY:=80;

B3.width:=16;
B3.height:=12;
B3.CenterX:=56;
B3.CenterY:=76;

B4.width:=16;
B4.height:=8;
B4.CenterX:=40;
B4.CenterY:=66;

B5.width:=16;			// up / down
B5.height:=8;
B5.CenterX:=16;
B5.CenterY:=50;
B5.dy:=1;

B6.width:=48;
B6.height:=8;
B6.CenterX:=54;
B6.CenterY:=33;

B7.width:=36;
B7.height:=16;
B7.CenterX:=112;
B7.CenterY:=39;


Tiles[0]:=@B0;
Tiles[1]:=@B1;
Tiles[2]:=@B2;
Tiles[3]:=@B3;
Tiles[4]:=@B4;
Tiles[5]:=@B5;
Tiles[6]:=@B6;
Tiles[7]:=@B7;

DrawTile(B0, 2);
DrawTile(B1, 2);
DrawTile(B2, 2);
DrawTile(B3, 2);
DrawTile(B4, 2);
DrawTile(B5, 2);
DrawTile(B6, 2);
DrawTile(B7, 2);

end;


function CollisionTile: byte;
var w,h, _w, _h: byte;
    dx,dy,wy,hx: smallint;
begin

Result:=0;

w := byte(A.width + B.width) shr 1;
h := byte(A.height + B.height) shr 1;

dx := Player.X - B.centerX;

if dx >= 0 then
 _w := dx
else
 _w := -dx;

dy := Player.Y - B.centerY;

if dy >= 0 then
 _h := dy
else
 _h := -dy;

if (_w <= w) and (_h <= h) then begin

    (* collision! *)
    wy := w * dy;
    hx := h * dx;

    if (wy > hx) then begin

        if (wy > smallint(-hx)) then
            (* collision at the bottom *)
	    Result := ord(bottom)
        else
            (* on the left *)
	    Result := ord(left);

    end else

        if (wy < smallint(-hx)) then
            (* on the top *)
	    Result := ord(top)
        else
            (* at the right *)
	    Result := ord(right);

end;

end;


function bound(x, minimum, maximum: shortreal): shortreal;
begin
    Result:= max(minimum, min(maximum, x));
end;


procedure onKey;
var wasleft, wasright: Boolean;
    accel, friction: shortreal;
begin

 Player.left := joy_1=joy_left;
 Player.right:= joy_1=joy_right;

 wasleft := Player.dx < 0;
 wasright:= Player.dx > 0;

 if falling then begin
   friction := friction_default*0.5;
   accel := accel_default*2.5;
// end else begin
//   friction := friction_default;
//   accel := accel_default;
 end;


 Player.ddx := 0;

 if (Player.left) then
   Player.ddx := Player.ddx - accel
 else if (wasleft) then
   Player.ddx := Player.ddx + friction;

 if (Player.right) then
   Player.ddx := Player.ddx + accel
 else if (wasright) then
   Player.ddx := Player.ddx - friction;


 Player.x  := Player.x + round(Player.dx);

 Player.dx := bound(Player.dx + Player.ddx, -maxdx, maxdx);

 if ((wasleft  and (Player.dx > 0)) or
     (wasright and (Player.dx < 0))) then
     begin
      Player.dx := 0;				// clamp at zero to prevent friction from making us jiggle side to side

      friction := friction_default;
      accel := accel_default;

      end;


 if JumpAllowed and (strig0=0) then begin

  jump:=1;
  JumpAllowed:=false;

 end;


 if jump>0 then begin

  dy:=tJump[jump];

  inc(jump);

  if jump > High(tJump) then begin
   jump:=0;
   falling:=true;
  end;

 end;

end;


function ResolveCollisions: byte;
var i, x,y, hit: byte;
begin

 falling:=true;

 Result:=0;

 for i:=0 to High(Tiles) do begin

 C:=Tiles[i];

 B:=C^;

 x:=byte(B.Width + A.Width) shr 1 + 1;
 y:=byte(B.Height + A.Height) shr 1 + 1;

 hit:=CollisionTile;

 Result:=Result or hit;

 case hit of

    ord(left):
	begin

	 Player.X:=B.CenterX-X;

	end;

   ord(right):
	begin

	 Player.X:=B.CenterX+X;

	end;

     ord(top):
	begin

	 Player.X := Player.X + B.dx;

	 Player.Y := B.CenterY - Y;

	 if B.dy <> 0 then dec(Player.Y);

	 jumpAllowed:=true;

	 falling:=false;

	 if B.status = 0 then begin
	  DrawTile(B, 3);

	  C^.Status:=1;
	 end;

	end;

  ord(bottom):
	begin

	 Player.Y := B.CenterY + Y;

	end;

 end;

 end;

end;


begin

InitGraph(7+16);

Init;


repeat

// HPalette[8]:=0;

 pause;

// HPalette[8]:=15;

 onKey;


 tmpX:=Player.X;
 tmpY:=Player.Y;


 if (jump > 0) {and (strig0=0)} then begin

  inc(Player.Y, dy);

  if ResolveCollisions <> 0 then begin

    if dy<>0 then Player.Y:=tmpY-2;

    Player.X:=tmpX;

    if (ResolveCollisions and ord(bottom))<>0 then begin
     jump:=0;
     falling:=true;
    end;

  end;

 end else
  if falling then begin

   JumpAllowed:=false;

   inc(Player.Y, 2); //tFall[fall]);

//   inc(fall);

   if ResolveCollisions <> 0 then begin
    Player.X:=tmpX;
    Player.Y:=tmpY + 2;

    ResolveCollisions;
   end;

  end else begin
   inc(Player.Y);

   ResolveCollisions;
  end;


 if (Player.X <> Player._X) or (Player.Y <> Player._Y) then begin

  DrawTile(A, 0);

  if Player.X < 2 then Player.X:=158;
  if Player.X > 158 then Player.X:=2;

  if Player.Y>127 then Player.Y:=2;

  A.CenterX := Player.X;
  A.CenterY := Player.Y;

  DrawTile(A, 1);

  Player._X := Player.X;
  Player._Y := Player.Y;

 end;


C:=Tiles[0];		// horizontal platform
B:=C^;

DrawTile(B,0);

B.CenterX:=B.CenterX + B.dx;

if (B.centerx > 140) or (B.centerx < 70) then B.dx:=-B.dx;

DrawTile(B,2);

C^:=B;



C:=Tiles[5];		// vertical platform
B:=C^;

DrawTile(B,0);

B.CenterY:=B.CenterY + B.dy;

if (B.centerY > 70) or (B.centerY < 32) then B.dy:=-B.dy;

DrawTile(B,2);

C^:=B;


until false;


end.

// 5651
