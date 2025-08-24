unit packfire;
(*
@type: unit
@name: PackFire
@author: Krzysztof 'XXL' Dudek, Tomasz 'Tebe' Biela

@description:

<https://www.pouet.net/prod.php?which=54840>

<https://www.cpcwiki.eu/forum/programming/dumb-question-15839-bitbuster-1-2/msg32069/#msg32069>

https://github.com/tebe6502/Mad-Assembler/tree/master/examples/compression/packfire

!!! PackFire v1.2 !!!

packfire -t filename.in filename.out

*)


interface

	procedure unPCF(compressed_data, decompressing: pointer); assembler; register;



implementation


procedure unPCF(compressed_data, decompressing: pointer); assembler; register;
asm

;compressed_data      equ $80  :edx
;decompressing        equ $82  :ecx

copsrc               = :edx+2

token                = :ecx+2
_IYL                 = :ecx+3
_IYH                 = :eax
_L                   = :eax+1
_H                   = :eax+2
_B                   = :eax+3

.macro	_GET_BYTE
	lda   (compressed_data),y
        inw   compressed_data
.endm


.macro	get_bit
	    asl   token
            bne   @+
            _GET_BYTE
            rol   @
            sta   token
@
.endm

	    txa:pha


PackFireTiny
            lda   compressed_data
            sta   sm_ix
            clc
            adc   #$1a
            sta   compressed_data
            lda   compressed_data+1
            sta   sm_ix+1
            adc   #$00
            sta   compressed_data+1
            ldy   #$00
            _GET_BYTE
            sta   token

literal_copy
            _GET_BYTE
            sta   (decompressing),y
            inw   decompressing
main_loop   get_bit
            bcs   literal_copy

            ldx   #$ff
            stx   _IYL
get_index   inc   _IYL
            get_bit
            bcc   get_index
            ;c=1

            ldx   _IYL
            cpx   #$10
            bne   @+

	    pla:tax
	    jmp @exit

;            rts                   ; koniec

@           jsr   get_pair
            ldx   _IYL
            stx   sm_len_L
            lda   _IYH
            sta   sm_len_H

            cpx   #$02
            beq   r2
            cpx   #$01
            beq   r1
            ldx   #$10        ; 0 i >2
            bne   fin_cmp1
r1          ldx   #$30        ; =1
            lda   #$02
            bne   fin_cmp
r2          ldx   #$20        ; =2
fin_cmp1    lda   #$04
fin_cmp     stx   sm_d0_L
            sty   sm_d0_H
            sta   _B

            jsr   get_bits
            jsr   get_pair

            sec
            lda   decompressing
            sbc   _IYL
            sta   copsrc
            lda   decompressing+1
            sbc   _IYH
            sta   copsrc+1

            ldx   #$ff
sm_len_H    equ   *-1
            beq   Remainder
Page        lda   (copsrc),y
            sta   (decompressing),y
            iny
            bne   Page
            inc   copsrc+1
            inc   decompressing+1
            dex
            bne   Page
Remainder   ldx   #$ff
sm_len_L    equ   *-1
            beq   copyDone
copyByte    lda   (copsrc),y
            sta   (decompressing),y
            iny
            dex
            bne   copyByte
            tya
            clc
            adc   decompressing
            sta   decompressing
            bcc   copyDone
            inc   decompressing+1
copyDone    ldy   #$00

            jmp   main_loop

; ---------------------------------

get_pair    inc   _IYL            ; zawsze < 256 ?  y=0
calc_len_dist
            tya
            and   #$0f
            bne   @+
            sta   _H
            ldx   #$01
            stx   _L
@           lsr   @
            php
            tya
            lsr   @
            tax
            lda   $ffff,x
sm_ix       equ   *-2
            plp
            bcc   nibble
        :4 lsr   @
nibble      and   #$0f
            sta   _B
            ldx   _L
            stx   sm_d0_L
            ldx   _H
            stx   sm_d0_H
            cmp   #$08
            bcc   mn8
            sbc   #$08     ; c=1
            tax
            lda   tab_bit,x         ;    D=n    E=0
            tax
            lda   #$00
            beq   @+
mn8         tax
            lda   tab_bit,x         ;    D=0    E=n
            ldx   #$00
@           clc
            adc   _L
            sta   _L
            txa
            adc   _H
            sta   _H
            iny
            dec   _IYL
            bne   calc_len_dist
            ldy   #$00

get_bits
            sty   _IYL
            sty   _IYH
            inc   _B

getting_bits
            dec   _B
            beq   _gb1

            get_bit
            bcc   @+
            asl   _IYL
            rol   _IYH
            inc   _IYL
            bne   getting_bits       ; jmp
@           asl   _IYL
            rol   _IYH
            jmp   getting_bits

_gb1        ;clc
            lda   #$ff
sm_d0_L     equ   *-1
            adc   _IYL
            sta   _IYL
            lda   #$ff
sm_d0_H     equ   *-1
            adc   _IYH
            sta   _IYH
            rts

;get_bit     asl   token
;            beq   @+
;            rts
;@           _GET_BYTE
;            rol   @
;            sta   token
;            rts

;_GET_BYTE   lda   (compressed_data),y
;            inw   compressed_data
;            rts

tab_bit     .byte $01,$02,$04,$08,$10,$20,$40,$80

end;


end.
