unit sys_vic20;
(*
 @type: unit
 @author: Bartosz Zbytniewski (Zbyti)
 @name: VI20 System
 @version: 1.0

 @description:
*)

//o-------------------------------------------------------------o

{
  o--------------------------------------------------------o
  | VIC 6560 NTSC / 6561 PAL                               |
  o--------------------------------------------------------o-------------------------------------o
  | Register | Hexadecimal |    Bit 7    | Bit 6 | Bit 5 | Bit 4 | Bit 3 | Bit 2 | Bit 1 | Bit 0 |
  o----------------------------------------------------------------------------------------------o
  |     0    |    9000     |  Interlace  |                 Horizontal origin                     |
  |----------------------------------------------------------------------------------------------|
  |     1    |    9001     |                           Vertical origin                           |
  |----------------------------------------------------------------------------------------------|
  |     2    |    9002     | Vid. Ad. b9 |                   Number of columns                   |
  |----------------------------------------------------------------------------------------------|
  |     3    |    9003     |    Rast. b0 |                 Number of rows                |  8/16 |
  |----------------------------------------------------------------------------------------------|
  |     4    |    9004     |                        Raster line (bits 8-1)                       |
  |----------------------------------------------------------------------------------------------|
  |     5    |    9005     |       Video addr (bits 13-10)       |   Char addr (bits 13-10)      |
  |----------------------------------------------------------------------------------------------|
  |     6    |    9006     |                         Light pen horizontal                        |
  |----------------------------------------------------------------------------------------------|
  |     7    |    9007     |                          Light pen vertical                         |
  |----------------------------------------------------------------------------------------------|
  |     8    |    9008     |                             Paddle X                                |
  |----------------------------------------------------------------------------------------------|
  |     9    |    9009     |                             Paddle Y                                |
  |----------------------------------------------------------------------------------------------|
  |    10    |    900A     |    enable   |                Oscillator 1 frequency                 |
  |----------------------------------------------------------------------------------------------|
  |    11    |    900B     |    enable   |                Oscillator 2 frequency                 |
  |----------------------------------------------------------------------------------------------|
  |    12    |    900C     |    enable   |                Oscillator 3 frequency                 |
  |----------------------------------------------------------------------------------------------|
  |    13    |    900D     |    enable   |                 White noise frequency                 |
  |----------------------------------------------------------------------------------------------|
  |    14    |    900E     |      AUX color (multi-color)        |            Volume             |
  |----------------------------------------------------------------------------------------------|
  |    15    |    900F     |               Background            | RV |         Border           |
  o----------------------------------------------------------------------------------------------o

  o-------------------------------------------------------------o
  | $9005 (bits 0-3) Character Map Location (unexpanded)        |
  | Hex Value   Hex Address   Type of characters                |
  o-------------------------------------------------------------o
  |  0           8000        uppercase                          |
  |  1           8400        uppercase reversed                 |
  |  2           8800        lowercase                          |
  |  3           8C00        lowercase reversed                 |
  |  4           9000        don't use - VIC chip               |
  |  5           9400        don't use - color map              |
  |  6           9800        don't use - I/O block              |
  |  7           9C00        don't use - I/O block              |
  |  8           0000        don't use - low RAM                |
  |  9           0400        can't be accessed                  |
  |  A           0800        can't be accessed                  |
  |  B           0C00        can't be accessed                  |
  |  C           1000        custom character set               |
  |  D           1400        custom character set               |
  |  E           1800        custom character set               |
  |  F           1C00        custom character set (2 pages)     |
  o-------------------------------------------------------------o

  o-------------------------------------------------------------o
  | $9005       $9002                                           |
  | Bits 7-4    Bit 7       Screen Map  Colour Map              |
  o-------------------------------------------------------------o
  | 1100            0         $1000       $9400                 |
  | 1100            1         $1200       $9600                 |
  | 1101            0         $1400       $9400                 |
  | 1101            1         $1600       $9600                 |
  | 1110            0         $1800       $9400                 |
  | 1110            1         $1A00       $9600                 |
  | 1111            0         $1C00       $9400                 |
  | 1111            1         $1E00       $9600                 |
  o-------------------------------------------------------------o

  o-------------------------------------------------------------o
  | Memory          Basic       Screen map      Colour map      |
  o-------------------------------------------------------------o
  | Unexpanded  $1000-$1DFF     $1E00-$1FFF     $9600-$97FF     |
  | +3K         $0400-$1DFF     $1E00-$1FFF     $9600-$97FF     |
  | +8K         $1200-$3FFF     $1000-$11FF     $9400-$95FF     |
  | +16K        $1200-$5FFF     $1000-$11FF     $9400-$95FF     |
  | +24K        $1200-$7FFF     $1000-$11FF     $9400-$95FF     |
  o-------------------------------------------------------------o

  o-------------------------------------------------------------o
  | Columns Rows     $9000               $9001                  |
  |               Bits 6-0                                      |
  |               Horizontal Offset   Vertical Offset           |
  o-------------------------------------------------------------o
  |  16      16       +6                  +16                   |
  |  22      23        0                    0                   |
  |  24      28       -3                   -9                   |
  |  25      30       -3                  -12                   |
  |  27      33       -5                  -19                   |
  o-------------------------------------------------------------o
}

