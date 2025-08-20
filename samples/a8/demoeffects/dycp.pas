
// DYCP - Different Y Char Position

uses crt, atari;

const
	dlist = $af00;

	charset1 = $b000;
	charset2 = $b400;
	screen1 = $b800;
	screen2 = $bc00;

	charset_font = $e000;

	scrWidth = 40;

	fntLimit = 34;
	fntPosAdd = 3;

	dlistData: array [0..26] of byte =
	($70,$70,$70,$70,$70,
	$42+$30,lo(screen1),hi(screen1),	// +$30 hscrol
	$32,$32,$32,$32,$32,$32,$32,$32,
	$32,$32,$32,$32,$32,$32,$32,$32,
	$41,lo(dlist), hi(dlist));

    txt: PChar = '        DYCP     Different Y Char Position         '~ + #$ff;


    sinTable: array [0..255] of byte = (
    $80 shr 1, $7d shr 1, $7a shr 1, $77 shr 1, $74 shr 1, $70 shr 1, $6d shr 1, $6a shr 1,
    $67 shr 1, $64 shr 1, $61 shr 1, $5e shr 1, $5b shr 1, $58 shr 1, $55 shr 1, $52 shr 1,
    $4f shr 1, $4d shr 1, $4a shr 1, $47 shr 1, $44 shr 1, $41 shr 1, $3f shr 1, $3c shr 1,
    $39 shr 1, $37 shr 1, $34 shr 1, $32 shr 1, $2f shr 1, $2d shr 1, $2b shr 1, $28 shr 1,
    $26 shr 1, $24 shr 1, $22 shr 1, $20 shr 1, $1e shr 1, $1c shr 1, $1a shr 1, $18 shr 1,
    $16 shr 1, $15 shr 1, $13 shr 1, $11 shr 1, $10 shr 1, $0f shr 1, $0d shr 1, $0c shr 1,
    $0b shr 1, $0a shr 1, $08 shr 1, $07 shr 1, $06 shr 1, $06 shr 1, $05 shr 1, $04 shr 1,
    $03 shr 1, $03 shr 1, $02 shr 1, $02 shr 1, $02 shr 1, $01 shr 1, $01 shr 1, $01 shr 1,
    $01 shr 1, $01 shr 1, $01 shr 1, $01 shr 1, $02 shr 1, $02 shr 1, $02 shr 1, $03 shr 1,
    $03 shr 1, $04 shr 1, $05 shr 1, $06 shr 1, $06 shr 1, $07 shr 1, $08 shr 1, $0a shr 1,
    $0b shr 1, $0c shr 1, $0d shr 1, $0f shr 1, $10 shr 1, $11 shr 1, $13 shr 1, $15 shr 1,
    $16 shr 1, $18 shr 1, $1a shr 1, $1c shr 1, $1e shr 1, $20 shr 1, $22 shr 1, $24 shr 1,
    $26 shr 1, $28 shr 1, $2b shr 1, $2d shr 1, $2f shr 1, $32 shr 1, $34 shr 1, $37 shr 1,
    $39 shr 1, $3c shr 1, $3f shr 1, $41 shr 1, $44 shr 1, $47 shr 1, $4a shr 1, $4d shr 1,
    $4f shr 1, $52 shr 1, $55 shr 1, $58 shr 1, $5b shr 1, $5e shr 1, $61 shr 1, $64 shr 1,
    $67 shr 1, $6a shr 1, $6d shr 1, $70 shr 1, $74 shr 1, $77 shr 1, $7a shr 1, $7d shr 1,
    $80 shr 1, $83 shr 1, $86 shr 1, $89 shr 1, $8c shr 1, $90 shr 1, $93 shr 1, $96 shr 1,
    $99 shr 1, $9c shr 1, $9f shr 1, $a2 shr 1, $a5 shr 1, $a8 shr 1, $ab shr 1, $ae shr 1,
    $b1 shr 1, $b3 shr 1, $b6 shr 1, $b9 shr 1, $bc shr 1, $bf shr 1, $c1 shr 1, $c4 shr 1,
    $c7 shr 1, $c9 shr 1, $cc shr 1, $ce shr 1, $d1 shr 1, $d3 shr 1, $d5 shr 1, $d8 shr 1,
    $da shr 1, $dc shr 1, $de shr 1, $e0 shr 1, $e2 shr 1, $e4 shr 1, $e6 shr 1, $e8 shr 1,
    $ea shr 1, $eb shr 1, $ed shr 1, $ef shr 1, $f0 shr 1, $f1 shr 1, $f3 shr 1, $f4 shr 1,
    $f5 shr 1, $f6 shr 1, $f8 shr 1, $f9 shr 1, $fa shr 1, $fa shr 1, $fb shr 1, $fc shr 1,
    $fd shr 1, $fd shr 1, $fe shr 1, $fe shr 1, $fe shr 1, $ff shr 1, $ff shr 1, $ff shr 1,
    $ff shr 1, $ff shr 1, $ff shr 1, $ff shr 1, $fe shr 1, $fe shr 1, $fe shr 1, $fd shr 1,
    $fd shr 1, $fc shr 1, $fb shr 1, $fa shr 1, $fa shr 1, $f9 shr 1, $f8 shr 1, $f6 shr 1,
    $f5 shr 1, $f4 shr 1, $f3 shr 1, $f1 shr 1, $f0 shr 1, $ef shr 1, $ed shr 1, $eb shr 1,
    $ea shr 1, $e8 shr 1, $e6 shr 1, $e4 shr 1, $e2 shr 1, $e0 shr 1, $de shr 1, $dc shr 1,
    $da shr 1, $d8 shr 1, $d5 shr 1, $d3 shr 1, $d1 shr 1, $ce shr 1, $cc shr 1, $c9 shr 1,
    $c7 shr 1, $c4 shr 1, $c1 shr 1, $bf shr 1, $bc shr 1, $b9 shr 1, $b6 shr 1, $b3 shr 1,
    $b1 shr 1, $ae shr 1, $ab shr 1, $a8 shr 1, $a5 shr 1, $a2 shr 1, $9f shr 1, $9c shr 1,
    $99 shr 1, $96 shr 1, $93 shr 1, $90 shr 1, $8c shr 1, $89 shr 1, $86 shr 1, $83 shr 1
    );

