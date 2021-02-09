unit b_maxflash8mb;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: MaxFlash 8Mbit writing and erasing routines
* @version: 0.1.0
* @description:
* Set of procedures to erase and write data onto MaxFlash 1Mbit cartridge.
* 
* Based on Steven Tucker's routines, placed into the public domain.
* 
* Now it works only with Am29F040 (or compatibile) modules, with sector size of 64K, but in future it might get
* extended for another chips. 
* 
* Be notified that during erase and write operations all nonmaskable interrupts are disabled, so be careful, and 
* enble them after, if they are needed.
*
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
uses atari;

const 
MF_ZPLOCATION = $D8; // starting location of reserved 4 bytes used by BurnPages routine

procedure SetBank(bank: byte);
(*
* @description:
* Switches cart to requested bank.
*
* @param: bank - cart bank number ($00-$7F)
*
*)
procedure SetSector(sec: byte);
(*
* @description:
* Switches to first bank of specified sector.
*
* @param: sec - cart sector number ($00-$0F);
*
*)
procedure EraseChip;
(*
* @description:
* Erases whole Maxflash memory.
*
*)
procedure EraseSector(sec: byte);
(*
* @description:
* Erases specified sector (8 banks = 64KB) of Maxflash memory.
*
* @param: sec - cart sector number ($00-$0F);
*
*)
procedure BurnByte(bank:byte;addr:word;val:byte);
(*
* @description:
* Writes one byte into Maxflash memory:
*
* @param: bank - cart bank number ($00-$7F)
* @param: addr - cart address ($A000-$BFFF)
* @param: val - byte value
*
*)
procedure BurnBlock(bank: byte; src, dest, size: word);
(*
* @description:
* Writes block of data from computer memory to Maxflash cart.
*
* @param: bank - cart bank number ($00-$7F)
* @param: src - source memory address ($0000-$FFFF)
* @param: dest - cart address ($A000-$BFFF)
* @param: size - number of bytes to write
*
*)
procedure BurnPages(sec, src, dest, pages:byte);
(*
* @description:
* Fastest procedure that copies whole memory pages from RAM into MaxFlash cart.
*
* @param: sec - cart sector number ($00-$0F);
* @param: src - starting source memory page ($00-$FF)
* @param: dest - cart memory address within selected sector ($00-$FF)
* @param: pages - number of pages to be copied
*
*)

implementation

const 
CARTOP = $BFFF; // @nodoc 
CARBAS = $A000; // @nodoc 

var GINTLK: byte absolute $03FA;  // @nodoc 
    TRIG3: byte absolute $D013;   // @nodoc 
    zerobank: byte absolute $D500;  // @nodoc 
    cartoff: byte absolute $D580;  // @nodoc 
    carbase: byte absolute $A000;  // @nodoc 
    banks: array [0..0] of byte absolute $D500;  // @nodoc 
    workpages, curbank, cursec: byte;  // @nodoc 
    copysrc: word absolute MF_ZPLOCATION;  // @nodoc 
    copydst: word absolute MF_ZPLOCATION + 2;  // @nodoc 

procedure SetBank(bank:byte);
begin
    curbank := bank;
    banks[curbank] := 0;
end;    
    
procedure SetSector(sec:byte);
begin
    cursec := sec;
    SetBank(sec shl 3);
end;    
  
  
procedure IncPtr;assembler;
asm {  
incptr      
        inc copysrc+1       ;; Increment the source pointer and the destination pointer
        inc copydst+1       ;; If the source pointer leaves the cartridge area, it is reset to the base of
        lda copydst+1       ;; the cartridges and the current bank number is incremented
        cmp .hi(CARTOP+1)   ;; Destination Pointer outside cartridge space?
        bne _decpage        ;;
        inc curbank     ;; Reset to base of cartridge and increment current bank 
        lda .hi(CARBASE)    ;;
        sta copydst+1       ;;
_decpage    
        lda workpages       ;;
        sec         ;;
        sbc #$01        ;;
        sta workpages       ;;  
};
end;

