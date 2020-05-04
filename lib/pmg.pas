unit PMG;
(*
  @type: unit
  @name: Player/missile graphics library

  @author: Bostjan Gorisek (Gury)

	Tebe - Core, supporting routines, modifications

  Initial release date: 6.10.2015
  @version: 1.0 R1 Beta

  Modifications:
    v1.0 (7.10.2015) - Tebe
	- Fixed usage of Unit (module) libraries (routine exchange)
	- Core and supporting routines (DPoke, DPeek, Fillchar)
	- Custom pointer variables for customizing P/M graphics in main program
    v1.1 (8.10.2015) - Gury:
	- Missile support
	- DPoke -> Poke
	- Code revisited
	- Documentation (comments)
    v1.2 (12.12.2015) - Tebe
	- Power -> math.pas
	- MoveM: Case statement
*)

{

ColorPM
ClearPM
InitPM
MoveM
MoveP
SetPM
ShowPM
SizeP
SizeMx

}


interface


uses math;

const
  _P_MAX = 14;          // Number of player data values
  _M0_MAX = 2;          // Number of missile 0 data values
  _M1_MAX = 0;          // Number of missile 1 data values
  _M2_MAX = 3;          // Number of missile 2 data values
  _M3_MAX = 4;          // Number of missile 3 data values
  _PM_NORMAL_SIZE = 0;  // PM normal size
  _PM_DOUBLE_SIZE = 1;  // PM double size
  _PM_QUAD_SIZE   = 3;  // PM quadruple size
  _PM_SHOW_ON     = 3;  // Show PM graphics
  _PM_SHOW_OFF    = 0;  // Hide/reset PM graphics
  _PM_DOUBLE_RES  = 1;  // PM double-line resolution
  _PM_SINGLE_RES  = 2;  // PM single-line resolution

var
  p_data : array [0..3] of pointer;	(* @var Player data graphics address *)
  m_data : array [0..3] of pointer;	(* @var Missile data graphics address *)

  pm_mem : word;			(* @var P/M graphics supporting variables *)
  pm_offset : word = 512;		(* @var P/M graphics supporting variables *)
  pm_top : byte = 8;			(* @var P/M graphics supporting variables *)
  pm_size : word = 128;			(* @var P/M graphics supporting variables *)


	procedure SetPM(res : byte);
	procedure ClearPM;
	procedure MoveP(p : byte; x : word; y : byte);
	procedure MoveM(m : byte; x : word; y : byte);
	procedure ColorPM(pm, col : byte);
	procedure SizeP(p, value : byte);
	function SizeMx(m, value : byte) : byte;
	procedure SizeM(m0, m1, m2, m3 : byte);
	procedure ShowPM(show : byte);
	procedure InitPM(res : byte);



implementation


procedure SetPM (res : byte);
(*
* @description:
* Set P/M variables
*
* @param: res (byte) - P/M graphics resolution type
* @param: _PM_SINGLE_RES
* @param: _PM_DOUBLE_RES
*)
begin
  pm_offset := 512 * res;
  pm_size := 128 * res;
  if res = _PM_SINGLE_RES then
    pm_top := 16
  else
    pm_top := 8;
end;


procedure ClearPM;
(*
* @description:
* Clear player/missile memory
*)
begin
  fillchar(pointer(pm_mem+pm_offset-pm_size), pm_size*5, 0);
end;


procedure MoveP (p : byte; x : word; y : byte);
(*
* @description:
* Draw and move selected player
*
* @param: p (byte) - selected player
* @param: x (word) - player horizontal coordinate
* @param: y (byte) - player vertical coordinate
*)
begin
  // Erase top and bottom line of player data
  Poke(pm_mem+pm_offset+pm_size*p+y-1, 0);
  Poke(pm_mem+pm_offset+pm_size*p+y+_P_MAX+1, 0);
  // Vertical position of player
  move(p_data[p], pointer(pm_mem+pm_offset+pm_size*p+y), _P_MAX+1);  // 1.1
  // Horizontal position of player
  Poke(53248+p, x);
end;


