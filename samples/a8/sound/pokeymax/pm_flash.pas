unit pm_flash;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: PokeyMAX library pm_flash.
* @version: 0.3.0
*
* @description:
* Set of useful constants, and structures to work with ATARI PokeyMAX. 
* Usefull to flash PokeyMAX.
*)

interface

uses pm_detect;


const
    CONFIG_FLASHOP = $B;    // 11
    CONFIG_FLASHADL = $D;   // 13
    CONFIG_FLASHADH = $E;   // 14
    CONFIG_FLASHDAT = $F;   // 15

    FLASH_WRITEPROTECTMASK =  $F800000;
    FLASH_SECTORMASK =        $700000;
    FLASH_PAGEMASK =          $fffff;

var 
    flash1, flash2: LongWord;
    al: Byte;
    res: LongWord;

procedure PMAX_FetchFlashAddress;
(*
* @description:
* Reads Pokey registry and sets flash variable.
*)

procedure PMAX_Wait;
(*
* @description:
* Reads flash and waits until status is 0. This procedure is called after Write to flash.
*)

function PMAX_ReadFlash(addr: LongWord; cfgarea: Byte): LongWord;
(*
* @description:
* Reads flash and returns content.
* addr Address to read from
* cfgarea 
*)

procedure PMAX_WriteFlash(addr: LongWord; cfgarea: Byte; data: LongWord);
(*
* @description:
* Write provided data to flash.
* addr Address to write to
* data Data to be written
* cfgarea 
*)

procedure PMAX_WriteProtect(mode: Boolean);
(*
* @description:
* Prepares flash to be writable.
* TRUE      non-writable - write protected
* FALSE     writable
*)

procedure PMAX_ErasePage(addr: LongWord);
(*
* @description:
* Erase page in flash under provided address.
* addr Address to write to
*)
procedure PMAX_EraseSector(sector: Byte);
(*
* @description:
* Erase provided sector in flash.
* sector to erase
*)

implementation

// function PMAX_GetPageSize: Word;
// begin
//     config[CONFIG_VERSION]:=5;
//     if config[CONFIG_VERSION] = 6 then Result:= 1024
//     else Result:= 512;
// end;

procedure PMAX_FetchFlashAddress;
begin

    flash1 := (LONGINT(config[CONFIG_PSGMODE]) SHL 24) OR
              (LONGINT(config[CONFIG_GTIA]) SHL 16) OR
              (LONGINT(config[CONFIG_DIV]) SHL 8) OR
              LONGINT(config[CONFIG_MODE]);
    
    flash2 := (LONGINT(config[CONFIG_OUTPUT]) SHL 24) OR
              (LONGINT(config[CONFIG_RESTRICT]) SHL 8) OR
              LONGINT(config[CONFIG_SIDMODE]);
end;

procedure PMAX_Wait;
begin
  repeat
    res:= PMAX_ReadFlash(0, 1);
  until (res and $3) = 0;
end;

function PMAX_ReadFlash(addr: LongWord; cfgarea: Byte): LongWord;
begin
  addr := addr SHL 2;

  al := addr and $ff;
  config[CONFIG_FLASHADL] := al or 3;
  config[CONFIG_FLASHADH] := (addr SHR 8) and $ff;

  config[CONFIG_FLASHOP] := (((addr SHR 16) and $7) SHL 3) or (cfgarea SHL 2) or 2 or 1;

  res:= config[CONFIG_FLASHDAT];
  config[CONFIG_FLASHADL] := al or 2;
  res:= res SHL 8;
  res:= res or config[CONFIG_FLASHDAT];
  config[CONFIG_FLASHADL] := al or 1;
  res:= res SHL 8;
  res:= res or config[CONFIG_FLASHDAT];
  config[CONFIG_FLASHADL] := al or 0;
  res:= res SHL 8;
  res:= res or config[CONFIG_FLASHDAT];
  Result := res;
end;

procedure PMAX_WriteFlash(addr: LongWord; cfgarea: Byte; data: LongWord);
begin
  addr := addr SHL 2;

  al := addr and $ff;
  config[CONFIG_FLASHADL] := al or 0;
  config[CONFIG_FLASHADH] := (addr SHR 8) and $ff;

  config[CONFIG_FLASHDAT] := data and $FF;
  config[CONFIG_FLASHADL] := al or 1;
  data := data SHR 8;
  config[CONFIG_FLASHDAT] := data and $FF;
  config[CONFIG_FLASHADL] := al or 2;
  data := data SHR 8;
  config[CONFIG_FLASHDAT] := data and $FF;
  config[CONFIG_FLASHADL] := al or 3;
  data := data SHR 8;
  config[CONFIG_FLASHDAT] := data;

  config[CONFIG_FLASHOP] := (((addr SHR 16) and $7) SHL 3) or (cfgarea SHL 2) or 2 or 0;
end;

procedure PMAX_WriteProtect(mode: Boolean);
begin
    res:= PMAX_ReadFlash(1, 1);
    res:= res or FLASH_SECTORMASK or FLASH_PAGEMASK;
    if mode then res:= res or FLASH_WRITEPROTECTMASK
    else res:=res and (not FLASH_WRITEPROTECTMASK);
    PMAX_WriteFlash(1, 1, res);
end;

procedure PMAX_ErasePage(addr: LongWord);
begin
  res:= PMAX_ReadFlash(1, 1);
  res:= res or FLASH_SECTORMASK;
  res:= res and (not FLASH_PAGEMASK);
  res:= res or addr;
  PMAX_WriteFlash(1, 1, res);
  PMAX_Wait;
end;

procedure PMAX_EraseSector(sector: Byte);
begin
  res:= PMAX_ReadFlash(1, 1);
  res:= res or FLASH_PAGEMASK;
  res:= res and (not FLASH_SECTORMASK);
  res:= res or (LongWord(sector) SHL 20);
  PMAX_WriteFlash(1, 1, res);
  PMAX_Wait;
end;

end.