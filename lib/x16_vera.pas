unit x16_vera;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: X16 VERA library for Mad-Pascal.
* @version: 0.1.0

* @description:
* Set of procedures to cover functionality provided by:    
*
* 
* https://github.com/X16Community/x16-docs/blob/master/X16%20Reference%20-%2009%20-%20VERA%20Programmer%27s%20Reference.md#chapter-9-vera-programmers-reference
*  
*
*   
* It's work in progress, please report any bugs you find.   
*   
*)

interface

// const

// var

procedure veraInit; assembler;
(*
* @description:
* Initialize graphics mode 320x240@256c. 
*
* 
* 
*)

procedure veraClear; assembler;
(*
* @description:
* Clear the current window with the current background color.
*
* 
* 
*)

procedure veraDrawImage(x, y: word; ptr: pointer; width, height: word); assembler;
(*
* @description:
* Draw a rectangular image from data in memory
* using zero page register r12
* 
* 
* @param: x - horizontal position x to place image to
* @param: y - vertical position y to place image to
* @param: ptr - pointer to image data in memory
* @param: width - width of image in pixels
* @param: height - height of image in pixels
*
*)

procedure veraDirectLoad(filename: String); assembler;
(*
* @description:
* Loads a named file from storage directly to video memory. 
*
* 
* 
* @param: name (TString) - name of the file with extension
*
*)

procedure veraFade(FadeDirection: byte); assembler;
(*
* @description:
* Performs fade Out and fade In of screen. 
* oryginal procedure code by unartic 
* 
* 
* @param: inout (byte) - if set to 0, performs fade out. If set to 1, performs fade in.
*
*)


implementation


procedure veraInit; assembler;
asm
    @Clrscr
    lda #$80
    jsr screen_mode
end;

procedure veraClear; assembler;
asm
	jsr GRAPH_clear
end;

procedure veraDrawImage(x, y: word; ptr: pointer; width, height: word); assembler;
asm
	phx
	lda x
	sta r0L
	lda x+1
	sta r0H

	lda y
	sta r1L
	lda y+1
	sta r1H

	lda ptr
	sta r2L
	lda ptr+1
	sta r2H

	lda width
	sta r3L
	lda width+1
	sta r3H

	lda height
	sta r4L
	lda height+1
	sta r4H
	
	jsr GRAPH_draw_image
	plx
end;

procedure veraDirectLoad(filename: String); assembler;
asm
        phx
        lda #1; // logical file number
        ldx #8; // device number
        ldy #2; // doing bvload
        jsr SETLFS

        // copy pointer to zero page
        lda filename
        sta r12L
        lda filename+1
        sta r12H

        // read first pointed-at byte - string length
        ldy #0
        lda (r12L),y
        
        // get pointer into x,y registers
        ldx r12L
        ldy r12H
        
        // increment past the length
        inx
        bne skip
        iny

    skip:
        jsr SETNAM


        lda #2; // BVLOAD to bank 0
        ldx #0; // address 0 (start of video mem)
        ldy #0
        jsr LOAD
        plx   
end;

