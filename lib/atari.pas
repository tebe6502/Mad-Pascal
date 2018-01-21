// changes: 03.11.2016

unit atari;

{


}

interface

type
	dmactl = (blank = %00, narrow = %01, normal = %10, wide = %11, missiles= %100, players = %1000, oneline = %10000, enable = %100000);

var
	rtclok: byte absolute $12;
	atract: byte absolute $4D;
	lmargin: byte absolute $52;		// lewy margines ekranu
	rmargin: byte absolute $53;		// prawy margines ekranu
	rowcrs: byte absolute $54;		// pionowa pozycja kursora
	colcrs: word absolute $55;		// (2) pozioma pozycja kursora
	dindex: byte absolute $57;		// numer trybu graficznego OS
	savmsc: word absolute $58;		// (2) adres pamieci obrazu

	vdslst: word absolute $200;
	sdlstl: word absolute $230;
	txtrow: byte absolute $290;		// wiersz kursora w oknie tekstowym
	txtcol: word absolute $291;		// (2) kolumna kursora w oknie tekstowym
	tindex: byte absolute $293;		// tryb graficzny OS w oknie tekstowym
	txtmsc: word absolute $294;		// adres pamieci okna tekstowego

	sdmctl: byte absolute $22F;		// rejestr cien DMACTL
	gprior: byte absolute $26F;		// rejestr cien GTIACTL
	crsinh: byte absolute $2F0;		// znacznik widocznosci kursora
	chact: byte absolute $2F3;		// rejestr cien CHRCTL
	chbas: byte absolute $2F4;		// rejestr cien CHBASE
	ch: byte absolute $2FC;			// rejestr cien KBCODE

	pcolr0: byte absolute $02C0;
	pcolr1: byte absolute $02C1;
	pcolr2: byte absolute $02C2;
	pcolr3: byte absolute $02C3;
	color0: byte absolute $02C4;
	color1: byte absolute $02C5;
	color2: byte absolute $02C6;
	color3: byte absolute $02C7;
	color4: byte absolute $02C8;

	hposp0: byte absolute $D000;
	hposp1: byte absolute $D001;
	hposp2: byte absolute $D002;
	hposp3: byte absolute $D003;
	hposm0: byte absolute $D004;
	hposm1: byte absolute $D005;
	hposm2: byte absolute $D006;
	hposm3: byte absolute $D007;

	P0PF: byte absolute $d004;

	Pal: byte absolute $D014;		// (R) znacznik systemu TV PAL = 1, NTSC = 15

	colpm0: byte absolute $D012;
	colpm1: byte absolute $D013;
	colpm2: byte absolute $D014;
	colpm3: byte absolute $D015;
	colpf0: byte absolute $D016;
	colpf1: byte absolute $D017;
	colpf2: byte absolute $D018;
	colpf3: byte absolute $D019;
	colbk: byte absolute $D01A;

	prior: byte absolute $D01B;
	gractl: byte absolute $D01D;
	hitclr: byte absolute $D01E;

	audf1: byte absolute $D200;
	audc1: byte absolute $D201;
	audf2: byte absolute $D202;
	audc2: byte absolute $D203;
	audf3: byte absolute $D204;
	audc3: byte absolute $D205;
	audf4: byte absolute $D206;
	audc4: byte absolute $D207;
	audctl: byte absolute $D208;
	skstat: byte absolute $D20F;

	portb: byte absolute $D301;

	dlistl: word absolute $D402;
	pmbase: byte absolute $D407;
	wsync: byte absolute $D40A;
	vcount: byte absolute $D40B;
	nmien: byte absolute $D40E;
	chbase: byte absolute $D409;
	hscrol: byte absolute $D404;
	vscrol: byte absolute $D405;

implementation



end.
