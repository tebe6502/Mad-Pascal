
(* Character codes *)

  PETSCII_SWAP_COLOR		= $01;
  PETSCII_CLEAR	        	= $93;
  PETSCII_BELL		        = $07;
  PETSCII_REVERSE_ON	        = $12;
  PETSCII_REVERSE_OFF	        = $92;
  PETSCII_ISO_ON	        = $0f;
  PETSCII_ISO_OFF	        = $8f;
  PETSCII_SWAP_LOWCHARSET       = $0e;
  PETSCII_SWAP_GFXCHARSET       = $8e;
  PETSCII_VERBATIM_MODE		= $80;

  PETSCII_CURSOR_UP	        = $91;
  PETSCII_CURSOR_DOWN	        = $11;
  PETSCII_CURSOR_RIGHT        	= $1d;
  PETSCII_CURSOR_LEFT         	= $9d;
  PETSCII_KEY_ESC		= $1b;
  PETSCII_KEY_BACKSPACE	      	= $14;
  PETSCII_KEY_DEL	        = $19;
  PETSCII_KEY_RETURN	        = $0d;
  PETSCII_KEY_SHIFT_RETURN	= $8d;
  PETSCII_KEY_TAB	        = $09;
  PETSCII_KEY_SHIFT_TAB	      	= $18;
  PETSCII_KEY_MENU	        = $06;
  PETSCII_KEY_HOME	        = $13;
  PETSCII_KEY_INSERT	        = $94;
  PETSCII_KEY_END	        = $04;
  PETSCII_KEY_HELP	        = $84;

  PETSCII_KEY_PAGEUP	        = $82;
  PETSCII_KEY_PAGEDOWN	      	= $02;
  PETSCII_KEY_F1	        = $85;
  PETSCII_KEY_F2	        = $89;
  PETSCII_KEY_F3	        = $86;
  PETSCII_KEY_F4	        = $8a;
  PETSCII_KEY_F5	        = $87;
  PETSCII_KEY_F6	        = $8b;
  PETSCII_KEY_F7	        = $88;
  PETSCII_KEY_F8	        = $8c;
  PETSCII_KEY_F9	        = $10;
  PETSCII_KEY_F10	        = $15;
  PETSCII_KEY_F11	        = $16;
  PETSCII_KEY_F12	        = $17;

  X16_CLEAR_SCREEN	  = chr(PETSCII_CLEAR);
  X16_SWAP_COLOR	  = chr(PETSCII_SWAP_COLOR);
  X16_BELL		  = chr(PETSCII_BELL);
  X16_REVERSE_ON	  = chr(PETSCII_REVERSE_ON);
  X16_REVERSE_OFF	  = chr(PETSCII_REVERSE_OFF);
  X16_ISO_ON	          = chr(PETSCII_ISO_ON);
  X16_ISO_OFF	          = chr(PETSCII_ISO_OFF);
  X16_SWAP_CHARSET        = chr(PETSCII_SWAP_LOWCHARSET);
  X16_SWAP_GFXCHARSET     = chr(PETSCII_SWAP_GFXCHARSET);
  X16_VERBATIM_MODE	  = chr(PETSCII_VERBATIM_MODE);

  X16_CURSOR_UP	          = chr(PETSCII_CURSOR_UP);
  X16_CURSOR_DOWN	  = chr(PETSCII_CURSOR_DOWN);
  X16_CURSOR_RIGHT        = chr(PETSCII_CURSOR_RIGHT);
  X16_CURSOR_LEFT         = chr(PETSCII_CURSOR_LEFT);
  X16_KEY_ESC	      	  = chr(PETSCII_KEY_ESC);
  X16_KEY_BACKSPACE	  = chr(PETSCII_KEY_BACKSPACE);
  X16_KEY_DEL	          = chr(PETSCII_KEY_DEL);
  X16_KEY_RETURN	  = chr(PETSCII_KEY_RETURN);
  X16_KEY_SHIFT_RETURN	  = chr(PETSCII_KEY_SHIFT_RETURN);
  X16_KEY_TAB	          = chr(PETSCII_KEY_TAB);
  X16_KEY_SHIFT_TAB	  = chr(PETSCII_KEY_SHIFT_TAB);
  X16_KEY_MENU	          = chr(PETSCII_KEY_MENU);
  X16_KEY_HOME	          = chr(PETSCII_KEY_HOME);
  X16_KEY_INSERT	  = chr(PETSCII_KEY_INSERT);
  X16_KEY_END	          = chr(PETSCII_KEY_END);
  X16_KEY_HELP	          = chr(PETSCII_KEY_HELP);

  X16_KEY_PAGEUP	  = chr(PETSCII_KEY_PAGEUP);
  X16_KEY_PAGEDOWN	  = chr(PETSCII_KEY_PAGEDOWN);
  X16_KEY_F1	          = chr(PETSCII_KEY_F1);
  X16_KEY_F2	          = chr(PETSCII_KEY_F2);
  X16_KEY_F3	          = chr(PETSCII_KEY_F3);
  X16_KEY_F4	          = chr(PETSCII_KEY_F4);
  X16_KEY_F5	          = chr(PETSCII_KEY_F5);
  X16_KEY_F6	          = chr(PETSCII_KEY_F6);
  X16_KEY_F7	          = chr(PETSCII_KEY_F7);
  X16_KEY_F8	          = chr(PETSCII_KEY_F8);
  X16_KEY_F9	          = chr(PETSCII_KEY_F9);
  X16_KEY_F10	          = chr(PETSCII_KEY_F10);
  X16_KEY_F11	          = chr(PETSCII_KEY_F11);
  X16_KEY_F12	          = chr(PETSCII_KEY_F12);

(* file mode *)
  fmOpenRead		= $04;
  fmOpenWrite		= $08;
  fmOpenAppend		= $09;
  fmOpenReadWrite	= $0c;

var
	DateSeparator: Char = '-';

	FileMode: byte = fmOpenReadWrite;

	GraphMode: byte;		(* @var current screen mode *)

	IOResult: byte;			(* @var result of last file IO operation *)

	EoLn: Boolean;			(* @var end of line status *)

	ScreenWidth: smallint = 80;	(* @var current screen width *)
	ScreenHeight: smallint = 60;	(* @var current screen height *)


	function VPeek(bank: byte; addr: word): byte; register; stdcall; assembler;
	procedure VPoke(bank: byte; addr:word; value:byte); register; stdcall; assembler;
