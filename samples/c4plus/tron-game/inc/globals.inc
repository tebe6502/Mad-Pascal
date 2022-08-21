//-----------------------------------------------------------------------------

var
  KEYSCAN                            : byte absolute $fd30;
  SETBITMAP                          : byte absolute $ff06;
  SETMCOLOR                          : byte absolute $ff07;
  JOY                                : byte absolute $ff08;
  DETIRQSRC                          : byte absolute $ff09;
  SETIRQSRC                          : byte absolute $ff0a;
  RC                                 : byte absolute $ff0b;
  TED_FF12                           : byte absolute $ff12;
  CHBAS                              : byte absolute $ff13;
  VIDEOMATRIX                        : byte absolute $ff14;
  BACKGROUND                         : byte absolute $ff15;
  COLOUR1                            : byte absolute $ff16;
  BORDER                             : byte absolute $ff19;
  VCOUNT                             : byte absolute $ff1d;
  IRQVEC                             : word absolute $fffe;

//-----------------------------------------------------------------------------

  t0b                                : byte absolute $58;
  t1b                                : byte absolute $59;
  i0b                                : byte absolute $5a;
  i1b                                : byte absolute $5b;
  alive                              : byte absolute $5c;
  newDir                             : byte absolute $5d;
  availDir                           : byte absolute $5e;
  joyStatus                          : byte absolute $5f;
  t0w                                : word absolute $60;
  t1w                                : word absolute $62;
  ply                                : ^Player absolute $64;
  tmpPly                             : ^Player absolute $66;
  c4p_time                           : byte absolute $a3;
  c4p_time_1                         : byte absolute $a4;
  c4p_time_2                         : byte absolute $a5;

//-----------------------------------------------------------------------------

  level                              : byte;
  gameOver                           : boolean;

//-----------------------------------------------------------------------------

  player1, player2, player3, player4 : Player;

//-----------------------------------------------------------------------------