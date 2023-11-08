unit pm_flash;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: PokeyMAX library pm_flash.
* @version: 0.1.0
*
* @description:
* Set of useful constants, and structures to work with ATARI PokeyMAX. 
* Usefull to flash PokeyMAX.
*)

interface

uses pm_detect;


const

    // flash_CFG     = %00000100;
    // flash_FIRMWARE= %00000000;
    // flash_VALID   = $10000000;
    CONFIG_FLASHOP = $B;    // 11
    CONFIG_FLASHADL = $D;   // 13
    CONFIG_FLASHADH = $E;   // 14
    CONFIG_FLASHDAT = $F;   // 15

    FLASH_WRITEPROTECTMASK =  $F800000;
    FLASH_SECTORMASK =        $700000;
    FLASH_PAGEMASK =          $fffff;

var 
    flash1, flash2: LongWord;
    // pagesize: Word;
    // buffer: PWord;
    al: Byte;

function PMAX_GetPageSize: Word;
(*
* @description:
* Reads Pokey registry and returns size of page.
*)

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

function PMAX_GetPageSize: Word;
begin
    config[CONFIG_VERSION]:=5;
    if config[CONFIG_VERSION] = 6 then Result:= 1024
    else Result:= 512;
end;

procedure PMAX_FetchFlashAddress;
begin
    // flash1 := (LONGINT(config[5]) SHL 24) OR
    //           (LONGINT(config[3]) SHL 16) OR
    //           (LONGINT(config[2]) SHL 8) OR
    //           LONGINT(config[0]);
    
    // flash2 := (LONGINT(config[9]) SHL 24) OR
    //           (LONGINT(config[7]) SHL 8) OR
    //           LONGINT(config[6]);

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
    flash2:= PMAX_ReadFlash(0, 1);
  until (flash2 and $3) = 0;
end;

function PMAX_ReadFlash(addr: LongWord; cfgarea: Byte): LongWord;

  // reused flash1 variable for calculation

begin
  addr := addr SHL 2;

  al := addr and $ff;
  config[CONFIG_FLASHADL] := al or 3;
  config[CONFIG_FLASHADH] := (addr shr 8) and $ff;

  config[CONFIG_FLASHOP] := (((addr shr 16) and $7) SHL 3) or (cfgarea SHL 2) or 2 or 1;

  flash2 := config[CONFIG_FLASHDAT];
  config[CONFIG_FLASHADL] := al or 2;
  flash2 := flash2 SHL 8 or config[CONFIG_FLASHDAT];
  config[CONFIG_FLASHADL] := al or 1;
  flash2 := flash2 SHL 8 or config[CONFIG_FLASHDAT];
  config[CONFIG_FLASHADL] := al or 0;
  flash2 := flash2 SHL 8 or config[CONFIG_FLASHDAT];
  Result := flash2;
end;

procedure PMAX_WriteFlash(addr: LongWord; cfgarea: Byte; data: LongWord);
begin
  addr := addr SHL 2;

  al := addr and $ff;
  config[CONFIG_FLASHADL] := al or 0;
  config[CONFIG_FLASHADH] := (addr shr 8) and $ff;

  config[CONFIG_FLASHDAT] := data and $FF;
  config[CONFIG_FLASHADL] := al or 1;
  data := data shr 8;
  config[CONFIG_FLASHDAT] := data and $FF;
  config[CONFIG_FLASHADL] := al or 2;
  data := data shr 8;
  config[CONFIG_FLASHDAT] := data and $FF;
  config[CONFIG_FLASHADL] := al or 3;
  data := data shr 8;
  config[CONFIG_FLASHDAT] := data;

  config[CONFIG_FLASHOP] := (((addr shr 16) and $7) SHL 3) or (cfgarea SHL 2) or 2 or 0;
end;

procedure PMAX_WriteProtect(mode: Boolean);
begin
    flash1:= PMAX_ReadFlash(1, 1);
    flash1:= flash1 or FLASH_SECTORMASK or FLASH_PAGEMASK;
    if mode then flash1:= flash1 or FLASH_WRITEPROTECTMASK
    else flash1:=flash1 and (not FLASH_WRITEPROTECTMASK);
    PMAX_WriteFlash(1, 1, flash1);
end;

procedure PMAX_ErasePage(addr: LongWord);
begin
  flash1:= PMAX_ReadFlash(1, 1);
  flash1:= flash1 or FLASH_SECTORMASK;
  flash1:= flash1 and (not FLASH_PAGEMASK);
  flash1:= flash1 or addr;
  PMAX_WriteFlash(1, 1, flash1);
  PMAX_Wait;
end;

procedure PMAX_EraseSector(sector: Byte);
begin
  flash1:= PMAX_ReadFlash(1, 1);
  flash1:= flash1 or FLASH_PAGEMASK;
  flash1:= flash1 and (not FLASH_SECTORMASK);
  flash1:= flash1 or (LongWord(sector) SHL 20);
  PMAX_WriteFlash(1, 1, flash1);
  PMAX_Wait;
end;

end.