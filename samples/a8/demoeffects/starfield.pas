uses crt, fastgraph;

const	star_max = 64;
	star_speed = 1;

	w = 160;
	h = 96;

	cx = w div 2;
	cy = h div 2;

	ds = 3;

var	star_x, star_y, px, py: array [0..star_max-1] of byte;
	star_s: array [0..star_max-1] of shortint;

	x, y, i: byte;


procedure init;
begin
	randomize;

	x:=w shr 1;
	y:=h shr 1;

	for i:=0 to star_max-1 do begin
		star_x[i]:=random(0);
		star_y[i]:=random(0);
		star_s[i]:=random(0);
	end;

end;


procedure anim;

function test: Boolean;
begin

 Result := ((px[i]<cx-ds) or (px[i]>cx+ds)) and ((py[i]<cy-ds) or (py[i]>cy+ds));

end;

begin

  for i:=star_max-1 downto 0do begin

    if test then begin

    SetColor(0);
    PutPixel(px[i], py[i]);

    end;

    dec(star_s[i], star_speed);
    if (star_s[i] < 0) then star_s[i]:=random(0) and $3f;

    px[i] := x+(star_x[i] div star_s[i]);
    py[i] := y+(star_y[i] div star_s[i]);


    if test then begin

    SetColor(1);
    PutPixel(px[i], py[i]);

    end;

  end;

end;



begin

 InitGraph(7+16);

 init;

 repeat
 	pause;
	anim;
 until keypressed;

end.