procedure MoveM (m : byte; x : word; y : byte);
(*
* @description:
* Draw and move selected missile
*
* @param: m (byte) - selected missile
* @param: x (word) - missile horizontal coordinate
* @param: y (byte) - missile vertical coordinate
*)
begin
  // Erase top line of missile data
  Poke(pm_mem+pm_offset-pm_size+y-1, 0);
  // Draw missile

  case m of

   0: begin
	Poke(pm_mem+pm_offset-pm_size+y+_M0_MAX+1, 0);
	move(m_data[m], pointer(pm_mem+pm_offset-pm_size+y), _M0_MAX+1);
      end;

   1: begin
	Poke(pm_mem+pm_offset-pm_size+y+_M1_MAX+1, 0);
	move(m_data[m], pointer(pm_mem+pm_offset-pm_size+y), _M1_MAX+1);
      end;

   2: begin
	Poke(pm_mem+pm_offset-pm_size+y+_M2_MAX+1, 0);
	move(m_data[m], pointer(pm_mem+pm_offset-pm_size+y), _M2_MAX+1);
      end;

   3: begin
	Poke(pm_mem+pm_offset-pm_size+y+_M3_MAX+1, 0);
	move(m_data[m], pointer(pm_mem+pm_offset-pm_size+y), _M3_MAX+1);
      end;

   end;

  // Missile horizontal position
  Poke(53252+m, x);
end;


procedure ColorPM (pm, col : byte);
(*
* @description:
* Player/missile color
*
* @param: pm (byte) - selected player
* @param: col (byte) - player color
*)
begin
  Poke(704+pm, col);
end;


procedure SizeP (p, value : byte);
(*
* @description:
* Player size
*
* @param: p (byte) - selected player
* @param: value (byte) - player size:
* @param: _PM_NORMAL_SIZE (0 = normal)
* @param: _PM_DOUBLE_SIZE (1 = double)
* @param: _PM_QUAD_SIZE   (3 = quadruple)
*)
begin
  Poke(53256+p, value);
end;


function SizeMx(m, value : byte) : byte;
(*
* @description:
* Calculate bit numbers for selected missile size
*
* @param: m (shortint) - selected missile
* @param: value (byte) - missile size:
* @param: _PM_NORMAL_SIZE (0 = normal)
* @param: _PM_DOUBLE_SIZE (1 = double)
* @param: _PM_QUAD_SIZE   (3 = quadruple)
*
* @returns: (byte) Calculated bit number for selected missile size
*)
var
  i : byte;
  mem : Byte = 0;
begin
  if value = _PM_DOUBLE_SIZE then begin
    mem := 1;
    if m > 0 then begin
      mem := Power(4, m);
    end;

  end else if value = _PM_QUAD_SIZE then begin
    mem := 3;
    if m > 0 then begin
      mem := 3 * Power(4, m);
    end;

  end;
  result := mem;
end;


procedure SizeM (m0, m1, m2, m3 : byte);
(*
* @description:
* Set missile sizes
*
* @param: m0 (byte) - size for missile 0
* @param: m1 (byte) - size for missile 1
* @param: m2 (byte) - size for missile 2
* @param: m3 (byte) - size for missile 3
*)
var
  mem : byte = 0;
begin
  mem := SizeMx(0, m0);
  mem := mem + SizeMx(1, m1);
  mem := mem + SizeMx(2, m2);
  mem := mem + SizeMx(3, m3);
  Poke(53260, mem);
end;


procedure ShowPM (show : byte);
(*
* @description:
* P/M graphics visibility
*
* @param: show (byte) - flag for selecting P/M visibility
* @param: _PM_SHOW_ON
* @param: _PM_SHOW_OFF
*)
begin
  Poke(53277, show);
end;


procedure InitPM (res : byte);
(*
* @description:
* Initialize P/M graphics
*
* @param: res (byte) - P/M graphics resolution type
* @param: _PM_DOUBLE_RES
* @param: _PM_SINGLE_RES
*)
begin
  Poke(53277, 0);
  pm_mem := Peek(106) - pm_top;
  Poke(54279, pm_mem);
  pm_mem := pm_mem * 256;
  if res = _PM_DOUBLE_RES then
    Poke(559, 46)
  else begin
    Poke(559, 62);
  end;
  ClearPM;
end;

end.