var
	pos, hsc, ichr: byte;
	screen, charset: word;

	rowScrAdr: array [0..29] of word;

	ptxt: ^char;

	chrAdr: array [0..255] of byte;


procedure RenderChars;
var i, py, y, dy, ch, psin: byte;
    pscr, pchr, schr: ^byte;
    scr: word;
begin

 scr:=screen;

 poke(dlist+7, hi(screen xor (screen1 xor screen2)));
 chbas:=hi(charset xor (charset1 xor charset2));
 chbase:=chbas;

 ch:=1;
 psin:=pos;
 pchr:=pointer(charset + 8);

 charset:=chbas shl 8;
 screen:=peek(dlist+7) shl 8;

 for i:=0 to fntLimit-1 do begin

  py:=sinTable[psin];
  y:= py shr 3;
  dy:= py and 7;

  pscr:=pointer(scr + rowScrAdr[y]);

  schr:=pointer(charset_font + chrAdr[i+ichr] * 8);

  asm
  	mwa pchr bp2
  end;

  case dy of
  0:
	asm
		ldy #8
		lda #0
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
	end;

  1:
	asm
		ldy #0
		tya
		sta (bp2),y

		ldy #9
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
	end;

  2:
	asm
		ldy #0
		tya
		sta (bp2),y
		iny
		sta (bp2),y

		ldy #10
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
	end;

  3:
	asm
		ldy #0
		tya
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y

		ldy #11
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
	end;

  4:
	asm
		ldy #0
		tya
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y

		ldy #12
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
	end;

  5:
	asm
		ldy #0
		tya
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y

		ldy #13
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
	end;

  6:
	asm
		ldy #0
		tya
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y

		ldy #14
		sta (bp2),y
		iny
		sta (bp2),y
	end;

  7:
	asm
		ldy #0
		tya
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y
		iny
		sta (bp2),y

		ldy #15
		sta (bp2),y
	end;
  end;


 asm
 	mwa schr eax

	lda pchr
	add dy
	sta bp2
	lda pchr+1
	adc #0
	sta bp2+1

	ldy #0
	lda (eax),y
	sta (bp2),y
	iny
	lda (eax),y
	sta (bp2),y
	iny
	lda (eax),y
	sta (bp2),y
	iny
	lda (eax),y
	sta (bp2),y
	iny
	lda (eax),y
	sta (bp2),y
	iny
	lda (eax),y
	sta (bp2),y
	iny
	lda (eax),y
	sta (bp2),y
	iny
	lda (eax),y
	sta (bp2),y

	mwa pscr bp2
end;

	case y of
	 0: ;
	 1:
		asm
			sbw bp2 #scrWidth eax

			ldy #0
			tya
			sta (eax),y
		end;

	 2:
		asm
			sbw bp2 #scrWidth*2 eax

			ldy #0
			tya
			sta (eax),y

			ldy #scrWidth
			sta (eax),y
		end;
	else
		asm
			sbw bp2 #scrWidth*3 eax

			ldy #0
			tya
			sta (eax),y

			ldy #scrWidth
			sta (eax),y

			ldy #scrWidth*2
			sta (eax),y
		end;
	end;

asm
	lda ch
	ldy #0
	sta (bp2),y

	add #1

	ldy #scrWidth
	sta (bp2),y

	adc #1
	sta ch
end;

	case y of
	 13:
		asm
			lda #0
			ldy #scrWidth*2
			sta (bp2),y

			ldy #scrWidth*3
			sta (bp2),y
		end;

	 14:
		asm
			lda #0
			ldy #scrWidth*2
			sta (bp2),y
		end;
	 15: ;

	else
		asm
			lda #0
			ldy #scrWidth*2
			sta (bp2),y

			ldy #scrWidth*3
			sta (bp2),y

			ldy #scrWidth*4
			sta (bp2),y
		end;

	end;


  inc(scr);
  inc(pchr, 16);

  inc(psin, 5);
 end;

 inc(pos,2);

end;


procedure Init;
var i: byte;
begin

 move(dlistData, pointer(dlist), sizeof(dlistData));	// DisplayList Initialization
 sdlstl:=dlist;

 sdmctl:=(sdmctl and $fc) or 1;				// narrow screen

 for i:=0 to High(rowScrAdr) do rowScrAdr[i]:=i * scrWidth + fntPosAdd;

 for i:=0 to scrWidth-1 do chrAdr[i] := 0;

 fillchar(pointer(screen1), 21*48, 0);
 fillchar(pointer(screen2), 21*48, 0);

end;


begin

 Init;

 screen := screen1;
 charset := charset1;

 hsc:=3;
 ichr:=0;

 ptxt:=txt;

 repeat

  poke($d01a, 0);

  pause;

  poke($d01a, 14);

  hscrol:=hsc;

  dec(hsc);
  if hsc=$ff then begin
   hsc:=3;
   inc(pos, 4);

   chrAdr[ichr+fntLimit] := ord(ptxt^);			// ring buffer
   inc(ptxt);

   if ptxt^ = #$ff then ptxt:=txt;

   inc(ichr);
  end;

  RenderChars;

 until keypressed;

end.
