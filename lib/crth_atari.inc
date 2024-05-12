
var
	TextAttr: byte = 0;			(* @var Text Attribute *)
	Consol: byte absolute $d01f;		// CONSOL register

const
	CN_START_SELECT_OPTION	= 0;		// Consol values
	CN_SELECT_OPTION	= 1;
	CN_START_OPTION		= 2;
	CN_OPTION		= 3;
	CN_START_SELECT		= 4;
	CN_SELECT		= 5;
	CN_START		= 6;
	CN_NONE			= 7;

{ Foreground and background color constants }

	BLACK                 = $00;
	WHITE                 = $0F;
	RED                   = $26;
	CYAN                  = $AC;
	PURPLE                = $48;
	GREEN                 = $B6;
	BLUE                  = $86;
	YELLOW                = $DC;
	ORANGE                = $18;
	BROWN                 = $F4;
	LIGHT_RED             = $2A;
	DARK_GREY             = $04;
	GREY                  = $08;
	LIGHT_GREEN           = $BC;
	LIGHT_BLUE            = $9A;
	LIGHT_GREY            = $0C;