//o-------------------------------------------------------------o

{
  $0000-$00FF free
  $0100-$01ff CPU stack
  $0200-$0313 free
  $0314-$0315 IRQ vector
  $0316-$0317 BRK vector
  $0318-$0319 NMI vector
  $031a-$03ff free
  $1000-$13ff custom charset memory
  $1400-$1bff free bytes
  $1c00-$1eed custom screen memory        25 * 30 = 750 bytes
  $1eee-$1fff free bytes                  16 + 256 bytes
  $9000-$93FF HW registers: VIC, 2xVIA
  $9400-$96ee color map                   4-bit memory
  $96f0-$97ff free nibbles                4-bit memory
}

//o-------------------------------------------------------------o

interface

//o-------------------------------------------------------------o

const
  BLACK        = 0;
  WHITE        = 1;
  RED          = 2;
  CYAN         = 3;
  PURPLE       = 4;
  GREEN        = 5;
  BLUE         = 6;
  YELLOW       = 7;
  ORANGE       = 8;
  LIGHT_ORANGE = 9;
  LIGHT_RED    = 10;
  LIGHT_CYAN   = 11;
  LIGHT_PURPLE = 12;
  LIGHT_GREEN  = 13;
  LIGHT_BLUE   = 14;
  LIGHT_YELLOW = 15;

  CHARSET_ADR  = $1000;
  SCREEN_ADR   = $1C00;
  COLORMAP_ADR = $9400;
  ROW_SIZE     = 25;
  COL_SIZE     = 30;
  ROW_MASK     = %00011111;
  COL_MASK     = %00011111;
  SCREEN_SIZE  = ROW_SIZE * COL_SIZE;
  CHARSET_SIZE = $400;
  CART_ADR     = $a000;
  CART_SIZE    = $2000;

  JOY_UP       = %00000100;
  JOY_DOWN     = %00001000;
  JOY_LEFT     = %00010000;
  JOY_RIGHT    = %10000000;
  JOY_FIRE     = %00100000;
  JOY_DIR_MASK = $10011100;

//:-------------------------------------------------------------:

var
  RTCLOCK  : byte absolute $60;
  JOY      : byte absolute $61;

//:-------------------------------------------------------------:

procedure sys_init; assembler;
procedure rsync(n: byte); assembler; register;
procedure wait; assembler; overload;
procedure wait(n: byte); assembler; overload; register;
procedure clrscr(v: byte); assembler; register;
procedure clrcol(c: byte); assembler; register;
procedure set_xy(x, y: byte); register;
procedure print(col: byte; s: pointer); assembler; register;
procedure put_char(col, c: byte); assembler; register;
procedure update_counter_2(v: byte; counter, scr_counter: pointer); assembler; register;
procedure update_counter_4(v: byte; counter, scr_counter: pointer); assembler; register;

function prnd: byte; register; assembler; overload;
function prnd(a, b, mask: byte): byte; register; overload;

//o-------------------------------------------------------------o

