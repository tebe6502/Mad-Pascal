procedure Dli1; interrupt;
begin
    asm {
        pha
        mva adr.level.colors+4 _ATARI._COLOR2
        mva #$0F _ATARI._COLOR1
        mva >CHARSET_TITLE_ADDRESS $D409
        mwa #DLI2 _ATARI._VDSLST
        pla
        };
end;

procedure Dli2; interrupt;
begin
    asm {
        pha
        mva adr.level.colors+1 _ATARI._COLOR1
        mva adr.level.colors+2 _ATARI._WSYNC
        sta _ATARI._COLOR2
        mva >CHARSET_GAME_ADDRESS $D409
        mwa #DLI3 _ATARI._VDSLST
        pla
        };
end;

procedure Dli3; interrupt;
begin
    asm {
        pha
        lda vcount
        cmp #113
        bmi @+
        lda #0
        sta _ATARI._WSYNC
        sta _ATARI._COLOR3
        sta _ATARI._COLOR2
        sta _ATARI._COLOR1
@
        pla
        };
end;

procedure Dli1T; interrupt;
begin
    asm {
        pha
        mva #0   _ATARI._COLOR2
        mva #$06 _ATARI._COLOR1
        :3 sta _ATARI._WSYNC
        mva #$08 _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$0a _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$0c _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$0a _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$08 _ATARI._COLOR1
        mwa #DLI2T _ATARI._VDSLST
        pla
        };
end;

procedure Dli2T; interrupt;
begin
    asm {
        pha
        mva #$84 _ATARI._COLOR0
        mva #$EE _ATARI._COLOR1
        mva #$28 _ATARI._COLOR2
        mwa #DLI3T _ATARI._VDSLST
        pla
        };
end;

procedure Dli3T; interrupt;
begin
    asm {
        pha
        mva #0   _ATARI._COLOR2
        mva #$0f _ATARI._COLOR1
        mva #$1c _ATARI._COLOR3
        mwa #DLI4T _ATARI._VDSLST

        pla
        };
end;

procedure Dli4T; interrupt;
begin
    asm {
        pha
        mva #0   _ATARI._COLOR2
        mva #$06 _ATARI._COLOR1
        :11 sta _ATARI._WSYNC
        mva #$08 _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$0a _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$0c _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$0a _ATARI._COLOR1
        sta _ATARI._WSYNC
        mva #$08 _ATARI._COLOR1

        pla
        };
end;


procedure Vblank; interrupt;
begin
    asm {
        sta regA
        stx regX
        sty regY
        mwa dliVector _ATARI._VDSLST    ; reset DLi to Dli1

        sta _ATARI._ATRACT

        lda vscrollstep             ; set vscroll
        asl
        sta _ATARI._VSCROL
        mwa dltop DLG+7     ; set DL GFX address

        inc _ATARI._RTCLOK+2

        mwa _ATARI._SDLSTL_ _ATARI._SDLSTL
        mva _ATARI._SDMCTL_ _ATARI._DMACTL
        mva _ATARI._GPRIOR_ _ATARI._GPRIOR
        :9 mva 704+# $d012+#

};
    //if music then msx.Play;

    asm {
        lda #0
regA    equ *-1
        ldx #0
regX    equ *-1
        ldy #0
regY    equ *-1
        rti
        };

    Dli1;
    Dli2;
    Dli3;
    Dli1T;
    Dli2T;
    Dli3T;
    Dli4T;
end;

