// rascal - Tutorial11_Lines

uses crt, fastgraph;

{$define romoff}

var	buf1: array [0..0] of byte absolute $c000;
	buf2: array [0..0] of byte absolute $e000;

	dl: word;

procedure UpdateRaster();
var
	xp: array[0..2] of byte = (40, 70, 50);
	yp: array[0..2] of byte = (40, 10, 90);
	xp2: array[0..2] of byte = (40, 70, 50);
	yp2: array[0..2] of byte = (40, 10, 90);
	dxp: array[0..2] of byte = (1, 1, 255);
	dyp: array[0..2] of byte = (255, 1, 1);

	i: byte;
begin

	fLine(xp[0],yp[0],xp[1],yp[1]);
	fLine(xp[1],yp[1],xp[2],yp[2]);
	fLine(xp[2],yp[2],xp[0],yp[0]);

	i:=8;
	fLine(xp[0]+i,yp[0]+i,xp[1]+i,yp[1]+i);
	fLine(xp[1]+i,yp[1]+i,xp[2]+i,yp[2]+i);
	fLine(xp[2]+i,yp[2]+i,xp[0]+i,yp[0]+i);

	fLine(xp[0]+i,yp[0]+i,xp[0],yp[0]);
	fLine(xp[1]+i,yp[1]+i,xp[1],yp[1]);
	fLine(xp[2]+i,yp[2]+i,xp[2],yp[2]);


	for i:=0 to High(xp) do begin
		xp2[i] := xp[i];
		yp2[i] := yp[i];
		xp[i] := xp[i]+dxp[i];
		yp[i] := yp[i]+dyp[i];

		if xp[i]>byte(ScreenWidth-10) then dxp[i]:=255;		// 255 = -1
		if xp[i]<10 then dxp[i]:=1;
		if yp[i]>byte(ScreenHeight-10) then dyp[i]:=255;
		if yp[i]<10 then dyp[i]:=1;
	end;

end;


begin
 InitGraph(7+16);

 dl:=dpeek($230);

 SetColor(1);

 repeat
//	FRAME #1

	pause;

  	dpoke(dl+4, word(@buf2));
	SetActiveBuffer(word(@buf1));

	fillchar(buf1, 40*96, 0);	// clear buf1

	UpdateRaster;

//	FRAME #2

	pause;

	dpoke(dl+4, word(@buf1));
	SetActiveBuffer(word(@buf2));

	fillchar(buf2, 40*96, 0);	// clear buf2

	UpdateRaster;

 until keypressed;

end.