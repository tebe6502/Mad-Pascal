unit pokeymaxconf;
(*
 @type: unit
 @author: MADRAFi <madrafi@gmail.com>
 @name: Pokey MAX Configuration

 @version: 1.0

 @description:
*)

interface

type
  TConfig = record
    MODE,
    CAPABILITY,
    POSTDIVIDE,
    GTIAEN,
    PSGMODE,
    SIDMODE,
    RESTRICT:byte;
    _RESERVED:array[0..2] of byte;
    _FLASH:array[0..4] of byte;
  end;

const

//
// PokeyMax Mode register -----------------------------------------------------
//
{
  Miscellaneous settings
}

  pmc_PAL         = %00100000;
{
  PAL
  0  (0) = NTSC: Use 4/7 PHI2 multiplier for 1MHz clock
  1 (32) = PAL: Use 5/9 PHI2 multipler for 1MHz clock
}

  pmc_MonoDet     = %00010000;
{
  MonoDet
  0  (0) = Left channel to left, right channel to right
  1 (16) = When right channel is silent, play left on both left and right.
}

  pmc_IRQEn       = %00001000;
{
  IRQEna
  0  (0) = Only pokey 1 irq is enabled
  1  (8) = All IRQs are enabled
}

  pmc_ChannelMode = %00000100;
{
  [Pokey] ChannelMode
  0  (0) = Each pokey outputs as a separate ‘chip’
  1  (4) = Output each pokey channel separately. E.g. channel 1 on AUD, channel 2
  on audio pin 1, channel 3 on audio pin 2 and channel 4 on
}

  pmc_Saturate    = %00000001;
{
  [Pokey] Saturate
  0  (0) = Linear saturation curve
  1  (1) = Pokey saturation curve
}

//
// PokeyMax CAPABILITY register -----------------------------------------------
//

  pmc_FLASH       = %01000000;
{
  FLASH
  0  (0) = Device does not support reading or writing flash contents
  1 (64) = Device supports flash memory access (UFM and CFM)
}

  pmc_SAMPLE      = %00100000;
{
  SAMPLE
  0  (0) = Device does not contain a sample player
  1 (32) = Device contains a block ram based sample player, with 32KB of memory
}

  pmc_COVOX       = %00010000;
{
  COVOX
  0  (0) = Device does not contain a COVOX
  1 (16) = Device contains four 8-bit COVOX manual volume registers
}

  pmc_PSG         = %00001000;
{
  PSG
  0  (0) = Device does not contain a PSG
  1  (8) = Device contains two PSG chips
}

  pmc_SID         = %00000100;
{
  SID
  0  (0) = Device does not contain a SID
  1  (4) = Device contains two SID chips
}

  pmc_POKEYS      = %00000011;
{
  Pokey
  00  (0) = Device contains a single pokey
  01  (1) = Device contains two pokeys
  10  (2) = Device contains four pokeys
}
  pmc_POKEY_MONO  = %00000000;
  pmc_POKEY_STEREO= %00000001;
  pmc_POKEY_QUAD  = %00000010;

//
// PokeyMax POSTDIVIDE register -----------------------------------------------
//

{
  PokeyMAX natively outputs 0-5V on each audio output. A single audio chip at
  max volume will be 5V and at min volume 0V.
  For internal output into the Atari pin 37 this is correct.
  For line level output we want closer to 1V, this register allows us to achieve this
  by dividing selected channels by 2, 4 or 8, giving 0-2.5V, 0-1.25V or 0-0.0675V.
  NB: When multiple devices are outputting at once, we could have a range of 0-
  10V, 0-20V or even 0-50V! Note that the pokeymax can natively only output 0-5V
  so anything above 5V will saturate. By using the /4 you will be able to have 4
  devices at maximum volume with no distortion
}
  pmc_POSTDIVCH0  = %00000011;
{
  CH0
  00  (0) = /1
  01  (1) = /2
  10  (2) = /4
  11  (3) = /8
}
  pmc_POSTDIV0_1  = %00000000;
  pmc_POSTDIV0_2  = %00000001;
  pmc_POSTDIV0_4  = %00000010;
  pmc_POSTDIV0_8  = %00000011;

  pmc_POSTDIVCH1  = %00001100;
{
  CH1
  00  (0) = /1
  01  (4) = /2
  10  (8) = /4
  11 (12) = /8
}
  pmc_POSTDIV1_1  = %00000000;
  pmc_POSTDIV1_2  = %00000100;
  pmc_POSTDIV1_4  = %00001000;
  pmc_POSTDIV1_8  = %00001100;

  pmc_POSTDIVCH2  = %00110000;
{
  CH2
  00  (0) = /1
  01 (16) = /2
  10 (32) = /4
  11 (48) = /8
}
  pmc_POSTDIV2_1  = %00000000;
  pmc_POSTDIV2_2  = %00010000;
  pmc_POSTDIV2_4  = %00100000;
  pmc_POSTDIV2_8  = %00110000;

  pmc_POSTDIVCH3  = %11000000;
{
  00  (0) = /1
  01 (64) = /2
  10(128) = /4
  11(192) = /8
}
  pmc_POSTDIV3_1  = %00000000;
  pmc_POSTDIV3_2  = %01000000;
  pmc_POSTDIV3_4  = %10000000;
  pmc_POSTDIV3_8  = %11000000;

