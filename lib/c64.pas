unit c64;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: C64
 @version: 1.0

 @description:

*)

interface

var

(*

// Standard Kernal ROM routines
  CHKIN      = $ffc6; // CHKIN. Define file as default input. (Must call OPEN beforehand.)
  CHKOUT     = $ffc9; // CHKOUT. Define file as default output. (Must call OPEN beforehand.)
  CHRIN      = $ffcf; // CHRIN. Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehand.)
  CHROUT     = $ffd2; // CHROUT. Write byte to default output. (If not screen, must call OPEN and CHKOUT beforehand.)
  CLALL      = $ffe7; // CLALL. Clear file table; call CLRCHN.
  CLOSE      = $ffc3; // CLOSE. Close file.
  CLRCHN     = $ffcc; // CLRCHN. Close default input/output files (for serial bus, send UNTALK and/or UNLISTEN); restore default input/output to keyboard/screen.
  GETIN      = $ffe4; // GETIN. Read byte from default input. (If not keyboard, must call OPEN and CHKIN beforehand.)
  IECIN      = $ffa5; // IECIN. Read byte from serial bus. (Must call TALK and TALKSA beforehand.)
  IECOUT     = $ffa8; // IECOUT. Write byte to serial bus. (Must call LISTEN and LSTNSA beforehand.)
  IOBASE     = $fff3; // IOBASE. Fetch CIA #1 base address.
  IOINIT     = $ff84; // IOINIT. Initialize CIA's, SID volume; setup memory configuration; set and start interrupt timer.
  LISTEN     = $ffb1; // LISTEN. Send LISTEN command to serial bus.
  LOAD       = $ffd5; // LOAD. Load or verify file. (Must call SETLFS and SETNAM beforehand.)
  LSTNSA     = $ff93; // LSTNSA. Send LISTEN secondary address to serial bus. (Must call LISTEN beforehand.)
  MEMBOT     = $ff99; // MEMBOT. Save or restore start address of BASIC work area.
  MEMTOP     = $ff9c; // MEMTOP. Save or restore end address of BASIC work area.
  OPEN       = $ffc0; // OPEN. Open file. (Must call SETLFS and SETNAM beforehand.)
  PLOT       = $fff0; // PLOT. Save or restore cursor position.
  RAMTAS     = $ff87; // RAMTAS. Clear memory addresses $0002-$0101 and $0200-$03FF; run memory test and set start and end address of BASIC work area accordingly; set screen memory to $0400 and datasette buffer to $033C.
  RDTIM      = $ffde; // RDTIM. read Time of Day, at memory address $00A0-$00A2.
  READST     = $ffb7; // READST. Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
  RESTOR     = $ff8a; // RESTOR. Fill vector table at memory addresses $0314-$0333 with default values.
  SAVE       = $ffd8; // SAVE. Save file. (Must call SETLFS and SETNAM beforehand.)
  SCINIT     = $ff81; // SCINIT. Initialize VIC; restore default input/output to keyboard/screen; clear screen; set PAL/NTSC switch and interrupt timer.
  SCNKEY     = $ff9f; // SCNKEY. Query keyboard; put current matrix code into memory address $00CB, current status of shift keys into memory address $028D and PETSCII code into keyboard buffer.
  SCREEN     = $ffed; // SCREEN. Fetch number of screen rows and columns.
  SETLFS     = $ffba; // SETLFS. Set file parameters.
  SETMSG     = $ff90; // SETMSG. Set system error display switch at memory address $009D.
  SETNAM     = $ffbd; // SETNAM. Set file name parameters.
  SETTIM     = $ffdb; // SETTIM. Set Time of Day, at memory address $00A0-$00A2.
  SETTMO     = $ffa2; // SETTMO. Unknown. (Set serial bus timeout.)
  STOP       = $ffe1; // STOP. Query Stop key indicator, at memory address $0091; if pressed, call CLRCHN and clear keyboard buffer.
  TALK       = $ffb4; // TALK. Send TALK command to serial bus.
  TALKSA     = $ff96; // TALKSA. Send TALK secondary address to serial bus. (Must call TALK beforehand.)
  UDTIM      = $ffea; // UDTIM. Update Time of Day, at memory address $00A0-$00A2, and Stop key indicator, at memory address $0091.
  UNLSTN     = $ffae; // UNLSTN. Send UNLISTEN command to serial bus.
  UNTALK     = $ffab; // UNTALK. Send UNTALK command to serial bus.
  VECTOR     = $ff8d; // VECTOR. Copy vector table at memory addresses $0314-$0333 from or into user table.

// floating point routines
  MOVFM      = $bba2; // MOVFM. Move a Floating Point Number from Memory to FAC1
  FOUT       = $bddd; // FOUT. Convert Contents of FAC1 to ASCII String
  MOV2F      = $bbc7; // MOV2F. Move a Floating Point Number from FAC1 to Memory

// interrupt routines and vectors
  IRQVECLO   = $0314; // hardware interrupt (IRQ) vector, low byte
  IRQVECHI   = $0315; // hardware interrupt (IRQ) vector, high byte
  STDIRQ     = $ea31; //start address of standard interrupt routines

// keyboard
  CURRKEY    = $cb;   // currently pressed keycode is stored to $00cb; $40  = no key pressed
*)

