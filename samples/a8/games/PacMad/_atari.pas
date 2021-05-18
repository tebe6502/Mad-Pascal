unit _atari;
interface

var
    _GPRIOR: byte absolute $D01B;
    _GPRIOR_: byte absolute $26F;

    _PCOLR0: byte absolute $D012;
    _PCOLR1: byte absolute $D013;
    _PCOLR2: byte absolute $D014;
    _PCOLR3: byte absolute $D015;

    _COLOR0: byte absolute $D016;
    _COLOR1: byte absolute $D017;
    _COLOR2: byte absolute $D018;
    _COLOR3: byte absolute $D019;
    _COLOR4: byte absolute $D01A;

    _PCOLR0_: byte absolute $2C0;
    _PCOLR1_: byte absolute $2C1;
    _PCOLR2_: byte absolute $2C2;
    _PCOLR3_: byte absolute $2C3;

    _COLOR0_: byte absolute $2C4;
    _COLOR1_: byte absolute $2C5;
    _COLOR2_: byte absolute $2C6;
    _COLOR3_: byte absolute $2C7;
    _COLOR4_: byte absolute $2C8;

    _HPOS0: byte absolute $D000;
    _HPOS1: byte absolute $D001;
    _HPOS2: byte absolute $D002;
    _HPOS3: byte absolute $D003;

    _HPOSM0: byte absolute $D004;
    _HPOSM1: byte absolute $D005;
    _HPOSM2: byte absolute $D006;
    _HPOSM3: byte absolute $D007;

    _SIZEP0: byte absolute $D008;
    _SIZEP1: byte absolute $D009;
    _SIZEP2: byte absolute $D00A;
    _SIZEP3: byte absolute $D00B;

    _SIZEM: byte absolute $D00C;

    _GRAFP0: byte absolute $D00D;
    _GRAFP1: byte absolute $D00E;
    _GRAFP2: byte absolute $D00F;
    _GRAFP3: byte absolute $D010;
    _GRAFM: byte absolute $D011;

    _P0PL: byte absolute $D00C;
    _P1PL: byte absolute $D00D;
    _P2PL: byte absolute $D00E;
    _P3PL: byte absolute $D00F;

    _VDELAY: byte absolute $D01C;
    _GRACTL: byte absolute $D01D;
    _HITCLR: byte absolute $D01E;

    _DMACTL: byte absolute $D400;
    _SDMCTL: byte absolute $D400;
    _CHACTL: byte absolute $D401;
    _SDLSTL: word absolute $D402;
    _HSCROL: byte absolute $D404;
    _VSCROL: byte absolute $D405;
    _PMBASE: byte absolute $D407;
    _CHBASE: byte absolute $D409;
    _WSYNC:  byte absolute $D40A;
    _VCOUNT: byte absolute $D40B;
    _NMIEN:  byte absolute $D40E;
    _NMIRES: byte absolute $D40F;
    _NMIST:  byte absolute $D40F;

    _AUDF1: byte absolute $D200;
    _AUDC1: byte absolute $D201;
    _AUDF2: byte absolute $D202;
    _AUDC2: byte absolute $D203;
    _AUDF3: byte absolute $D204;
    _AUDC3: byte absolute $D205;
    _AUDF4: byte absolute $D206;
    _AUDC4: byte absolute $D207;
    _AUDCTL: byte absolute $D208;
    _KBCODE: byte absolute $D209;
    _SKSTAT: byte absolute $D20F;

    _ATRACT: byte absolute $4D;
    _LMARGIN: byte absolute $52;    // lewy margines ekranu
    _RMARGIN: byte absolute $53;    // prawy margines ekranu
    _ROWCRS: byte absolute $54;     // pionowa pozycja kursora
    _COLCRS: word absolute $55;     // (2) pozioma pozycja kursora
    _DINDEX: byte absolute $57;     // numer trybu graficznego OS
    _TXTMSC: word absolute $294;

    _VDSLST: word absolute $200;
    _SDLSTL_: word absolute $230;   // (2) adres listy displayowej
    _SDMCTL_: byte absolute $22F;
    _SAVMSC: word absolute $58;     // (2) adres pamieci obrazu

    _CHACT: byte absolute $2F3;     // rejestr cien CHRCTL
    _CHBAS: byte absolute $2F4;     // rejestr cien CHBASE
    _CH: byte absolute $2FC;        // rejestr cien KBCODE

    _EXITVBL: byte absolute $E462;

    _STICK0: byte absolute $D300;
    _STICK1: byte absolute $D301;
    _STRIG0: byte absolute $D010;
    _STRIG1: byte absolute $D011;

    _STICK0_: byte absolute $278;
    _STICK1_: byte absolute $279;
    _STRIG0_: byte absolute $284;
    _STRIG1_: byte absolute $285;

    _CONSOL: byte absolute $D01F;
    _PORTB: byte absolute $D301;
    _NMIVEC: word absolute $FFFA;

    _RTCLOK: byte absolute 18;

implementation
end.
