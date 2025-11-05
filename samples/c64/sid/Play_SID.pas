{ ==================================
  Demo program - SID player (c64)
  Created: 12/5/2022
  Song:    What It Takes, by Jimmy Nielsen (Shogun)
  URL:     https://csdb.dk/sid/?id=57014
   ================================== }
program PlaySID;
uses Commodore64;

var
  CIA_Interrupt : byte absolute $DC0D;
  ScreenControl : byte absolute $D011;
  RasterLine    : byte absolute $D012;
  InterruptFlag : byte absolute $D019;
  InterruptMask : byte absolute $D01A;

  IRQ: word absolute $314;
  SID: array of byte = ({$BIN2CSV Test.sid});
  
  Src, Dst, Count: word ZeroPage;
  
  procedure CopyR;
  begin
    asm
          LDA SID + $0A     ; get address of Init
          STA Dst+1
          LDA SID + $0B
          STA Dst
          LDX Count+1  ; the last byte must be moved first
          CLC          ; start at the final pages of FROM and TO
          TXA
          ADC Src+1
          STA Src+1
          CLC
          TXA
          ADC Dst+1
          STA Dst+1
          INX          ; allows the use of BNE after the DEX below
          LDY Count
          BEQ next
          DEY          ; move bytes on the last page first
          BEQ loop2
 loop1:   LDA (Src),Y
          STA (Dst),Y
          DEY
          BNE loop1
 loop2:   LDA (Src),Y ; handle Y = 0 separately
          STA (Dst),Y
 next:    DEY
          DEC Src+1   ; move the next page (if any)
          DEC Dst+1
          DEX
          BNE loop1
    end; 
  end;
   
begin
  Src   := @SID + $7E;
  //Dst   := @SID + $7C;
  Count := SID.Length - $7E;
  CopyR;
  
  CIA_Interrupt := $7F;  // stops IRQs from CIA
  asm 
          LDA SID + $0A     ; get address of Init
          STA init + 2
          LDA SID + $0B
          STA init + 1
          LDA SID + $0C     ; get address of Play
          STA play + 2
          LDA SID + $0D
          STA play + 1
          
	        LDA #0            ; start with first song
  init:   JSR $0000         ; Init SID player
          SEI
          LDA #1
          STA InterruptMask ; enable raster interrupts
          LDA #$64
          STA RasterLine    ; raise IRQ in that line
          LDA ScreenControl
          AND #$7F          ; Clear bit 7
          STA ScreenControl ; 9th bit of RasterLine
          LDA #<IRQ_Handler ; Hijack IRQ vector
          STA IRQ
          LDA #>IRQ_Handler
          STA IRQ + 1
          CLI
          RTS
          
  IRQ_Handler:          
          INC InterruptFlag ; ack the interrupt
  play:   JSR $0000         ; Play
          JMP $EA31  
  end; 
end.
