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

procedure veraDirectLoad(filename: TString); assembler;
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

procedure veraDirectLoad(filename: TString); assembler;
asm
    phx
    lda #1; // logical file number
    ldx #8; // device number
    ldy #2; // doing bvload
    jsr SETLFS

    lda #10
    ldx filename
    ldy filename+1
    jsr SETNAM

    // lda filename
    // sta r0L
    // lda filename+1
    // sta r0H
    // ldy #0
    // lda (r0L),y
    // pha
    // iny
    // lda (r0L),y
    // tax
    // iny
    // lda (r0L),y
    // tay
    // pla
    // jsr SETNAM

    lda #2; // BVLOAD to bank 0
    ldx #0; // address 0 (start of video mem)
    ldy #0
    jsr LOAD
    plx   
end;

end.