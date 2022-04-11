(* declare your interrupt routines here *)

procedure dli;assembler;interrupt;
asm {
    pha ; store registers
    mva #2 atari.colpf2
    mva #8 atari.colpf1
    mva >DEFAULT_CHARSET chbase
    mva #176 hposp3
    mva #3 sizep3

    
    mwa #dli2 atari.vdslst
    pla ; restore registers
};
end;

procedure dli2;assembler;interrupt;
asm {
    pha ; store registers
    mva config.editorBackgroundColor atari.colpf2
    mva config.editorForegroundColor atari.colpf1
    mva editorCharset chbase

    
    
    mwa #dli3 atari.vdslst
    pla ; restore registers
};
end;

procedure dli3;assembler;interrupt;
asm {
    pha ; store registers
    sta wsync
    mva #2 atari.colpf2
    mva #8 atari.colpf1
    lda statusCustomCharset
    sne
    mva >DEFAULT_CHARSET chbase
    
    mva brushFramePosX hposp3
    mva #0 sizep3
    
    pla ; restore registers
};
end;


procedure vbl;assembler;interrupt;
asm {
    phr ; store registers
    
    
    mwa #dli atari.vdslst

    ; cursor blink
    lda rtclok+2
    lsr
    and #$0f
    tax 
    lda cursorBrightness,x
    sta atari.pcolr0
    sta atari.pcolr1
    sta atari.pcolr2
    sta atari.pcolr3

    
    lda keyRepeatCounter
    seq
    dec keyRepeatCounter
    

    plr ; restore registers
    jmp $E462 ; jump to system VBL handler
cursorBrightness    
    dta 4, 5, 6, 7, 8, 9, 10, 11, 12, 11, 10, 9, 8, 7, 6, 5
};
end;
