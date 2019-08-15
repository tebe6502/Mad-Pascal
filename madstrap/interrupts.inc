(* declare your interrupt routines here *)

procedure dli;assembler;interrupt;
asm {
    phr ; store registers

;   *** example test routine
;    lda #64 ; wait this number of lines
;@   cmp vcount
;    bpl @-
;    mva #$0f atari.colbk ; change backgroung color to white
    
    plr ; restore registers
};
end;

procedure vbl;assembler;interrupt;
asm {
    phr ; store registers
    
;   *** example test routine    
;    mva 20 atari.colbk // blink background
    
;   *** RMT play routine
;    lda MSX
;    ldy MSX+1
;    jsr RMT.TRMT.PLAY

    plr ; restore registers
    jmp $E462 ; jump to system VBL handler
};
end;
