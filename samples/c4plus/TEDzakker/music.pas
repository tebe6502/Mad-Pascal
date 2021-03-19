{$r msx.rc}

// TEDzakker demo music

const
  MUSIC = $4000;

begin
  asm { lda #0 \ jsr MUSIC };

  repeat
    pause;
    asm { jsr MUSIC+3 };
  until false;
end.
