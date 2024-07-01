(* HIT BOX 2 *)

uses crt, joystick, fastgraph;

type
	TBox = record
		x,y, w, h: byte;
	       end;

	TColision = (left=1, right=2, top=4, bottom=8, nohit=0);

var
	b1, b2: TBox;

	v, f: byte;
	
{
    x,y           
     *---------------------------*
     |                           |
     |           Cx,Cy           | h-eight
     |                           |
     *---------------------------*
                  w-idth

     Cx = x + w/2
     Cy = y + h/2
}
     
function hitBox(A, B: TBox): TColision;
var w,h, _w, _h: byte;
    dx,dy,wy,hx: smallint;
begin

Result:=nohit;

w := byte(A.w + B.w) shr 1;
h := byte(A.h + B.h) shr 1;

dx := (A.x + A.w shr 1) - (B.x + B.w shr 1);	// A.Cx - B.Cx

if dx >= 0 then
 _w := dx
else
 _w := -dx;

dy := (A.y + A.h shr 1) - (B.y + B.h shr 1);	// A.Cy - B.Cy

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
	    Result := bottom
        else
            (* on the left *)
	    Result := left;

    end else

        if (wy < smallint(-hx)) then
            (* on the top *)
	    Result := top
        else
            (* at the right *)
	    Result := right;

end;

end;


procedure drawBox(B: TBox; c: byte);
begin

 SetColor(c);
 
 Rectangle(B.x, B.y, B.x + B.w, B.y + B.h)

end;


begin
 InitGraph(15);

 b1.x:=85;	// box1 -> fire ON + joy
 b1.y:=75;
 b1.w:=11;
 b1.h:=16;

 b2.x:=50;	// box2 -> fire OFF + joy
 b2.y:=54;
 b2.w:=27;
 b2.h:=16;

 drawBox(b1, 1);
 drawBox(b2, 2);

 repeat

  pause;

  v:=joy_1;	// read joystick #1
  f:=trig0;	// read fire #1

  if v <> joy_none then begin

{$i hitbox.inc}

   case hitBox(b1,b2) of
   
      left: writeln('left');
     right: writeln('right');
       top: writeln('top');
    bottom: writeln('bottom');
    
   else
   
    writeln;
    
   end;
  

  end;


 until false;

end.