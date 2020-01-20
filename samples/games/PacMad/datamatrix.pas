unit datamatrix;
interface

procedure CalculateMatrix;
procedure SetMessage(msg:string;dmData:word);

implementation
uses graph;

const
   DataMatrix_EOF = 255;

procedure CalculateMatrix;
begin
asm
{
    txa
    pha

; datamatrix.asx - Data Matrix barcode encoder in 6502 assembly language

; "THE BEER-WARE LICENSE" (Revision 42):
; Piotr Fusik <fox@scene.pl> wrote this file.
; As long as you retain this notice you can do whatever you want with this stuff.
; If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.

; Compile with xasm (http://xasm.atari.org/), for example:
; xasm datamatrix.asx /l /d:DataMatrix_code=$b600 /d:DataMatrix_data=$b900 /d:DataMatrix_SIZE=20
; DataMatrix_code - self-modifying code
; DataMatrix_data - uninitialized data
; DataMatrix_SIZE - 10, 12, 14, 16, 18, 20, 22, 24, 26, 32, 36, 40, 44 or 48


DataMatrix_data = DM_DATA;
DataMatrix_SIZE = DM_SIZE;

DataMatrix_message  equ DataMatrix_data ; DataMatrix_DATA_CODEWORDS

   DataMatrix_symbol = DataMatrix_data+$100;

; private:

    ift DataMatrix_SIZE<=26
DataMatrix_MATRIX_SIZE  equ DataMatrix_SIZE-2
    els
DataMatrix_MATRIX_SIZE  equ DataMatrix_SIZE-4
    eif

DataMatrix_dataCodewords    equ DataMatrix_message  ; DataMatrix_DATA_CODEWORDS
DataMatrix_errorCodewords   equ DataMatrix_dataCodewords+DataMatrix_DATA_CODEWORDS ; DataMatrix_ERROR_CODEWORDS

DataMatrix_exp  equ DataMatrix_data+$100    ; $100
DataMatrix_log  equ Datamatrix_data+$200    ; $100

    ldx #-1
DataMatrix_encodeMessage_1
    inx
    inc DataMatrix_message,x
    bne DataMatrix_encodeMessage_1
    lda #129
DataMatrix_padMessage_1
    sta DataMatrix_message,x+
    lda DataMatrix_padding,x
    bne DataMatrix_padMessage_1

    tax ; #0
    lda #1
DataMatrix_initExpLog_1
    sta DataMatrix_exp,x
    tay
    txa
    sta DataMatrix_log,y
    tya
    asl @
    scc:eor <301
    inx
    bne DataMatrix_initExpLog_1

    ldy #DataMatrix_ERROR_CODEWORDS-1
    txa ; #0
    sta:rpl DataMatrix_errorCodewords,y-
;   ldx #0
DataMatrix_reedSolomon_1
    txa:pha
    ldy #0
    lda DataMatrix_dataCodewords,x
    eor DataMatrix_errorCodewords
DataMatrix_reedSolomon_2
    pha
    beq DataMatrix_reedSolomon_3
    tax
    lda DataMatrix_log,x
    add DataMatrix_poly,y
    adc #0
    tax
    lda DataMatrix_exp,x
DataMatrix_reedSolomon_3
    cpy #DataMatrix_ERROR_CODEWORDS-1
    scs:eor DataMatrix_errorCodewords+1,y
    sta DataMatrix_errorCodewords,y+
    pla
    bcc DataMatrix_reedSolomon_2
    pla:tax
    inx
    cpx #DataMatrix_DATA_CODEWORDS
    bcc DataMatrix_reedSolomon_1

    ldy #DataMatrix_SIZE-3
    mwa #DataMatrix_symbol  DataMatrix_clear_store+1
DataMatrix_clear_line
    lda #DataMatrix_SIZE
    add:sta DataMatrix_clear_store+1
    scc:inc DataMatrix_clear_store+2
    ldx #DataMatrix_SIZE-1
DataMatrix_clear_dashed
    tya
    and #1
DataMatrix_clear_store
    sta $ffff,x
    lda #2
    dex
    bmi DataMatrix_clear_next
    ift DataMatrix_SIZE>26
    beq DataMatrix_clear_solid
    cpx #DataMatrix_SIZE/2-1
    beq DataMatrix_clear_dashed
    cpx #DataMatrix_SIZE/2
    eif
    bne DataMatrix_clear_store
DataMatrix_clear_solid
    lsr @
    bpl DataMatrix_clear_store  ; jmp
DataMatrix_clear_next
    dey
    bpl DataMatrix_clear_line

    ldx #DataMatrix_SIZE-1
DataMatrix_horizontal_1
    txa
    and:eor #1
    sta DataMatrix_symbol,x
:DataMatrix_SIZE>26 sta DataMatrix_symbol+DataMatrix_SIZE/2*DataMatrix_SIZE,x
    mva #1  DataMatrix_symbol+[DataMatrix_SIZE-1]*DataMatrix_SIZE,x
:DataMatrix_SIZE>26 sta DataMatrix_symbol+[DataMatrix_SIZE/2-1]*DataMatrix_SIZE,x
    dex
    bpl DataMatrix_horizontal_1

    mwa #DataMatrix_dataCodewords   DataMatrix_fillSource
    ldx #0
    ldy #4

DataMatrix_fill_1
; Check corner cases
    ift [DataMatrix_MATRIX_SIZE&4]!=0
    txa
    bne DataMatrix_noCorner
    cpy #DataMatrix_MATRIX_SIZE-[DataMatrix_MATRIX_SIZE&2]
    bne DataMatrix_noCorner
; corner1/2
    lda #15
    jsr DataMatrix_setCorner
DataMatrix_noCorner
    eif

; Sweep upward-right
DataMatrix_fill_up
    cpy #DataMatrix_MATRIX_SIZE
    jsr DataMatrix_setUtah
DataMatrix_no_up
:2  inx
:2  dey
    bmi DataMatrix_fill_top
    cpx #DataMatrix_MATRIX_SIZE
    bcc DataMatrix_fill_up
DataMatrix_fill_top
:3  inx
    iny
; Sweep downward-left
DataMatrix_fill_down
    tya
    bmi DataMatrix_no_down
    cpx #DataMatrix_MATRIX_SIZE
    jsr DataMatrix_setUtah
DataMatrix_no_down
:2  iny
:2  dex
    bmi DataMatrix_fill_left
    cpy #DataMatrix_MATRIX_SIZE
    bcc DataMatrix_fill_down
DataMatrix_fill_left
    inx
:3  iny
    cpx #DataMatrix_MATRIX_SIZE
    bcc DataMatrix_fill_1
    cpy #DataMatrix_MATRIX_SIZE
    bcc DataMatrix_fill_1

    ift [DataMatrix_SIZE&2]==0
; Fixed pattern in the bottom-right corner.
    lda #1
    sta DataMatrix_symbol+[DataMatrix_SIZE-3]*DataMatrix_SIZE+DataMatrix_SIZE-3
    sta DataMatrix_symbol+[DataMatrix_SIZE-2]*DataMatrix_SIZE+DataMatrix_SIZE-2
    lsr @
    sta DataMatrix_symbol+[DataMatrix_SIZE-3]*DataMatrix_SIZE+DataMatrix_SIZE-2
    sta DataMatrix_symbol+[DataMatrix_SIZE-2]*DataMatrix_SIZE+DataMatrix_SIZE-3
    eif
    pla
    tax
    rts

DataMatrix_setUtah
    bcs DataMatrix_setUtah_no
    lda DataMatrix_matrixLo,y
    ift DataMatrix_SIZE>26
    cpx #DataMatrix_MATRIX_SIZE/2
    scc:adc #1
    eif
    sta DataMatrix_setUtah_load+1
    lda DataMatrix_matrixHi,y
    ift DataMatrix_SIZE>26
    adc #0
    eif
    sta DataMatrix_setUtah_load+2
DataMatrix_setUtah_load
    lda $ffff,x
    lsr @
    beq DataMatrix_setUtah_no
    lda #7
DataMatrix_setCorner
    stx DataMatrix_column
    sty DataMatrix_row
    tay
DataMatrix_setShape_1
    tya:pha
    lda #0
DataMatrix_column   equ *-1
    add DataMatrix_shapeX,y
    tax
    lda #0
DataMatrix_row  equ *-1
    add DataMatrix_shapeY,y
    tay
    bpl DataMatrix_setModuleWrapped_yOk
    add #DataMatrix_MATRIX_SIZE
    tay
    ift [DataMatrix_MATRIX_SIZE&7]!=0
    txa
    add #4-[[DataMatrix_MATRIX_SIZE+4]&7]
    tax
    eif
DataMatrix_setModuleWrapped_yOk
    txa
    bpl DataMatrix_setModuleWrapped_xOk
    add #DataMatrix_MATRIX_SIZE
    tax
    ift [DataMatrix_MATRIX_SIZE&7]!=0
    tya
    add #4-[[DataMatrix_MATRIX_SIZE+4]&7]
    tay
    eif
DataMatrix_setModuleWrapped_xOk
    ift DataMatrix_SIZE>26
    cpx #DataMatrix_MATRIX_SIZE/2
    bcc DataMatrix_setModuleWrapped_leftRegion
    inx:inx
DataMatrix_setModuleWrapped_leftRegion
    eif
    mva DataMatrix_matrixLo,y   DataMatrix_setModule_store+1
    mva DataMatrix_matrixHi,y   DataMatrix_setModule_store+2
    asl DataMatrix_dataCodewords
DataMatrix_fillSource   equ *-2
    lda #0
    rol @
DataMatrix_setModule_store
    sta $ffff,x
    pla:tay
    dey
    and #7
    bne DataMatrix_setShape_1
    inw DataMatrix_fillSource
    ldx DataMatrix_column
    ldy DataMatrix_row
DataMatrix_setUtah_no
    rts

    ift DataMatrix_SIZE==10
DataMatrix_DATA_CODEWORDS   equ 3
DataMatrix_ERROR_CODEWORDS  equ 5
DataMatrix_poly dta $eb,$cf,$d2,$f4,$0f

    eli DataMatrix_SIZE==12
DataMatrix_DATA_CODEWORDS   equ 5
DataMatrix_ERROR_CODEWORDS  equ 7
DataMatrix_poly dta $b1,$1e,$d6,$da,$2a,$c5,$1c

    eli DataMatrix_SIZE==14
DataMatrix_DATA_CODEWORDS   equ 8
DataMatrix_ERROR_CODEWORDS  equ 10
DataMatrix_poly dta $c7,$32,$96,$78,$ed,$83,$ac,$53,$f3,$37

    eli DataMatrix_SIZE==16
DataMatrix_DATA_CODEWORDS   equ 12
DataMatrix_ERROR_CODEWORDS  equ 12
DataMatrix_poly dta $a8,$8e,$23,$ad,$5e,$b9,$6b,$c7,$4a,$c2,$e9,$4e

    eli DataMatrix_SIZE==18
DataMatrix_DATA_CODEWORDS   equ 18
DataMatrix_ERROR_CODEWORDS  equ 14
DataMatrix_poly dta $53,$ab,$21,$27,$08,$0c,$f8,$1b,$26,$54,$5d,$f6,$ad,$69

    eli DataMatrix_SIZE==20
DataMatrix_DATA_CODEWORDS   equ 22
DataMatrix_ERROR_CODEWORDS  equ 18
DataMatrix_poly dta $a4,$09,$f4,$45,$b1,$a3,$a1,$e7,$5e,$fa,$c7,$dc,$fd,$a4,$67,$8e,$3d,$ab

    eli DataMatrix_SIZE==22
DataMatrix_DATA_CODEWORDS   equ 30
DataMatrix_ERROR_CODEWORDS  equ 20
DataMatrix_poly dta $7f,$21,$92,$17,$4f,$19,$c1,$7a,$d1,$e9,$e6,$a4,$01,$6d,$b8,$95,$26,$c9,$3d,$d2

    eli DataMatrix_SIZE==24
DataMatrix_DATA_CODEWORDS   equ 36
DataMatrix_ERROR_CODEWORDS  equ 24
DataMatrix_poly dta $41,$8d,$f5,$1f,$b7,$f2,$ec,$b1,$7f,$e1,$6a,$16,$83,$14,$ca,$16,$6a,$89,$67,$e7,$d7,$88,$55,$2d

    eli DataMatrix_SIZE==26
DataMatrix_DATA_CODEWORDS   equ 44
DataMatrix_ERROR_CODEWORDS  equ 28
DataMatrix_poly dta $96,$20,$6d,$95,$ef,$d5,$c6,$30,$5e,$32,$0c,$c3,$a7,$82,$c4,$fd,$63,$a6,$ef,$de,$92,$be,$f5,$b8,$ad,$7d,$11,$97

    eli DataMatrix_SIZE==32
DataMatrix_DATA_CODEWORDS   equ 62
DataMatrix_ERROR_CODEWORDS  equ 36
DataMatrix_poly dta $39,$56,$bb,$45,$8c,$99,$1f,$42,$87,$43,$f8,$54,$5a,$51,$db,$c5,$02,$01,$27,$10,$4b,$e5,$14,$33,$fc,$6c,$d5,$b5,$b7,$57,$6f,$4d,$e8,$a8,$b0,$9c

    eli DataMatrix_SIZE==36
DataMatrix_DATA_CODEWORDS   equ 86
DataMatrix_ERROR_CODEWORDS  equ 42
DataMatrix_poly dta $e1,$26,$e1,$94,$c0,$fe,$8d,$0b,$52,$ed,$51,$18,$0d,$7a,$ff,$6a,$a7,$0d,$cf,$a0,$58,$cb,$26,$8e,$54,$42,$03,$a8,$66,$9c,$01,$c8,$58,$3c,$e9,$86,$73,$72,$ea,$5a,$41,$8a

    eli DataMatrix_SIZE==40
DataMatrix_DATA_CODEWORDS   equ 114
DataMatrix_ERROR_CODEWORDS  equ 48
DataMatrix_poly dta $72,$45,$7a,$1e,$5e,$0b,$42,$e6,$84,$49,$91,$89,$87,$4f,$d6,$21,$0c,$dc,$8e,$d5,$88,$7c,$d7,$a6,$09,$de,$1c,$9a,$84,$04,$64,$aa,$91,$3b,$a4,$d7,$11,$f9,$66,$f9,$86,$80,$05,$f5,$83,$7f,$dd,$9c

    eli DataMatrix_SIZE==44
DataMatrix_DATA_CODEWORDS   equ 144
DataMatrix_ERROR_CODEWORDS  equ 56
DataMatrix_poly dta $1d,$b3,$63,$95,$9f,$48,$7d,$16,$37,$3c,$d9,$b0,$9c,$5a,$2b,$50,$fb,$eb,$80,$a9,$fe,$86,$f9,$2a,$79,$76,$48,$80,$81,$e8,$25,$0f,$18,$dd,$8f,$73,$83,$28,$71,$fe,$13,$7b,$f6,$44,$a6,$42,$76,$8e,$2f,$33,$c3,$f2,$f9,$83,$26,$42

    eli DataMatrix_SIZE==48
DataMatrix_DATA_CODEWORDS   equ 174
DataMatrix_ERROR_CODEWORDS  equ 68
DataMatrix_poly dta $21,$4f,$be,$f5,$5b,$dd,$e9,$19,$18,$06,$90,$97,$79,$ba,$8c,$7f,$2d,$99,$fa,$b7,$46,$83,$c6,$11,$59,$f5,$79,$33,$8c,$fc,$cb,$52,$53,$e9,$98,$dc,$9b,$12,$e6,$d2,$5e,$20,$c8,$c5,$c0,$c2,$ca,$81,$0a,$ed,$c6,$5e,$b0,$24,$28,$8b,$c9,$84,$db,$22,$38,$71,$34,$14,$22,$f7,$0f,$33

    els
    ert 1   ; unsupported DataMatrix_SIZE
    eif

DataMatrix_padding
:DataMatrix_DATA_CODEWORDS  dta [129+[1+#]*149%253]%254+1
; NOTE: the following two zero bytes terminate DataMatrix_padding:
DataMatrix_shapeY   dta 0,0,0,-1,-1,-1,-2,-2
    ift DataMatrix_SIZE==14||DataMatrix_SIZE==22||DataMatrix_SIZE==32||DataMatrix_SIZE==40||DataMatrix_SIZE==48 ; corner1
    dta 3-DataMatrix_MATRIX_SIZE,2-DataMatrix_MATRIX_SIZE,1-DataMatrix_MATRIX_SIZE,-DataMatrix_MATRIX_SIZE,-DataMatrix_MATRIX_SIZE,-1,-1,-1
    eli DataMatrix_SIZE==16||DataMatrix_SIZE==24 ; corner2
    dta 3-DataMatrix_MATRIX_SIZE,2-DataMatrix_MATRIX_SIZE,2-DataMatrix_MATRIX_SIZE,2-DataMatrix_MATRIX_SIZE,2-DataMatrix_MATRIX_SIZE,1,0,-1
    eif
DataMatrix_shapeX   dta 0,-1,-2,0,-1,-2,-1,-2
    ift DataMatrix_SIZE==14||DataMatrix_SIZE==22||DataMatrix_SIZE==32||DataMatrix_SIZE==40||DataMatrix_SIZE==48 ; corner1
    dta DataMatrix_MATRIX_SIZE-1,DataMatrix_MATRIX_SIZE-1,DataMatrix_MATRIX_SIZE-1,DataMatrix_MATRIX_SIZE-1,DataMatrix_MATRIX_SIZE-2,2,1,0
    eli DataMatrix_SIZE==16||DataMatrix_SIZE==24 ; corner2
    dta DataMatrix_MATRIX_SIZE-1,DataMatrix_MATRIX_SIZE-1,DataMatrix_MATRIX_SIZE-2,DataMatrix_MATRIX_SIZE-3,DataMatrix_MATRIX_SIZE-4,0,0,0
    eif

    ift DataMatrix_SIZE<=26
DataMatrix_matrixLo
:DataMatrix_MATRIX_SIZE dta l(DataMatrix_symbol+[1+#]*DataMatrix_SIZE+1)
DataMatrix_matrixHi
:DataMatrix_MATRIX_SIZE dta h(DataMatrix_symbol+[1+#]*DataMatrix_SIZE+1)
    els
DataMatrix_matrixLo
:DataMatrix_MATRIX_SIZE/2   dta l(DataMatrix_symbol+[1+#]*DataMatrix_SIZE+1)
:DataMatrix_MATRIX_SIZE/2   dta l(DataMatrix_symbol+[1+DataMatrix_SIZE/2+#]*DataMatrix_SIZE+1)
DataMatrix_matrixHi
:DataMatrix_MATRIX_SIZE/2   dta h(DataMatrix_symbol+[1+#]*DataMatrix_SIZE+1)
:DataMatrix_MATRIX_SIZE/2   dta h(DataMatrix_symbol+[1+DataMatrix_SIZE/2+#]*DataMatrix_SIZE+1)
    eif
};
end;

procedure SetMessage(msg:string;dmData:word);
var len: byte;
begin
    len := byte(msg[0]);
    Move(@msg[1],Pointer(dmData),len);
    Poke(dmData+len,DataMatrix_EOF);
end;

end.
