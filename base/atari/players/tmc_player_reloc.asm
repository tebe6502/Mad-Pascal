/**********************
      TMC  Player
    Jaskier/Taquart
**********************/


byte	equ $fa     ;(1)
bajt	equ byte+1  ;(1)
addr	equ bajt+1  ;(2)
adrsng	equ addr+2  ;(1)

	.reloc

	jmp play	; CLC -> PLAY , SEC -> SOUND
	jmp init

maxvol dta 15
volume dta d'        '
freqen dta d'        '
kanal  dta d'        '
aktwys dta d'        '
numdzw dta d'        '
audctl dta d'        '
aud1   dta 0
aud2   dta 0

voltab
 dta d'                '
 dta d'        !!!!!!!!'
 dta d'    !!!!!!!!""""'
 dta d'   !!!!!"""""###'
 dta d'  !!!!""""####$$'
 dta d'  !!!"""###$$$%%'
 dta d'  !!"""##$$$%%&&'
 dta d'  !!""##$$%%&&'''''
 dta d' !!""##$$%%&&''''('
 dta d' !!""#$$%%&''''(()'
 dta d' !!"##$%%&''''())*'
 dta d' !!"#$$%&''''()**+'
 dta d' !""#$%&&''()**+,'
 dta d' !"##$%&''()**+,-'
 dta d' !"#$%&''''()*+,-.'
 dta d' !"#$%&''()*+,-./'

frqtab
 dta 0,$f1,$e4,$d7,$cb,$c0,$b5,$aa
 dta $a1,$98,$8f,$87,$7f,$78,$72,$6b
 dta $65,$5f,$5a,$55,$50,$4b,$47,$43
 dta $3f,$3c,$38,$35,$32,$2f,$2c,$2a
 dta $27,$25,$23,$21,$1f,$1d,$1c,$1a
 dta $18,$17,$16,$14,$13,$12,$11,$10
 dta 15,14,13,12,11,10,9,8
 dta 7,6,5,4,3,2,1,0

 dta 0,$f2,$e6,$da,$ce,$bf,$b6,$aa
 dta $a1,$98,$8f,$89,$80,$7a,$71,$6b
 dta $65,$5f,$5c,$56,$50,$4d,$47,$44
 dta $3e,$3c,$38,$35,$32,$2f,$2d,$2a
 dta $28,$25,$23,$21,$1f,$1d,$1c,$1a
 dta $18,$17,$16,$14,$13,$12,$11,$10
 dta 15,14,13,12,11,10,9,8
 dta 7,6,5,4,3,2,1,0

 dta 0,$ff,$f1,$e4,$d8,$ca,$c0,$b5
 dta $ab,$a2,$99,$8e,$87,$7f,$79,$73
 dta $70,$66,$61,$5a,$55,$52,$4b,$48
 dta $43,$3f,$3c,$39,$37,$33,$30,$2d
 dta $2a,$28,$25,$24,$21,$1f,$1e,$1c
 dta $1b,$19,$17,$16,$15,$13,$12,$11
 dta $10,15,14,13,12,11,10,9
 dta 8,7,6,5,4,3,2,1

 dta 0,$f3,$e6,$d9,$cc,$c1,$b5,$ad
 dta $a2,$99,$90,$88,$80,$79,$72,$6c
 dta $66,$60,$5b,$55,$51,$4c,$48,$44
 dta $40,$3c,$39,$35,$32,$2f,$2d,$2a
 dta $28,$25,$23,$21,$1f,$1d,$1c,$1a
 dta $18,$17,$16,$14,$13,$12,$11,$10
 dta 15,14,13,12,11,10,9,8
 dta 7,6,5,4,3,2,1,0

basslo
 dta 0,$f2,$33,$96,$e2,$38,$8c,$00
 dta $6a,$e8,$6a,$ef,$80,$08,$ae,$46
 dta $e6,$95,$41,$f6,$b0,$6e,$30,$f6
 dta $bb,$84,$52,$22,$f4,$c8,$a0,$7a
 dta $55,$34,$14,$f5,$d8,$bd,$a4,$8d
 dta $77,$60,$4e,$38,$27,$15,$06,$f7
 dta $e8,$db,$cf,$c3,$b8,$ac,$a2,$9a
 dta $90,$88,$7f,$78,$70,$6a,$64,$5e