//
// PokeyMax GTIAEN register ---------------------------------------------------
//
{
  This register allows mixing gtia into the output channels.
  Typically this is done for the channels actual to phono connectors and not for
  channels directly outputting into the system, since the motherboard already
  mixes gtia.
}
  pmc_GTIAEN      = %00001111;
{
  bits 3-0 are:
  0 = gtia not included in channel 0-3
  1 = gtia included in channel 0-3
}
  pmc_GTIA0       = %00000001;
  pmc_GTIA1       = %00000010;
  pmc_GTIA2       = %00000100;
  pmc_GTIA3       = %00001000;

//
// PokeyMax PSGMODE register --------------------------------------------------
//
{
  This register allows changing settings for the PSG chips
}
  psg_VOLP        = %01100000;
{
  VOLP
  00  (0) = Log volume
  11 (96) = Linear volume
}

  psg_LOGVol      = %0000000;
  psg_LINVol      = $1100000;

  psg_ENV         = %00010000;
{
  ENV
  0  (0) = 32 step envelope
  1 (16) = 16 step envelope
}

  psg_ENV16       = %10000;
  psg_ENV32       = %00000;

  psg_STEREO      = %00001100;
{
STEREO
  00  (0) = mono. All channels of both chips to left and right
  01  (4) = Polish standard. A+B to left, B+C to right. For both chips.
  10  (8) = Czech standard. A+C to left, B+C to right. For both chips
  11 (12) = chip 1 to left, chip 2 to right.
}

  psg_MONO        = %0000;
  psg_ABBC        = $0100;
  psg_ACBC        = $1000;
  psg_CLCR        = $1100;

  psg_FREQ        = %00000011;
{
  FREQ
  00  (0) = 2MHz
  01  (1) = 1MHz
  10  (2) = 1.7MHz
  11  (3) = reserved
}

  psg_2MHz        = %00;
  psg_1MHz        = %01;
  psg_1_7MHz      = %10;

//
// PokeyMax SIDMODE register --------------------------------------------------
//
{
  This register allows changing settings for the SID chips. This changes the filter
  curve linear to approximate the very non-linear 6581 curve. It also changes the
  mixed waveforms and enables 6581 filter distortion. Digifix may also be
  enabled/disabled for the 8580.
}

  sid_1_CHIPTYPE  = %00000001;
  sid_2_CHIPTYPE  = %00010000;
{
  CHIP
    0 = 8580 (linear filter)
    1 = 6581
}

  sid_1_DIGIFIX   = %00000010;
  sid_2_DIGIFIX   = %00100000;
{
  DIGIFIX
    0 = DIGIFIX OFF
    1 = DIGIFIX ON
}

//
// PokeyMax RESTRICT register -------------------------------------------------
//
{
  Allows disabling sound chips via software. This is used by the U1MB plugin.
}

  pmr_SAMPLE      = %00010000;
{
  SAMPLE
  0  (0) = COVOX/SAMPLE area replaced by pokey 1
  1  (8) = COVOX/SAMPLE on
}

  pmr_PSG         = %00001000;
{
  PSG
  0  (0) = PSG area replaced by pokey 1
  1  (8) = PSG on
}

  pmr_SID         = %00000100;
{
  SID
  0  (0) = SID area replaced by pokey 1
  1  (4) = SID on
}

  pmr_POKEYS      = %00000011;
{
  POKEY
  00  (0) = Mono
  01  (1) = Stereo (if off area replaced by pokey1)
  10  (2) = Quad (if off area replaced by pokey1)
}
  pmr_POKEY_MONO  = %00000000;
  pmr_POKEY_STERO = %00000001;
  pmr_POKEY_QUAD  = %00000010;

//
// PokeyMax CONFIG register ---------------------------------------------------
//
  pmc_CFGEN     = %00111111;
{
CFGEN
00111111(63) –Map configuration into the $D210-$D21F memory area
Others values - $D210-$D21F is unchanged
}

//
// PokeyMax FLASHOP registe
//

  flash_CFG     = %00000100;
  flash_FIRMWARE= %00000000;
  flash_VALID   = $10000000; // this constans does belong to PokeyMax!!
                             // Use ONLY in 'flashPokeyMax' function
                             // causes, validation of FLASH memory writing
{
  CFG
  0  (0) = Access data area (i.e. main flash data).
  1  (4) = Access cfg area. This consists of two special registers in the max 10 for
           status, write protect and page/sector erase.
}

  flash_REQ     = %00000010;
{
  REQ
  0  (0) = Do not make a 32-bit wide request to the flash controller.
  1  (2) = Make a new 32-bit wide request to the flash controller. Once it is complete,
           REQ is cleared. For reads you can expect data to be available in the 32-bit
           FLASHDAT register by the next cycle. Writes/erases may takes longer. Writes
           takes data from the 32-bit FLASHDAT register.
}

  flash_RW      = %00000001;
{
  R/W
  0  (0) = write to flash data or cfg (must erase first)
  1  (1) = read from flash data or cfg
}
  flash_Read    = %00000001;
  flash_Write   = %00000000;

  flash_A14_16  = %00111000;
{
  mask for address bits A14 thru A16
}

