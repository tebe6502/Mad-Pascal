procedure dli;assembler;interrupt;
asm {
    phr
    
    mwa planesH $fe

plane_sky
    ldy #3
    ldx #$88
    lda ($fe),y
    sta wsync
    ;nop:nop:nop
    sta atari.hscrol
    stx atari.colbk
    lda #$0a
    sta atari.colpf0
    lda #$04
    sta atari.colpf1
    lda #$88
    sta atari.colpf2
    lda #B_TOP
    sta atari.colpf3
    ldx #$0f
    lda #14
    jsr waitforline
    lda #$0c
    sta wsync
    sta atari.colpf2
    stx atari.colpf1

plane_houses
    lda #24
    jsr waitforline
    ldy #2
    ldx #$86
    lda ($fe),y
    sta wsync
    nop:nop:nop
    sta atari.hscrol
    stx atari.colbk
    lda #$18
    sta atari.colpf0
    lda #$1c
    sta atari.colpf1
    lda #$91
    sta atari.colpf2

    ldx #$84
    lda #38
    jsr waitforline
    sta wsync
    sta wsync
    stx atari.colbk

    lda #46
    jsr waitforline
    lda #$b2
    sta wsync
    sta atari.colpf0
    lda #$70
    ldx #$b0
    sta wsync
    sta atari.colbk
    stx atari.colpf2
    lda #$98
    sta atari.colpf1

plane_water
    lda #51
    jsr waitforline
    lda #$74
    sta atari.colpf0
    lda #$7c
    sta atari.colpf1
    lda #$76
    sta atari.colpf2
    ldy #1
    lda ($fe),y
    sta wsync
    nop:nop:nop
    sta atari.hscrol
    ;sta atari.colbk


plane_barrel3
    lda #68
    jsr waitforline
    lda #B_SHADOW
    sta wsync
    sta atari.colpf3
    lda #B_BODY
    sta wsync
    sta atari.colpf3


plane_boat
    lda #74
    jsr waitforline
    ldy #4
    lda ($fe),y
    sta wsync
    :3 nop
    sta atari.hscrol
    ;sta atari.colbk
    lda #$86
    sta atari.colpf0
    lda #$26
    sta atari.colpf2
    lda #78
    jsr waitforline
    lda #B_SHADOW
    sta wsync
    sta wsync
    sta atari.colpf3
    lda #B_BOTTOM
    sta wsync
    sta atari.colpf3
    lda #B_TOP
    sta wsync
    sta atari.colpf3
    lda #B_SHADOW
    sta wsync
    sta atari.colpf3
    lda #B_BODY
    sta wsync
    sta atari.colpf3


plane_fences
    lda #86
    jsr waitforline
    ldx #$18
    stx atari.colpf1
    ldx #$24
    stx atari.colpf0
    ldx #$10
    stx atari.colpf2
    ldy #0
    lda ($fe),y
    sta wsync
    :3 nop
    sta atari.hscrol
    ;sta atari.colbk


    ; barrel 2
    lda #90
    jsr waitforline
    lda #B_SHADOW
    sta wsync
    sta wsync
    sta atari.colpf3
    lda #B_BOTTOM
    sta wsync
    sta atari.colpf3
    lda #B_TOP
    sta wsync
    sta atari.colpf3
    lda #B_SHADOW
    sta wsync
    sta atari.colpf3
    lda #B_BODY
    sta wsync
    sta atari.colpf3

plane_road    
    lda #94
    jsr waitforline
    lda #$10
    sta wsync
    sta wsync
    sta atari.colbk
    sta atari.colpf2
    lda #$00
    sta wsync
    sta wsync
    sta atari.colbk
    sta atari.colpf2
    lda #$02
    sta wsync
    sta atari.colbk
    sta atari.colpf2

    ; barrel 3
    lda #102
    jsr waitforline
    lda #B_SHADOW
    sta wsync
    sta wsync
    sta atari.colpf3
    lda #B_BOTTOM
    sta wsync
    sta atari.colpf3
    
    lda #108
    jsr waitforline
    lda #$d2
    sta wsync
    sta atari.colbk
    sta atari.colpf2
    lda #$d4
    ldx #$0d
    :2 sta wsync
    sta atari.colbk
    sta atari.colpf2
    stx atari.colpf1
    plr
    
    rti
    
waitforline
    cmp vcount
    bpl waitforline
    rts

.def :putnum
    and #%1111
    ora #16
    sta TXT_RAM,y;
    dey
    rts

.def :printScore
    ldx #0
@              
    lda score,x 
    pha
    jsr putnum
    pla
    :4 lsr 
    jsr putnum
    inx
    cpx #3
    bne @-
    rts
    
.def :addScore
    txa
    pha
    sed
    clc
    lda score
    adc count
    sta score
    ldx #1
@             
    lda score,x
    adc #0
    sta score,x
    inx 
    cpx #4
    bne @-
    cld

    ldy #16
    jsr printScore
    pla
    tax
    rts
};
end;
