function RGet(chn: byte; buffer: PByte): Tstring;
(*
* @description:
* Gets text record and returns as Tstring. Equivalent in Atari BASIC: INPUT #channel VAR$
*
* @param: (byte) chn - Free IOCB channel.
* @param: (PByte) buffer - Where to place data.
* @returns: (Tstring) - Record contents.
*)
var
     cnt  : byte;
     tmp  : Tstring;
begin
     asm {	

          lda chn
          :4 asl @
          tax

          lda #5
          sta iccmd,x

          lda buffer
          sta icbufa,x
          lda buffer+1
          sta icbufa+1,x
          lda #$ff
          sta icbufl,x
          lda #0
          sta icbufl+1,x

          m@call	ciov
     };

     // Temporary string

     tmp := '';

     // Counter 

     cnt := 0;

     // Move result record to result variable
     While Peek(word(buffer) + cnt) <> $9b do begin
          tmp := Concat(tmp, Chr(Peek(word(buffer) + cnt)));
          Inc(cnt);
     end;

     Result := tmp;
end;

procedure RSkip(chn: byte; buffer: PByte);
(*
* @description:
* Skips record. Equivalent in Atari BASIC: INPUT #channel VAR$
*
* @param: (byte) chn - Free IOCB channel.
* @param: (PByte) buffer - Where to place data.
*)
begin
     asm {	
          lda chn
          :4 asl @
          tax

          lda #5
          sta iccmd,x

          lda buffer
          sta icbufa,x
          lda buffer+1
          sta icbufa+1,x
          lda #$ff
          sta icbufl,x
          lda #0
          sta icbufl+1,x

          m@call	ciov
     };
end;

function FindFirstFreeChannel: byte;
(*
* @description:
* Find first available IOCB channel
*
* @returns: (byte) - first available channel number (multiplied by 16) or error -95. 
* Source: http://atariki.krap.pl/index.php/Programowanie:_Jak_wyszuka%C4%87_pierwszy_wolny_IOCB
*)
begin
     asm {	

          ldx #$00
          ldy #$01
ff_loop   lda icchid,x
          cmp #$ff
          beq ff_found
          txa
          clc
          adc #$10
          tax
          bpl ff_loop
          ldx #-95
ff_found  stx Result
     };
end;
