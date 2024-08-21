unit fp;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Float-point OS
 @version: 1.0

 @description:

*)


{


}

interface

	procedure _atofp(var inbuff, flptr); external;
	procedure _fptoa(var loadfr0.adr, ptr1); external;

	procedure _itofp(fr0: word; var flptr); external;
	function _fptoi(flptr: word): word; external;

	procedure _fpadd(var loadfr0.adr, loadfr1.adr, flptr); external;
	procedure _fpsub(var loadfr0.adr, loadfr1.adr, flptr); external;
	procedure _fpdiv(var loadfr0.adr, loadfr1.adr, flptr); external;
	procedure _fpmul(var loadfr0.adr, loadfr1.adr, flptr); external;

	function _fpgt(var loadfr0.adr, loadfr1.adr): Boolean; external;
	function _fplt(var loadfr0.adr, loadfr1.adr): Boolean; external;
	function _fpne(var loadfr0.adr, loadfr1.adr): Boolean; external;
	function _fplteq(var loadfr0.adr, loadfr1.adr): Boolean; external;
	function _fpgteq(var loadfr0.adr, loadfr1.adr): Boolean; external;
	function _fpeq(var loadfr0.adr, loadfr1.adr): Boolean; external;

implementation


{$link fp/fp.obx}


end.
