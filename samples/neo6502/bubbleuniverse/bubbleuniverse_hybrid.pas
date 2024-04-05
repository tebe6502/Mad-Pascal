program universe;

//----------------------------------------------------------

uses crt, neo6502, neo6502Math;

//----------------------------------------------------------

const
	n = 200;

//----------------------------------------------------------

var
	a     : float     absolute $54;
	b     : float     absolute $58;
	r     : float     absolute $5c;
	x     : float     absolute $60;
	y     : float     absolute $64;
	v     : float     absolute $68;
	t     : float     absolute $6c;
	u     : float     absolute $70;
	i     : byte      absolute $74;
	j     : byte      absolute $75;
	s     : byte      absolute $76;
	c     : byte      absolute $77;
	d     : byte      absolute $78;
	time1 : cardinal  absolute $80;
	time2 : cardinal  absolute $84;
//----------------------------------------------------------

begin
	time1 := NeoGetTimer;

	// prepare palette
	NeoSetDefaults(0, 255, 1, 0, 0);
	NeoSetPalette(255, 0, 0, 0);
	for i := 0 to 14 do
		for j := 0 to 14 do
			NeoSetPalette((i shl 4) or j, i * 16, j * 16, 100);

	// draw
	x := 0; y := 0; v := 0; t := 0; s := 60;
	r := (PI * 2) / 255;

	NeoSetColor(255);
	NeoDrawRect(0, 0, 319, 239);

	for i := 0 to n do
		for j := 0 to n do begin
			a := i + v;
			b := r * i + x;
			u := sin(a) + sin(b);
			v := cos(a) + cos(b);
			x := u;

			a := u * s;
			b := v * s;
			c := ((i div 14) shl 4) or (j div 14);

			NeoWritePixel(Round(a) + 160, Round(b) + 120, c);
		end;

	time2 := NeoGetTimer;
	NeoSetTextColor(16, 15);
	GotoXY(1,1); write((time2 - time1) / 100);
	repeat until false;

end.