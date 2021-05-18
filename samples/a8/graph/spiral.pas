
uses crt, fastgraph;

const
  WIN_XCENTER: smallint = 160 DIV 2;
  WIN_YCENTER: smallint = 96 DIV 2;

var	anm: byte;


procedure DrawSpiral(Phi0: single; Colour: Byte);
var x, y, x0,y0: smallint;
    Phase1, Phase2: single;
    i: byte;
begin

  SetColor(Colour);

  Phase1 := -Phi0*7.3828125;
  Phase2 := 0.0;
  for i := 0 to 31 do
  begin
    x := WIN_XCENTER + round(Phase2*sin(Phase1));
    y := WIN_YCENTER + round(Phase2*cos(Phase1));

    if i=0 then begin
     x0:=x;
     y0:=y;
    end else begin
     ClipLine(x0,y0,x,y);

     x0:=x;
     y0:=y;
    end;

    Phase1 := Phase1 + 0.3515625*Pi;		// 360/1024
    Phase2 := Phase2 + 1.0546875*Pi;		// (360/1024)*4
  end;
end;


begin

 InitGraph(7+16);

 SetClipRect(0,0,ScreenWidth-1, ScreenHeight-1);

 anm:=23;

 repeat
 	DrawSpiral(single(anm*7), 1);

	//pause;

	fillByte(pointer(dpeek(88)), 96*40, 0);

	inc(anm);
	anm:=anm mod 14;

	//writeln(anm);

 until keypressed;

end.