implementation

//o-------------------------------------------------------------o

const
  ZP_0_B       = $54;
  ZP_1_B       = $55;
  ZP_0_W       = $56;
  ZP_1_W       = $58;
  ZP_2_W       = $5a;
  ZP_3_W       = $5c;
  ZP_0_P       = $5e;

//:-------------------------------------------------------------:

  {
    characters : $1000-$13FF [128 chars; 4 pages]
    screen     : $1C00-$1EEE [25x30]
    colour map : $9400
  }
  vic_def  : array [0..15] of byte = (
    $09,                      // $9000 - horizontal centering; bit 7 is Interlace scan bit
    $1A,                      // $9001 - vertical centering
    $19,                      // $9002 - set # of columns; bit 7 is auxiliary byte of video address
    $3C,                      // $9003 - set # of rows; bit 1 is character size 8x8, or 8x16 pixels; bit 7 is raster beam location bit 0
    $00,                      // $9004 - TV raster beam line bit 8-1
    $FC,                      // $9005 - bits 0-3 start of character memory; 4-7 bytes of video address
    $00,                      // $9006 - horizontal position of light pen
    $00,                      // $9007 - vertical position of light pen
    $FF,                      // $9008 - Digitalized value of paddle X
    $FF,                      // $9009 - Digitalized value of paddle Y
    $00,                      // $900A - Frequency of oscillator 1 (low)
    $00,                      // $900B - Frequency of oscillator 2 (medium)
    $00,                      // $900C - Frequency of oscillator 3 (high)
    $00,                      // $900D - Frequency of noise source
    $00,                      // $900E - bit 0-3 sets volume of all sound; bits 4-7 are auxiliary color information
    (BLUE shl 4) + 8 + BLUE   // $900F - screen and border color register
  );

//:-------------------------------------------------------------:

  PAL_TIMER1   = $5686;
  VBI_START    = 146;

//:-------------------------------------------------------------:

// Vectors to interrupts routines
var
  CINV     : word absolute $0314; // handler for IRQVEC ($FFFE)
  CBINV    : word absolute $0316; // handler for RESVEC ($FFFC)
  NMINV    : word absolute $0318; // handler for NMIVEC ($FFFA)

//:-------------------------------------------------------------:

// The 6560/6561 VIC Chip Registers ($9000 - $900F)
var
  VICCR0   : byte absolute $9000; // Left edge of TV picture and interlace switch
  VICCR1   : byte absolute $9001; // Vertical TV picture origin
  VICCR2   : byte absolute $9002; // Number of columns displayed, part of screen map address
  VICCR3   : byte absolute $9003; // Number of character lines displayed, part of raster location
  VICCR4   : byte absolute $9004; // Raster beam location bits 8-1
  VICCR5   : byte absolute $9005; // Screen map and character map addresses
  VICCR6   : byte absolute $9006; // Light pen horizontal screen location
  VICCR7   : byte absolute $9007; // Light pen vertical screen location
  VICCR8   : byte absolute $9008; // Potentiometer X/Paddle X value
  VICCR9   : byte absolute $9009; // Potentiometer Y/Paddle Y value
  VICCRA   : byte absolute $900A; // Relative frequency of sound oscillator 1 (bass)
  VICCRB   : byte absolute $900B; // Relative frequency of sound oscillator 2 (alto)
  VICCRC   : byte absolute $900C; // Relative frequency of sound oscillator 3 (soprano)
  VICCRD   : byte absolute $900D; // Relative frequency of sound oscillator 4 (noise)
  VICCRE   : byte absolute $900E; // Sound volume and auxiliary color
  VICCRF   : byte absolute $900F; // Background color, border color, inverse color switch

//:-------------------------------------------------------------:

