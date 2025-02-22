unit x16_zsmkit;
(*
* @type: unit
* @author: MADRAFi <madrafi@gmail.com>
* @name: X16 zsmkit library for Mad-Pascal.
* @version: 0.1.0

* @description:
* Set of procedures to cover functionality provided by:
*
* <https://github.com/mooinglemur/zsmkit/>
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
    oldIRQ: Word;


procedure zsmInit; assembler;
(*
* @description:
* Initialize engine. It sets Interrupts to trigger every 1/50th of a second to call zsm_tick().
*
*
*
*)

procedure zsmSetISR; assembler;
(*
* @description:
* This sets up a default interrupt service routine that calls zsm_tick on every interrupt. The existing IRQ handler is called afterwards.
*
*
*
*)

procedure zsmClearISR; assembler;
(*
* @description:
* This routine removes the interrupt service routine.
*
*
*
*)

procedure zsmDirectLoad(filename: String; bank: Byte; addr: Word); assembler;
(*
* @description:
* Loads filename music file into bank.
*
* @param (String) - Filename to load
* @param (Byte) - RAM bank to load to
* @param (Word) - Address in Memory to load to
*
*)

procedure zsmSetMem(priority: Byte; bank: Byte; addr: Word); assembler;
(*
* @description:
* Sets up the song pointers and parses the header based on a ZSM that was previously loaded into RAM. If the song is valid, it marks the priority slot as playable.
*
* @param: (Byte) - Sets the priority for the music
* @param: (Byte) - Switches to chosen bank 1-63 (512kb) or 1-255 (2048kb)
* @param: (Word) - Address in memory to switch to
*
*)

procedure zsmPlay(priority: Byte); assembler;
(*
* @description:
* Starts playback of a song. If zsm_stop was called, this function continues playback from the point that it was stopped.
*
* @param: (Byte) - Priority for playback 0-255
*
*)

procedure zsmStop(priority: Byte); assembler;
(*
* @description:
* Pauses playback of a song. Playback can optionally be resumed from that point later with zsm_play.
*
* @param: (Byte) - Priority for playback 0-255
*
*)

procedure zsmRewind(priority: Byte); assembler;
(*
* @description:
* Stops playback of a song (if it is already playing) and resets its pointer to the beginning of the song. Playback can then be started again with zsm_play.
*
* @param: (Byte) - Priority for playback 0-255
*
*)

procedure zsmSetAtten(priority, volume: Byte); assembler;
(*
* @description:
* Changes the master volume of a priority slot by setting an attenuation value. A value of $00 implies no attenuation (full volume) and a value of $3F is full mute.
*
* @param: (Byte) - Priority for playback 0-255
*
*)


implementation


procedure zsmInit; assembler;
asm

    lda #1
    jsr zsm_init_engine

    // lda IRQVec
    // sta oldIRQ
    // lda IRQVec+1
    // sta oldIRQ+1

    // sei
    // lda #<irqhandler
    // sta IRQVec
    // lda #>irqhandler
    // sta IRQVec+1
    // cli

    // rts

    // .proc irqhandler
    //     lda #35
    //     sta VERA_dc_border
    //     lda #0
    //     jsr zsm_tick
    //     jmp (oldIRQ)
    // .endp

end;

procedure zsmSetISR; assembler;
asm
    jsr zsmkit_setisr
end;

procedure zsmClearISR; assembler;
asm
    jsr zsmkit_clearisr
end;

procedure zsmDirectLoad(filename: String; bank: Byte; addr: Word); assembler;
asm
        pha
        phx
        phy

        lda #<(adr.filename+1)
        sta r12L
        lda #>(adr.filename+1)
        sta r12H

        lda adr.filename
        // get pointer into x,y registers
        ldx r12L
        ldy r12H
        jsr SETNAM

        lda #2; // logical file number
        ldx #8; // device number
        ldy #2;
        jsr SETLFS

        lda bank
        sta RAMBank
        lda #0
        ldx addr
        ldy addr+1

        jsr LOAD

        ply
        plx
        pla
end;

procedure zsmSetMem(priority: Byte; bank: Byte; addr: Word); assembler;
asm
    pha
    phx
    phy

    lda bank
    sta RAMBank

    ldx priority
    lda addr
    ldy addr+1
    jsr zsm_setmem

    ply
    plx
    pla
end;

procedure zsmPlay(priority: Byte); assembler;
asm
    phx
    ldx priority
    jsr zsm_play
    plx
end;

procedure zsmStop(priority: Byte); assembler;
asm
    phx
    ldx priority
    jsr zsm_stop
    plx
end;

procedure zsmRewind(priority: Byte); assembler;
asm
    phx
    ldx priority
    jsr zsm_rewind
    plx
end;

procedure zsmSetAtten(priority, volume: Byte); assembler;
asm
    phx
    ldx priority
    lda volume
    plx
end;

end.