// PokeyMax FLASHADH
  flash_A6_13   = %11111111;
{
  mask for address bits A6 thru A13
}

// PokeyMax FLASHADL
  flash_A0_5    = %11111100;
{
  mask for address bits A0 thru A5
}

  flash_WIN     = %00000011;
{
  mask for 32-bit window address
}

var
  [volatile] pmcID:byte absolute $d20c;         // R
  [volatile] pmcCONFIG:byte absolute $d20c;     // W
  [volatile] pmcVERSION:byte absolute $d214;    // R
  [volatile] pmcVERSIONLOC:byte absolute $d214; // W
  [volatile] pmcFLASHOP:byte absolute $d21b;    // W
  [volatile] pmcFLASHADL:byte absolute $d21d;   // W
  [volatile] pmcFLASHADH:byte absolute $d21e;   // W
  [volatile] pmcFLASHDAT:byte absolute $d21f;   // R/W
  [volatile] lifeConfig:TConfig absolute $d210; // R/W

function detectPokeyMax:Boolean;
function GetVersion:PString;
procedure FetchConfiguration(var _config:TConfig);
function FlashPokeyMax(var _data; startAdr:word; size:byte; mode:byte):boolean;
procedure FlashConfiguration(var _config:TConfig);

implementation

function detectPokeyMAX:boolean;
begin
  result:=(pmcID=1);
end;

function GetVersion:PString;
var
  i:byte;

begin
  result[0]:=#8;
  for i:=1 to 8 do
  begin
    pmcVERSIONLOC:=i-1;
    result[i]:=char(pmcVERSION);
  end;
end;

procedure FetchConfiguration(var _config:TConfig);
begin
  pmcCONFIG:=pmc_CFGEN;
  move(LifeConfig,_config,sizeOf(TConfig));
  pmcCONFIG:=0;
end;

{
  function for flash PokeyMax chip
  _data - source of data
  startAdr - begining address of flash
  size - size of data (max 256 bytes at once)
  mode - FLASH_CFG for flash configuration
         FLASH_FIRMWARE for flash firmware
         FLASH_VALID for validate data
  return:
  true  - if flush is correct
  false - if not
}
function FlashPokeyMax(var _data; startAdr:word; size:byte; mode:byte):boolean;
var
  adr:Word absolute $d8;
  adrL:Byte absolute $d8;
  adrH:Byte absolute $d9;
  _fOP:byte absolute $da;
  _fAH:byte absolute $db;
  _FAL:byte absolute $dc;
  data:array[0..0] of byte;

  i:byte;
  validate:boolean;

  procedure setAddr;
  begin
    _fOP:=(adrH and %11100000) shr 2;
    _fAH:=(adrH shl 3) or (adrL shr 2);
    _fAL:=adrL shl 2;
  end;

begin
  validate:=(mode and FLASH_VALID)<>0;
  mode:=mode and FLASH_CFG; // prevent, from bad values
  data:=_data;

  adr:=startAdr;

  // erase
  setAddr;
  pmcFLASHOP:=_fOP or mode or flash_Write;
  pmcFLASHADH:=_fAH;

  for i:=0 to size-1 do
  begin
    pmcFLASHADL:=_fAL or (i and 3);
    pmcFLASHDAT:=$FF;
    if i and 3=3 then // after each 4 bytes (32-bits) push request to PokeyMax
      pmcFLASHOP:=_fOP or mode or flash_REQ or flash_Write;
      inc(_fAL);
  end;

  // write
  setAddr;
  pmcFLASHOP:=_fOP+mode or flash_Write;
  pmcFLASHADH:=_fAH;

  for i:=0 to size-1 do
  begin
    pmcFLASHADL:=_fAL or (i and 3);
    pmcFLASHDAT:=data[i];
    if i and 3=3 then // after each 4 bytes (32-bits) push request to PokeyMax
      pmcFLASHOP:=_fOP or mode or flash_REQ or flash_Write;
    inc(_fAL);
  end;

  // correct check
  if validate then
  begin
    setAddr;
    pmcFLASHOP:=_fOP+mode or flash_Read;
    pmcFLASHADH:=_fAH;

    for i:=0 to size-1 do
    begin
      pmcFLASHADL:=_fAL or (i and 3);
      if pmcFLASHDAT<>data[i] then exit(false);
      if i and 3=3 then // after each 4 bytes (32-bits) push request to PokeyMax
        pmcFLASHOP:=_fOP or mode or flash_REQ or flash_Read;
      inc(_fAL);
    end;
  end;
  result:=true;
end;

procedure FlashConfiguration(var _config:TConfig);
begin
  pmcCONFIG:=pmc_CFGEN; // enable PokeyMax config bank
  flashPokeyMax(_config,$0000,$10,FLASH_CFG);
  pmcCONFIG:=0; // just disable PokeyMax config bank
end;

end.