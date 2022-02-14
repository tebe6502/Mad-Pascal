
{$r blit.rc}

uses crt, graph, vbxe;

const
	sinustable: array [0..255] of byte = (
	$80, $7d, $7a, $77, $74, $70, $6d, $6a,
	$67, $64, $61, $5e, $5b, $58, $55, $52,
	$4f, $4d, $4a, $47, $44, $41, $3f, $3c,
	$39, $37, $34, $32, $2f, $2d, $2b, $28,
	$26, $24, $22, $20, $1e, $1c, $1a, $18,
	$16, $15, $13, $11, $10, $0f, $0d, $0c,
	$0b, $0a, $08, $07, $06, $06, $05, $04,
	$03, $03, $02, $02, $02, $01, $01, $01,
	$01, $01, $01, $01, $02, $02, $02, $03,
	$03, $04, $05, $06, $06, $07, $08, $0a,
	$0b, $0c, $0d, $0f, $10, $11, $13, $15,
	$16, $18, $1a, $1c, $1e, $20, $22, $24,
	$26, $28, $2b, $2d, $2f, $32, $34, $37,
	$39, $3c, $3f, $41, $44, $47, $4a, $4d,
	$4f, $52, $55, $58, $5b, $5e, $61, $64,
	$67, $6a, $6d, $70, $74, $77, $7a, $7d,
	$80, $83, $86, $89, $8c, $90, $93, $96,
	$99, $9c, $9f, $a2, $a5, $a8, $ab, $ae,
	$b1, $b3, $b6, $b9, $bc, $bf, $c1, $c4,
	$c7, $c9, $cc, $ce, $d1, $d3, $d5, $d8,
	$da, $dc, $de, $e0, $e2, $e4, $e6, $e8,
	$ea, $eb, $ed, $ef, $f0, $f1, $f3, $f4,
	$f5, $f6, $f8, $f9, $fa, $fa, $fb, $fc,
	$fd, $fd, $fe, $fe, $fe, $ff, $ff, $ff,
	$ff, $ff, $ff, $ff, $fe, $fe, $fe, $fd,
	$fd, $fc, $fb, $fa, $fa, $f9, $f8, $f6,
	$f5, $f4, $f3, $f1, $f0, $ef, $ed, $eb,
	$ea, $e8, $e6, $e4, $e2, $e0, $de, $dc,
	$da, $d8, $d5, $d3, $d1, $ce, $cc, $c9,
	$c7, $c4, $c1, $bf, $bc, $b9, $b6, $b3,
	$b1, $ae, $ab, $a8, $a5, $a2, $9f, $9c,
	$99, $96, $93, $90, $8c, $89, $86, $83
	);

	bonus = VBXE_OVRADR+320*256;				// adres bitmapy w pamięci VBXE, ladowana przez RESOURCE $R

	src0 = bonus + 0;
	src1 = bonus + 16;
	src2 = bonus + 16*2;
	src3 = bonus + 16*3;
	src4 = bonus + 16*4;
	src5 = bonus + 16*5;
	src6 = bonus + 16*6;
	src7 = bonus + 16*7;
	src8 = bonus + 16*8;
	src9 = bonus + 16*9;

	dst0 = VBXE_OVRADR+16*320+24;
	dst1 = VBXE_OVRADR+16*2*320+24;
	dst2 = VBXE_OVRADR+16*3*320+24;
	dst3 = VBXE_OVRADR+16*4*320+24;
	dst4 = VBXE_OVRADR+16*5*320+24;
	dst5 = VBXE_OVRADR+16*6*320+24;
	dst6 = VBXE_OVRADR+16*7*320+24;
	dst7 = VBXE_OVRADR+16*8*320+24;
	dst8 = VBXE_OVRADR+16*9*320+24;
	dst9 = VBXE_OVRADR+16*10*320+24;

var	i: byte;

	blit0: TBCB absolute VBXE_BCBADR+VBXE_WINDOW;
	blit1: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21;
	blit2: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*2;
	blit3: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*3;
	blit4: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*4;
	blit5: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*5;
	blit6: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*6;
	blit7: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*7;
	blit8: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*8;
	blit9: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*9;

	blit10: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*10;
	blit11: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*11;
	blit12: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*12;
	blit13: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*13;
	blit14: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*14;
	blit15: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*15;
	blit16: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*16;
	blit17: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*17;
	blit18: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*18;
	blit19: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*19;

	colbak: byte absolute $d01a;

	vram: TVBXEMemoryStream;


procedure InitBlit(var a: TBCB; src, dst: cardinal; ctr: byte);
begin

 fillbyte(a, sizeof(a), 0);

 a.src_adr.byte2:=src shr 16;
 a.src_adr.byte1:=src shr 8;
 a.src_adr.byte0:=src;

 a.dst_adr.byte2:=dst shr 16;
 a.dst_adr.byte1:=dst shr 8;
 a.dst_adr.byte0:=dst;

 a.src_step_x:=1;
 a.src_step_y:=256;

 a.dst_step_x:=1;
 a.dst_step_y:=320;

 a.blt_width:=16-1;
 a.blt_height:=16-1;

 a.blt_and_mask:=0;

 a.blt_zoom:=$01;

 a.blt_control:=ctr or 1;

end;


