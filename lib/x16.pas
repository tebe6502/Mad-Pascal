unit x16;
(*
 @type: unit
 @author: MADRAFi <madrafi@gmail.com>
 @name: X16

 @version: 0.1.0

 @description:
 Documentation https://github.com/X16Community/x16-docs/blob/master/X16%20Reference%20-%2005%20-%20KERNAL.md 
*)

interface

var

// Standard Kernal ROM routines
  ACPTR      : byte absolute $ffa5; // ACPTR. Read byte from peripheral bus.
  BASIN	     : byte absolute $ffcf; // Get character.
  BSAVE      : byte absolute $feba; // Like SAVE but omits the 2-byte header.
  BSOUT	     : byte absolute $ffd2; // Write byte in A to default output. For writing to a file must call OPEN and CHKOUT beforehand.
  CIOUT	     : byte absolute $ffa8; // Send byte to peripheral bus.
  CLOSEALLCH : byte absolute $ffe7; // CLALL. Close all channels.
  CLOSECH	   : byte absolute $ffc3; // CLOSE. Close a channel.
  CHKIN      : byte absolute $ffc6; // Set channel for character input.
  CHKOUT     : byte absolute $ffc9; // CHKOUT. Define file as default output. (Must call OPEN beforehand.)
  CHRIN      : byte absolute $ffcf; // Alias for BASIN.
  CHROUT     : byte absolute $ffd2; // Alias for BSOUT.
  CLOSE_ALL  : byte absolute $ff4a; // Close all files on a device.
  CLRCHN     : byte absolute $ffcc; // Restore character I/O to screen/keyboard.
  GETIN      : byte absolute $ffe4; // Get character from keyboard.

  IECIN      : byte absolute $ffa5; // IECIN. Read byte from serial bus. (Must call TALK and TALKSA beforehand.)
  IECOUT     : byte absolute $ffa8; // IECOUT. Write byte to serial bus. (Must call LISTEN and LSTNSA beforehand.)
  IOBASE     : byte absolute $fff3; // Return start of I/O area.
  IOINIT     : byte absolute $ff84; // IOINIT. Initialize CIA's, SID volume; setup memory configuration; set and start interrupt timer.
  LISTEN     : byte absolute $ffb1; // Send LISTEN command to serial bus.
  LKUPLA     : byte absolute $ff59; // Search tables for given LA.
  LKUPSA     : byte absolute $ff5c; // Search tables for given SA.
  LOAD       : byte absolute $ffd5; // LOAD. Load or verify file. (Must call SETLFS and SETNAM beforehand.)
  LSTNSA     : byte absolute $ff93; // LSTNSA. Send LISTEN secondary address to serial bus. (Must call LISTEN beforehand.)
  MEMBOT     : byte absolute $ff99; // MEMBOT. Save or restore start address of BASIC work area.
  MEMTOP     : byte absolute $ff9c; // MEMTOP. Save or restore end address of BASIC work area.
  OPEN       : byte absolute $ffc0; // OPEN. Open file. (Must call SETLFS and SETNAM beforehand.)
  PLOT       : byte absolute $fff0; // PLOT. Save or restore cursor position.
  PRIMM      : byte absolute $ff7d; // Print string following the caller’s code.

  RAMTAS     : byte absolute $ff87; // RAMTAS. Clear memory addresses $0002-$0101 and $0200-$03FF; run memory test and set start and end address of BASIC work area accordingly; set screen memory to $0400 and datasette buffer to $033C.
  RDTIM      : byte absolute $ffde; // RDTIM. read Time of Day, at memory address $00A0-$00A2.
  READST     : byte absolute $ffb7; // READST. Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
  RESTOR     : byte absolute $ff8a; // RESTOR. Fill vector table at memory addresses $0314-$0333 with default values.
  SAVE       : byte absolute $ffd8; // SAVE. Save file. (Must call SETLFS and SETNAM beforehand.)
  SCINIT     : byte absolute $ff81; // SCINIT. Initialize VIC; restore default input/output to keyboard/screen; clear screen; set PAL/NTSC switch and interrupt timer.
  SCNKEY     : byte absolute $ff9f; // SCNKEY. Query keyboard; put current matrix code into memory address $00CB, current status of shift keys into memory address $028D and PETSCII code into keyboard buffer.
  SCREEN     : byte absolute $ffed; // SCREEN. Fetch number of screen rows and columns.

  SETLFS     : byte absolute $ffba; // SETLFS. Set file parameters.
  SETMSG     : byte absolute $ff90; // SETMSG. Set system error display switch at memory address $009D.
  SETNAM     : byte absolute $ffbd; // SETNAM. Set file name parameters.
  SETTIM     : byte absolute $ffdb; // SETTIM. Set Time of Day, at memory address $00A0-$00A2.
  SETTMO     : byte absolute $ffa2; // SETTMO. Unknown. (Set serial bus timeout.)
  STOP       : byte absolute $ffe1; // STOP. Query Stop key indicator, at memory address $0091; if pressed, call CLRCHN and clear keyboard buffer.
  TALK       : byte absolute $ffb4; // TALK. Send TALK command to serial bus.
  TALKSA     : byte absolute $ff96; // TALKSA. Send TALK secondary address to serial bus. (Must call TALK beforehand.)
  UDTIM      : byte absolute $ffea; // UDTIM. Update Time of Day, at memory address $00A0-$00A2, and Stop key indicator, at memory address $0091.
  UNLSTN     : byte absolute $ffae; // UNLSTN. Send UNLISTEN command to serial bus.
  UNTALK     : byte absolute $ffab; // UNTALK. Send UNTALK command to serial bus.
  VECTOR     : byte absolute $ff8d; // VECTOR. Copy vector table at memory addresses $0314-$0333 from or into user table.

