unit zx5;
(*
* @type: unit
* @author: Einar Saukas, Krzysztof 'XXL' Dudek, Tomasz 'Tebe' Biela
* @name: ZX5
*
* @version: 1.0
*
* @description:
* ZX5 decompressor
*
* <https://github.com/einar-saukas/ZX5>
*
* <http://xxl.atari.pl/zx5-decompressor/>
*)

{

unZX5

}

interface

procedure unZX5(inputPointer, outputPointer: pointer); assembler; overload;
procedure unZX5(fnam: PString; outputPointer: pointer); overload;


implementation



procedure unZX5(fnam: PString; outputPointer: pointer); overload;
(*
@description:
ZX5 I/O stream decompressor (Einar Saukas, Krzysztof 'XXL' Dudek)

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)
var f: file;
    buf: array [0..255] of byte absolute __buffer;


procedure READ_BUF;
begin

 {$I-}

 asm
	lda :TMP
	pha
	lda :TMP+1
	pha
	lda :TMP+2
	pha
	lda :TMP+3
	pha
	lda :edx
	pha
	lda :edx+1
	pha
	lda :edx+2
	pha
	lda :edx+3
	pha
	lda :ecx
	pha
	lda :ecx+1
	pha
	lda :ecx+2
	pha
	lda :ecx+3
	pha
	lda :eax
	pha
	lda :eax+1
	pha
	lda :eax+2
	pha
	lda :eax+3
	pha
 end;

 blockread(f, buf, 256);

 asm
	pla
	sta :eax+3
	pla
	sta :eax+2
	pla
	sta :eax+1
	pla
	sta :eax
	pla
	sta :ecx+3
	pla
	sta :ecx+2
	pla
	sta :ecx+1
	pla
	sta :ecx
	pla
	sta :edx+3
	pla
	sta :edx+2
	pla
	sta :edx+1
	pla
	sta :edx
	pla
	sta :TMP+3
	pla
	sta :TMP+2
	pla
	sta :TMP+1
	pla
	sta :TMP

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
ZX5_OUTPUT      equ :EAX+0
copysrc         equ :EAX+2
offset          equ :EAX+4
offset2         equ :EAX+6
offset3         equ :EAX+8
len             equ :EAX+$A
pnb             equ :EAX+$C

unZX5		stx @sp

		mwa outputPointer ZX5_OUTPUT

		mva #$00 _GET_BYTE+1

		lda   #$ff
		sta   offset
		sta   offset+1
		ldy   #$00
		sty   len
		sty   len+1
		lda   #$80

dzx5s_literals
		jsr   dzx5s_elias
		pha
cop0		jsr   _GET_BYTE
		ldy   #$00
		sta   (ZX5_OUTPUT),y
		inw   ZX5_OUTPUT
		lda   len
		bne   @+
		dec   len+1
@		dec   len
		bne   cop0
		lda   len+1
		bne   cop0
		pla
		asl   @
		bcs   dzx5s_other_offset

dzx5s_last_offset
		jsr   dzx5s_elias
dzx5s_copy	pha
		lda   ZX5_OUTPUT
		clc
		adc   offset
		sta   copysrc
		lda   ZX5_OUTPUT+1
		adc   offset+1
		sta   copysrc+1
		ldy   #$00
		ldx   len+1
		beq   Remainder
Page		lda   (copysrc),y
		sta   (ZX5_OUTPUT),y
		iny
		bne   Page
		inc   copysrc+1
		inc   ZX5_OUTPUT+1
		dex
		bne   Page
Remainder	ldx   len
		beq   copyDone
copyByte	lda   (copysrc),y
		sta   (ZX5_OUTPUT),y
		iny
		dex
		bne   copyByte
		tya
		clc
		adc   ZX5_OUTPUT
		sta   ZX5_OUTPUT
		bcc   copyDone
		inc   ZX5_OUTPUT+1
copyDone	stx   len+1
		stx   len
		pla
		asl   @
		bcc   dzx5s_literals

dzx5s_other_offset
		asl   @
		bne   dzx5s_other_offset_skip
		jsr   _GET_BYTE
		sec	; można usunąć jeśli dekompresja z pamięci a nie pliku
		rol   @
dzx5s_other_offset_skip
		bcc   dzx5s_prev_offset

dzx5s_new_offset
		sta   pnb
		asl   @
		ldx   offset2
		stx   offset3
		ldx   offset2+1
		stx   offset3+1
		ldx   offset
		stx   offset2
		ldx   offset+1
		stx   offset2+1
		ldx   #$fe
		stx   len
		jsr   dzx5s_elias_loop
		pha
		ldx   len
		inx
		stx   offset+1
		bne   @+
		pla

		jmp to_exit	; koniec

@		jsr   _GET_BYTE
		sta   offset
		ldx   #$00
		stx   len+1
		inx
		stx   len
		pla
		dec   pnb
		bmi   @+
		jsr   dzx5s_elias_backtrack
@		inw   len
		jmp   dzx5s_copy

dzx5s_prev_offset
		asl   @
		bcc   dzx5s_second_offset
		ldy   offset2
		ldx   offset3
		sty   offset3
		stx   offset2
		ldy   offset2+1
		ldx   offset3+1
		sty   offset3+1
		stx   offset2+1

