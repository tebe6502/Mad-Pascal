// rascal - Tutorial11_Lines

uses crt, fastgraph;


var	buf1, buf2: TDisplayBuffer;


procedure UpdateRaster();
var
	xp: array[0..2] of byte = (40, 70, 50);
	yp: array[0..2] of byte = (50, 20, 70);
	dxp: array[0..2] of byte = (1, 1, -1);
	dyp: array[0..2] of byte = (-2, 2, 2);

	i: byte;
begin

	SwitchDisplayBuffer(buf1, buf2);

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

	for i:=0 to High(xp) do begin

		xp[i] := xp[i]+dxp[i];
		yp[i] := yp[i]+dyp[i];

		if xp[i] >= byte(ScreenWidth-18) then dxp[i]:=-1;
		if xp[i] < 18 then dxp[i]:=1;

		if yp[i] >= byte(ScreenHeight-18) then dyp[i]:=-2;
		if yp[i] < 18 then dyp[i]:=2;
	end;

end;


begin

// SetBuffer(buffer, mode, ramtop)

 NewDisplayBuffer(buf1, 7 + 16, $c0);		// ramtop = $c0

 NewDisplayBuffer(buf2, 7 + 16, $a0);		// ramtop = $a0

// SetClipRect(0, 0, ScreenWidth, ScreenHeight);

 SetColor(1);

 repeat
	pause;

	UpdateRaster;

 until keypressed;

end.