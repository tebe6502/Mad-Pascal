(* declare your interrupt routines here *)

procedure dli;assembler;interrupt;
asm {
    phr ; store registers

    
    mwa #0 $fe
    lda borderlinePos
    and #15
    asl:asl:asl:asl
    asl
    rol $ff
    asl
    rol $ff
    sta $fe
    adw $fe #adr.borderlines

    lda #14 ; wait this number of lines
@   cmp vcount
    bpl @-
   
    ldy #63
    sty wsync
@
    lda ($fe),y
    tax
    and #2
    ora #$c4
    sta wsync
    stx atari.colpf1
    sta atari.colbk
    dey
    bpl @-
    lda #0
    sta wsync
    sta atari.colbk
    
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
