//---------------------- INTERFACE ---------------------------------------------

interface
  procedure run;

  var
    name   : string[26];

//---------------------- IMPLEMENTATION ----------------------------------------

implementation

  uses b_system, gr, counter, md5;

  var
    rnd           : byte absolute $D20A;
    isRewritable  : boolean = false;
