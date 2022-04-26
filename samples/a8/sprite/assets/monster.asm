.extrn	shanti.sprites, shanti.multi.ret01, shanti.multi.ret23, shanti.shape_tab01, shanti.shape_tab23	.word
.public	monster

.reloc

.proc	monster(.byte a) .reg

	asl @
	tay

  .rept 16,#
	.ifdef shp%%1
	mwa #shp%%1._01 shanti.shape_tab01,y
	mwa #shp%%1._23 shanti.shape_tab23,y
	iny
	iny
	.endif
  .endr

	rts
.endp


.local	shp0

_01
	lda #0
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$500+13,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$400+15,x
	sta shanti.sprites+$500+15,x
	lda #24
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$400+13,x
	lda #28
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$500+12,x
	lda #36
	sta shanti.sprites+$500+11,x
	lda #62
	sta shanti.sprites+$400+4,x
	lda #66
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$500+10,x
	lda #126
	sta shanti.sprites+$400+11,x
	lda #153
	sta shanti.sprites+$400+7,x
	lda #195
	sta shanti.sprites+$400+8,x
	lda #218
	sta shanti.sprites+$400+6,x
	lda #219
	sta shanti.sprites+$400+9,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$700+13,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$600+15,x
	sta shanti.sprites+$700+15,x
	lda #24
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$600+13,x
	lda #28
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$700+12,x
	lda #36
	sta shanti.sprites+$700+11,x
	lda #62
	sta shanti.sprites+$600+4,x
	lda #66
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$700+10,x
	lda #126
	sta shanti.sprites+$600+11,x
	lda #153
	sta shanti.sprites+$600+7,x
	lda #195
	sta shanti.sprites+$600+8,x
	lda #218
	sta shanti.sprites+$600+6,x
	lda #219
	sta shanti.sprites+$600+9,x

	jmp shanti.multi.ret23
.endl

.local	shp1

_01
	lda #0
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$400+11,x
	sta shanti.sprites+$500+11,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$400+13,x
	sta shanti.sprites+$500+13,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$400+15,x
	sta shanti.sprites+$500+15,x
	lda #2
	sta shanti.sprites+$400+8,x
	lda #24
	sta shanti.sprites+$400+7,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$400+10,x
	lda #36
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+9,x
	sta shanti.sprites+$500+10,x
	lda #90
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$500+9,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$600+11,x
	sta shanti.sprites+$700+11,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$600+13,x
	sta shanti.sprites+$700+13,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$600+15,x
	sta shanti.sprites+$700+15,x
	lda #2
	sta shanti.sprites+$600+8,x
	lda #24
	sta shanti.sprites+$600+7,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$600+10,x
	lda #36
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+9,x
	sta shanti.sprites+$700+10,x
	lda #90
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$700+9,x

	jmp shanti.multi.ret23
.endl

.local	shp2

_01
	lda #0
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$400+11,x
	sta shanti.sprites+$500+11,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$400+13,x
	sta shanti.sprites+$500+13,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$400+15,x
	sta shanti.sprites+$500+15,x
	lda #24
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$400+9,x
	lda #36
	sta shanti.sprites+$400+8,x
	lda #60
	sta shanti.sprites+$400+7,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$600+11,x
	sta shanti.sprites+$700+11,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$600+13,x
	sta shanti.sprites+$700+13,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$600+15,x
	sta shanti.sprites+$700+15,x
	lda #24
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$600+9,x
	lda #36
	sta shanti.sprites+$600+8,x
	lda #60
	sta shanti.sprites+$600+7,x

	jmp shanti.multi.ret23
.endl

.local	shp3

_01
	lda #0
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$400+4,x
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$400+11,x
	sta shanti.sprites+$500+11,x
	sta shanti.sprites+$400+12,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$400+13,x
	sta shanti.sprites+$500+13,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$400+15,x
	sta shanti.sprites+$500+15,x
	lda #24
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	lda #26
	sta shanti.sprites+$400+7,x
	lda #36
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+10,x
	lda #90
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$400+9,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$600+4,x
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$600+11,x
	sta shanti.sprites+$700+11,x
	sta shanti.sprites+$600+12,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$600+13,x
	sta shanti.sprites+$700+13,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$600+15,x
	sta shanti.sprites+$700+15,x
	lda #24
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	lda #26
	sta shanti.sprites+$600+7,x
	lda #36
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+10,x
	lda #90
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$600+9,x

	jmp shanti.multi.ret23
.endl

.local	shp4

_01
	lda #0
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$400+15,x
	sta shanti.sprites+$500+15,x
	lda #24
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$400+13,x
	lda #28
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$400+12,x
	lda #36
	sta shanti.sprites+$500+4,x
	lda #62
	sta shanti.sprites+$400+11,x
	lda #66
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$400+10,x
	lda #126
	sta shanti.sprites+$400+4,x
	lda #129
	sta shanti.sprites+$400+8,x
	lda #218
	sta shanti.sprites+$400+9,x
	lda #219
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$600+15,x
	sta shanti.sprites+$700+15,x
	lda #24
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$600+13,x
	lda #28
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$600+12,x
	lda #36
	sta shanti.sprites+$700+4,x
	lda #62
	sta shanti.sprites+$600+11,x
	lda #66
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$600+10,x
	lda #126
	sta shanti.sprites+$600+4,x
	lda #129
	sta shanti.sprites+$600+8,x
	lda #218
	sta shanti.sprites+$600+9,x
	lda #219
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x

	jmp shanti.multi.ret23
.endl

.local	shp5

