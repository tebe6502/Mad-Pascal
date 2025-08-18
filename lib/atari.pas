unit atari;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Common used memory registers (Atari XE/XL)
 @version: 1.3

 @description:
 <https://www.atariarchives.org/mapping/memorymap.php>
*)


{


}

interface

type	TDMACtl = (blank = %00, narrow = %01, normal = %10, wide = %11, missiles= %100, players = %1000, oneline = %10000, enable = %100000);
	(*
	@description:

	*)

const
    DL_BLANK1 = 0; // 1 blank line
    DL_BLANK2 = %00010000; // 2 blank lines
    DL_BLANK3 = %00100000; // 3 blank lines
    DL_BLANK4 = %00110000; // 4 blank lines
    DL_BLANK5 = %01000000; // 5 blank lines
    DL_BLANK6 = %01010000; // 6 blank lines
    DL_BLANK7 = %01100000; // 7 blank lines
    DL_BLANK8 = %01110000; // 8 blank lines

    DL_DLI = %10000000; // Order to run DLI
    DL_LMS = %01000000; // Order to set new memory address
    DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
    DL_HSCROLL = %00010000; // Turn on horizontal scroll on this line

    DL_JMP = %00000001; // Order to jump
    DL_JVB = %01000001; // Jump to begining

			// Antic Modes
    DL_MODE_2 = $2;
    DL_MODE_3 = $3;
    DL_MODE_4 = $4;
    DL_MODE_5 = $5;

    DL_MODE_E = $E;
    DL_MODE_F = $F;