// VIC-II registers
  Sprite0X             : byte absolute $d000; //  X coordinate sprite 0
  Sprite0Y             : byte absolute $d001; //  Y coordinate sprite 0
  Sprite1X             : byte absolute $d002; //  X coordinate sprite 1
  Sprite1Y             : byte absolute $d003; //  Y coordinate sprite 1
  Sprite2X             : byte absolute $d004; //  X coordinate sprite 2
  Sprite2Y             : byte absolute $d005; //  Y coordinate sprite 2
  Sprite3X             : byte absolute $d006; //  X coordinate sprite 3
  Sprite3Y             : byte absolute $d007; //  Y coordinate sprite 3
  Sprite4X             : byte absolute $d008; //  X coordinate sprite 4
  Sprite4Y             : byte absolute $d009; //  Y coordinate sprite 4
  Sprite5X             : byte absolute $d00a; //  X coordinate sprite 5
  Sprite5Y             : byte absolute $d00b; //  Y coordinate sprite 5
  Sprite6X             : byte absolute $d00c; //  X coordinate sprite 6
  Sprite6Y             : byte absolute $d00d; //  Y coordinate sprite 6
  Sprite7X             : byte absolute $d00e; //  X coordinate sprite 7
  Sprite7Y             : byte absolute $d00f; //  Y coordinate sprite 7

  SpritesXmsb          : byte absolute $d010; //  MSBs of X coordinates
  ControlRegister1     : byte absolute $d011; //  Control register 1
  RasterCounter        : byte absolute $d012; //  Raster counter
  LightpenX            : byte absolute $d013; //  Light pen X
  LightpenY            : byte absolute $d014; //  Light pen Y
  EnableSprites        : byte absolute $d015; //  Sprite enabled
  ControlRegister2     : byte absolute $d016; //  Control register 2
  SpriteYExpansion     : byte absolute $d017; //  Sprite Y expansion
  Memorypointers       : byte absolute $d018; //  Memory pointers
  Interruptregister    : byte absolute $d019; //  Interrupt register
  Interruptenabled     : byte absolute $d01a; //  Interrupt enabled
  Spritedatapriority   : byte absolute $d01b; //  Sprite data priority
  Spritemulticolor     : byte absolute $d01c; //  Sprite multicolor
  SpriteXExpansion     : byte absolute $d01d; //  Sprite X expansion
  SpriteSpriteCollision: byte absolute $d01e; //  Sprite-sprite collision
  SpritedataCollision  : byte absolute $d01f; //  Sprite-data collision
  Bordercolor          : byte absolute $d020; //  Border color
  Backgroundcolor0     : byte absolute $d021; //  Background color 0
  Backgroundcolor1     : byte absolute $d022; //  Background color 1
  Backgroundcolor2     : byte absolute $d023; //  Background color 2
  Backgroundcolor3     : byte absolute $d024; //  Background color 3
  SpriteMulticolor0    : byte absolute $d025; //  Sprite multicolor 0
  SpriteMulticolor1    : byte absolute $d026; //  Sprite multicolor 1
  Sprite0Color         : byte absolute $d027; //  Color sprite 0
  Sprite1Color         : byte absolute $d028; //  Color sprite 1
  Sprite2Color         : byte absolute $d029; //  Color sprite 2
  Sprite3Color         : byte absolute $d02a; //  Color sprite 3
  Sprite4Color         : byte absolute $d02b; //  Color sprite 4
  Sprite5Color         : byte absolute $d02c; //  Color sprite 5
  Sprite6Color         : byte absolute $d02d; //  Color sprite 6
  Sprite7Color         : byte absolute $d02e; //  Color sprite 7


