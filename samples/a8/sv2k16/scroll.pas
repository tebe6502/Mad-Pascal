uses crt, vbxe, rmt;

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

	wf = 256;		// font bitmap width

	step = 26;

	ov_step = 384;		// overlay step

	VBXE_OVRADR2 = VBXE_OVRADR+ov_step*240;

	buf0 = VBXE_OVRADR+32;
	buf1 = VBXE_OVRADR2+32;

	fonts	= VBXE_OVRADR2+ov_step*240;
	logo	= fonts+wf*192;

	modul	= $5000;	// rmt modul
	player	= $8000;	// rmt player

	fnt_order: array [0..34] of word = (
	32*wf, 64*wf, 96*wf, 128*wf, 160*wf,
	32, 32+32*wf, 32+64*wf, 32+96*wf, 32+128*wf, 32+160*wf,
	32*2, 32*2+32*wf, 32*2+64*wf, 32*2+96*wf, 32*2+128*wf, 32*2+160*wf,
	32*3, 32*3+32*wf, 32*3+64*wf, 32*3+96*wf, 32*3+128*wf, 32*3+160*wf,
	32*4, 32*4+32*wf, 32*4+64*wf, 32*4+96*wf, 32*4+128*wf, 32*4+160*wf,
	32*5, 32*5+32*wf, 32*5+64*wf, 32*5+96*wf, 32*5+128*wf, 32*5+160*wf+1+wf
	);

	dig_order: array [0..9] of word = (
	6*32, 6*32+wf*32, 6*32+wf*64, 6*32+wf*96, 6*32+wf*128, 6*32+wf*160,
	7*32, 7*32+wf*32, 7*32+wf*64, 7*32+wf*96+1+wf
	);

	txt =
	'       '+
	'Howdy Atari Cowboys! Here we strike once again with another invitation for the biggest '+
	'Atari demoscene event in Europe! Silly Venture - the most maverick and unconventional '+
	'event on this planet, where the international Atari community from the Atari 2600 '+
	'through the XL/XE, ST/STe, Falcon, as well as the handheld Atari Lynx console and the '+
	'64-bit beast that is the Atari Jaguar meet to celebrate another year of survival from '+
	'oblivion! Come to the north of Poland between the 11th and 13th (Friday to Sunday) of '+
	'November 2016 and feel the heartbeat of the Atari scene, which is still alive and kicking! '+
	'Help us to keep the Atari flag on top as in years past, or raise it even higher! How? '+
	'Just take part in any compo category and let''s try to break the SV2k14 record '+
	'(over 120 entries!). You can win some really cool Atari-related prizes and everlasting '+
	'fame in the Atari scene!  Remember: the name of adventure is Silly Venture! '+
	'Atari, beers, concerts, girls and hours spent during compo night! More information about '+
	'the party can be found on the official SV2k16 website: www.sillyventure.eu'+
	'           Msx: wiecz0r    Text: Grey    Code: Tebe (MadPascal)       '+#255;

var
	[striped] sinScrol, sinLogo: array [0..255] of cardinal;

	msx: TRMT;

	xdl: TXDL absolute VBXE_XDLADR+VBXE_WINDOW;

	blt: TBCB absolute VBXE_BCBADR+VBXE_WINDOW;

	chr0: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21;
	chr1: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*2;
	chr2: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*3;
	chr3: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*4;
	chr4: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*5;
	chr5: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*6;
	chr6: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*7;
	chr7: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*8;
	chr8: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*9;
	chr9: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*10;
	chr10: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*11;
	chr11: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*12;
	chr12: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*13;
	chr13: TBCB absolute VBXE_BCBADR+VBXE_WINDOW+21*14;

	i, j, hsc, ntsc: byte;

	x, base, scrol_base, scrl: cardinal;

	palntsc: byte absolute $d014;

	old_vbl: pointer;

	a: char;
	ptxt: ^char;

	vram: TVBXEMemoryStream;

{$r scroll.rc}


procedure vbl_ntsc; interrupt;
begin

	if ntsc=6 then
	 ntsc:=0
	else
	 msx.play;

	inc(ntsc);