// x16 specific routines
  clock_get_date_time    : byte absolute $ff50; // Get the date and time.
  clock_set_date_time    : byte absolute $ff4d; //	Set the date and time.
  entropy_get            : byte absolute $fecf; // Get 24 random bits.
  enter_basic            : byte absolute $ff47; // Enter BASIC.
  screen_mode            : byte absolute $ff5f; // Get/Set screen mode.
  screen_set_charset     : byte absolute $ff62; // Activate 8x8 text mode charset.

// Graphics routines
  GRAPH_init             : byte absolute $ff20; // Initialize graphics.
  GRAPH_clear            : byte absolute $ff23; // Clear screen.
  GRAPH_set_window       : byte absolute $ff26; // Set clipping region.
  GRPAH_set_colors       : byte absolute $ff29; // Set stroke, fill and background colors.
  GRAPH_draw_line        : byte absolute $ff2c; // Draw a line.
  GRAPH_draw_rect        : byte absolute $ff2f; // Draw a rectangle (optionally filled).
  GRAPH_move_rect        : byte absolute $ff32; // Move pixels.
  GRAPH_draw_oval        : byte absolute $ff35; // Draw an oval or circle.
  GRAPH_draw_image       : byte absolute $ff38; // Draw an image.
  GRAPH_set_font         : byte absolute $ff3b; // Set the current font.
  GRAPH_get_char_size    : byte absolute $ff3e; // Get the size of a character.
  GRAPH_put_char         : byte absolute $ff41; // Draw a character.

// floating point routines
  MOVFM      : byte absolute $bba2; // MOVFM. Move a Floating Point Number from Memory to FAC1
  FOUT       : byte absolute $bddd; // FOUT. Convert Contents of FAC1 to ASCII String
  MOV2F      : byte absolute $bbc7; // MOV2F. Move a Floating Point Number from FAC1 to Memory

// interrupt routines and vectors
  IRQVec     : byte absolute $0314; // hardware interrupt (IRQ) vector, low byte
  BRKVec     : byte absolute $0316;
  NMIVec     : byte absolute $0318;
  FETVec     : byte absolute $03AF;
  //STAVec      = TBD
  //CMPVec      = TBD
  //STDIRQ   : byte absolute $ea31; //start address of standard interrupt routines

// keyboard
  CURRKEY    : byte absolute $cb;   // currently pressed keycode is stored to $00cb; $40  : byte absolute no key pressed

