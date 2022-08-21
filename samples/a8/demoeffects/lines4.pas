// rascal - Tutorial11_Lines

uses crt, fastgraph;


var	buf1, buf2: TDisplayBuffer;

	ts: array [0..1] of PByte;	// scanline begin address
	tc: array [0..1] of word;	// counter

	frm: byte;

procedure UpdateRaster();
var
	xp: array[0..2] of byte = (40, 70, 50);
	yp: array[0..2] of byte = (50, 20, 70);
	dxp: array[0..2] of byte = (1, 1, -1);
	dyp: array[0..2] of byte = (-2, 2, 2);

	i, max_y, min_y, y: byte;
	a: word;
begin

	if frm = 0 then begin
		SetDisplayBuffer(buf2);
		SetActiveBuffer(buf1);
	end else begin
		SetDisplayBuffer(buf1);
		SetActiveBuffer(buf2);
	end;

//	ts[frm]		start address
//	tc[frm]		count bytes

	fillchar(pointer(ts[frm]), tc[frm], 0);

	fLine(xp[0],yp[0],xp[1],yp[1]);
	fLine(xp[1],yp[1],xp[2],yp[2]);
	fLine(xp[2],yp[2],xp[0],yp[0]);

	i:=16;
	fLine(xp[0]+i,yp[0]+i,xp[1]+i,yp[1]+i);
	fLine(xp[1]+i,yp[1]+i,xp[2]+i,yp[2]+i);
	fLine(xp[2]+i,yp[2]+i,xp[0]+i,yp[0]+i);

	fLine(xp[0]+i,yp[0]+i,xp[0],yp[0]);
	fLine(xp[1]+i,yp[1]+i,xp[1],yp[1]);
	fLine(xp[2]+i,yp[2]+i,xp[2],yp[2]);

	max_y:=0;	// maximum Y
	min_y:=255;	// minimum Y

	for i:=0 to High(xp) do begin

		xp[i] := xp[i]+dxp[i];
		yp[i] := yp[i]+dyp[i];

		y := yp[i];

		if y>max_y then max_y:=y;
		if y<min_y then min_y:=y;

		if xp[i]>=byte(ScreenWidth-18) then dxp[i]:=-1;
		if xp[i]<18 then dxp[i]:=1;

		if y >= byte(ScreenHeight-18) then dyp[i]:=-2;
		if y < 18 then dyp[i]:=2;
	end;

	ts[frm]:=Scanline(min_y - 2);

	a:=(max_y-min_y) + 22;

	a:=a shl 3;
	a:=a + a shl 2;

	tc[frm]:=a;		// *40 = *8 + *32
end;


begin

 NewDisplayBuffer(buf1, 7 + 16, $c0);		// ramtop = $c0
 ts[0]:=Scanline(0);

 NewDisplayBuffer(buf2, 7 + 16, $a0);		// ramtop = $a0
 ts[1]:=Scanline(0);

 SetColor(1);

 repeat
	pause;

	UpdateRaster;

	frm:=frm xor 1;

 until keypressed;

end.