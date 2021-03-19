{$r msx.rc}

// TEDzakker demo music

const
  MUSIC = $4000;

begin
  asm { txa:pha \ lda #0 \ jsr MUSIC \ pla:tax };

  repeat
    pause;
    asm { txa:pha \ jsr MUSIC+3 \ pla:tax };
  until false;
end.
