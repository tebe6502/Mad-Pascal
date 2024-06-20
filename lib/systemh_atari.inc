
	__PORTB_BANKS = $0101;		// memory banks array

	mGTIA	= 0;
	mVBXE	= $80;
//	WINDOW	= $10;			// text window
//	NARROW	= $20;			// narrow screen

	VBXE_XDLADR = $0000;		// XDLIST
	VBXE_BCBTMP = $00E0;		// BLITTER TEMP
	VBXE_BCBADR = $0100;		// BLITTER LIST ADDRESS
	VBXE_MAPADR = $1000;		// COLOR MAP ADDRESS (row = 256b default)
	VBXE_CHBASE = $1000;		// CHARSET BASE ADDRESS
	VBXE_OVRADR = $5000;		// OVERLAY ADDRESS
	VBXE_WINDOW = $B000;		// 4K WINDOW $B000..$BFFF

	iDLI = 0;			// set new DLI vector
	iVBL = 1;			// set new VBLD vector
	iVBLD = 1;
	iVBLI = 2;			// set new VBLI vector
	iTIM1 = 3;			// set new IRQ TIMER1 vector
	iTIM2 = 4;			// set new IRQ TIMER2 vector
	iTIM4 = 5;			// set new IRQ TIMER4 vector

(* Character codes *)
	CH_DELCHR	= chr($FE);	// delete char under the cursor
	CH_ENTER	= chr($9B);
	CH_ESC		= chr($1B);
	CH_CURS_UP	= chr(28);
	CH_CURS_DOWN	= chr(29);
	CH_CURS_LEFT	= chr(30);
	CH_CURS_RIGHT	= chr(31);

	CH_TAB		= chr($7F);	// tabulator
	CH_EOL		= chr($9B);	// end-of-line marker
	CH_CLR		= chr($7D);	// clear screen
	CH_BELL		= chr($FD);	// bell
	CH_DEL		= chr($7E);	// back space (delete char to the left)
	CH_DELLINE	= chr($9C);	// delete line
	CH_INSLINE	= chr($9D);	// insert line

(* color defines *)
	PAL_PMCOLOR0	= 0;		// palette index Palette[..] , HPalette[..]
	PAL_PMCOLOR1	= 1;
	PAL_PMCOLOR2	= 2;
	PAL_PMCOLOR3	= 3;

	PAL_COLOR0	= 4;
	PAL_COLOR1	= 5;
	PAL_COLOR2	= 6;
	PAL_COLOR3	= 7;
	PAL_COLBAK	= 8;

	COLOR_BLACK		= $00;
	COLOR_WHITE		= $0e;
	COLOR_RED		= $32;
	COLOR_CYAN		= $96;
	COLOR_VIOLET		= $68;
	COLOR_GREEN		= $c4;
	COLOR_BLUE		= $74;
	COLOR_YELLOW		= $ee;
	COLOR_ORANGE		= $28;
	COLOR_BROWN		= $e4;
	COLOR_LIGHTRED		= $3c;
	COLOR_GRAY1		= $04;
	COLOR_GRAY2		= $06;
	COLOR_GRAY3		= $0a;
	COLOR_LIGHTGREEN	= $cc;
	COLOR_LIGHTBLUE 	= $7c;

(* file mode *)
	fmOpenRead	= $04;
	fmOpenWrite	= $08;
	fmOpenAppend	= $09;
	fmOpenReadWrite	= $0c;

var
	DateSeparator: Char = '-';

	[volatile] Rnd: byte absolute $d20a;
	Palette: array [0..8] of byte absolute 704;
	HPalette: array [0..8] of byte absolute $d012;

	FileMode: byte = fmOpenReadWrite;

	GraphMode: byte;		(* @var current screen mode *)

	IOResult: byte;			(* @var result of last file IO operation *)

	EoLn: Boolean;			(* @var end of line status *)

	ScreenWidth: smallint = 40;	(* @var current screen width *)
	ScreenHeight: smallint = 24;	(* @var current screen height *)