dzx5s_second_offset
		ldy   offset2
		ldx   offset
		sty   offset
		stx   offset2
		ldy   offset2+1
		ldx   offset+1
		sty   offset+1
		stx   offset2+1
		jmp   dzx5s_last_offset

dzx5s_elias	inc   len
dzx5s_elias_loop
		asl   @
		bne   dzx5s_elias_skip
		jsr   _GET_BYTE
		sec	; można usunąć jeśli dekompresja z pamięci a nie pliku
		rol   @
dzx5s_elias_skip
		bcc   dzx5s_elias_backtrack
		rts

dzx5s_elias_backtrack
		asl   @
		rol   len
		rol   len+1
		jmp   dzx5s_elias_loop


_GET_BYTE	lda adr.buf
		inc _GET_BYTE+1
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


procedure unZX5(inputPointer, outputPointer: pointer); assembler; overload;
(*
@description:
ZX5 decompressor (Einar Saukas, Krzysztof 'XXL' Dudek)

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)

asm
ZX5_OUTPUT      equ :EAX+0
copysrc         equ :EAX+2
offset          equ :EAX+4
offset2         equ :EAX+6
offset3         equ :EAX+8
len             equ :EAX+$A
pnb             equ :EAX+$C

unZX5		stx @sp

		mwa inputPointer ZX5_INPUT
		mwa outputPointer ZX5_OUTPUT

		lda   #$ff
		sta   offset
		sta   offset+1
		ldy   #$00
		sty   len
		sty   len+1
		lda   #$80

dzx5s_literals
		jsr   dzx5s_elias
		pha
cop0		jsr   _GET_BYTE
		ldy   #$00
		sta   (ZX5_OUTPUT),y
		inw   ZX5_OUTPUT
		lda   len
		bne   @+
		dec   len+1
@		dec   len
		bne   cop0
		lda   len+1
		bne   cop0
		pla
		asl   @
		bcs   dzx5s_other_offset

dzx5s_last_offset
		jsr   dzx5s_elias
dzx5s_copy	pha
		lda   ZX5_OUTPUT
		clc
		adc   offset
		sta   copysrc
		lda   ZX5_OUTPUT+1
		adc   offset+1
		sta   copysrc+1
		ldy   #$00
		ldx   len+1
		beq   Remainder
Page		lda   (copysrc),y
		sta   (ZX5_OUTPUT),y
		iny
		bne   Page
		inc   copysrc+1
		inc   ZX5_OUTPUT+1
		dex
		bne   Page
Remainder	ldx   len
		beq   copyDone
copyByte	lda   (copysrc),y
		sta   (ZX5_OUTPUT),y
		iny
		dex
		bne   copyByte
		tya
		clc
		adc   ZX5_OUTPUT
		sta   ZX5_OUTPUT
		bcc   copyDone
		inc   ZX5_OUTPUT+1
copyDone	stx   len+1
		stx   len
		pla
		asl   @
		bcc   dzx5s_literals

dzx5s_other_offset
		asl   @
		bne   dzx5s_other_offset_skip
		jsr   _GET_BYTE
		sec	; można usunąć jeśli dekompresja z pamięci a nie pliku
		rol   @
dzx5s_other_offset_skip
		bcc   dzx5s_prev_offset

dzx5s_new_offset
		sta   pnb
		asl   @
		ldx   offset2
		stx   offset3
		ldx   offset2+1
		stx   offset3+1
		ldx   offset
		stx   offset2
		ldx   offset+1
		stx   offset2+1
		ldx   #$fe
		stx   len
		jsr   dzx5s_elias_loop
		pha
		ldx   len
		inx
		stx   offset+1
		bne   @+
		pla

		jmp to_exit	; koniec

@		jsr   _GET_BYTE
		sta   offset
		ldx   #$00
		stx   len+1
		inx
		stx   len
		pla
		dec   pnb
		bmi   @+
		jsr   dzx5s_elias_backtrack
@		inw   len
		jmp   dzx5s_copy

dzx5s_prev_offset
		asl   @
		bcc   dzx5s_second_offset
		ldy   offset2
		ldx   offset3
		sty   offset3
		stx   offset2
		ldy   offset2+1
		ldx   offset3+1
		sty   offset3+1
		stx   offset2+1

dzx5s_second_offset
		ldy   offset2
		ldx   offset
		sty   offset
		stx   offset2
		ldy   offset2+1
		ldx   offset+1
		sty   offset+1
		stx   offset2+1
		jmp   dzx5s_last_offset

dzx5s_elias	inc   len
dzx5s_elias_loop
		asl   @
		bne   dzx5s_elias_skip
		jsr   _GET_BYTE
		sec	; można usunąć jeśli dekompresja z pamięci a nie pliku
		rol   @
dzx5s_elias_skip
		bcc   dzx5s_elias_backtrack
		rts

dzx5s_elias_backtrack
		asl   @
		rol   len
		rol   len+1
		jmp   dzx5s_elias_loop

_GET_BYTE	lda    $ffff
ZX5_INPUT	equ    *-2
		inw    ZX5_INPUT
		rts

to_exit		ldx #0
@sp		equ *-1
end;

end.
