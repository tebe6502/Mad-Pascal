{$r msx.rc}

// TEDzakker demo music

const
  MUSIC = $4000;

begin
  asm { phr \ lda #0 \ jsr MUSIC \ plr };

  repeat
    pause;
    asm { phr \ jsr MUSIC+3 \ plr };
  until false;
end.
