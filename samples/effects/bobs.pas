
{
Just a test of 3-frame snake-bob animation. By Bill Kendrick 12/29/94.
After watching the DragonBob part of Slight's "Bitter Reality" megademo,
I decided to try my hand at the animation routine.
(I should use the display list, but was lazy).

The animation is done by having three screens which are constantly flipped
through.  An object ("bob"), in this case a small circle, is moved around
the screen.  It is placed on the current screen, so when the next
frame appears, it is gone.  In the next frame after THAT, it is gone
as well.  Finally, in the NEXT frame, it reappears.  It sounds dumb, but
when it's moving, it looks like they are ALL constantly moving.  (Oh, and
you use THREE frames because if you used only two, there'd be only motion
and no DIRECTION).

-bill!  kendrick@vax.sonoma.edu
}

uses crt, graph, joystick;

var
	ss: array [0..2, 0..1920-1] of byte;

	q: byte;
	x, y, xm, ym: smallint;

	sc: pointer;
	
const
	rad=4;
	dia=rad*2;

begin

 InitGraph(6+16);

 SetColor(1);
 
 sc:=pointer(dpeek(88));
 
 x:=dia;
 y:=dia;
 
 xm:=3;
 ym:=3;
 
  repeat
	pause;

	inc(q);
	if q > 2 then q:=0;

	move(@ss[q,0], sc, 1920);

	inc(x, xm); 
	inc(y, ym);

	if (x<dia) or (x>ScreenWidth-dia) then begin xm:=-xm; inc(x, xm) end;
	if (y<dia) or (y>ScreenHeight-dia) then begin ym:=-ym; inc(y, ym) end;

	Circle(x, y, rad);

	move(sc, @ss[q][0], 1920);

 until keypressed;

end.
