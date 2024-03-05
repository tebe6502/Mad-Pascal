unit x16_zsmkit;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: X16 zsmkit library for Mad-Pascal.
* @version: 0.1.0

* @description:
* Set of procedures to cover functionality provided by:    
*
* https://github.com/mooinglemur/zsmkit/
* 
*  
*
*   
* It's work in progress, please report any bugs you find.   
*   
*)

interface

const
{$i zsmkit8c00.inc}
{$r zsmkit.res}



var
    // zsmRAMBank: byte;
    oldIRQ: Word;


procedure zsmInit; assembler;
(*
* @description:
* Initialize engine. It sets Interrupts to trigger every 1/50th of a second to call zsm_tick().
*
* 
* 
*)

procedure zsmDirectLoad(filename: String; Bank: Byte); assembler;
(*
* @description:
* Loads filename music file into bank.
*
* 
* 
*)

procedure zsmSetMemBank(priorityRAMbank: Byte); assembler;
(*
* @description:
* Sets up the song pointers and parses the header based on a ZSM that was previously loaded into RAM. If the song is valid, it marks the priority slot as playable.
*
* 
* 
*)


implementation


procedure zsmInit; assembler;
asm
    lda #1
    jsr zsm_init_engine

    jsr setup_handler

    .proc setup_handler
        lda IRQVec
        sta oldIRQ
        lda IRQVec+1
        sta oldIRQ+1

        sei
        lda #<irqhandler
        sta IRQVec
        lda #>irqhandler
        sta IRQVec+1
        cli

        rts
    .endp

    .proc irqhandler
        lda #35
        sta VERA_dc_border
        lda #0
        jsr zsm_tick
        jmp (oldIRQ)
    .endp

end;

procedure zsmDirectLoad(filename: String; Bank: Byte); assembler;
asm
        phx



        lda #2; // logical file number
        ldx #8; // device number
        ldy #2; // doing bvload
        jsr SETLFS

        // copy pointer to zero page
        lda filename
        sta r12L
        lda filename+1
        sta r12H

        // read first pointed-at byte - string length
        ldy #0
        lda (r12L),y
        
        // get pointer into x,y registers
        ldx r12L
        ldy r12H
        
        // increment past the length
        inx
        bne skip
        iny

    skip:
        jsr SETNAM


        lda #Bank; // BVLOAD
        ldx #0;
        ldy #0
        jsr LOAD
        plx   
end;



end.