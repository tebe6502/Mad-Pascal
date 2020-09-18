unit c64;

interface

const
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

// VIC-II registers
  Sprite0X              =  $d000;  //  X coordinate sprite 0
  Sprite0Y              =  $d001;  //  Y coordinate sprite 0
  Sprite1X              =  $d002;  //  X coordinate sprite 1
  Sprite1Y              =  $d003;  //  Y coordinate sprite 1
  Sprite2X              =  $d004;  //  X coordinate sprite 2
  Sprite2Y              =  $d005;  //  Y coordinate sprite 2
  Sprite3X              =  $d006;  //  X coordinate sprite 3
  Sprite3Y              =  $d007;  //  Y coordinate sprite 3
  Sprite4X              =  $d008;  //  X coordinate sprite 4
  Sprite4Y              =  $d009;  //  Y coordinate sprite 4
  Sprite5X              =  $d00a;  //  X coordinate sprite 5
  Sprite5Y              =  $d00b;  //  Y coordinate sprite 5
  Sprite6X              =  $d00c;  //  X coordinate sprite 6
  Sprite6Y              =  $d00d;  //  Y coordinate sprite 6
  Sprite7X              =  $d00e;  //  X coordinate sprite 7
  Sprite7Y              =  $d00f;  //  Y coordinate sprite 7
  SpritesXmsb           =  $d010;  //  MSBs of X coordinates
  ControlRegister1      =  $d011;  //  Control register 1
  RasterCounter         =  $d012;  //  Raster counter
  LightpenX             =  $d013;  //  Light pen X
  LightpenY             =  $d014;  //  Light pen Y
  EnableSprites         =  $d015;  //  Sprite enabled
  ControlRegister2      =  $d016;  //  Control register 2
  SpriteYExpansion      =  $d017;  //  Sprite Y expansion
  Memorypointers        =  $d018;  //  Memory pointers
  Interruptregister     =  $d019;  //  Interrupt register
  Interruptenabled      =  $d01a;  //  Interrupt enabled
  Spritedatapriority    =  $d01b;  //  Sprite data priority
  Spritemulticolor      =  $d01c;  //  Sprite multicolor
  SpriteXExpansion      =  $d01d;  //  Sprite X expansion
  SpriteSpriteCollision =  $d01e;  //  Sprite-sprite collision
  SpritedataCollision   =  $d01f;  //  Sprite-data collision
  Bordercolor           =  $d020;  //  Border color
  Backgroundcolor0      =  $d021;  //  Background color 0
  Backgroundcolor1      =  $d022;  //  Background color 1
  Backgroundcolor2      =  $d023;  //  Background color 2
  Backgroundcolor3      =  $d024;  //  Background color 3
  SpriteMulticolor0     =  $d025;  //  Sprite multicolor 0
  SpriteMulticolor1     =  $d026;  //  Sprite multicolor 1
  Sprite0Color          =  $d027;  //  Color sprite 0
  Sprite1Color          =  $d028;  //  Color sprite 1
  Sprite2Color          =  $d029;  //  Color sprite 2
  Sprite3Color          =  $d02a;  //  Color sprite 3
  Sprite4Color          =  $d02b;  //  Color sprite 4
  Sprite5Color          =  $d02c;  //  Color sprite 5
  Sprite6Color          =  $d02d;  //  Color sprite 6
  Sprite7Color          =  $d02e;  //  Color sprite 7

// colors
  BLACK                 = $0;
  WHITE                 = $1;
  RED                   = $2;
  CYAN                  = $3;
  PURPLE                = $4;
  GREEN                 = $5;
  BLUE                  = $6;
  YELLOW                = $7;
  ORANGE                = $8;
  BROWN                 = $9;
  LIGHT_RED             = $A;
  DARK_GREY             = $B;
  GREY                  = $C;
  LIGHT_GREEN           = $D;
  LIGHT_BLUE            = $E;
  LIGHT_GREY            = $F;

  colorRAM              = $d800;

implementation

end.