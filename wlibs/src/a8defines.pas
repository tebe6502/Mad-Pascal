// Library: a8defines.pas
// Desc...: Atari 8 Bit Library Definitions
// Author.: Wade Ripkowski, amarok, MADRAFi
// Date...: 2023.03
// License: GNU General Public License v3.0
// Note...: Requires: a8defwin.pas
//          -Converted from C
// Revised:
// - Added CHDN_I definition

unit a8defines;

interface

const
    // Version
    LIB_VERSION = '1.2.1';

    // Window Record and Memory Alloc
    WRECSZ = 10;
    WBUFSZ = 2068;

    // Window flags
    WON = 1;
    WOFF = 0;

    // Window Positioning
    WPABS = 128;
    WPTOP = 241;
    WPBOT = 242;
    WPLFT = 251;
    WPRGT = 252;
    WPCNT = 255;

    // Window Error status
    WENONE = 100;
    WENOPN = 101;
    WEUSED = 102;

    // Gadget flags
    GDISP  = 0;
    GEDIT  = 1;
    GHORZ  = 1;
    GVERT  = 2;
    GCON   = 1;
    GCOFF  = 2;
    GANY   = 0;
    GALNUM = 1;
    GALPHA = 2;
    GNUMER = 3;
    GFILE  = 4;

    // Menu Exits
    XESC  = 253;
    XTAB  = 254;
    XNONE = 255;

    // OS Registers
    // DMACTL = 559;
    // COLDST = 580;
    // GPRIOR = 623;
    INVFLG = 694;
    SHFLOK = 702;
    HELPFG = 732;
    KEYPCH = 764;
    // GRACTL = 53277;
    CONSOL = 53279;
    // PMBASE = 54279;

    // PM Registers
    // HPOSP0 = 53248;
    // HPOSP1 = 53249;
    // HPOSP2 = 53250;

    // Screen Bits
    ALMARG = 82;
    RSCRN  = 88;
    // PCOLR0 = 704;
    // PCOLR1 = 705;
    // PCOLR2 = 706;
    // PCOLR3 = 707;
    // AFOREG = 709;
    // ABACKG = 710;
    // ABORDR = 712;
    ACURIN = 752;

    // Colors
    // CBLACK  = 0;
    // CWHITE  = 14;
    // CGREEN  = 210;
    // CBLUE   = 146;
    // CRED    = 50;
    // CYELLOW = 222;

    // Keystroke Values
    KNOMAP = 199;
    KNONE  = 255;
    KENTER = 12;
    KDEL   = 52;
    KDEL_S = 116;
    KDEL_C = 180;
    KINS   = 183;
    KPLUS  = 6;
    KASTER = 7;
    KMINUS = 14;
    KEQUAL = 15;
    KESC   = 28;
    KSPACE = 33;
    KINV   = 39;
    KTAB   = 44;
    KTAB_S = 108;
    KCAP   = 60;
    KLEFT  = 134;
    KRIGHT = 135;
    KUP    = 142;
    KDOWN  = 143;
    KEYB   = 21;
    KEYC   = 18;
    KEYD   = 58;
    KEYH   = 57;
    KEYN   = 35;
    KEYP   = 10;
    KEYR   = 40;
    KEYS   = 62;
    KEYT   = 45;

    KB_C   = 149;
    KE_C   = 170;
    KX     = 22;
    KX_S   = 86;
    KE_CS  = 234;
    KS_CS  = 254;

    // Console key value
    KCNON  = 7;
    KCSTA  = 262;
    KCSEL  = 261;
    KCOPT  = 259;

    // Function Key Values
    KFHLP = 17;
    KF1   = 3;
    KF2   = 4;
    KF3   = 19;
    KF4   = 20;

    // Character Codes
    CHBTRGT = #3;
    CHTPRGT = #5;
    CHTPLFT = #17;
    CHBTLFT = #26;
    CHBALL  = #20;
    CHESC   = #27;
    CHUP    = #28;
    CHDN    = #29;
    CHLFT   = #30;
    CHRGT   = #31;
    CHSPACE = #32;
    CHDMND  = #96;
    CHCLS   = #125;
    CHBACK  = #126;
    CHTAB   = #127;
    CHENT   = #155;
    CHDELLN = #156;
    CHINVSP = #160;
    CHBUZ   = #253;
    CHO_L   = #111;
    CHDN_I  = #157;
    CHRGT_I = #159;
    CHI_I   = #201;
    

implementation

end.