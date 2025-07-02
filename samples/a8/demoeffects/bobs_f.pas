
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

uses crt, fastgraph, joystick;

const
	rad=4;
	dia=rad*2;

	b0=$4000;
	b1=$4800;
	b2=$4000;
	b3=$4800;

var
	ss: array [0..3] of word = (b0,b1,b2,b3);
	
	q, t: byte;
	
	dl: word;
	
	x, y, xm, ym: smallint;

	sc: pointer;
	

begin

 InitGraph(6+16);

 SetColor(1);
 
 dl:=dpeek($230);
 
 x:=dia;
 y:=dia;
 
 xm:=3;
 ym:=3;
 
 q:=3;
 t:=0;
  
  repeat
	pause;
	pause;
	pause;
	
	FrameBuffer(ss[q]);
	
	dpoke(dl+4, ss[t]);
	
	inc(x, xm); 
	inc(y, ym);

	if (x<dia) or (x>ScreenWidth-dia) then begin xm:=-xm; inc(x, xm) end;
	if (y<dia) or (y>ScreenHeight-dia) then begin ym:=-ym; inc(y, ym) end;

	Circle(x, y, rad);

	inc(q); q:=q and 3;
	inc(t); t:=t and 3;

 until keypressed;

end.