procedure Wr5555(val:byte);assembler;
asm {
        lda val
.def :_wr5555
        bit curbank
        bvs _wr5c2
        sta $d502   
        sta $b555
        rts     
_wr5c2  
        sta $d542   
        sta $b555
};
end;

procedure Wr2AAA(val:byte);assembler;
asm {
        lda val
        bit curbank
        bvs _wr2c2
        sta $d501
        sta $aaaa
        rts 
_wr2c2      
        sta $d541       
        sta $aaaa       
};    
end;

procedure CmdUnlock;
begin
    Wr5555($AA);
    Wr2AAA($55);
end;

procedure CmdInit;assembler;
asm {
    lda #$00            
    sta nmien           
    sta wsync   
};
end;

procedure CmdCleanup();assembler;
asm {
    sta cartoff
    sta wsync           
    lda trig3           
    sta GINTLK  
    lda #$40
    sta nmien   
};
end;

procedure WaitToComplete;assembler;
asm {
poll_write  
        lda #$00        
        sta workpages       
_poll_again 
        lda carbase 
        cmp carbase         
        bne poll_write      
        cmp carbase         
        bne poll_write      
        inc workpages       
        bne _poll_again     
};
end;

procedure EraseChip;
begin
   CmdInit;
   CmdUnlock;
   Wr5555($80);
   CmdUnlock;
   Wr5555($10);
   WaitToComplete;
   CmdCleanup;
end;

procedure EraseSector(sec:byte);
begin
   CmdInit;
   SetSector(sec);
   CmdUnlock;
   Wr5555($80);
   CmdUnlock;
   SetSector(sec);
   carbase := $30; 
   WaitToComplete;
   CmdCleanup;
end;

procedure BurnByte(bank:byte;addr:word;val:byte);
begin
    CmdUnlock;
    Wr5555($A0);
    SetBank(bank);
    Poke(addr,val);
end;

procedure BurnBlock(bank: byte; src, dest, size: word);
begin
    CmdInit;
    repeat
        BurnByte(bank,dest,peek(src));
        inc(src);
        inc(dest);
        if dest = CARTOP + 1 then begin
            Inc(bank);
            dest := CARBAS;
        end;
        dec(size);
    until size = 0;
    CmdCleanup;
end;

procedure BurnPages(sec,src,dest,pages:byte);
begin
    CmdInit;
    workpages := pages - 1;
    SetSector(sec);
    curbank := curbank + (dest shr 5);
    copysrc := src shl 8;
    copydst := (Hi(CARBAS) + (dest and $1F)) shl 8;
asm {
        txa 
        pha
        
_nextpage   
        ldy #$00        ;; Write a page from copysrc to copydst within flash
_quickpage  
        jsr cmdunlock
        lda #$A0
        jsr _wr5555
        ldx curbank
        sta zerobank,x
        lda (copysrc),y
        sta (copydst),y
        iny
        bne _quickpage
        jsr incptr      ;; Increment pointers and banks, decrement work pages.
        bpl _nextpage
        
        pla 
        tax
        
        rts

incptr      
        inc copysrc+1       ;; Increment the source pointer and the destination pointer
        inc copydst+1       ;; If the source pointer leaves the cartridge area, it is reset to the base of
        lda copydst+1       ;; the cartridges and the current bank number is incremented
        cmp .hi(cartop+1)   ;; Destination Pointer outside cartridge space?
        bne _decpage        ;;
        inc curbank     ;; Reset to base of cartridge and increment current bank 
        lda .hi(carbas) ;;
        sta copydst+1       ;;
_decpage    
        lda workpages       ;;
        sec         ;;
        sbc #$01        ;;
        sta workpages       ;;  
        rts 

};
    CmdCleanup;
end;


end.