// VIC-II registers
  // Sprite0X             : byte absolute $d000; //  X coordinate sprite 0
  // Sprite0Y             : byte absolute $d001; //  Y coordinate sprite 0
  // Sprite1X             : byte absolute $d002; //  X coordinate sprite 1
  // Sprite1Y             : byte absolute $d003; //  Y coordinate sprite 1
  // Sprite2X             : byte absolute $d004; //  X coordinate sprite 2
  // Sprite2Y             : byte absolute $d005; //  Y coordinate sprite 2
  // Sprite3X             : byte absolute $d006; //  X coordinate sprite 3
  // Sprite3Y             : byte absolute $d007; //  Y coordinate sprite 3
  // Sprite4X             : byte absolute $d008; //  X coordinate sprite 4
  // Sprite4Y             : byte absolute $d009; //  Y coordinate sprite 4
  // Sprite5X             : byte absolute $d00a; //  X coordinate sprite 5
  // Sprite5Y             : byte absolute $d00b; //  Y coordinate sprite 5
  // Sprite6X             : byte absolute $d00c; //  X coordinate sprite 6
  // Sprite6Y             : byte absolute $d00d; //  Y coordinate sprite 6
  // Sprite7X             : byte absolute $d00e; //  X coordinate sprite 7
  // Sprite7Y             : byte absolute $d00f; //  Y coordinate sprite 7

  // SpritesXmsb          : byte absolute $d010; //  MSBs of X coordinates
  // ControlRegister1     : byte absolute $d011; //  Control register 1
  // RasterCounter        : byte absolute $d012; //  Raster counter
  // LightpenX            : byte absolute $d013; //  Light pen X
  // LightpenY            : byte absolute $d014; //  Light pen Y
  // EnableSprites        : byte absolute $d015; //  Sprite enabled
  // ControlRegister2     : byte absolute $d016; //  Control register 2
  // SpriteYExpansion     : byte absolute $d017; //  Sprite Y expansion
  // Memorypointers       : byte absolute $d018; //  Memory pointers
  // Interruptregister    : byte absolute $d019; //  Interrupt register
  // Interruptenabled     : byte absolute $d01a; //  Interrupt enabled
  // Spritedatapriority   : byte absolute $d01b; //  Sprite data priority
  // Spritemulticolor     : byte absolute $d01c; //  Sprite multicolor
  // SpriteXExpansion     : byte absolute $d01d; //  Sprite X expansion
  // SpriteSpriteCollision: byte absolute $d01e; //  Sprite-sprite collision
  // SpritedataCollision  : byte absolute $d01f; //  Sprite-data collision
  // Bordercolor          : byte absolute $d020; //  Border color
  // Backgroundcolor0     : byte absolute $d021; //  Background color 0
  // Backgroundcolor1     : byte absolute $d022; //  Background color 1
  // Backgroundcolor2     : byte absolute $d023; //  Background color 2
  // Backgroundcolor3     : byte absolute $d024; //  Background color 3
  // SpriteMulticolor0    : byte absolute $d025; //  Sprite multicolor 0
  // SpriteMulticolor1    : byte absolute $d026; //  Sprite multicolor 1
  // Sprite0Color         : byte absolute $d027; //  Color sprite 0
  // Sprite1Color         : byte absolute $d028; //  Color sprite 1
  // Sprite2Color         : byte absolute $d029; //  Color sprite 2
  // Sprite3Color         : byte absolute $d02a; //  Color sprite 3
  // Sprite4Color         : byte absolute $d02b; //  Color sprite 4
  // Sprite5Color         : byte absolute $d02c; //  Color sprite 5
  // Sprite6Color         : byte absolute $d02d; //  Color sprite 6
  // Sprite7Color         : byte absolute $d02e; //  Color sprite 7


// // MEMORY MAP

//   D6510               : byte absolute $0000;
//   R6510               : byte absolute $0001;

//   PRA2                : byte absolute $DD00;

