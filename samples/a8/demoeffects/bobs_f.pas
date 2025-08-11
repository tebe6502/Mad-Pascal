program bobs_f;

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

uses
  crt,
  fastgraph,
  joystick;

const
  rad = 4;
  dia = rad * 2;

  mode = 6 + 16;

  b0 = $4000;
  b1 = $4800;
  b2 = $4000;
  b3 = $4800;

var
  buf1, buf2, buf3, buf4: TDisplayBuffer;

  buf: array [0..3] of ^TDisplayBuffer;

  q, t: Byte;

  dl: Word;

  x, y, xm, ym: Smallint;

  sc: pointer;


begin

  InitGraph(mode);


  NewDisplayBuffer(buf1, mode, $40);
  NewDisplayBuffer(buf2, mode, $48);
  NewDisplayBuffer(buf3, mode, $50);
  NewDisplayBuffer(buf3, mode, $58);
  buf[0]:=@buf1;
  buf[1]:=@buf2;
  buf[2]:=@buf3;
  buf[3]:=@buf3;

  SetColor(1);

  dl := dpeek($230);

  x := dia;
  y := dia;

  xm := 3;
  ym := 3;

  q := 3;
  t := 0;

  repeat
    pause;
    pause;
    pause;

    SetDisplayBuffer(buf[q]^);

    // dpoke(dl + 4, ss[t]);

    Inc(x, xm);
    Inc(y, ym);

    if (x < dia) or (x > ScreenWidth - dia) then
    begin
      xm := -xm;
      Inc(x, xm);
    end;
    if (y < dia) or (y > ScreenHeight - dia) then
    begin
      ym := -ym;
      Inc(y, ym);
    end;

    Circle(x, y, rad);

    Inc(q);
    q := q and 3;
    Inc(t);
    t := t and 3;

  until keypressed;

end.
