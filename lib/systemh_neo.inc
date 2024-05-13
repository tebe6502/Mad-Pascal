
	NEO_CURSOR_LEFT 	= chr(1);
	NEO_CURSOR_RIGHT	= chr(4);
	NEO_INSERT		= chr(5);
	NEO_PAGE_DOWN		= chr(6);
	NEO_END			= chr(7);
	NEO_BACKSPACE		= chr(8);
	NEO_HTAB		= chr(9);	// horizontal tab
	NEO_LINE_FEED		= chr(10);
	NEO_CLEAR_SCREEN	= chr(12);
	NEO_ENTER		= chr(13);
	NEO_PAGE_UP		= chr(18);
	NEO_CURSOR_DOWN 	= chr(19);
	NEO_CURSOR_HOME		= chr(20);
	NEO_VTAB 		= chr(22);	// vertical tab
	NEO_CURSOR_UP		= chr(23);
	NEO_CURSOR_REV		= chr(24);	// cursor reverse
	NEO_DELETE		= chr(26);
	NEO_ESCAPE		= chr(27);	// general break – e.g. exits BASIC

// 	;--------------------------;
//	; color control characters ;
//	;--------------------------;

	NEO_COLOR_BLACK			= chr($80);
	NEO_COLOR_RED			= chr($81);
	NEO_COLOR_GREEN			= chr($82);
	NEO_COLOR_YELLOW		= chr($83);
	NEO_COLOR_BLUE			= chr($84);
	NEO_COLOR_MAGENTA		= chr($85);
	NEO_COLOR_CYAN			= chr($86);
	NEO_COLOR_WHITE			= chr($87);
	NEO_COLOR_ALT_BLACK		= chr($88);
	NEO_COLOR_DARK_GREY		= chr($89);
	NEO_COLOR_DARK_GREEN		= chr($8A);
	NEO_COLOR_ORANGE		= chr($8B);
	NEO_COLOR_DARK_ORANGE		= chr($8C);
	NEO_COLOR_BROWN			= chr($8D);
	NEO_COLOR_PINK			= chr($8E);
	NEO_COLOR_LIGHT_GREY		= chr($8F);

(* file mode *)
	fmOpenRead	= $04;
	fmOpenWrite	= $08;
	fmOpenAppend	= $09;
	fmOpenReadWrite	= $0c;

var
	DateSeparator: Char = '-';

	FileMode: byte = fmOpenReadWrite;

	GraphMode: byte;		(* @var current screen mode *)

	IOResult: byte;			(* @var result of last file IO operation *)

	EoLn: Boolean;			(* @var end of line status *)

	ScreenWidth: smallint = 40;	(* @var current screen width *)
	ScreenHeight: smallint = 24;	(* @var current screen height *)