procedure MoveBlit(var a: TBCB; dst: cardinal);
begin

 a.dst_adr.byte2 := dst shr 16;
 a.dst_adr.byte1 := dst shr 8;
 a.dst_adr.byte0 := dst;

 a.blt_and_mask := $ff;

 inc(a.blt_control);
end;


begin

 InitGraph(mVBXE, 0, '');

 if GraphResult <> grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 for i:=1 to 23 do begin gotoxy(39,i); write(i) end;

 gotoXY(2,1);
 writeln('VBXE Blitter Demo');

 SetHorizontalRes(MedRes);

 vram.position:=VBXE_OVRADR;
 vram.size:=BONUS;		// size := $000000..BONUS
 vram.clear;

 vram.position:=VBXE_BCBADR;
 vram.SetBank;

 InitBlit(blit0, src0, dst0, %1000);
 InitBlit(blit1, src1, dst1, %1000);
 InitBlit(blit2, src2, dst2, %1000);
 InitBlit(blit3, src3, dst3, %1000);
 InitBlit(blit4, src4, dst4, %1000);
 InitBlit(blit5, src5, dst5, %1000);
 InitBlit(blit6, src6, dst6, %1000);
 InitBlit(blit7, src7, dst7, %1000);
 InitBlit(blit8, src8, dst8, %1000);
 InitBlit(blit9, src9, dst9, %1000);

 InitBlit(blit10, src9, dst0, %1000);
 InitBlit(blit11, src8, dst1, %1000);
 InitBlit(blit12, src7, dst2, %1000);
 InitBlit(blit13, src6, dst3, %1000);
 InitBlit(blit14, src5, dst4, %1000);
 InitBlit(blit15, src4, dst5, %1000);
 InitBlit(blit16, src3, dst6, %1000);
 InitBlit(blit17, src2, dst7, %1000);
 InitBlit(blit18, src1, dst8, %1000);
 InitBlit(blit19, src0, dst9, 0);

 i:=0;

 repeat

 colbak := 0;

 pause;

 colbak := $0f;

 blit0.blt_control := %1000;
 blit1.blt_control := %1000;
 blit2.blt_control := %1000;
 blit3.blt_control := %1000;
 blit4.blt_control := %1000;
 blit5.blt_control := %1000;
 blit6.blt_control := %1000;
 blit7.blt_control := %1000;
 blit8.blt_control := %1000;
 blit9.blt_control := %1000;

 blit10.blt_control := %1000;
 blit11.blt_control := %1000;
 blit12.blt_control := %1000;
 blit13.blt_control := %1000;
 blit14.blt_control := %1000;
 blit15.blt_control := %1000;
 blit16.blt_control := %1000;
 blit17.blt_control := %1000;
 blit18.blt_control := %1000;
 blit19.blt_control := 0;

 blit0.blt_and_mask := 0;		// Clear
 blit1.blt_and_mask := 0;
 blit2.blt_and_mask := 0;
 blit3.blt_and_mask := 0;
 blit4.blt_and_mask := 0;
 blit5.blt_and_mask := 0;
 blit6.blt_and_mask := 0;
 blit7.blt_and_mask := 0;
 blit8.blt_and_mask := 0;
 blit9.blt_and_mask := 0;

 blit10.blt_and_mask := 0;
 blit11.blt_and_mask := 0;
 blit12.blt_and_mask := 0;
 blit13.blt_and_mask := 0;
 blit14.blt_and_mask := 0;
 blit15.blt_and_mask := 0;
 blit16.blt_and_mask := 0;
 blit17.blt_and_mask := 0;
 blit18.blt_and_mask := 0;
 blit19.blt_and_mask := 0;

 RunBCB(Blit0);

 while BlitterBusy do;

 MoveBlit(blit0, dst0 + sinustable[i]);
 MoveBlit(blit1, dst1 + sinustable[i+16]);
 MoveBlit(blit2, dst2 + sinustable[i+16*2]);
 MoveBlit(blit3, dst3 + sinustable[i+16*3]);
 MoveBlit(blit4, dst4 + sinustable[i+16*4]);
 MoveBlit(blit5, dst5 + sinustable[i+16*5]);
 MoveBlit(blit6, dst6 + sinustable[i+16*6]);
 MoveBlit(blit7, dst7 + sinustable[i+16*7]);
 MoveBlit(blit8, dst8 + sinustable[i+16*8]);
 MoveBlit(blit9, dst9 + sinustable[i+16*9]);

 MoveBlit(blit10, dst0 + sinustable[i+16*10]);
 MoveBlit(blit11, dst1 + sinustable[i+16*11]);
 MoveBlit(blit12, dst2 + sinustable[i+16*12]);
 MoveBlit(blit13, dst3 + sinustable[i+16*13]);
 MoveBlit(blit14, dst4 + sinustable[i+16*14]);
 MoveBlit(blit15, dst5 + sinustable[i+16*15]);
 MoveBlit(blit16, dst6 + sinustable[i+16*16]);
 MoveBlit(blit17, dst7 + sinustable[i+16*17]);
 MoveBlit(blit18, dst8 + sinustable[i+16*18]);
 MoveBlit(blit19, dst9 + sinustable[i+16*19]);

 RunBCB(blit0);

 while BlitterBusy do;

 inc(i);

 until keypressed;

 VBXEOff;

end.

