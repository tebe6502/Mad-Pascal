; code by dmsc, unrolled by tebe (2022-09-12; 2022-09-19; 2022-11-06)
;
; LZSS Compressed SAP player for 16 match bits (Mad Pascal)
; ---------------------------------------------------------
;
; (c) 2020 DMSC
; Code under MIT license, see LICENSE file.
;
; This player uses:
;  Match length: 8 bits  (1 to 256)
;  Match offset: 8 bits  (1 to 256)
;  Min length: 2
;  Total match bits: 16 bits
;
; Compress using:
;  lzss -b 16 -o 8 -m 1 input.rsap test.lz12
;
; Assemble this file with MADS assembler, the compressed song is expected in
; the `test.lz16` file at assembly time.
;
; The plater needs 256 bytes of buffer for each pokey register stored, for a
; full SAP file this is 2304 bytes.
;

song_ptr = $90

POKEY = $D200
SKCTL = $D20F
AUDCTL= $d208

len = chn_bits1-chn_bits0

chn_pokey = chn_pokey8-chn_pokey0


//.public init_song, decode_frame, play_frame, buffers


    .reloc

.macro get_byte
    lda (song_ptr),y
    iny
.endm

    jmp play_frame	; CLC -> decode_frame ; SEC -> play_frame
    jmp init_song

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Song Initialization - this runs in the first tick:
; A	< song address
; X	> song address
; Y	$00 POKEY $D200; $10 POKEY $D210 ...

.proc init_song
    pha
    txa
    pha

    lda song_ptr
    sta tmp0
    lda song_ptr+1
    sta tmp1

    ; Example: here initializes song pointer:
    pla
    sta song_ptr+1
    sta song_h
    pla
    sta song_ptr
    sta song_l
 
    lda #0
    sta skctl,y
    sta audctl,y

    lda #3
    sta skctl,y

    sty poke

    ldx #chn_pokey

fpok			; modify chn_pokey0..8
    tya
    sta chn_pokey0+1,x

    iny

    txa
    sub #6
    tax
    bpl fpok
	
    lda <chn_bits0
    sta chn_bits+1
    lda >chn_bits0
    sta chn_bits+2

    ldy #0

    get_byte
    add song_ptr
    sta song_end_l
    get_byte
    adc song_ptr+1
    sta song_end_h

    get_byte
    sta bit_data


    ldx #8

lp  lsr bit_data
    bcs @+

    lda #3
    dta {bit $100}
@
    lda #len			; skip channel

    ldy #1
    add chn_bits+1
    jsr chn_bits
    lda #0
    adc chn_bits+2
    jsr chn_bits

    adw chn_bits+1 #len

    dex
    bpl lp

restart

    ldy #3

    lda >buffers
    sta cbuf+2

    ; Init all channels:
    ldx #8
clear
    ; Read just init value and store into buffer and POKEY
    get_byte

    sta poke: POKEY,x
cbuf
    sta buffers + 255
    inc cbuf + 2
    dex
    bpl clear

    tya
    add song_ptr
    sta song_ptr_l
 ;   sta song_l
    lda #$00
    adc song_ptr+1
    sta song_ptr_h
;    sta song_h

    clc
    
    ldy tmp0: #$00	; restore ZP: SONG_PTR
    lda tmp1: #$00

reset

    sty song_ptr
    sta song_ptr+1
    
    bcs restart

    ; Initialize buffer pointer:
;    sty bptr
    ldy #1
    sty bit_data

    dey
    sty cur_pos

    sty chn_copy0+1
    sty chn_copy1+1
    sty chn_copy2+1
    sty chn_copy3+1
    sty chn_copy4+1
    sty chn_copy5+1
    sty chn_copy6+1
    sty chn_copy7+1
    sty chn_copy8+1

_rts rts

chn_bits
    sta $1000,y
    iny
    rts

.endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; play_frame
;

play_frame

    bcc decode_frame

    ldy pos: #$00

    .rept 9,#
    lda buffers+:1*$100,y
chn_pokey:1
    sta POKEY+8-:1
    .endr

    dec pos

    rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Play one frame of the song
;
decode_frame
;    lda #>buffers
;    sta bptr+1

;    lda song_data
;    sta chn_bits

    lda song_ptr
    sta sng_l
    lda song_ptr+1
    sta sng_h

    lda song_ptr_l: #$00
    sta song_ptr

    lda song_ptr_h: #$00
    sta song_ptr+1


    ldx cur_pos: #$00
    stx pos

    inc cur_pos

    ldy #0

;    ldx #8
    .rept 9,#

chn_bits:1
     jmp *

    ; Loop through all "channels", one for each POKEY register
;chn_loop:
;    lsr chn_bits
;    bcs skip_chn       ; C=1 : skip this channel
;    bcs @+3

chn_copy:1
    lda #$00    ; Get status of this stream
 ;   bne do_copy_byte   ; If > 0 we are copying bytes
    bne @+1

    ; We are decoding a new match/literal
    lsr bit_data        ; Get next bit
;    bne got_bit
    bne @+

    get_byte            ; Not enough bits, refill!
    ror                 ; Extract a new bit and add a 1 at the high bit (from C set above)
    sta bit_data        ;

;got_bit:
@
    get_byte            ; Always read a byte, it could mean "match size/offset" or "literal byte"
;    bcs store          ; Bit = 1 is "literal", bit = 0 is "match"
    bcs @+1

    sta chn_pos:1+1     ; Store in "copy pos"

    get_byte
    sta chn_copy:1+1    ; Store in "copy length"

                        ; And start copying first byte
;do_copy_byte:
@
    dec chn_copy:1+1    ; Decrease match length, increase match position
    inc chn_pos:1+1

chn_pos:1
    ; Now, read old data, jump to data store
    lda buffers+:1*$100

;store:
@
;    sta POKEY+8-:1      ; Store to output and buffer
    sta buffers+:1*$100,x

;skip_chn:
@
    ; Increment channel buffer pointer
;    inc bptr+1

    .endr

chn_bits9

    tya
    add song_ptr
    tay
    lda #$00
    adc song_ptr+1

    sty song_ptr_l
    sta song_ptr_h

;    dex
;    bpl chn_loop        ; Next channel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check for ending of song and jump to the next frame
;

    cmp song_end_h: #0
    bne @+
    cpy song_end_l: #0
@
    bcc end_loop

    ldy song_l: #$00	; C = 1
    lda song_h: #$00

    jsr init_song.reset

end_loop

    lda sng_l: #$00
    sta song_ptr

    lda sng_h: #$00
    sta song_ptr+1

    rts

bit_data
    dta 0

    ert <* <> 0

buffers
;    :256*9 brk
