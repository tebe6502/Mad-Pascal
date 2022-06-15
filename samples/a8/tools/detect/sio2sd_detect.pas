program detectSIO2SD;

uses atari, crt;

const
     SIO_NONE        = $00;
     SIO_READ        = $40;
     SIO_WRITE       = $80;
     SIO_READ_WRITE  = $c0;
     
     SIO2SD_STATUS   = $00;
     SIO2SD_GETVER   = $11;

var
     DDEVIC	   : byte absolute $0300;
     DUNIT 	   : byte absolute $0301;
     DCOMND	   : byte absolute $0302;
     DSTATS	   : byte absolute $0303;
     DBUFLO	   : byte absolute $0304;
     DBUFHI	   : byte absolute $0305;
     DTIMLO	   : byte absolute $0306;
     DUNUSE	   : byte absolute $0307;
     DBYTLO	   : byte absolute $0308;
     DBYTHI	   : byte absolute $0309;
     DAUX1 	   : byte absolute $030a;
     DAUX2 	   : byte absolute $030b;
     SIOresult    : byte;
     SIO2SDresult : byte;
     majorVersion : byte;
     minorVersion : byte;
     buffer       : word absolute $8000;
     
procedure exec_sio(device: byte; dunit: byte; command: byte; aux1: byte; aux2: byte; direction: byte; timeout: byte; size: word);
var l, h: byte;
begin

     l := Lo(size);
     h := Hi(size);
     
     asm {
     
          lda  device
          sta  DDEVIC
          lda  dunit
          sta  DUNIT
          lda  command
          sta  DCOMND
          lda  aux1
          sta  DAUX1
          lda  aux2
          sta  DAUX2
          lda  direction
          sta  DSTATS
          lda  <buffer
          sta  DBUFLO
          lda  >buffer
          sta  DBUFHI
          lda  timeout
          sta  DTIMLO
          lda  l
          sta  DBYTLO
          lda  h
          sta  DBYTHI
          jsr  $E459
          
          sty  SIOresult
     
     };

end;

begin

     exec_sio($72, $00, SIO2SD_STATUS, $00, $00, SIO_READ, $06, $01);
     
     if SIOresult = 1 then begin 
     
          writeln('SIO2SD present');
          
          SIO2SDresult := Peek(buffer);
          
          case SIO2SDresult of 
          
               0: writeln('No card in slot');
               1: writeln('Card is in slot');
          
          end;
             
          exec_sio($72, $0, SIO2SD_GETVER, $0, $0, SIO_READ, $06, $01);
     
          if SIOresult = 1 then begin
         
               majorVersion := byte(Peek($8000) div $10);
               minorVersion := byte(Peek($8000) mod $10);
               
               writeln('Firmware ver. ', majorVersion, '.', minorVersion);
               
               writeln;
               writeln('Press any key to exit...');
          
          end;
          
     end else begin
          writeln('SIO2SD is not present');
          writeln;
          writeln('Press any key to exit...');
     end;
     
     repeat until keypressed;

end.