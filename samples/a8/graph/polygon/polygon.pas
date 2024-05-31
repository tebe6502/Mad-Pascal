// https://github.com/drmortalwombat/oscar64/blob/main/samples/hiresmc/polygon.c

uses crt, graph;


procedure Draw;

type
    PPoint = ^TPoint;

var px, py: array [0..9] of real;

    pt: array [0..63] of PPoint;

    fx, fy, w, c, s, r, cw, sw: real;

    i, j: byte;

begin

	for i:=0 to High(pt)-1 do
	  GetMem(pt[i], sizeof(TPoint));


	for i:=0 to 9 do begin

		w := i * PI / 5;
		c := cos(w);
		s := sin(w);

		if i and 1 <> 0 then
		 r := 1.0
		else
		 r := 0.5;

		px[i] := r * c;
		py[i] := r * s;
	end;


	for i := 0 to 63 do begin

		r := i + 8;
		w := i * PI / 16;
		c := r * cos(w);
		s := r * sin(w);
		cw := r * cos(w * 2.0);
		sw := r * sin(w * 2.0);

		for j :=0 to 9 do begin

			fx := px[j];
			fy := py[j];

			pt[j].x := 160 + round(cw + fx * c + fy * s);	// px
			pt[j].y := 100 + round(sw - fx * s + fy * c);	// py
		end;

		DrawPoly(10, pt);

	end;


	for i:=0 to High(pt)-1 do
	  FreeMem(pt[i], sizeof(TPoint));

end;


begin

 InitGraph(8 + 16);

// SetClipRect(0,0, ScreenWidth-1, ScreenHeight-1);

 SetColor(1);


 Draw;


 repeat until keypressed;

end.
