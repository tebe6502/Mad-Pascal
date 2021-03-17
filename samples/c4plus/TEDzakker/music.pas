{$r msx.rc}

// TEDzakker demo music

const
  MUSIC = $4000;

begin
  asm { phr \ jsr MUSIC \ plr };

  repeat
    pause;
    asm { phr \ lda #0 \ jsr MUSIC+3 \ plr };
  until false;
end.
