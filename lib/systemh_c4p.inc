
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