// 6522 Versatile Interface Adapter 1 ($9110 - $911F) [VIA No.1] NMI interrupts
var
  VIA1PB   : byte absolute $9110; // VIA1PB Port B I/O register
  VIA1PA   : byte absolute $9111; // Port A I/O register
  VIA1DDRB : byte absolute $9112; // Data direction register for port B
  VIA1DDRA : byte absolute $9113; // Data direction register for port A
  VIA1T1CL : byte absolute $9114; // Timer 1 least significant byte (LSB) of count
  VIA1T1CH : byte absolute $9115; // Timer 1 most significant byte (MSB) of count
  VIA1T1LL : byte absolute $9116; // Timer 1 low order (LSB) latch byte
  VIA1T1LH : byte absolute $9117; // Timer 1 high order (MSB) latch byte
  VIA1T2CL : byte absolute $9118; // Timer 2 low order (LSB) counter and LSB latch
  VIA1T2CH : byte absolute $9119; // Timer 2 high order (MSB) counter and MSB latch
  VIA1SR   : byte absolute $911A; // Shift register for parallel/serial conversion
  VIA1ACR  : byte absolute $911B; // Auxiliary control register
  VIA1PCR  : byte absolute $911C; // Peripheral control register for handshaking
  VIA1IFR  : byte absolute $911D; // Interrupt flag register (IFR)
  VIA1IER  : byte absolute $911E; // Interrupt enable register (IER)
  VIA1PA2  : byte absolute $911F; // This is a mirror of port A I/O register at location $9111


//:-------------------------------------------------------------:

// 6522 Versatile Interface Adapter 2 ($9120 - $912F) [VIA No.2] IRQ interrupts
var
  VIA2PB   : byte absolute $9120; // VIA2PB Port B I/O register
  VIA2PA   : byte absolute $9121; // Port A I/O register
  VIA2DDRB : byte absolute $9122; // Data direction register for port B
  VIA2DDRA : byte absolute $9123; // Data direction register for port A
  VIA2T1CL : byte absolute $9124; // Timer 1 least significant byte (LSB) of count
  VIA2T1CH : byte absolute $9125; // Timer 1 most significant byte (MSB) of count
  VIA2T1LL : byte absolute $9126; // Timer 1 low order (LSB) latch byte
  VIA2T1LH : byte absolute $9127; // Timer 1 high order (MSB) latch byte
  VIA2T2CL : byte absolute $9128; // Timer 2 low order (LSB) counter and LSB latch
  VIA2T2CH : byte absolute $9129; // Timer 2 high order (MSB) counter and MSB latch
  VIA2SR   : byte absolute $912A; // Shift register for parallel/serial conversion
  VIA2ACR  : byte absolute $912B; // Auxiliary control register
  VIA2PCR  : byte absolute $912C; // Peripheral control register for handshaking
  VIA2IFR  : byte absolute $912D; // Interrupt flag register (IFR)
  VIA2IER  : byte absolute $912E; // Interrupt enable register (IER)
  VIA2PA2  : byte absolute $912F; // This is a mirror of port A I/O register at location $9121

//:-------------------------------------------------------------:

var
  scr      : word absolute ZP_0_W;
  colmap   : word absolute ZP_1_W;
  tmp      : word absolute ZP_2_W;
  game_vbi : word absolute ZP_0_P;

  t0b      : byte absolute ZP_0_B;
  t1b      : byte absolute ZP_1_B;

//:-------------------------------------------------------------:

procedure sys_vbi; assembler; interrupt;
asm
      inc RTCLOCK

      ldx VIA1DDRA
      ldy VIA2DDRB
      mva #%11000011 VIA1DDRA
      lda VIA1PA
      stx VIA1DDRA
      and #%00111100                  // up, down, left, fire
      sta JOY
      mva #%01111111 VIA2DDRB
      lda VIA2PB
      sty VIA2DDRB
      and #%10000000                  // right
      ora JOY
      eor #%10111100                  // inverse values
      sta JOY

      jsr VBI

      mva #%01000000 VIA2IFR
      plr
end;

//:-------------------------------------------------------------:

procedure sys_init; assembler;
asm
      sei

      mva #%01111111 VIA1IER          // disable all NMI
      mva #%11000000 VIA2IER          // enable IRQ via2/timer1
      mva #%01000000 VIA2ACR          // put via2/timer1 in continuous free-running mode

      mwa #SYS_VBI CINV               // register IRQ procedure

      mva #0 RTCLOCK                  // reset raster

      lda #VBI_START                  // wait for 130 raster line
