// https://github.com/dzutrinh/TP-RayCast/

uses	crt, graph;

const	MAP_WIDTH	= 24;
	MAP_HEIGHT	= 24;

        MAP_DIMMER	= 2;

type	WORLD		= array[0..MAP_WIDTH-1, 0..MAP_HEIGHT-1] of byte;

const	MAX_WIDTH	= 64;
        MAX_HEIGHT	= 100;
	HALF_HEIGHT	= MAX_HEIGHT shr 1;

var
	map: WORLD = 
	(	
	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1),
	(1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1),
	(1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,4,4,4,0,4,4,4,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,1),
	(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,5,0,5,0,5,0,1),
	(1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,2,0,2,0,0,1),
	(1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,5,0,5,0,5,0,1),
	(1,4,0,4,4,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
	(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
	);

	lh, ls, le, clr, x,
	xstep, ystep, mx, my	: smallint;
	done, hit, side		: boolean;
	xp, yp, drx, dry, cam_x,
	px, py, xod, xop, mvspd,
	rtspd,xsided, ysided,
	dist, xdd, ydd, rdx, rdy: real;
        key			: char;



procedure	line_v(x, y1, y2: byte; color: byte);
//var	p	: SURFACE;
//	i	: smallint;
begin
//	p := srf + Y_OFFSET[y1] + x;
//        for i := 0 to abs(y2-y1+1) do
//        begin
//        	p^ := char(color);
//                inc(p, MAX_WIDTH);
//        end;
	
	SetColor(color);
	line(x, y1, x, y2);
	
end;

procedure	bard(x, y, w, h: byte; color: byte);
var	p	: pointer;
begin
//	p := srf + Y_OFFSET[y] + x;
//        for i := 0 to h-1 do
//        begin
//		fillchar(p^, w, color);
//                inc(p, MAX_WIDTH);
//        end;

	p := pointer(dpeek(88) + y*40);
	fillByte(p, h*40, color);

end;


begin
        InitGraph(9);
	
        done  	:= TRUE;
	mvspd 	:= 0.3;	rtspd	:= 0.04;
	xp	:= 22;	yp	:= 12;
	drx	:= -1;	dry	:= 0;
	px	:= 0;	py	:= 0.66;

	repeat
	
	   if done then begin
	
		bard(0, 0, MAX_WIDTH, HALF_HEIGHT, $00);		{ ceiling }
		bard(0, HALF_HEIGHT, MAX_WIDTH, HALF_HEIGHT, $11);	{ floor }

		for x := 0 to MAX_WIDTH-1 do
		begin
			cam_x 	:= 2.0 * x / MAX_WIDTH - 1;
			rdx 	:= drx + px * cam_x;
			rdy 	:= dry + py * cam_x;
			mx	:= trunc(xp);
			my	:= trunc(yp);

		       	if rdx = 0 then xdd := 1E6 else xdd := abs(1/rdx);
			if rdy = 0 then ydd := 1E6 else ydd := abs(1/rdy);

			if (rdx < 0) then
			begin
				xstep := -1;
				xsided := (xp - mx) * xdd;
			end
			else
			begin
				xstep := 1;
				xsided := (mx + 1.0 - xp) * xdd;
			end;
			if (rdy < 0) then
			begin
				ystep := -1;
				ysided := (yp - my) * ydd;
			end
			else
			begin
				ystep := 1;
				ysided := (my + 1.0 - yp) * ydd;
			end;

			hit := FALSE;
			while (not hit) do
			begin
				if(xsided < ysided) then
				begin
					xsided := xsided + xdd;
					inc(mx, xstep);
					side := FALSE;
				end
				else
				begin
					ysided := ysided + ydd;
					inc(my, ystep);
					side := TRUE;
				end;
				hit := (map[mx, my] > 0);
			end;

			if not side then dist := (xsided - xdd)
			else          	 dist := (ysided - ydd);

			if dist < 1E-4 then dist := 1E-4;
			lh := trunc(MAX_HEIGHT / dist);

			ls := -(lh shr 1) + HALF_HEIGHT;
			if (ls < 0) then ls := 0;
			le := +(lh shr 1) + HALF_HEIGHT;
			if (le >= MAX_HEIGHT) then le := MAX_HEIGHT - 1;

			case map[mx, my] of
			1:	clr := 4;
			2:	clr := 6;
			3:	clr := 8;
			4:	clr := 10;
                        5:	clr := 12;
			else	clr := 0;
			end;
			
			if side then     if clr <> 0 then dec(clr, MAP_DIMMER);
                        if dist > 5 then if clr <> 0 then dec(clr, MAP_DIMMER);

			line_v(x, ls, le, clr);
		end;


	   end;
	  

//		delay(5);

                done := false;

		if keypressed then
		begin
			key := upcase(readkey);
			case key of
			'W':	begin
					if (map[trunc(xp + drx * mvspd), trunc(yp)] = 0) then xp := xp + drx * mvspd;
					if (map[trunc(xp), trunc(yp + dry * mvspd)] = 0) then yp := yp + dry * mvspd;
					
					done:=true;
				end;
			'S':	begin
					if (map[trunc(xp - drx * mvspd), trunc(yp)] = 0) then xp := xp - drx * mvspd;
					if (map[trunc(xp), trunc(yp - dry * mvspd)] = 0) then yp := yp - dry * mvspd;
					
					done:=true;
				end;
			'D':	begin
					xod    	:= drx;
					drx   	:= drx * cos(-rtspd) - dry * sin(-rtspd);
					dry   	:= xod * sin(-rtspd) + dry * cos(-rtspd);
					xop    	:= px;
					px	:= px  * cos(-rtspd) - py * sin(-rtspd);
					py 	:= xop * sin(-rtspd) + py * cos(-rtspd);
					
					done:=true;
				end;
			'A':	begin
					xod	:= drx;
					drx	:= drx * cos(rtspd) - dry * sin(rtspd);
					dry	:= xod * sin(rtspd) + dry * cos(rtspd);
					xop	:= px;
					px	:= px  * cos(rtspd) - py * sin(rtspd);
					py	:= xop * sin(rtspd) + py * cos(rtspd);
					
					done:=true;
				end;
			end;
		end;

	until FALSE;

end.