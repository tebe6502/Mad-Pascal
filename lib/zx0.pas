unit zx0;
(*
* @type: unit
* @author: Einar Saukas, Krzysztof 'XXL' Dudek, Tomasz 'Tebe' Biela
* @name: ZX0 decompression unit
*
* @version: 1.2
*
* @description:
* ZX0 decompressor
*
* zx0.exe input_filename output_filename
*
* <https://github.com/einar-saukas/ZX0>
*
* <https://xxl.atari.pl/zx0-decompressor/>
*)

{

unZX0

}

interface

	procedure unZX0(inputPointer, ZX0_OUTPUT: pointer); assembler; register; overload;
	procedure unZX0(fnam: PString; outputPointer: pointer); register; overload;

implementation



procedure unZX0(fnam: PString; outputPointer: pointer); register; overload;
(*
@description:
ZX0 I/O stream decompressor (Einar Saukas, Krzysztof 'XXL' Dudek)

@param: inputPointer - source data address, :EDX
@param: outputPointer - destination data address, :ECX
*)
var f: file;
    buf: array [0..255] of byte absolute __buffer;


procedure READ_BUF;
begin

 {$I-}

 asm
	lda :ecx
	pha
	lda :ecx+1
	pha
	lda :eax
	pha
	lda :eax+1
	pha
 end;

 blockread(f, buf, 256);

 asm
	pla
	sta :eax+1
	pla
	sta :eax
	pla
	sta :ecx+1
	pla
	sta :ecx
 end;

 {$I+}

end;


begin

 assign(f, fnam); reset(f,1);

 if IOResult > 127 then begin
  close(f);

  Exit;
 end;

 READ_BUF;

asm
decompressing   equ :ecx
copysrc         equ :eax

		stx @sp

		mva #$00 GET_BYTE+1

dzx0_standard
		lda   #$ff
		sta   offsetL
		sta   offsetH
		ldy   #$00
		sty   lenL
		sty   lenH
		lda   #$80

; Literal (copy next N bytes from compressed file)
; 0  Elias(length)  byte[1]  byte[2]  ...  byte[N]
dzx0s_literals
		jsr   dzx0s_elias
		pha

cop0		jsr   GET_BYTE
		ldy   #$00
		sta   (decompressing),y
		inw   decompressing
		lda   #$ff
lenL		equ   *-1
		bne   @+
		dec   lenH
@		dec   lenL
		lda   lenL
		ora   #$ff
lenH		equ   *-1
		bne   cop0

		pla
		asl   @
		bcs   dzx0s_new_offset

; Copy from last offset (repeat N bytes from last offset)
; 0  Elias(length)
		jsr   dzx0s_elias
dzx0s_copy
		pha
		lda   decompressing
		clc
		adc   #$ff
offsetL		equ   *-1
		sta   copysrc
		lda   decompressing+1
		adc   #$ff
offsetH		equ   *-1
		sta   copysrc+1

		ldy   #$00
		ldx   lenH
		beq   Remainder
Page		lda   (copysrc),y
		sta   (decompressing),y
		iny
		bne   Page
		inc   copysrc+1
		inc   decompressing+1
		dex
		bne   Page
Remainder	ldx   lenL
		beq   copyDone
copyByte	lda   (copysrc),y
		sta   (decompressing),y
		iny
		dex
		bne   copyByte
		tya
		clc
		adc   decompressing
		sta   decompressing
		bcc   copyDone
		inc   decompressing+1
copyDone	stx   lenH
		stx   lenL

		pla
		asl   @
		bcc   dzx0s_literals

; Copy from new offset (repeat N bytes from new offset)
; 1  Elias(MSB(offset))  LSB(offset)  Elias(length-1)
dzx0s_new_offset
		jsr   dzx0s_elias
		pha
		php
		lda   #$00
		sec
		sbc   lenL
		sta   offsetH
		bne   @+
		plp
		pla
		jmp to_exit	; koniec

@		jsr   GET_BYTE
		plp
		sta   offsetL
		ror   offsetH
		ror   offsetL
		ldx   #$00
		stx   lenH
		inx
		stx   lenL
		pla
		bcs   @+
		jsr   dzx0s_elias_backtrack
@		inc   lenL
		bne   @+
		inc   lenH
@		jmp   dzx0s_copy

