{ ==================================
  SID player (C64)
  ================================== }
program PlaySID;

uses crt, sysutils;

var
  CIAInterrupt     : byte absolute $DC0D;
  ScreenControl    : byte absolute $D011;
  RasterLine       : byte absolute $D012;
  InterruptFlag    : byte absolute $D019;
  InterruptMask    : byte absolute $D01A;
  BorderColor      : byte absolute $D020;
  BackgroundColor0 : byte absolute $D021;

  IRQ: word absolute $314;
  SID: array of byte = [{$BIN2CSV 'Play_SID.sid'}];
  
  Src  : Word;
  Dst  : Word;
  Size : Word;
  InitAddress : Word;
  PlayAddress : Word;
   
begin

  BorderColor:=0;
  BackgroundColor0:=0;
  WriteLn(#147#5'Doublebass (v2)');
  WriteLn(#159'Aidan Crouzet-Pascal (acrouzet)');
  WriteLn(#30'2021 Genesis Project');
  WriteLn(#156'https://demozoo.org/music/330333');
  WriteLn;

  Src   := Word(@SID + $7E);
  Dst   := SID[$7C]+256*SID[$7D];
  Size  := Length(SID) - $7E;
  Move(Pointer(src), Pointer(Dst), Size);
  WriteLn(#151'Copied $',HexStr(Size,4),' bytes from $',HexStr(Src,4),' to $',HexStr(Dst,4),'.');

  InitAddress   := 256*SID[$0A]+SID[$0B];
  PlayAddress   := 256*SID[$0C]+SID[$0D];
  WriteLn(#151'Init address $',HexStr(InitAddress,4),', play address $',HexStr(PlayAddress,4),'.');
  CIAInterrupt := $7F;  // stops IRQs from CIA
  asm
          MWA InitAddress init+1  ; get address of Init
          MWA PlayAddress play+1  ; get address of Play

	  LDA #0                  ; start with the first song
  init:   JSR $ffff               ; initialize the SID player
          SEI
          MVA #1 InterruptMask    ; enable raster interrupts
          MVA #$64 RasterLine     ; raise IRQ in that line
          LDA ScreenControl
          AND #$7F                ; Clear bit 7
          STA ScreenControl       ; 9th bit of RasterLine
          MWA #IRQ_Handler IRQ    ; Hijack IRQ vector
          CLI
          RTS

          
  IRQ_Handler:          
          INC InterruptFlag       ; ack the interrupt

  play:   JSR $ffff               ; Play
          JMP $EA31
  end; 
end.
