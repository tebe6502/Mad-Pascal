(* HIT BOX *)

uses crt, joystick, fastgraph;

type
	TBox = record
		x,y, w, h: byte;
	       end;

var
	b1, b2: TBox;

	v, f: byte;


{
    x,y           
     *---------------------------*
     |                           |
     |                           | h-eight
     |                           |
     *---------------------------*
                 w-idth
}

function hitBox(A, B: TBox): Boolean;
begin

  if
    (A.x < byte(B.x + B.w)) and
    (byte(A.x + A.w) > B.x) and
    (A.y < byte(B.y + B.h)) and
    (byte(A.y + A.h) > B.y)
  then
    Result:=true
  else
    Result:=false;

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

   writeln( hitBox(b1,b2) );

  end;


 until false;

end.