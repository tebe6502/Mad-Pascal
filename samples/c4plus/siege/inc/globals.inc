//-----------------------------------------------------------------------------

var
  KEYSCAN                            : byte absolute $fd30;
  JOY                                : byte absolute $ff08;
  RAMROMSEL                          : byte absolute $ff12;
  CHBAS                              : byte absolute $ff13;
  BACKGROUND                         : byte absolute $ff15;
  BOREDER                            : byte absolute $ff19;

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

//-----------------------------------------------------------------------------

  level                              : byte;
  gameOver                           : boolean;

//-----------------------------------------------------------------------------

  player1, player2, player3, player4 : Player;

//-----------------------------------------------------------------------------