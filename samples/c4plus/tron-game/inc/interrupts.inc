//-----------------------------------------------------------------------------

procedure msx1call; assembler; interrupt;
asm {
  phr

  lda DETIRQSRC \ sta DETIRQSRC

  jsr MUSIC+3

  mva #$cc RC
  mwa #MSX2CALL IRQVEC

  plr
};
end;

//-----------------------------------------------------------------------------

procedure msx2call; assembler; interrupt;
asm {
  phr

  lda DETIRQSRC \ sta DETIRQSRC

  jsr MUSIC+3

  mva #VBI_TRIGGER RC
  mwa #VBI IRQVEC

  plr
};
end;

//-----------------------------------------------------------------------------

procedure vbi; interrupt;
begin
  asm {
        phr
        inc c4p_time+2
        bne off
        inc c4p_time+1
        bne off
        inc c4p_time
  off:
        mva #0 RC
        mwa #MSX1CALL IRQVEC
  };

  checkJoyStatus;
  if (c4p_time_2 and 1) = 0 then animateStuff;

  asm {
        mva #2 DETIRQSRC
        plr
  };
end;

//-----------------------------------------------------------------------------