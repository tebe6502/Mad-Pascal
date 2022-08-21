{$r msx.rc}

// TEDzakker demo music

const
  MUSIC = $4000;


var
  DETIRQSRC                          : byte absolute $ff09;  //detect IRQ source, and clear IRQ flag
  SETIRQSRC                          : byte absolute $ff0a;  //set IRQ source
  RC                                 : byte absolute $ff0b;  //raser counter bits 0-7
  BACKGROUND                         : byte absolute $ff15;
  BORDER                             : byte absolute $ff19;
  VCOUNT                             : byte absolute $ff1d;  //vertical line bits 0-7
  IRQVEC                             : word absolute $fffe;


procedure myRasterIrq; assembler; interrupt;
asm {
  phr

  lda DETIRQSRC \ sta DETIRQSRC

  inc BORDER;
  jsr MUSIC+3;
  dec BORDER;

  plr
};
end;

begin
  pause;

  asm {
    sei
    sta $ff3f
    txa:pha \ lda #0 \ jsr MUSIC \ pla:tax
  };

  RC := 4; SETIRQSRC := 2;
  DETIRQSRC := DETIRQSRC and %01111111;

  IRQVEC := word(@myRasterIrq);

  asm { cli };

  repeat until false;
end.
