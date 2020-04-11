unit pokey;
(*
 @type: unit
 @author:
 @name: POKEY unit
 @version: 1.0

 changes: 17.08.2017

 @description:
 POKEY memory registers
*)


interface

var
    pot0    : byte absolute $d200;
    pot1    : byte absolute $d201;
    pot2    : byte absolute $d202;
    pot3    : byte absolute $d203;
    pot4    : byte absolute $d204;
    pot5    : byte absolute $d205;
    pot6    : byte absolute $d206;
    pot7    : byte absolute $d207;
    allpot  : byte absolute $d208;
    audf1   : byte absolute $d200;
    audc1   : byte absolute $d201;
    audf2   : byte absolute $d202;
    audc2   : byte absolute $d203;
    audf3   : byte absolute $d204;
    audc3   : byte absolute $d205;
    audf4   : byte absolute $d206;
    audc4   : byte absolute $d207;
    audctl  : byte absolute $d208;
    stimer  : byte absolute $d209;
    kbcode  : byte absolute $d209;
    skres   : byte absolute $d20a;
    random  : byte absolute $d20a;
    potgo   : byte absolute $d20b;
    serout  : byte absolute $d20d;
    serin   : byte absolute $d20d;
    irqen   : byte absolute $d20e;
    irqst   : byte absolute $d20e;
    skctl   : byte absolute $d20f;
    skstat  : byte absolute $d20f;

implementation

end.