var
	[volatile] irqens: byte absolute $10;		// rejestr cien IRQEN

	[volatile] rtclok: byte absolute $12;

	[volatile] rtclok1: byte absolute $12;
	[volatile] rtclok2: byte absolute $13;
	[volatile] rtclok3: byte absolute $14;

	atract: byte absolute $4D;
	lmargin: byte absolute $52;		// lewy margines ekranu
	rmargin: byte absolute $53;		// prawy margines ekranu
	rowcrs: byte absolute $54;		// pionowa pozycja kursora
	colcrs: word absolute $55;		// (2) pozioma pozycja kursora
	dindex: byte absolute $57;		// numer trybu graficznego OS
	savmsc: word absolute $58;		// (2) adres pamieci obrazu
	palnts: byte absolute $62;
	ramtop: byte absolute $6a;

	vdslst: word absolute $200;		// (2) adres programu przerwania 'Display List'
	sdlstl: word absolute $230;		// (2) adres programu ANTIC-a 'Display List'
	txtrow: byte absolute $290;		// wiersz kursora w oknie tekstowym
	txtcol: word absolute $291;		// (2) kolumna kursora w oknie tekstowym
	tindex: byte absolute $293;		// tryb graficzny OS w oknie tekstowym
	txtmsc: word absolute $294;		// (2) adres pamieci okna tekstowego

	sdmctl: byte absolute $22F;		// rejestr cien DMACTL
	gprior: byte absolute $26F;		// rejestr cien GTIACTL
	crsinh: byte absolute $2F0;		// znacznik widocznosci kursora
	chact: byte absolute $2F3;		// rejestr cien CHRCTL
	chbas: byte absolute $2F4;		// rejestr cien CHBASE
	ch: byte absolute $2FC;			// rejestr cien KBCODE
	fildat: byte absolute $02FD;		// numer koloru dla FILL

	pcolr0: byte absolute $02C0;		// cienie rejestrow kolorow $D012 .. $D01A
	pcolr1: byte absolute $02C1;
	pcolr2: byte absolute $02C2;
	pcolr3: byte absolute $02C3;
	color0: byte absolute $02C4;
	color1: byte absolute $02C5;
	color2: byte absolute $02C6;
	color3: byte absolute $02C7;
	color4: byte absolute $02C8;
	colbaks: byte absolute $02C8;

	hposp0: byte absolute $D000;		// rejestry dla poziomej pozycja duchow
	hposp1: byte absolute $D001;
	hposp2: byte absolute $D002;
	hposp3: byte absolute $D003;
	hposm0: byte absolute $D004;		// rejestry dla poziomej pozycja pociskow
	hposm1: byte absolute $D005;
	hposm2: byte absolute $D006;
	hposm3: byte absolute $D007;

	sizep0: byte absolute $D008;		// poziomy rozmiar gracza 0 (Z)
	sizep1: byte absolute $D009;		// poziomy rozmiar gracza 1 (Z)
	sizep2: byte absolute $D00A;		// poziomy rozmiar gracza 2 (Z)
	sizep3: byte absolute $D00B;		// poziomy rozmiar gracza 3 (Z)
	sizem: byte absolute $D00C;		// poziomy rozmiar pociskow (Z)

	grafp0: byte absolute $D00D;		// rejestr grafiki gracza 0 (Z)
	grafp1: byte absolute $D00E;		// rejestr grafiki gracza 1 (Z)
	grafp2: byte absolute $D00F;		// rejestr grafiki gracza 2 (Z)
	grafp3: byte absolute $D010;		// rejestr grafiki gracza 3 (Z)
	grafm: byte absolute $D011;		// rejestr grafiki pociskow (Z)

	P0PF: byte absolute $D004;

	Pal: byte absolute $D014;		// (R) znacznik systemu TV PAL = 1, NTSC = 15

	[volatile] trig3: byte absolute $d013;	// (R) znacznik podlaczenia cartridga

	colpm0: byte absolute $D012;		// rejestry sprzetowe kolorow duchow i pociskow
	colpm1: byte absolute $D013;
	colpm2: byte absolute $D014;
	colpm3: byte absolute $D015;
	colpf0: byte absolute $D016;		// rejestry sprzetowe kolorow pola gry
	colpf1: byte absolute $D017;
	colpf2: byte absolute $D018;
	colpf3: byte absolute $D019;

	colbak: byte absolute $D01A;		// rejestr sprzetowy koloru tla
	colbk: byte absolute $D01A;		// rejestr sprzetowy koloru tla

	prior: byte absolute $D01B;		// rejestr piorytetu GTIA
	gractl: byte absolute $D01D;		// rejestr kontroli PMG
	pmcntl: byte absolute $D01D;
	hitclr: byte absolute $D01E;		// rejestr zerujacy kolizje PMG
	consol: byte absolute $D01F;		// console keys status

	audf1: byte absolute $D200;
	audc1: byte absolute $D201;
	audf2: byte absolute $D202;
	audc2: byte absolute $D203;
	audf3: byte absolute $D204;
	audc3: byte absolute $D205;
	audf4: byte absolute $D206;
	audc4: byte absolute $D207;
	audctl: byte absolute $D208;
	kbcode: byte absolute $D209;		// code of last pressed key

	irqen: byte absolute $D20E;		// zezwolenie przerwan IRQ (Z)
	skstat: byte absolute $D20F;

	porta: byte absolute $D300;
	portb: byte absolute $D301;
	pactl: byte absolute $D302;

	dmactl: byte absolute $D400;
	chactl: byte absolute $D401;
	dlistl: word absolute $D402;
	hscrol: byte absolute $D404;
	vscrol: byte absolute $D405;
	pmbase: byte absolute $D407;
	chbase: byte absolute $D409;
	wsync: byte absolute $D40A;
	[volatile] vcount: byte absolute $D40B;
	penh: byte absolute $D40C;
	penv: byte absolute $D40D;
	nmien: byte absolute $D40E;

	nmivec	: word absolute $FFFA;		// wektor przerwania NMI (6502)
	resetvec: word absolute $FFFC;		// wektor przerwania RESET
	irqvec	: word absolute $FFFE;		// wektor przerwania IRQ

implementation


end.
