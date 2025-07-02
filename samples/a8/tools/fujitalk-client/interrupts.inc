(* declare your interrupt routines here *)

procedure dlitop;assembler;interrupt;
asm {
    phr ; store registers
    
    lda adr.theme+1
    ldx adr.theme+2
    sta wsync
    sta atari.colpf2
    stx atari.colpf1

    mwa #dlicontent atari.vdslst
    
dli_end    
    plr ; restore registers
};
end;

procedure dlicontent;assembler;interrupt;
asm {
    phr ; store registers
    
    lda adr.theme+7
    ldx adr.theme+8
    sta wsync
    sta atari.colpf2
    stx atari.colpf1

    mwa #dlibottom atari.vdslst
    
    plr ; restore registers
};
end;

procedure dlibottom;assembler;interrupt;
asm {
    phr ; store registers
    
    lda adr.theme+1
    ldx inputfg
    sta wsync
    sta atari.colpf2
    stx atari.colpf1

    mwa #dlitop atari.vdslst
    
    plr ; restore registers
};
end;


procedure vbl;assembler;interrupt;
asm {
    phr ; store registers
    
    mwa #dlitop atari.VDSLST

    lda adr.theme
    sta atari.color4
    lda #2
    sta atari.color2
    lda #0
    sta atari.color1
    lda adr.theme+9
    sta atari.pcolr0
    lda adr.theme+10
    sta atari.pcolr1

    plr ; restore registers
    jmp $E462 ; jump to system VBL handler
};
end;
