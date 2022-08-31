; Code by DMSC, unrolled by TEBE (2022-08-28)
;
; LZSS Compressed SAP player for 16 match bits
; --------------------------------------------
;
; This player uses:
;  Match length: 8 bits  (2 to 257)
;  Match offset: 8 bits  (1 to 256)
;  Min length: 2
;  Total match bits: 16 bits
;
; Compress using:
;  lzss -6 input.rsap test.lz16
;

	icl 'atari.hea'


POKEY = $D200

sap_lzss.zp	= $90

len = sap_lzss.chn_bits1-sap_lzss.chn_bits0

.public sap_lzss.init, sap_lzss.play, sap_lzss.stop


    .RELOC


.local sap_lzss

; --------------------

init

; --------------------

    lda sap_lzss.zp
    pha
    lda sap_lzss.zp+1
    pha

    stx sap_lzss.zp
    sty sap_lzss.zp+1

    ldy #0

    lda (sap_lzss.zp),y

    sta sptr

    iny
    lda (sap_lzss.zp),y

    sta sptr+1

    iny
    lda (sap_lzss.zp),y
    sta size_l
    iny
    lda (sap_lzss.zp),y
    sta size_h

    iny
    lda (sap_lzss.zp),y
    tax
    stx buf

    stx buf_lda0+2
    stx buf_sta0+2
    inx
    stx buf_lda1+2
    stx buf_sta1+2
    inx
    stx buf_lda2+2
    stx buf_sta2+2
    inx
    stx buf_lda3+2
    stx buf_sta3+2
    inx
    stx buf_lda4+2
    stx buf_sta4+2
    inx
    stx buf_lda5+2
    stx buf_sta5+2
    inx
    stx buf_lda6+2
    stx buf_sta6+2
    inx
    stx buf_lda7+2
    stx buf_sta7+2
    inx
    stx buf_lda8+2
    stx buf_sta8+2

    iny
    lda (sap_lzss.zp),y
    tax
    stx chn_pokeyA+1

    stx chn_pokey0+1
    inx
    stx chn_pokey1+1
    inx
    stx chn_pokey2+1
    inx
    stx chn_pokey3+1
    inx
    stx chn_pokey4+1
    inx
    stx chn_pokey5+1
    inx
    stx chn_pokey6+1
    inx
    stx chn_pokey7+1
    inx
    stx chn_pokey8+1


    jsr stop


    ldx #8+1

clear
    lda sptr: $1000

    sta chn_temp,x

    inw sptr

    dex
    bpl clear


    lda <chn_bits0		; unroll chn_bits
    sta sap_lzss.zp
    lda >chn_bits0
    sta sap_lzss.zp+1


    lda chn_temp+9
    sta bit_data

    .rept 9,#
    lsr bit_data
    bcs @+

    lda #3
    dta {bit $100}
@
    lda #len			; skip channel

    add sap_lzss.zp
    sta chn_bits:1+1
    lda #0
    adc sap_lzss.zp+1
    sta chn_bits:1+2

    adw sap_lzss.zp #len

    .endr

    pla
    sta sap_lzss.zp+1
    pla
    sta sap_lzss.zp

; --------------------

restart

; --------------------

    lda buf: #0
    sta cbuf+2

    ldx #8
cp  lda chn_temp,x

chn_pokeyA
    sta POKEY,x

cbuf
    sta $1000+255
    inc cbuf+2
    dex
    bpl cp

    inx				; =0
    stx cur_pos

    stx chn_pos0+1
    stx chn_pos1+1
    stx chn_pos3+1
    stx chn_pos4+1
    stx chn_pos5+1
    stx chn_pos6+1
    stx chn_pos7+1
    stx chn_pos8+1

    stx chn_copy0+1
    stx chn_copy1+1
    stx chn_copy2+1
    stx chn_copy3+1
    stx chn_copy4+1
    stx chn_copy5+1
    stx chn_copy6+1
    stx chn_copy7+1
    stx chn_copy8+1

    inx
    stx bit_data		; =1

    lda sptr
    sta ladr
    clc
    adc size_l: #0
    sta song_end_l

    lda sptr+1
    sta hadr
    adc size_h: #0
    sta song_end_h

    sec

    rts

bit_data brk


.macro	gbyte
    lda (sap_lzss.zp),y

    iny
.endm

; --------------------

play

; --------------------

    stx regX

    lda sap_lzss.zp
    sta ltmp
    lda sap_lzss.zp+1
    sta htmp

    lda ladr: #0
    sta sap_lzss.zp

    lda hadr: #0
    sta sap_lzss.zp+1

    ldy #0

    ldx cur_pos: #$00
    inc cur_pos


    .rept 9,8-#,#,#+1

;    ldx #8

    ; Loop through all "channels", one for each POKEY register
;chn_loop:

chn_bits:2
    jmp chn_bits:3

;    lda #0
;    bne @+3

;    lsr chn_bits
;    bcs @+3	;skip_chn       ; C=1 : skip this channel


chn_copy:1

    lda #$00	;, x    ; Get status of this stream
    bne @+1	; do_copy_byte   ; If > 0 we are copying bytes

    ; We are decoding a new match/literal
    lsr bit_data       ; Get next bit
    bne @+	;got_bit
    gbyte       ; Not enough bits, refill!

    ror @       ; Extract a new bit and add a 1 at the high bit (from C set above)
    sta bit_data       ;
@	;got_bit:
    gbyte       ; Always read a byte, it could mean "match size/offset" or "literal byte"
    bcs @+1	;store          ; Bit = 1 is "literal", bit = 0 is "match"

    sta chn_pos:1+1	;, x     ; Store in "copy pos"

    gbyte
    sta chn_copy:1+1	;, x    ; Store in "copy length"
                        ; And start copying first byte
@	;do_copy_byte:
    dec chn_copy:1+1	;, x     ; Decrease match length, increase match position

    inc chn_pos:1+1	;, x
chn_pos:1
    ;ldy #$00		;, x

    ; Now, read old data, jump to data store
buf_lda:2
    lda $1000+#*$100

@	;store:

    ;ldy cur_pos
chn_pokey:1
    sta POKEY+:1	;, x        ; Store to output and buffer

buf_sta:2
    sta $1000+#*$100,x

    ; Increment channel buffer pointer
    ;inc bptr+1


@	;skip_chn:
	.endr

chn_bits9

    tya
    add sap_lzss.zp
    sta sap_lzss.zp
    scc
    inc sap_lzss.zp+1

    sta ladr

    lda sap_lzss.zp+1
    sta hadr
    cmp song_end_h: #0
    bne @+
    lda sap_lzss.zp
    cmp song_end_l: #0
@
    bcc toExit

    jsr restart

toExit

    lda ltmp: #0
    sta sap_lzss.zp

    lda htmp: #0
    sta sap_lzss.zp+1

    ldx regX: #0
    rts

chn_temp :10 brk


; --------------------

stop

; --------------------

    ldy chn_pokeyA+1

    lda #0
    sta AUDCTL,y
    lda #3
    sta SKCTL,y
    lda #0
    :8 sta POKEY+#,y

    rts

.endl