//   SP0X                : byte absolute $D000;
//   SP0Y                : byte absolute $D001;
//   SP1X                : byte absolute $D002;
//   SP1Y                : byte absolute $D003;
//   SP2X                : byte absolute $D004;
//   SP2Y                : byte absolute $D005;
//   SP3X                : byte absolute $D006;
//   SP3Y                : byte absolute $D007;
//   SP4X                : byte absolute $D008;
//   SP4Y                : byte absolute $D009;
//   SP5X                : byte absolute $D00A;
//   SP5Y                : byte absolute $D00B;
//   SP6X                : byte absolute $D00C;
//   SP6Y                : byte absolute $D00D;
//   SP7X                : byte absolute $D00E;
//   SP7Y                : byte absolute $D00F;
//   MSIGX               : byte absolute $D010;
//   SCROLY              : byte absolute $D011;
//   VICCR1              : byte absolute $D011; // alias
//   RASTER              : byte absolute $D012;
//   LPENX               : byte absolute $D013;
//   LPENY               : byte absolute $D014;
//   SPENA               : byte absolute $D015;
//   SCROLX              : byte absolute $D016;
//   VICCR2              : byte absolute $D016; // alias
//   YXPAND              : byte absolute $D017; // Sprite double height register
//   VMCSB               : byte absolute $D018; // ssss ccc-  s: Screen pointer (A13-A10),  c: Bitmap/charset pointer (A13-A11)
//   VICIRQ              : byte absolute $D019;
//   IRQMASK             : byte absolute $D01A;
//   SPBGPR              : byte absolute $D01B;
//   SPMC                : byte absolute $D01C; // Sprite multicolor mode register
//   XXPAND              : byte absolute $D01D; // Sprite double width register
//   SPSPCL              : byte absolute $D01E;
//   SPBGCL              : byte absolute $D01F;
//   EXTCOL              : byte absolute $D020;
//   BGCOL0              : byte absolute $D021;
//   BGCOL1              : byte absolute $D022;
//   BGCOL2              : byte absolute $D023;
//   BGCOL3              : byte absolute $D024;
//   SPMC0               : byte absolute $D025; // Sprite extra color #1
//   SPMC1               : byte absolute $D026; // Sprite extra color #2
//   SP0COL              : byte absolute $D027;
//   SP1COL              : byte absolute $D028;
//   SP2COL              : byte absolute $D029;
//   SP3COL              : byte absolute $D02A;
//   SP4COL              : byte absolute $D02B;
//   SP5COL              : byte absolute $D02C;
//   SP6COL              : byte absolute $D02D;
//   SP7COL              : byte absolute $D02E;
//   FRELO1              : byte absolute $D400;
//   FREHI1              : byte absolute $D401;
//   PWLO1               : byte absolute $D402;
//   PWHI1               : byte absolute $D403;
//   VCREG1              : byte absolute $D404;
//   ATDCY1              : byte absolute $D405;
//   SUREL1              : byte absolute $D406;
//   FRELO2              : byte absolute $D407;
//   FREHI2              : byte absolute $D408;
//   PWLO2               : byte absolute $D409;
//   PWHI2               : byte absolute $D40A;
//   VCREG2              : byte absolute $D40B;
//   ATDCY2              : byte absolute $D40C;
//   SUREL2              : byte absolute $D40D;
//   FRELO3              : byte absolute $D40E;
//   FREHI3              : byte absolute $D40F;
//   PWLO3               : byte absolute $D410;
//   PWHI3               : byte absolute $D411;
//   VCREG3              : byte absolute $D412;
//   ATDCY3              : byte absolute $D413;
//   SUREL3              : byte absolute $D414;
//   CUTLO               : byte absolute $D415;
//   CUTHI               : byte absolute $D416;
//   RESON               : byte absolute $D417;
//   SIGVOL              : byte absolute $D418;
//   POTX                : byte absolute $D419;
//   POTY                : byte absolute $D41A;
//   // [volatile]	RANDOM  : byte absolute $D41B;
//   ENV3                : byte absolute $D41C;
//   COLORRAM            : byte absolute $D800;
//   CIAPRA              : byte absolute $DC00;
//   CIAPRB              : byte absolute $DC01;
//   CIDDRA              : byte absolute $DC02;
//   CIDDRB              : byte absolute $DC03;
//   TIMALO              : byte absolute $DC04;
//   TIMAHI              : byte absolute $DC05;
//   TIMBLO              : byte absolute $DC06;
//   TIMBHI              : byte absolute $DC07;
//   TODTEN              : byte absolute $DC08;
//   TODSEC              : byte absolute $DC09;
//   TODMIN              : byte absolute $DC0A;
//   TODHRS              : byte absolute $DC0B;
//   CIASDR              : byte absolute $DC0C;
//   CIAICR              : byte absolute $DC0D;
//   CIACRA              : byte absolute $DC0E;
//   CIACRB              : byte absolute $DC0F;
//   CI2PRA              : byte absolute $DD00;
//   CI2PRB              : byte absolute $DD01;
//   C2DDRA              : byte absolute $DD02;
//   C2DDRB              : byte absolute $DD03;
//   TI2ALO              : byte absolute $DD04;
//   TI2AHI              : byte absolute $DD05;
//   TI2BLO              : byte absolute $DD06;
//   TI2BHI              : byte absolute $DD07;
//   TO2TEN              : byte absolute $DD08;
//   TO2SEC              : byte absolute $DD09;
//   TO2MIN              : byte absolute $DD0A;
//   TO2HRS              : byte absolute $DD0B;
//   CI2SDR              : byte absolute $DD0C;
//   CI2ICR              : byte absolute $DD0D;
//   CI2CRA              : byte absolute $DD0E;
//   CI2CRB              : byte absolute $DD0F;


//   NMIADL              : byte absolute $FFFA;
//   NMIADH              : byte absolute $FFFB;
//   RSTADL              : byte absolute $FFFC;
//   RSTADH              : byte absolute $FFFD;
//   IRQADL              : byte absolute $FFFE;
//   IRQADH              : byte absolute $FFFF;

implementation

end.