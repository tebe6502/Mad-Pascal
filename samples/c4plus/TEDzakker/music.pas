{$r msx.rc}

// TEDzakker demo music

const
  MUSIC = $4000;

var
  VCOUNT                             : byte absolute $ff1d;  //vertical line bits 0-7

begin
  pause;

  asm { phr \ jsr MUSIC \ plr };

  repeat
    repeat until VCOUNT = $d8;
    asm { phr \ lda #0 \ jsr MUSIC+3 \ plr };
  until false;
end.