asm
{	jmp xitvbv
};
end;


procedure vbl_pal; interrupt;
begin

	 msx.play;

asm
{	jmp xitvbv
};
end;


begin

 for i:=0 to 127 do begin
  sinScrol[i]:=(sinusTable[i shl 1] shr 1)*ov_step + 16*ov_step;
  sinScrol[i+128]:=sinScrol[i];
 end;

 for i:=0 to 255 do sinLogo[i]:=logo + sinusTable[i] + (sinusTable[i shl 1] shr 1)*560;

 if VBXE.GraphResult <> VBXE.grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 SetHRes(VBXE.VGAMed);
 ColorMapOff;

 msx.player:=pointer(player);
 msx.modul:=pointer(modul);

 msx.init(0);

 poke(559, 0);		// dma disable

 ptxt:=pointer(txt);

 hsc:=step-1;

 base:=buf0;
 scrol_base:=VBXE_OVRADR;

 vram.position:=VBXE_XDLADR;
 vram.SetBank;

 xdl.ov_step:=ov_step;

 vram.position:=VBXE_BCBADR;
 vram.SetBank;

 IniBCB(blt, logo, VBXE_OVRADR, 560, ov_step, 320-1, 192-1, %1000);		// copy logo

 IniBCB(chr0, fonts, VBXE_OVRADR, wf, ov_step, 32-1, 32-1, %1001);		// copy scroll fonts
 chr1:=chr0;
 chr2:=chr0;
 chr3:=chr0;
 chr4:=chr0;
 chr5:=chr0;
 chr6:=chr0;
 chr7:=chr0;
 chr8:=chr0;
 chr9:=chr0;
 chr10:=chr0;
 chr11:=chr0;
 chr12:=chr0;
 chr13:=chr0; chr13.blt_control:=1;	// = %0001 last program blitter


 GetIntVec(iVBLI, old_vbl);


 if palntsc=1 then
  SetIntVec(iVBL, @vbl_pal)
 else
  SetIntVec(iVBL, @vbl_ntsc);

 i:=0;

 repeat
	pause;

	vram.position:=VBXE_XDLADR;
	vram.SetBank;

	xdl.ov_adr.byte2 := base shr 16;
	xdl.ov_adr.byte1 := base shr 8;
	xdl.ov_adr.byte0 := base;

	vram.position:=VBXE_BCBADR;
	vram.SetBank;

	if hsc=step-1 then begin

		chr0.src_adr := chr1.src_adr;
		chr1.src_adr := chr2.src_adr;
		chr2.src_adr := chr3.src_adr;
		chr3.src_adr := chr4.src_adr;
		chr4.src_adr := chr5.src_adr;
		chr5.src_adr := chr6.src_adr;
		chr6.src_adr := chr7.src_adr;
		chr7.src_adr := chr8.src_adr;
		chr8.src_adr := chr9.src_adr;
		chr9.src_adr := chr10.src_adr;
		chr10.src_adr := chr11.src_adr;
		chr11.src_adr := chr12.src_adr;
		chr12.src_adr := chr13.src_adr;

		a:=UpCase(ptxt^);
		x:=fonts;

		case a of
		'A'..'Z': x := fonts + fnt_order[ord(a)-ord('A')];
		'0'..'9': x := fonts + dig_order[ord(a)-ord('0')];
		     ' ': x := fonts;
		     '.': x := fonts+4*32+wf*32*3;
		     ',': x := fonts+4*32+wf*32*4;
		    '''': x := fonts+4*32+wf*32*5;
		     '!': x := fonts+5*32;
		     '?': x := fonts+5*32+wf*32*1;
		     '-': x := fonts+5*32+wf*32*2;
		     ':': x := fonts+5*32+wf*32*3;
	     '(',')','/': x := fonts+5*32+wf*32*4;
		 #255: ptxt := pointer(txt);
		end;

		chr13.src_adr.byte2 := x shr 16;
		chr13.src_adr.byte1 := x shr 8;
		chr13.src_adr.byte0 := x;

		inc(ptxt);
	end;

	base:=base xor (buf0 xor buf1);
	scrol_base:=scrol_base xor (VBXE_OVRADR xor VBXE_OVRADR2);

	scrl:=scrol_base+hsc;

	x:=sinLogo[i];

	blt.src_adr.byte2 := x shr 16;
	blt.src_adr.byte1 := x shr 8;
	blt.src_adr.byte0 := x;

	blt.dst_adr.byte2 := base shr 16;
	blt.dst_adr.byte1 := base shr 8;
	blt.dst_adr.byte0 := base;


	x:=scrl+sinScrol[j];
	chr0.dst_adr.byte2 := x shr 16;
	chr0.dst_adr.byte1 := x shr 8;
	chr0.dst_adr.byte0 := x;

	x:=scrl+step+sinScrol[j+8];
	chr1.dst_adr.byte2 := x shr 16;
	chr1.dst_adr.byte1 := x shr 8;
	chr1.dst_adr.byte0 := x;

	x:=scrl+step*2+sinScrol[j+8*2];
	chr2.dst_adr.byte2 := x shr 16;
	chr2.dst_adr.byte1 := x shr 8;
	chr2.dst_adr.byte0 := x;

	x:=scrl+step*3+sinScrol[j+8*3];
	chr3.dst_adr.byte2 := x shr 16;
	chr3.dst_adr.byte1 := x shr 8;
	chr3.dst_adr.byte0 := x;

	x:=scrl+step*4+sinScrol[j+8*4];
	chr4.dst_adr.byte2 := x shr 16;
	chr4.dst_adr.byte1 := x shr 8;
	chr4.dst_adr.byte0 := x;

	x:=scrl+step*5+sinScrol[j+8*5];
	chr5.dst_adr.byte2 := x shr 16;
	chr5.dst_adr.byte1 := x shr 8;
	chr5.dst_adr.byte0 := x;

	x:=scrl+step*6+sinScrol[j+8*6];
	chr6.dst_adr.byte2 := x shr 16;
	chr6.dst_adr.byte1 := x shr 8;
	chr6.dst_adr.byte0 := x;

	x:=scrl+step*7+sinScrol[j+8*7];
	chr7.dst_adr.byte2 := x shr 16;
	chr7.dst_adr.byte1 := x shr 8;
	chr7.dst_adr.byte0 := x;

	x:=scrl+step*8+sinScrol[j+8*8];
	chr8.dst_adr.byte2 := x shr 16;
	chr8.dst_adr.byte1 := x shr 8;
	chr8.dst_adr.byte0 := x;

	x:=scrl+step*9+sinScrol[j+8*9];
	chr9.dst_adr.byte2 := x shr 16;
	chr9.dst_adr.byte1 := x shr 8;
	chr9.dst_adr.byte0 := x;

	x:=scrl+step*10+sinScrol[j+8*10];
	chr10.dst_adr.byte2 := x shr 16;
	chr10.dst_adr.byte1 := x shr 8;
	chr10.dst_adr.byte0 := x;

	x:=scrl+step*11+sinScrol[j+8*11];
	chr11.dst_adr.byte2 := x shr 16;
	chr11.dst_adr.byte1 := x shr 8;
	chr11.dst_adr.byte0 := x;

	x:=scrl+step*12+sinScrol[j+8*12];
	chr12.dst_adr.byte2 := x shr 16;
	chr12.dst_adr.byte1 := x shr 8;
	chr12.dst_adr.byte0 := x;

	x:=scrl+step*13+sinScrol[j+8*13];
	chr13.dst_adr.byte2 := x shr 16;
	chr13.dst_adr.byte1 := x shr 8;
	chr13.dst_adr.byte0 := x;

	RunBCB(blt);

//	while BlitterBusy do;

	dec(hsc);

	if hsc=$ff then begin
		hsc:=step-1;
		inc(j,7);
	end;

	inc(i);

	inc(j); j:=j and $7f;

 until keypressed;

 poke(559, 34);

 SetIntVec(iVBL, old_vbl);

 msx.stop;

 VBXEOff;

end.
