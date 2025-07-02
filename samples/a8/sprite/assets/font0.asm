
.extrn	shanti.sprites, shanti.multi.ret01, shanti.multi.ret23	.word

.public	shp0._01, shp0._23
.public	shp1._01, shp1._23
.public	shp2._01, shp2._23
.public	shp3._01, shp3._23
.public	shp4._01, shp4._23
.public	shp5._01, shp5._23
.public	shp6._01, shp6._23
.public	shp7._01, shp7._23


	.reloc


.local	shp0

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #2
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	lda #34
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	lda #48
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	lda #50
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	lda #102
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #120
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	lda #128
	sta shanti.sprites+$500+1,x
	lda #204
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x
	lda #252
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #2
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	lda #34
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	lda #48
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	lda #50
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	lda #102
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #120
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	lda #128
	sta shanti.sprites+$700+1,x
	lda #204
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x
	lda #252
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x

	jmp shanti.multi.ret23
.endl

.local	shp1

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #6
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	lda #34
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	lda #48
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	lda #124
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #204
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x
	lda #248
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #6
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	lda #34
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	lda #48
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	lda #124
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #204
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x
	lda #248
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x

	jmp shanti.multi.ret23
.endl

.local	shp2

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #6
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	lda #32
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	lda #38
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	lda #48
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	lda #60
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #120
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x
	lda #192
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x
	lda #204
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #6
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	lda #32
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	lda #38
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	lda #48
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	lda #60
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #120
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x
	lda #192
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x
	lda #204
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x

	jmp shanti.multi.ret23
.endl

.local	shp3

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #6
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	lda #34
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	lda #48
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	lda #124
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #204
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x
	lda #248
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #6
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	lda #34
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	lda #48
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	lda #124
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #204
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x
	lda #248
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x

	jmp shanti.multi.ret23
.endl

.local	shp4

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #32
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	lda #60
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	lda #62
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	lda #126
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #192
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x
	lda #248
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x
	lda #252
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #32
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	lda #60
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	lda #62
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	lda #126
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #192
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x
	lda #248
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x
	lda #252
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x

	jmp shanti.multi.ret23
.endl

.local	shp5

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #32
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	lda #60
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	lda #62
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	lda #96
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #192
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x
	lda #248
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x
	lda #252
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #32
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	lda #60
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	lda #62
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	lda #96
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #192
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x
	lda #248
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x
	lda #252
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x

	jmp shanti.multi.ret23
.endl

.local	shp6

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #2
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	lda #32
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	lda #34
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	lda #38
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	lda #48
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	lda #62
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #120
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	lda #124
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x
	lda #192
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	lda #204
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x
	lda #220
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #2
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	lda #32
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	lda #34
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	lda #38
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	lda #48
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	lda #62
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #120
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	lda #124
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x
	lda #192
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	lda #204
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x
	lda #220
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x

	jmp shanti.multi.ret23
.endl

.local	shp7

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #2
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+7,x
	lda #34
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	lda #50
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$500+9,x
	lda #102
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$500+15,x
	lda #204
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$400+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$400+11,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x
	lda #252
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #2
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+7,x
	lda #34
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	lda #50
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$700+9,x
	lda #102
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$700+15,x
	lda #204
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$600+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$600+11,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x
	lda #252
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x

	jmp shanti.multi.ret23
.endl
