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
*
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


    // lda filename
    // ldx filename+1
    // ldy filename+1
    // jsr SETNAM

    lda filename
    sta r0L
    lda filename+1
    sta r0H
    ldy #0
    lda (r0L),y
    pha
    iny
    lda (r0L),y
    tax
    iny
    lda (r0L),y
    tay
    pla
    jsr SETNAM

    lda #2; // BVLOAD to bank 0
    ldx #0; // address 0 (start of video mem)
    ldy #0
    jsr LOAD
    plx   
end;

end.