@     cmp VICCR4
      bne @-

      mwa #PAL_TIMER1 VIA2T1CL        // set via2/timer1; 1/50 sec.

      ldy #15
      mva:rpl adr.VIC_DEF,y VICCR0,y- // init VIC registers

      cli
end;

//:-------------------------------------------------------------:

procedure rsync(n: byte); assembler; register;
asm
      lda n
@     cmp VICCR4
      bne @-
end;

//:-------------------------------------------------------------:

procedure wait; assembler; overload;
asm
      lda:cmp:req RTCLOCK
end;

//:-------------------------------------------------------------:

procedure wait(n: byte); assembler; overload; register;
asm
      lda n
      add RTCLOCK
@     cmp RTCLOCK
      bne @-
end;

//:-------------------------------------------------------------:

procedure clrscr(v: byte); assembler; register;
asm
      ldy #0
      lda v
@     sta SCREEN_ADR,y
      sta SCREEN_ADR + $100,y
      sta SCREEN_ADR + $200,y
      iny
      bne @-
end;

//:-------------------------------------------------------------:

procedure clrcol(c: byte); assembler; register;
asm
      ldy #0
      lda c
@     sta COLORMAP_ADR,y
      sta COLORMAP_ADR + $100,y
      sta COLORMAP_ADR + $200,y
      iny
      bne @-
end;

//:-------------------------------------------------------------:

procedure set_xy(x, y: byte); register;
begin
  t0b := x; t1b := y;
  tmp := t1b * ROW_SIZE; inc(tmp, t0b);

  scr    := tmp + SCREEN_ADR;
  colmap := tmp + COLORMAP_ADR;
end;

//:-------------------------------------------------------------:

procedure print(col :byte; s: pointer); assembler; register;
asm
      ldy #0
      mva (s),y ZP_0_B
      tay:dey:inc s
@     mva (s),y (scr),y
      mva col (colmap),y
      dey
      bpl @-
end;

//:-------------------------------------------------------------:

procedure put_char(col, c: byte); assembler; register;
asm
      ldy #0
      mva c (scr),y
      mva col (colmap),y
end;

//:-------------------------------------------------------------:

procedure update_counter_2(v: byte; counter, scr_counter: pointer); assembler; register;
asm
      sed

      ldy #0
      lda (counter),y
      add v
      sta (counter),y

      cld

      ldy #0
      lda (counter),y
      pha
      and #%00001111
      ora #%00110000
      ldy #3
      sta (scr_counter),y
      pla
:4    lsr
      ora #%00110000
      dey
      sta (scr_counter),y
end;

//:-------------------------------------------------------------:

procedure update_counter_4(v: byte; counter, scr_counter: pointer); assembler; register;
asm
      sed

      ldy #0
      lda (counter),y
      add v
      sta (counter),y
      bcc @+
      iny
      lda (counter),y
      add #1
      sta (counter),y

@     cld

      ldy #0
      lda (counter),y
      pha
      and #%00001111
      ora #%00110000
      ldy #3
      sta (scr_counter),y
      pla
:4    lsr
      ora #%00110000
      dey
      sta (scr_counter),y

      dey
      lda (counter),y
      and #%00001111
      ora #%00110000
      sta (scr_counter),y
      lda (counter),y
:4    lsr
      ora #%00110000
      dey
      sta (scr_counter),y
end;

//:-------------------------------------------------------------:

function prnd: byte; register; assembler; overload;
asm
      lda VICCR4
      adc RTCLOCK
      eor VIA2T1LH
      eor VIA2T1LL
      eor VIA1T1CL
      eor VIA1T1CH
      sta RESULT
end;

//:-------------------------------------------------------------:

function prnd(a, b, mask: byte): byte; register; overload;
begin
  RESULT := prnd and mask;

  if RESULT < a then inc(RESULT,a);
  if RESULT > b then repeat
    RESULT := RESULT shr 1;
  until RESULT <= b;
end;


//o-------------------------------------------------------------o

initialization
  scr    := SCREEN_ADR;
  colmap := COLORMAP_ADR;
end.

//o-------------------------------------------------------------o
