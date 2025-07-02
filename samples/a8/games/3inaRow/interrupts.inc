procedure dliInGame;assembler; interrupt;
asm {
    phr

    mva >CHARSET_TXT_ADDRESS chbase
    lda progressColor1
    ldy progressColor0
    :19 sta wsync
    sta $D017
    sty $D018
    lda #BOARD_COLOR1
    ldy #BOARD_COLOR2
    ldx bgColor
    :9 sta wsync
    sta $D017
    sty $D018
    stx $D01A
    mva boardCharset chbase
    ldy #10
@
    lda #8
    sta wsync
    sta $D016
    lda #6
    :4 sta wsync
    sta $D016
    lda #4
    :6 sta wsync
    sta $D016
    lda #2
    :3 sta wsync
    sta $D016
    lda #4
    :2 sta wsync
    sta $D016
    dey
    bne @-
    lda #0
    sta $D01A
    sta $d018
    mva >CHARSET_TXT_ADDRESS chbase
    mva comboBrightness $D017
    mva #0 $D018

    plr
};
end;

procedure vbli:interrupt;
var dx,dy:shortInt;
begin
    asm {
        phr

        ;***************** cusrsor handling

        lda cursorDelay
        beq canmove    ; NOT CHECKIN MOVEMENT CHANGE
        dec cursorDelay
        jmp notmoved

canmove
        lda #0
        sta dx
        sta dy
        lda $284
        jeq notmoved

        lda $278
        cmp #11
        bne @+
        mva #-1 dx

        jmp moved
@
        cmp #7
        bne @+
        mva #1 dx

        jmp moved
@
        cmp #13
        bne @+
        mva #1 dy

        jmp moved
@
        cmp #14
        jne notmoved
        mva #-1 dy
        //jmp moved

moved
        mva #CURSOR_SPEED cursorDelay
        sta atari.atract

        lda updateCursor
        beq noShow1

        lda cursorShown
        beq noShow1

        lda $ff
        tay
        lda adr.board,y
        asl
        tax
        mwa adr.C_tiles,x $f4

        ldy #0                  // clear old cursor
        mwa ($f4),y ($f8),y
        adw $f4 #2
        adw $f8 #32
        ldy #0
        mwa ($f4),y ($f8),y
        mva #0 cursorShown

noShow1
        lda cursorX     // change cursor pos
        add dx
        cmp #10
        sne
        lda #0
        cmp #-1
        sne
        lda #9
        sta cursorX

        lda cursorY
        add dy
        cmp #10
        sne
        lda #0
        cmp #-1
        sne
        lda #9
        sta cursorY

        lda cursorY
        ldy cursorX
        beq @+1
@       add #10
        dey
        bne @-
@
        tay
        lda adr.board,y
        cmp #TILE_BLOCK
        beq noShow1
        cmp #TILE_VOID
        beq noShow1

notmoved
        lda updateCursor
        jeq noShow2

        lda cursorShown
        jne noShow2

        lda cursorY
        ldy cursorX
        beq @+1
@       add #10
        dey
        bne @-
@
        tay
        sty $ff
        lda adr.board,y
        asl
        tax
        mwa adr.C_cursor,x $f4

        mwa #VRAM_ADDRESS+6 $f6
        adb $f6 cursorX
        scc
        inc $f7
        adb $f6 cursorX
        scc
        inc $f7
        ldy cursorY
        beq @+1
@       adb $f6 #64
        scc
        inc $f7
        dey
        bne @-
@

        mwa $f6 $f8
        ldy #0
        mwa ($f4),y ($f6),y
        adw $f4 #2
        adw $f6 #32
        ldy #0
        mwa ($f4),y ($f6),y
        mva #1 cursorShown

noShow2


        ;************* hint blink
        lda showHintTimer
        jeq noBlink

        dec showHintTimer

        cmp #1
        beq showBall
        and #4
        bne hideBall

showBall
        ldy #0
        mwa hint1pos $f4
        mwa hint1ball1 ($f4),y
        ldy #32
        mwa hint1ball2 ($f4),y
        ldy #0
        mwa hint2pos $f4
        mwa hint2ball1 ($f4),y
        ldy #32
        mwa hint2ball2 ($f4),y

        jmp noBlink

hideBall
        ldy #0
        mwa hint1pos $f4
        mwa #$0e0d ($f4),y
        ldy #32
        mwa #$2e2d ($f4),y
        ldy #0
        mwa hint2pos $f4
        mwa #$0e0d ($f4),y
        ldy #32
        mwa #$2e2d ($f4),y

noBlink

        ;************** combo label fading

        lda fadeDelay
        beq fadeCombo
        dec fadeDelay
        bne @+
fadeCombo
        lda comboBrightness
        beq @+
        lda 20
        and #%10
        bne @+
        dec comboBrightness

@
        ;************** timer

        lda timerTicks
        beq noTimer
	
	
        cmp progressTick
        bne incTick
        mva #0 progressTick
        lda progress
        beq noTimer
        dec progress
        ; show progress
        lda progress
        :3 lsr
        tay
        lda progress
        and #7
        tax
        lda adr.progressMap,x
        sta PROGRESS_ADDRESS+32,y
        tya
        :2 lsr
        tay
        mva adr.progressColors0,y progressColor0
        mva adr.progressColors1,y progressColor1

        jmp noTimer

incTick
        inc progressTick
noTimer

	lda 20
        and #%11
        bne @+
		;*************** bomb fuse blink

		lda CHARSET_TILE_ADDRESS + ($13 * 8) + 5
		ldy CHARSET_TILE_ADDRESS + ($13 * 8) + 6
		sty CHARSET_TILE_ADDRESS + ($13 * 8) + 5
		sta CHARSET_TILE_ADDRESS + ($13 * 8) + 6

		lda CHARSET_TILE_ADDRESS + ($4b * 8) + 5
		ldy CHARSET_TILE_ADDRESS + ($4b * 8) + 6
		sty CHARSET_TILE_ADDRESS + ($4b * 8) + 5
		sta CHARSET_TILE_ADDRESS + ($4b * 8) + 6


		ldx #15
explode_loop

		lda CHARSET_TILE_ADDRESS + ($4f * 8),x
		tay
		lda CHARSET_TILE_ADDRESS + ($51 * 8),x
		sta CHARSET_TILE_ADDRESS + ($4f * 8),x
		tya
		sta CHARSET_TILE_ADDRESS + ($51 * 8),x

		lda CHARSET_TILE_ADDRESS + ($6f * 8),x
		tay
		lda CHARSET_TILE_ADDRESS + ($71 * 8),x
		sta CHARSET_TILE_ADDRESS + ($6f * 8),x
		tya
		sta CHARSET_TILE_ADDRESS + ($71 * 8),x

		dex
		bpl explode_loop


@       ;************** register shadowing
toEnd
        mwa sdlstl dlistl

        sta $d403
        lda 559   ;DMACTLS
        sta $d400
        lda 623   ;GTICTLS
        sta $d01b

        ldx #8
col     lda 704,x
        sta $d012,x
        dex
        bpl col

        lda $D300
        and #15
        sta $278
        lda $D301
        and #15
        sta $279
        mva $D010 $284
        mva $D011 $285

        ;lda musicOn;
        ;beq @+
        ;lda MSX
        ;ldy MSX+1
        ;jsr RMT.TRMT.PLAY
@
	plr
    };
end;