// MEMORY MAP

  D6510               : byte absolute $0000;
  R6510               : byte absolute $0001;

  PRA2                : byte absolute $DD00;

  SP0X                : byte absolute $D000;
  SP0Y                : byte absolute $D001;
  SP1X                : byte absolute $D002;
  SP1Y                : byte absolute $D003;
  SP2X                : byte absolute $D004;
  SP2Y                : byte absolute $D005;
  SP3X                : byte absolute $D006;
  SP3Y                : byte absolute $D007;
  SP4X                : byte absolute $D008;
  SP4Y                : byte absolute $D009;
  SP5X                : byte absolute $D00A;
  SP5Y                : byte absolute $D00B;
  SP6X                : byte absolute $D00C;
  SP6Y                : byte absolute $D00D;
  SP7X                : byte absolute $D00E;
  SP7Y                : byte absolute $D00F;
  MSIGX               : byte absolute $D010;
  SCROLY              : byte absolute $D011;
  VICCR1              : byte absolute $D011; // alias
  RASTER              : byte absolute $D012;
  LPENX               : byte absolute $D013;
  LPENY               : byte absolute $D014;
  SPENA               : byte absolute $D015;
  SCROLX              : byte absolute $D016;
  VICCR2              : byte absolute $D016; // alias
  YXPAND              : byte absolute $D017; // Sprite double height register
  VMCSB               : byte absolute $D018; // ssss ccc-  s: Screen pointer (A13-A10),  c: Bitmap/charset pointer (A13-A11)
  VICIRQ              : byte absolute $D019;
  IRQMASK             : byte absolute $D01A;
  SPBGPR              : byte absolute $D01B;
  SPMC                : byte absolute $D01C; // Sprite multicolor mode register
  XXPAND              : byte absolute $D01D; // Sprite double width register
  SPSPCL              : byte absolute $D01E;
  SPBGCL              : byte absolute $D01F;
  EXTCOL              : byte absolute $D020;
  BGCOL0              : byte absolute $D021;
  BGCOL1              : byte absolute $D022;
  BGCOL2              : byte absolute $D023;
  BGCOL3              : byte absolute $D024;
  SPMC0               : byte absolute $D025; // Sprite extra color #1
  SPMC1               : byte absolute $D026; // Sprite extra color #2
  SP0COL              : byte absolute $D027;
  SP1COL              : byte absolute $D028;
  SP2COL              : byte absolute $D029;
  SP3COL              : byte absolute $D02A;
  SP4COL              : byte absolute $D02B;
  SP5COL              : byte absolute $D02C;
  SP6COL              : byte absolute $D02D;
  SP7COL              : byte absolute $D02E;
  FRELO1              : byte absolute $D400;
  FREHI1              : byte absolute $D401;
  PWLO1               : byte absolute $D402;
  PWHI1               : byte absolute $D403;
  VCREG1              : byte absolute $D404;
  ATDCY1              : byte absolute $D405;
  SUREL1              : byte absolute $D406;
  FRELO2              : byte absolute $D407;
  FREHI2              : byte absolute $D408;
  PWLO2               : byte absolute $D409;
  PWHI2               : byte absolute $D40A;
  VCREG2              : byte absolute $D40B;
  ATDCY2              : byte absolute $D40C;
  SUREL2              : byte absolute $D40D;
  FRELO3              : byte absolute $D40E;
  FREHI3              : byte absolute $D40F;
  PWLO3               : byte absolute $D410;
  PWHI3               : byte absolute $D411;
  VCREG3              : byte absolute $D412;
  ATDCY3              : byte absolute $D413;
  SUREL3              : byte absolute $D414;
  CUTLO               : byte absolute $D415;
  CUTHI               : byte absolute $D416;
  RESON               : byte absolute $D417;
  SIGVOL              : byte absolute $D418;
  POTX                : byte absolute $D419;
  POTY                : byte absolute $D41A;
  [volatile] RANDOM   : byte absolute $D41B;
  ENV3                : byte absolute $D41C;
  COLORRAM            : byte absolute $D800;
  CIAPRA              : byte absolute $DC00;
  CIAPRB              : byte absolute $DC01;
  CIDDRA              : byte absolute $DC02;
  CIDDRB              : byte absolute $DC03;
  TIMALO              : byte absolute $DC04;
  TIMAHI              : byte absolute $DC05;
  TIMBLO              : byte absolute $DC06;
  TIMBHI              : byte absolute $DC07;
  TODTEN              : byte absolute $DC08;
  TODSEC              : byte absolute $DC09;
  TODMIN              : byte absolute $DC0A;
  TODHRS              : byte absolute $DC0B;
  CIASDR              : byte absolute $DC0C;
  CIAICR              : byte absolute $DC0D;
  CIACRA              : byte absolute $DC0E;
  CIACRB              : byte absolute $DC0F;
  CI2PRA              : byte absolute $DD00;
  CI2PRB              : byte absolute $DD01;
  C2DDRA              : byte absolute $DD02;
  C2DDRB              : byte absolute $DD03;
  TI2ALO              : byte absolute $DD04;
  TI2AHI              : byte absolute $DD05;
  TI2BLO              : byte absolute $DD06;
  TI2BHI              : byte absolute $DD07;
  TO2TEN              : byte absolute $DD08;
  TO2SEC              : byte absolute $DD09;
  TO2MIN              : byte absolute $DD0A;
  TO2HRS              : byte absolute $DD0B;
  CI2SDR              : byte absolute $DD0C;
  CI2ICR              : byte absolute $DD0D;
  CI2CRA              : byte absolute $DD0E;
  CI2CRB              : byte absolute $DD0F;
 
  NMIADL              : byte absolute $FFFA;
  NMIADH              : byte absolute $FFFB;
  RSTADL              : byte absolute $FFFC;
  RSTADH              : byte absolute $FFFD;
  IRQADL              : byte absolute $FFFE;
  IRQADH              : byte absolute $FFFF;

implementation

end.