basshi
 dta 0,13,13,12,11,11,10,10
 dta 9,8,8,7,7,7,6,6
 dta 5,5,5,4,4,4,4,3
 dta 3,3,3,3,2,2,2,2
 dta 2,2,2,1,1,1,1,1
 dta 1,1,1,1,1,1,1,0
 dta 0,0,0,0,0,0,0,0
 dta 0,0,0,0,0,0,0,0

czygrx dta d'        '
pozwpt dta d'        '
delay  dta d'        '
numptr dta d'        '
poddzw dta d'        '
wysdzw dta d'        '
znksz  dta d'        '
frq    dta d'        '
vol1ch dta d'        '
vol2ch dta d'        '
adcvl1 dta d'        '
adcvl2 dta d'        '
adrsnl dta d'        '
adrsnh dta d'        '
slupy  dta d'        '
opad1  dta d'        '
opad2  dta d'        '
lopad1 dta d'        '
lopad2 dta d'        '
typ    dta d'        '
param  dta d'        '
pomoc1 dta d'        '
pomoc2 dta d'        '
czekaj dta d'        '
dtyp   dta d'        '
ltyp   dta d'        '
ilperm dta d'        '
aperm  dta d'        '
dperm  dta d'        '
lperm  dta d'        '
kolejn dta d'        '
tempo  dta 0
ltempo dta 0
pozptr dta 0
czygrc dta 0

przeci
 dta 4,5,6,7,0,1,2,3

audtb1
 dta 4,2,0,0,4,2,0,0

audtb2
 dta 0,16,0,8,0,16,0,8

play
 jcs sound

 lda czygrc
 beq r1-3
 lda pozptr
 cmp #64
 bcc r1
 dec ltempo
 beq *+5
 jmp sound

 ldx #7
 lda #0
p1 sta pozwpt,x
 sta delay,x
 dex
 bpl p1
 sta pozptr
 tax
 ldy #15
p2 lda (adrsng),y
 bpl p3
 dey
 lda (adrsng),y
 bpl *+5
 jmp stop
 stx addr
 asl @
 asl @
 rol addr
 asl @
 rol addr
 asl @
 rol addr
zm0 adc #0
 sta adrsng
 lda addr
zm1 adc #0
 sta adrsng+1
 bcc p2-2
p3 sta numptr,x
 dey
 lda (adrsng),y
 sta poddzw,x
 inx
 dey
 bpl p2
 clc
 lda adrsng
 adc #16
 sta adrsng
 bcc *+4
 inc adrsng+1
 jmp sound

r1 dec ltempo
 bpl r1-3
 inc pozptr
 lda tempo
 sta ltempo
 ldx #7
r2 dec delay,x
 bmi *+5
 jmp r14
 ldy numptr,x
zm2 lda $ffff,y
 sta addr
zm3 lda $ffff,y
 sta addr+1
 ldy pozwpt,x
r3 lda (addr),y
 bne r4
 jsr nparam
 jmp r13
r4 cmp #$40
 bcs r5
 adc poddzw,x
 sta wysdzw,x
 jsr nparam
 ldy numdzw,x
 jsr dzwiek
 jmp r13
r5 bne r8
 iny
 inc pozwpt,x
 lda (addr),y
 bpl r6
 sta bajt
 jsr nparam
 lda bajt
r6 and #$7f
 bne r7
 lda #64
 sta pozptr
 bne r13
r7 sta tempo
 sta ltempo
 bne r13
r8 cmp #$80
 bcs r11
 and #$3f
 adc poddzw,x
 sta wysdzw,x
 iny
 inc pozwpt,x
 lda (addr),y
 and #127
 bne r9
 lda #64
 sta pozptr
 bne r10
r9 sta tempo
 sta ltempo
r10 jsr nparam
 ldy numdzw,x
 jsr dzwiek
 jmp r13
