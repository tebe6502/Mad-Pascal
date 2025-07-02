asm
	//read pot registers

	ldx potx
	ldy poty

	//start new cycle
.ifndef MAIN.@DEFINES.useShadows
	sta potgo	//This instruction must be executd in EVERY VBL, with less than ca. 100 cycles accuracy in every frame
				//The best solution would be to do that at the very beginning of VBL. 
				//Jitter with calling this instruction may cause unstable mouse movement or invalid data.
				//This instruction is the only requirement to get it working. 
.endif


.ifdef MAIN.@DEFINES.debug
	//Simple debug info
	stx debugpx;
	sty debugpy;
.endif

.ifdef MAIN.@DEFINES.debug
	txa
	pha
	//poor-man execution time visualization
	ldx #$50
@	sta atari.wsync
	dex
	bpl @-	
	lda #15
	sta atari.colbk
	pla
	tax
.endif	
	//valid data has one and only bit set: bit 6 or bit 7.
	//both x, and Y should be valid
	
	//validate x
	txa
	sta valx
	rol 
	eor valx: #$00
	bpl invalidpot
	
	//validate y
	tya
	sta valy
	rol 
	eor valy: #$00
	bpl invalidpot
	
	//potx, poty in X,y
	
	
	
	//calculate x-movement -32 to +31
calcDX:
	txa
	sec
	sbc oldX
	beq endCalcX		//no x movememnt. Skip calculations. A=0
	sta @+
	rol
	eor @: #$00
	and #$80
	eor @-
	cmp #$80 
	ror 
	bpl @+
	adc #0
@	beq endcalcX
	stx oldX
endcalcDX:	//x movement in A

	//I did a small simplification, x,y +- movement will never cross byte boundary.
	//This may not be true if soft sprites in hires used. 
	//calculate x position
	
calcX:	
	clc
	adc cursor.x
	cmp #cursor_minX
	bcs @+
	lda #cursor_minX
@	cmp #cursor_maxX
	beq @+
	bcc @+
	lda #cursor_maxX
@	sta cursor.x
	sta hposp0
endCalcX	

	//calculate y-movement -32 to +31
calcDY:
	tya
	sec
	sbc oldY
	beq endCalcY
	sta @+
	rol
	eor @: #$00
	and #$80
	eor @-
	cmp #$80
	ror 
	bpl @+
	adc #0
@	beq endCalcY
	sty oldY
endCalcDY	//y movement in A
	
	//I did a small simplification, x,y +- movement will never cross byte boundary.

	//calculate y position	
calcY:	
	clc
	adc cursor.y
	cmp #cursor_minY
	bcs @+
	lda #cursor_minY
@	cmp #cursor_maxY
	beq @+
	bcc @+
	lda #cursor_maxY
@	sta cursor.y
.ifdef MAIN.@DEFINES.useAsmMovement
	jsr moveCursorToY
.endif
endCalcY		
	
invalidpot: 

//check wheel.

wheel:
	lda portA
	and #wheelMask
.ifdef MAIN.@DEFINES.debug
	sta debugWheel
.endif	
	tay
	eor wheelState
	beq endSlider	//no movement
	eor #wheelMask
	beq endwheel	//invalid movement -  rare case, but we need to store the invalid state
	and #wheelDirMsk
	sta @+1
	sty @+
	tya
	lsr
	eor @: #00
	and #wheelDirMsk 
	eor @: #00
	beq @+
	lda #$fe 
@	eor #$ff
endWheel:
	sty wheelState

	//wheel movement in A, only +1, 0, or -1 is possible 
	
	//calculate slider.y
.ifdef MAIN.@DEFINES.debug
	sta debugWheelDelta
.endif	

	clc
	adc slider.y
	tay
	clc
	adc #$ff-slider_maxY
	adc #slider_maxY-slider_minY+1
	bcc endSlider	
	sty slider.y	
.ifdef MAIN.@DEFINES.useAsmMovement
	jsr moveSliderToY
.endif	
endSlider:




exitVBI:
.ifdef MAIN.@DEFINES.debug
	lda #0
	sta atari.colbk
.endif	
	jmp xitvbv

.ifdef MAIN.@DEFINES.useAsmMovement
moveCursorToY:
	//move cursor to new y
	//clear cursor data
	clc
	lda #<(PMGBASE+cursor_offset)
	adc cursor.lasty
	sta @+1
	lda #0
	ldx #cursor_height-1
@	sta @: PMGBASE+cursor_offset,x
	dex
	bpl @-1
	
	clc
	adc cursor.y
	sta cursor.lasty
	adc #<(PMGBASE+cursor_offset)
	sta @+1
	ldx #cursor_height-1
@	lda adr.cursor_data,x
	sta @: PMGBASE+cursor_offset,x
	dex
	bpl @-1
	rts

moveSliderToY:
	//move cursor to new y
	//clear cursor data
	clc
	lda #<(PMGBASE+slider_offset)
	adc slider.lasty
	sta @+1
	lda #0
	ldx #slider_height-1
@	sta @: PMGBASE+slider_offset,x
	dex
	bpl @-1
	
	clc
	adc slider.y
	sta slider.lasty
	adc #<(PMGBASE+slider_offset)
	sta @+1
	ldx #slider_height-1
@	lda adr.slider_data,x
	sta @: PMGBASE+slider_offset,x
	dex
	bpl @-1
	rts
.endif

//some "static" variables

oldX:
	dta $80;
	
oldY:
	dta $80;
	
wheelState:
	dta $00;


end;	