dzx0s_elias	inc   lenL
dzx0s_elias_loop
		asl   @
		bne   dzx0s_elias_skip
		jsr   GET_BYTE
		sec   ; można usunąć jeśli dekompresja z pamięci a nie pliku
		rol   @
dzx0s_elias_skip
		bcc   dzx0s_elias_backtrack
		rts
dzx0s_elias_backtrack
		asl   @
		rol   lenL
		rol   lenH
		jmp   dzx0s_elias_loop


GET_BYTE	lda adr.buf
		inc GET_BYTE+1
		bne @+

		php
		pha
		ldx @sp
		jsr READ_BUF
		pla
		plp

@		rts

to_exit		lda #0
		tya
		sta:rne @buf,y+

		ldx #0
@sp		equ *-1
end;

 close(f);

end;


procedure unZX0(inputPointer, ZX0_OUTPUT: pointer); assembler; register; overload;
(*
@description:
ZX0 decompressor (Einar Saukas, Krzysztof 'XXL' Dudek)
FORMAT V2 !!! (last update: 10/10/21)

@param: inputPointer - source data address, :EDX
@param: ZX0_OUTPUT   - destination data address, :ECX
*)

asm
copysrc = :edx

              stx @sp

              mwa inputPointer ZX0_INPUT

dzx0_standard
              lda   #$ff
              sta   offsetL
              sta   offsetH
              ldy   #$00
              sty   lenL
              sty   lenH
              lda   #$80

dzx0s_literals
              jsr   dzx0s_elias
              pha
cop0          jsr   get_byte
              ldy   #$00
              sta   (ZX0_OUTPUT),y
              inw   ZX0_OUTPUT
              lda   #$ff
lenL          equ   *-1
              bne   @+
              dec   lenH
@             dec   lenL
              bne   cop0
              lda   #$ff
lenH          equ   *-1
              bne   cop0
              pla
              asl   @
              bcs   dzx0s_new_offset
              jsr   dzx0s_elias
dzx0s_copy    pha
              lda   ZX0_OUTPUT
              clc
              adc   #$ff
offsetL       equ   *-1
              sta   copysrc
              lda   ZX0_OUTPUT+1
              adc   #$ff
offsetH       equ   *-1
              sta   copysrc+1
              ldy   #$00
              ldx   lenH
              beq   Remainder
Page          lda   (copysrc),y
              sta   (ZX0_OUTPUT),y
              iny
              bne   Page
              inc   copysrc+1
              inc   ZX0_OUTPUT+1
              dex
              bne   Page
Remainder     ldx   lenL
              beq   copyDone
copyByte      lda   (copysrc),y
              sta   (ZX0_OUTPUT),y
              iny
              dex
              bne   copyByte
              tya
              clc
              adc   ZX0_OUTPUT
              sta   ZX0_OUTPUT
              bcc   copyDone
              inc   ZX0_OUTPUT+1
copyDone      stx   lenH
              stx   lenL
              pla
              asl   @
              bcc   dzx0s_literals
dzx0s_new_offset
              ldx   #$fe
              stx   lenL
              jsr   dzx0s_elias_loop
              pha
//php ; stream
              ldx   lenL
              inx
              stx   offsetH
              bne   @+
//plp ; stream
              pla
              jmp to_exit
//            rts           ; koniec

@             jsr   get_byte
//plp ; stream
              sta   offsetL
              ror   offsetH
              ror   offsetL
              ldx   #$00
              stx   lenH
              inx
              stx   lenL
              pla
              bcs   @+
              jsr   dzx0s_elias_backtrack
@             inc   lenL
              bne   @+
              inc   lenH
@             jmp   dzx0s_copy
dzx0s_elias   inc   lenL
dzx0s_elias_loop
              asl   @
              bne   dzx0s_elias_skip
              jsr   get_byte
//sec ; stream
              rol   @
dzx0s_elias_skip
              bcc   dzx0s_elias_backtrack
              rts

dzx0s_elias_backtrack
              asl   @
              rol   lenL
              rol   lenH
              jmp   dzx0s_elias_loop

GET_BYTE      lda    $ffff
ZX0_INPUT     equ    *-2
              inw    ZX0_INPUT
              rts

to_exit       ldx #0
@sp           equ *-1
end;

end.
