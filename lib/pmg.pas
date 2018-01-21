unit pmg;

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


{
  Player/missile graphics library  
  Unit: PMG.PAS
    
  Author: Bostjan Gorisek (Gury)
          Tebe - Core, supporting routines, modifications
  Initial release date: 6.10.2015
  Version: 1.0 R1 Beta

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
}

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
  // Player data graphics address
  p_data : array [0..3] of pointer;
  // Missile data graphics address
  m_data : array [0..3] of pointer;

  // P/M graphics supporting variables  
  pm_mem : word;
  pm_offset : word = 512;
  pm_top : byte = 8;  // 1.1
  pm_size : word = 128;


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


//-----------------------------------------------------------------------------
// Procedure  : SetPM
// Description: Set P/M variables
// Parameters : res (byte) - P/M graphics resolution type
//                           (_PM_SINGLE_RES, _PM_DOUBLE_RES)
//-----------------------------------------------------------------------------
procedure SetPM(res : byte);
begin
  pm_offset := 512 * res;
  pm_size := 128 * res;
  if res = _PM_SINGLE_RES then
    pm_top := 16
  else
    pm_top := 8;
end;
 
//-----------------------------------------------------------------------------
// Procedure  : ClearPM
// Description: Clear player/missile memory
//-----------------------------------------------------------------------------
procedure ClearPM;
begin
  fillchar(pointer(pm_mem+pm_offset-pm_size), pm_size*5, 0);
end;

//-----------------------------------------------------------------------------
// Procedure  : MoveP
// Description: Draw and move selected player
// Parameters : p (byte) - selected player
//              x (word) - player horizontal coordinate
//              y (byte) - player vertical coordinate
//-----------------------------------------------------------------------------
procedure MoveP(p : byte; x : word; y : byte);
begin
  // Erase top and bottom line of player data
  Poke(pm_mem+pm_offset+pm_size*p+y-1, 0);
  Poke(pm_mem+pm_offset+pm_size*p+y+_P_MAX+1, 0);
  // Vertical position of player   
  move(p_data[p], pointer(pm_mem+pm_offset+pm_size*p+y), _P_MAX+1);  // 1.1
  // Horizontal position of player
  Poke(53248+p, x);
end;

//-----------------------------------------------------------------------------
// Procedure  : MoveM
// Description: Draw and move selected missile
// Parameters : m (byte) - selected missile
//              x (word) - missile horizontal coordinate
//              y (byte) - missile vertical coordinate
//-----------------------------------------------------------------------------
procedure MoveM(m : byte; x : word; y : byte);
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

//-----------------------------------------------------------------------------
// Procedure  : ColorPM
// Description: Player/missile color
// Parameters : pm (byte) - selected player
//              col (byte) - player color
//-----------------------------------------------------------------------------
procedure ColorPM(pm, col : byte);
begin
  Poke(704+pm, col);
end;

//-----------------------------------------------------------------------------
// Procedure  : SizeP
// Description: Player size
// Parameters : p (byte) - selected player
//              value (byte) - player size:
//                _PM_NORMAL_SIZE (0 = normal)
//                _PM_DOUBLE_SIZE (1 = double)
//                _PM_QUAD_SIZE   (3 = quadruple)
//-----------------------------------------------------------------------------
procedure SizeP(p, value : byte);
begin
  Poke(53256+p, value);
end;

//-----------------------------------------------------------------------------
// Function      : SizeMx
// Description   : Calculate bit numbers for selected missile size
// Parameters    : m (shortint) - selected missile
//                 value (byte) - missile size:
//                   _PM_NORMAL_SIZE (0 = normal)
//                   _PM_DOUBLE_SIZE (1 = double)
//                   _PM_QUAD_SIZE   (3 = quadruple)
// Returns (byte): Calculated bit number for selected missile size
//-----------------------------------------------------------------------------
function SizeMx(m: shortint; value : byte) : byte;
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

//-----------------------------------------------------------------------------
// Procedure  : SizeM
// Description: Set missile sizes
// Parameters : m0 (byte) - size for missile 0
//              m1 (byte) - size for missile 1
//              m2 (byte) - size for missile 2
//              m3 (byte) - size for missile 3
//-----------------------------------------------------------------------------
procedure SizeM(m0, m1, m2, m3 : byte);
var
  mem : byte = 0;
begin
  mem := SizeMx(0, m0);
  mem := mem + SizeMx(1, m1);
  mem := mem + SizeMx(2, m2);
  mem := mem + SizeMx(3, m3);
  Poke(53260, mem);
end;

//-----------------------------------------------------------------------------
// Procedure  : ShowPM
// Description: P/M graphics visibility
// Parameters : show (byte) - flag for selecting P/M visibility
//                            (_PM_SHOW_ON, _PM_SHOW_OFF)
//-----------------------------------------------------------------------------
procedure ShowPM(show : byte);
begin
  Poke(53277, show);
end;

//-----------------------------------------------------------------------------
// Procedure  : InitPM
// Description: Initialize P/M graphics
// Parameters : res (byte) - P/M graphics resolution type
//                           (_PM_DOUBLE_RES, _PM_SINGLE_RES)
//-----------------------------------------------------------------------------
procedure InitPM(res : byte);
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

