
var	WIN_LEFT: smallint = 0;
	WIN_RIGHT: smallint = 39;
	WIN_TOP: smallint = 0;
	WIN_BOTTOM: smallint = 23;

	ScreenRAM : pointer;


	procedure SetDisplayBuffer(var a: TDisplayBuffer);
	procedure SetActiveBuffer(var a: TDisplayBuffer);
	function Scanline(y: smallint): PByte;
	function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
	procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);