r11 cmp #$c0
 bcs r12
 and #$3f
 sta numdzw,x
 iny
 inc pozwpt,x
 jmp r3
r12 and #$3f
 sta delay,x
r13 inc pozwpt,x
r14 dex
 bmi sound
 jmp r2

sound ldx #7
p5 lda czygrx,x
 beq p6
 jsr graj
 lda audctl,x
 and audtb1,x
 beq p6
 ldy #71
 lda (addr),y
 clc
 adc aktwys,x
 sta aktwys+2,x
 tay
 lda frqtab,y
 sec
 adc pomoc1,x
 sta frq+2,x
p6 dex
 bpl p5

 asl maxvol
 asl maxvol
 asl maxvol
 asl maxvol
 inx
 stx addr
 stx addr+1
 ldx #7
p9 txa
 tay
 lda vol1ch,y
 bne p10
 ldy przeci,x
 lda vol2ch,y
 bne p10
 txa
 tay
 lda #0
p10 sta byte
 tya
 sta kanal,x
 lda frq,y
 sta freqen,x
 lda audctl,y
 sta bajt
 ora addr+1
 sta addr+1
 lda bajt
 and audtb1,x
 beq p11
 lda frq+2,y
 sta freqen+2,x
p11 lda bajt
 and audtb2,x
 beq p12
 lda aktwys,y
 and #$3f
 tay
 iny
 sty addr
 lda basshi-1,y
 sta freqen,x
 jmp p13
p12 ldy addr
 beq p13
 lda basslo-1,y
 sta freqen,x
 lda #0
 sta addr
p13 lda byte
 ora maxvol
 tay
 lda voltab,y
 ldy kanal,x
 ora znksz,y
 sta volume,x
 cpx #4
 bne p14
 lda addr+1
 sta aud2
 lda #0
 sta addr+1
p14 dex
 bpl p9
 lsr maxvol
 lsr maxvol
 lsr maxvol
 lsr maxvol
 lda addr+1
quit ldx #3
 stx $d21f
 stx $d20f
 ldx freqen+4
 ldy freqen
 stx $d210
 sty $d200
 ldx volume+4
 ldy volume
 stx $d211
 sty $d201
 ldx freqen+5
 ldy freqen+1
 stx $d212
 sty $d202
 ldx volume+5
 ldy volume+1
 stx $d213
 sty $d203
 ldx freqen+6
 ldy freqen+2
 stx $d214
 sty $d204
 ldx volume+6
 ldy volume+2
 stx $d215
 sty $d205
 ldx freqen+7
 ldy freqen+3
 stx $d216
 sty $d206
 ldx volume+7
 ldy volume+3
 stx $d217
 sty $d207
 sta aud1
 ldx aud2
 stx $d218
 sta $d208
 rts

graj lda adrsnl,x
 sta addr
 lda adrsnh,x
 sta addr+1
 ldy slupy,x
 cpy #63
 beq n6
 inc slupy,x
 inc slupy,x
 inc slupy,x
 lda (addr),y
 and #$f0
 sta znksz,x
 lda (addr),y
 and #15
 sec
 sbc adcvl1,x
 bpl n1
 lda #0
n1 sta vol1ch,x
 iny
 lda (addr),y
 and #15
 sec
 sbc adcvl2,x
 bpl n2
 lda #0
n2 sta vol2ch,x
 lda (addr),y
 and #$f0
 beq n8
 bpl n3
 ldy #73
 lda (addr),y
 ldy slupy,x
 dey
 dey
 bpl n4
n3 lda #0
n4 sta audctl,x
 lda (addr),y
 and #$70
 beq n9
 lsr @
 lsr @
 sta n5+1
 lda #0
 sta pomoc1,x
 iny
 lda (addr),y
n5 bcc *
 nop
 nop
 nop
 nop
 jmp a1
 nop
 jmp a2
 nop
 jmp a3
 nop
 jmp a4
 nop
 jmp a5
 nop
 jmp a6
 nop
 jmp a7
n6 lda opad1,x
 beq n7
 dec lopad1,x
 bne n7
 sta lopad1,x
 lda vol1ch,x
 and #15
 beq n7
 dec vol1ch,x
