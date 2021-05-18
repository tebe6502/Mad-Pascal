var
        _dlist: word absolute 560;
        _savmsc: word absolute 88;
        _wsync: byte absolute $d40a;
        _vcount: byte absolute $d40b;
        _nmien: byte absolute $d40e;
        _dmactl: byte absolute 559;
        _gractl: byte absolute 53277;
        _pmbase: byte absolute 54279;
        _gprior: byte absolute 53275;
        _gprior_: byte absolute 623;

        _bgcolrS: byte absolute 710;
        _bgcolr: byte absolute $D018;
        _brcolrS: byte absolute 712;
        _brcolr: byte absolute $D01A;
        _c1colrS: byte absolute 709;
        _c1colr: byte absolute $D017;
        _c2colrS: byte absolute 708;
        _c2colr: byte absolute $D016;
        _lmargin: byte absolute 82;
        _charsetS: byte absolute 756;
        _cursor: byte absolute 752;

        // PMG
        _pcolr0: byte absolute 53266;
        _pcolr1: byte absolute 53267;
        _pcolr2: byte absolute 53268;
        _pcolr3: byte absolute 53269;

        _hposp0: byte absolute 53248;
        _hposp1: byte absolute 53249;
        _hposp2: byte absolute 53250;
        _hposp3: byte absolute 53251;

        _sizep0: byte absolute 53256;
        _sizep1: byte absolute 53257;
        _sizep2: byte absolute 53258;
        _sizep3: byte absolute 53259;