procedure veraFade(FadeDirection: byte); assembler;
asm
    // jsr start

    jsr CopyPaletteToHighmem
    jsr Fade
    jmp FadeEnd

    PTR = ur0; // user register
    FadeSpeed               = 200    ; // higher is slower, max 255
    RambankForPaletteData   = 1      ; // Rambank which holds the original palette data for fading in


    tmp:  .byte 0
    tmp2: .byte 0
    // ; FadeDirection: .byte 0  ;if=0>fade out, if=1->fade in


    ; // not nececary, but makes reading easier
    NibbleLeftNew:    .byte 0
    NibbleRightNew:   .byte 0
    NibbleLeftOrig:   .byte 0
    NibbleRightOrig:  .byte 0

    // start:
    //     jsr CopyPaletteToHighmem
    //     jsr Fade
    //     // jmp FadeEnd


    Fade:
        ldx #0
        NextFadeStep:
            jsr Delay
            jsr FadeOneStep

            inx
            cpx #15     ; // 4 bits, so 16 steps should result in all black
            bne NextFadeStep
    rts



    FadeOneStep:
        ; // prepare pointer to check max palette color values 
        lda #$00
        sta PTR
        lda #$a0
        sta PTR+1
        
        lda $00  ; // save current rambank and restore when done
        pha

            ; // set rambank to RambankForPaletteData
            lda #RambankForPaletteData
            sta $00
            phx

            ; // set vera address to palette offset, no auto increment
            lda #$00
            sta VERA_addr_low
            lda #$FA
            sta VERA_addr_high
            lda #$01
            sta VERA_addr_bank
            
            ldy #0

            NextY:
                ldx #0

            NextX:
                phy
                    lda VERA_data0          ; // get byte from p
                    
                    ldy FadeDirection
                    cpy #0
                    bne FadeIn
                    ; // FadeOut
                    pha
                        ; // decrement the right nibble
                        sec
                        sbc #$01
                        AND #$0F ; // discard the left nibble
                        sta tmp
                    pla   
                    
                    ;decrement the left nible
                    sec
                    sbc #$10
                    AND #$F0    ; // discard the right nible
                    ora tmp     ; // merge the new left and right nibble
                    
                    jsr CheckNegative ; // check if any of the nibbles has become negarive, if so set nibble to 0
                    jmp StoreNewColorData
                    
                    FadeIn:                    
                        ; // FadeIn
                        pha
                            ; // increment the right nibble
                            clc
                            adc #$01
                            AND #$0F ; // discard the left nibble
                            sta tmp
                        pla   
                        
                        ; // increment the left nible
                        clc
                        adc #$10
                        AND #$F0    ; // discard the right nible
                        ora tmp     ; // merge the new left and right nibble
                        jsr CheckWithOriginalPalette
                        
                    StoreNewColorData:                    
                        sta VERA_data0 ; // store new palette color values
                        
                        ; // Increment VERA address
                        inc VERA_addr_low       ; //increase low byte
                        bne DoNotIncHighByte    
                        inc VERA_addr_high   ; // inc high byte if low byte became zero, we do not care about the 3rd byte
                    

                    DoNotIncHighByte:
                    
                        ; // Increment PTR to palette in rambank
                        inc PTR
                        bne DoNotIncHighBytePtr
                        inc PTR+1
                        DoNotIncHighBytePtr:
                ply
                    
                    
                inx
                cpx #0      ; // 256 times
                bne NextX
                iny
                cpy #2      ; // times 2 = the full pallete
                bne NextY

            plx      
        pla
        sta $00
    rts
    
    CheckNegative:
        ; //check if a nibble has become negative,  then force zero
        sta tmp2
        
        AND #$F0
        cmp #$F0
        bne NotNegativeLeft
        lda tmp2
        AND #$0F ;negative, so set left nibble to zero
        sta tmp2
        NotNegativeLeft:
        
        ; // check right nible
        lda tmp2
        AND #$0F
        cmp #$0F
        bne NotNegativeRight      
        lda tmp2
        AND #$F0
        sta tmp2
        NotNegativeRight:
        lda tmp2
    rts



    CheckWithOriginalPalette: 
        ; // check the new palette color values against the original palette in highram, 
        ; // and cap the max value per nibblw
    
        sta tmp
        AND #$F0
        sta NibbleLeftNew
        lda tmp
        AND #$0F
        sta NibbleRightNew  

        lda (PTR)   
        sta tmp
        AND #$F0
        sta NibbleLeftOrig
        lda tmp
        AND #$0F
        sta NibbleRightOrig
        
        lda NibbleLeftNew
        cmp NibbleLeftOrig
        bcc DoNotCapLeft
            lda NibbleLeftOrig
            sta NibbleLeftNew
        DoNotCapLeft:

        lda NibbleRightNew
        cmp NibbleRightOrig
        bcc DoNotCapRight
            lda NibbleRightOrig
            sta NibbleRightNew
        DoNotCapRight:
        
        lda NibbleLeftNew
        ora NibbleRightNew
    rts



    CopyPaletteToHighmem:
    
        lda $00
        pha
            lda #RambankForPaletteData
            sta $00  ; // set rambank #1
            
            ; // set vera address to pallette offset, auto increment by 1
            lda #$00
            sta VERA_addr_low
            lda #$FA
            sta VERA_addr_high
            lda #$11
            sta VERA_addr_bank  
            
            ; // set from address
            lda #<VERA_data0
            sta r0
            lda #>VERA_data0
            sta r0+1
            
            ; // set destination
            lda #$00
            sta r1
            lda #$a0
            sta r1+1
            
            ; // set number of bytes $200 = 521
            lda #$00
            sta r2
            lda #$02
            sta r2+1
            
            jsr MEMORY_COPY   ; // kernal function memory_copy
        pla
        sta $00
    rts

    Delay:
        phy
        phx
        ldx #0
        @NextX:
            ldy #0
            @NextY:
                iny
                cpy #0
                bne @NextY
                inx
                cpx #FadeSpeed
                bne @NextX
        plx
        ply
    rts
    
    FadeEnd:

end;


end.