n7 lda opad2,x
 beq n8
 dec lopad2,x
 bne n8
 sta lopad2,x
 lda vol2ch,x
 and #15
 beq n8
 dec vol2ch,x
n8 ldy #72
 lda (addr),y
 sta audctl,x
n9 lda aperm,x
 clc
 adc #63
 tay
 lda (addr),y
 adc wysdzw,x
 sta aktwys,x
 tay
 lda frqtab,y
 sta frq,x
 dec lperm,x
 bpl m1
 lda dperm,x
 sta lperm,x
 lda kolejn,x
 beq m6
 clc
 adc aperm,x
 sta aperm,x
 beq m7
 cmp ilperm,x
 bne m1
 lda #$fe
m7 clc
 adc #1
 sta kolejn,x
 bne m1
m6 inc aperm,x
 lda ilperm,x
 cmp aperm,x
 bcs m1
 lda #0
 sta aperm,x
m1 lda czekaj,x
 beq m2
 dec czekaj,x
 rts
m2 lda pomoc2,x
 sta byte
 lda param,x
 sta bajt
 jsr m4
 dec ltyp,x
 bpl m4-1
 lda byte
 sta pomoc2,x
 lda bajt
 sta param,x
 lda dtyp,x
 sta ltyp,x
 rts
m4 lda typ,x
 sta m5+1
m5 bpl *
 jmp typ0
 nop
 jmp typ1
 nop
 jmp typ2
 nop
 jmp typ3
 nop
 jmp typ4
 nop
 jmp typ5
 nop
 jmp typ6
 nop
 jmp typ7

typ1 lda byte
 inc byte
 and #3
 lsr @
 bcc t2
 bne typ6
 lda bajt
t1 sta pomoc1,x
 clc
 adc frq,x
 sta frq,x
typ0 rts
t2 lda #0
 sta pomoc1,x
 rts
typ2 jsr t5
 jmp t1
typ3 jsr t5
 clc
 adc aktwys,x
 jmp a5
typ4 lda byte
 sta pomoc1,x
 clc
 adc frq,x
t3 sta frq,x
 lda byte
 clc
 adc bajt
 sta byte
 rts
typ5 lda aktwys,x
 sec
 sbc byte
 sta aktwys,x
 tay
 lda frqtab,y
 jmp t3
typ6 lda frq,x
 sec
 sbc bajt
 sta frq,x
 sec
 lda #0
 sbc bajt
 sta pomoc1,x
 rts
typ7 lda ltyp,x
 bne typ0
 lda bajt
 bpl t4
 lda vol2ch,x
 beq typ0
 lda vol1ch,x
 cmp #15
 beq typ0
 inc vol1ch,x
 rts
t4 lda vol1ch,x
 beq typ0
 lda vol2ch,x
 cmp #15
 beq typ0
 inc vol2ch,x
 rts
t5 ldy byte
 lda bajt
 bmi t6
 iny
 iny
t6 dey
 tya
 sta byte
 cmp bajt
 bne t7
 lda bajt
 eor #$ff
 sta bajt
t7 tya
 rts

a2 adc frq,x
a1 sta frq,x
 rts
a3 ldy wysdzw,x
 adc frqtab,y
 sta frq,x
 tya
 sta aktwys,x
 rts
a4 and $d20a
 sta frq,x
 rts
a7 adc wysdzw,x
a5 sta aktwys,x
 tay
 lda frqtab,y
 sta frq,x
 rts
a6 sta aktwys,x
 tay
 lda frq,x
 adc frqtab,y
 sta frq,x
 rts

nparam iny
 inc pozwpt,x
 lda (addr),y
 lsr @
 lsr @
 lsr @
 lsr @
 sta adcvl1,x
 lda (addr),y
 and #15
 sta adcvl2,x
 rts

songx jsr stop
 ldy #15
zm4 lda #0
 sta adrsng
zm5 lda #0
 sta adrsng+1
d5 txa
 beq inic
d3 lda (adrsng),y
 bpl d4
 dex
