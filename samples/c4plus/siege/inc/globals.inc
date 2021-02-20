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
  i0b                                : byte absolute $59;
  alive                              : byte absolute $5a;
  newDir                             : byte absolute $5b;
  availDir                           : byte absolute $5c;
  joyStatus                          : byte absolute $5d;
  t0w                                : word absolute $5e;
  ply                                : ^Player absolute $70;
  tmpPly                             : ^Player absolute $72;

//-----------------------------------------------------------------------------

  obstacles                          : array [0..7] of word absolute $60;

//-----------------------------------------------------------------------------

  level                              : byte;
  gameOver                           : boolean;

//-----------------------------------------------------------------------------

  player1, player2, player3, player4 : Player;

//-----------------------------------------------------------------------------