_01
	lda #0
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	sta shanti.sprites+$500+11,x
	sta shanti.sprites+$500+12,x
	sta shanti.sprites+$500+13,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$500+14,x
	sta shanti.sprites+$400+15,x
	sta shanti.sprites+$500+15,x
	lda #24
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	sta shanti.sprites+$400+13,x
	lda #28
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$400+12,x
	lda #36
	sta shanti.sprites+$500+4,x
	lda #62
	sta shanti.sprites+$400+11,x
	lda #66
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$400+10,x
	lda #126
	sta shanti.sprites+$400+4,x
	lda #129
	sta shanti.sprites+$400+8,x
	lda #218
	sta shanti.sprites+$400+9,x
	lda #219
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$400+7,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	sta shanti.sprites+$700+11,x
	sta shanti.sprites+$700+12,x
	sta shanti.sprites+$700+13,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$700+14,x
	sta shanti.sprites+$600+15,x
	sta shanti.sprites+$700+15,x
	lda #24
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	sta shanti.sprites+$600+13,x
	lda #28
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$600+12,x
	lda #36
	sta shanti.sprites+$700+4,x
	lda #62
	sta shanti.sprites+$600+11,x
	lda #66
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$600+10,x
	lda #126
	sta shanti.sprites+$600+4,x
	lda #129
	sta shanti.sprites+$600+8,x
	lda #218
	sta shanti.sprites+$600+9,x
	lda #219
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$600+7,x

	jmp shanti.multi.ret23
.endl

.local	shp6

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$500+15,x
	lda #24
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #25
	sta shanti.sprites+$400+9,x
	lda #36
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+13,x
	lda #60
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$500+14,x
	lda #66
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+11,x
	lda #98
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+12,x
	lda #102
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$500+12,x
	lda #103
	sta shanti.sprites+$400+11,x
	lda #126
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+13,x
	lda #153
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	lda #195
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	lda #219
	sta shanti.sprites+$400+7,x
	lda #231
	sta shanti.sprites+$400+4,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$700+15,x
	lda #24
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #25
	sta shanti.sprites+$600+9,x
	lda #36
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+13,x
	lda #60
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$700+14,x
	lda #66
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+11,x
	lda #98
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+12,x
	lda #102
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$700+12,x
	lda #103
	sta shanti.sprites+$600+11,x
	lda #126
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+13,x
	lda #153
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	lda #195
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	lda #219
	sta shanti.sprites+$600+7,x
	lda #231
	sta shanti.sprites+$600+4,x

	jmp shanti.multi.ret23
.endl

.local	shp7

_01
	lda #0
	sta shanti.sprites+$500+0,x
	sta shanti.sprites+$400+5,x
	sta shanti.sprites+$400+10,x
	sta shanti.sprites+$500+15,x
	lda #24
	sta shanti.sprites+$400+0,x
	sta shanti.sprites+$400+1,x
	sta shanti.sprites+$400+14,x
	sta shanti.sprites+$400+15,x
	lda #25
	sta shanti.sprites+$400+9,x
	lda #36
	sta shanti.sprites+$400+2,x
	sta shanti.sprites+$400+13,x
	lda #60
	sta shanti.sprites+$500+1,x
	sta shanti.sprites+$500+14,x
	lda #66
	sta shanti.sprites+$500+4,x
	sta shanti.sprites+$500+11,x
	lda #98
	sta shanti.sprites+$400+3,x
	sta shanti.sprites+$400+12,x
	lda #102
	sta shanti.sprites+$500+3,x
	sta shanti.sprites+$500+12,x
	lda #103
	sta shanti.sprites+$400+11,x
	lda #126
	sta shanti.sprites+$500+2,x
	sta shanti.sprites+$500+13,x
	lda #153
	sta shanti.sprites+$400+6,x
	sta shanti.sprites+$500+7,x
	sta shanti.sprites+$500+8,x
	lda #195
	sta shanti.sprites+$500+5,x
	sta shanti.sprites+$500+6,x
	sta shanti.sprites+$400+8,x
	sta shanti.sprites+$500+9,x
	sta shanti.sprites+$500+10,x
	lda #219
	sta shanti.sprites+$400+7,x
	lda #231
	sta shanti.sprites+$400+4,x

	jmp shanti.multi.ret01

_23
	lda #0
	sta shanti.sprites+$700+0,x
	sta shanti.sprites+$600+5,x
	sta shanti.sprites+$600+10,x
	sta shanti.sprites+$700+15,x
	lda #24
	sta shanti.sprites+$600+0,x
	sta shanti.sprites+$600+1,x
	sta shanti.sprites+$600+14,x
	sta shanti.sprites+$600+15,x
	lda #25
	sta shanti.sprites+$600+9,x
	lda #36
	sta shanti.sprites+$600+2,x
	sta shanti.sprites+$600+13,x
	lda #60
	sta shanti.sprites+$700+1,x
	sta shanti.sprites+$700+14,x
	lda #66
	sta shanti.sprites+$700+4,x
	sta shanti.sprites+$700+11,x
	lda #98
	sta shanti.sprites+$600+3,x
	sta shanti.sprites+$600+12,x
	lda #102
	sta shanti.sprites+$700+3,x
	sta shanti.sprites+$700+12,x
	lda #103
	sta shanti.sprites+$600+11,x
	lda #126
	sta shanti.sprites+$700+2,x
	sta shanti.sprites+$700+13,x
	lda #153
	sta shanti.sprites+$600+6,x
	sta shanti.sprites+$700+7,x
	sta shanti.sprites+$700+8,x
	lda #195
	sta shanti.sprites+$700+5,x
	sta shanti.sprites+$700+6,x
	sta shanti.sprites+$600+8,x
	sta shanti.sprites+$700+9,x
	sta shanti.sprites+$700+10,x
	lda #219
	sta shanti.sprites+$600+7,x
	lda #231
	sta shanti.sprites+$600+4,x

	jmp shanti.multi.ret23
.endl
