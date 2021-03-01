var
  DETIRQSRC                          : byte absolute $ff09;  //detect IRQ source, and clear IRQ flag
  SETIRQSRC                          : byte absolute $ff0a;  //set IRQ source
  RC                                 : byte absolute $ff0b;  //raser counter bits 0-7
  BACKGROUND                         : byte absolute $ff15;
  BORDER                            : byte absolute $ff19;
  VCOUNT                             : byte absolute $ff1d;  //vertical line bits 0-7
  IRQVEC                             : word absolute $fffe;

var
  tmp                                : byte absolute $ff;


procedure myRasterIrq; interrupt;
begin
  asm { phr };

  Inc(BORDER);
  tmp:= VCOUNT + 32; repeat until tmp = VCOUNT;
  Dec(BORDER);

  DETIRQSRC := DETIRQSRC and %01111111;
  asm { plr };
end;

begin
  pause;

  asm { sei \ sta $ff3f};

  RC := 204; SETIRQSRC := 2;
  DETIRQSRC := DETIRQSRC and %01111111;

  IRQVEC := word(@myRasterIrq);

  asm { cli };

  repeat until false;
end.
