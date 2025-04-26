(* declare your interrupt routines here *)

procedure dli;assembler;interrupt;
asm {
    phr ; store registers

;   *** example test routine
    lda #64 ; wait until this line
@   cmp vcount
    bpl @-
    ldy #0
@
    sty atari.colbk ; change backgroung color to white
    sty atari.colpf2 ; change playfield color to white
    iny
    :6 sty wsync
    cpy #14
    bne @-   

    plr ; restore registers
};
end;

procedure vbl_os;assembler;interrupt;
asm {
    phr ; store registers
    
;   *** example test routine    
    mva 20 atari.color1 // blink text
    
;   *** RMT play routine
    lda MSX
    ldy MSX+1
    jsr RMT.TRMT.PLAY

    plr ; restore registers
    jmp $E462 ; jump to system VBL handler ONLY if OS in ON!
};
end;

procedure vbl_nos;assembler;interrupt;
asm {
    phr ; store registers
    
;   *** example test routine    
    mva 20 atari.color1 // blink text
    
;   *** RMT play routine
    lda MSX
    ldy MSX+1
    jsr RMT.TRMT.PLAY

rewrite_shadows  ; optional and usable only if OS is OFF
    ldy #0
@    
    mva atari.pcolr0,y atari.colpm0,y ; color shadows
    iny 
    cpy #9
    bne @-
    mva atari.sdmctl atari.dmactl 
    mva atari.gprior atari.prior
    mwa sdlstl atari.dlistl 
    ;mwa dlivec __dlivec ; restore DLI if needed
    lda porta ; contoller
    and #$0F
    sta $278 ; stick0
    mva $d010 $284 ; strig0

    plr ; restore registers

};
end;

procedure dummy;keep;begin msx.play end; // this is dirty fix needed only if msx.play is called only from assembler code