d4 clc
 lda adrsng
 adc #16
 sta adrsng
 bcc d5
 inc adrsng+1
 bcs d5

playx jsr stop
 lda #0
 sta addr
 txa
 asl @
 asl @
 rol addr
 asl @
 rol addr
 asl @
 rol addr
zm6 adc #0
 sta adrsng
 lda addr
zm7 adc #0
 sta adrsng+1
inic lda #64
 sta pozptr
 lda #1
 sta ltempo
 sta czygrc
 rts

init cmp #$10
 bcc songx
 cmp #$20
 bcc playx
 cmp #$30
 bcs *+5
 jmp d2
 cmp #$40
 bcs i1
 txa
 and #15
 beq i1-1
 sta tempo
 rts
i1 cmp #$50
 bcc stop
 cmp #$60
 bcs i2
 lda #0
i3 sta czygrc
 rts
i2 cmp #$70
 bcc i3

 lda #1
 sta ltempo
 lda #64
 sta pozptr
 sty addr
 stx addr+1
 ldy #30
 lda (addr),y
 sta tempo
 lda addr
 clc
 adc #32
 sta zm8+1
 bcc *+3
 inx
 stx zm8+2
 clc
 adc #$40
 sta zm9+1
 bcc *+3
 inx
 stx zm9+2
 clc
 adc #$40
 sta zm2+1
 bcc *+3
 inx
 stx zm2+2
 clc
 adc #$80
 sta zm3+1
 bcc *+3
 inx
 stx zm3+2
 clc
 adc #$80
 sta adrsng
 sta zm0+1
 sta zm4+1
 sta zm6+1
 bcc *+3
 inx
 stx adrsng+1
 stx zm1+1
 stx zm5+1
 stx zm7+1

stop ldy #7
 lda #0
 sta czygrc
d9 sta $d200,y
 sta $d210,y
 sta volume,y
 sta vol1ch,y
 sta vol2ch,y
 sta audctl,y
 sta czygrx,y
 dey
 bpl d9
 sta $d208
 sta $d218
 sta aud1
 sta aud2
 rts

d1 sta vol1ch,x
 sta vol2ch,x
 sta audctl,x
 lda wysdzw,x
 sta aktwys,x
 rts
d0 tya
 eor #$f0
 lsr @
 lsr @
 lsr @
 lsr @
 sta adcvl1,x
 tya
 and #15
 eor #15
 sta adcvl2,x
 rts
d2 and #7
 sta addr
 txa
 ldx addr
 and #$3f
 beq d0
 sta wysdzw,x
dzwiek lda #0
 sta czygrx,x
zm8 lda $ffff,y
 sta adrsnl,x
 sta addr
zm9 lda $ffff,y
 sta adrsnh,x
 sta addr+1
 ora addr
 beq d1
 ldy #74
 lda (addr),y
 sta opad1,x
 sta lopad1,x
 iny
 lda (addr),y
 sta opad2,x
 sta lopad2,x
 iny
 lda (addr),y
 and #$70
 lsr @
 lsr @
 sta typ,x
 lda (addr),y
 and #15
 sta param,x
 lda (addr),y
 bpl d7
 lda param,x
 eor #$ff
 clc
 adc #1
 sta param,x
d7 iny
 lda (addr),y
 sta czekaj,x
 iny
 lda (addr),y
 and #$3f
 sta dtyp,x
 sta ltyp,x
 iny
 lda (addr),y
 and #$80
 beq d8
 lda #1
d8 sta kolejn,x
 lda (addr),y
 and #$70
 lsr @
 lsr @
 lsr @
 lsr @
 sta ilperm,x
 bne d6
 sta kolejn,x
d6 lda (addr),y
 and #15
 sta dperm,x
 sta lperm,x
 dey
 lda (addr),y
 and #$c0
 clc
 adc wysdzw,x
 sta wysdzw,x
 sta aktwys,x
 tay
 lda frqtab,y
 sta frq,x
 lda #0
 sta slupy,x
 sta pomoc1,x
 sta pomoc2,x
 sta aperm,x
 lda #1
 sta czygrx,x
 rts
