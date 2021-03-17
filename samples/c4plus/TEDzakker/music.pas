{$r msx.rc}

// TEDzakker demo music

const
  MUSIC = $4000;

var
  VCOUNT                             : byte absolute $ff1d;  //vertical line bits 0-7

begin
  pause;

  asm { phr \ jsr $4000 \ plr };

  repeat
    repeat until VCOUNT = $d8;
    asm { phr \ jsr $4003 \ plr };
  until false;
end.
