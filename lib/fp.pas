unit fp;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Float-point OS
 @version: 1.1

 @description:

*)


{


}

interface

type
	FloatOS = array [0..5] of byte;


	procedure _atofp(var inbuff, flptr); external;				// ascii -> fp
	procedure _fptoa(var loadfr0.adr, ptr1); external;			// fp -> ascii

	procedure _itofp(fr0: integer; var flptr); external;			// int32 [-65535..65535] -> fp
	function _fptoi(var flptr): integer; external;				// fp -> int32 [-65535..65535]

	procedure _fpadd(var loadfr0.adr, loadfr1.adr, flptr); external;
	procedure _fpsub(var loadfr0.adr, loadfr1.adr, flptr); external;
	procedure _fpdiv(var loadfr0.adr, loadfr1.adr, flptr); external;
	procedure _fpmul(var loadfr0.adr, loadfr1.adr, flptr); external;

	function _fpgt(var loadfr0.adr, loadfr1.adr): Boolean; external;	// >
	function _fplt(var loadfr0.adr, loadfr1.adr): Boolean; external;	// <
	function _fpne(var loadfr0.adr, loadfr1.adr): Boolean; external;	// <>
	function _fplteq(var loadfr0.adr, loadfr1.adr): Boolean; external;	// <=
	function _fpgteq(var loadfr0.adr, loadfr1.adr): Boolean; external;	// >=
	function _fpeq(var loadfr0.adr, loadfr1.adr): Boolean; external;	// =

implementation


{$link fp/fp.obj}


end.
