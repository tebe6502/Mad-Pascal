// 6502 MOD Player 2.0 (VBL, IRQ) 15.6 kHz
// pattern limit = 37
// sample length limit = 16384 bytes

// volume $de00 - $feff

// playloop		= $0000
// mainloop		= $0400..$5ff


program ModPlay;

uses crt, atari, objects;


{$r modplay.rc}


type

	TName = array [0..21] of char;

	TSample = packed record
			name		: TName;
			len		: word;
			fine_tune,
			volume		: byte;
			loop_start,
			loop_len	: word;
		end;

	TPSample = ^TSample;


const
	COVOX	= $d600;

	PATTERN_LIMIT = 37;
	SAMPLE_LIMIT = 31;

	ZPAGE	= $db00;		// kopia strony zerowej
	EFFECT	= $dc00;		// dekodowaniu kodu dla efektu sampla
	TADCL	= $dd00;		// mlodsze bajty przyrostu offsetu dla sampla (nuta)
	TADCH	= TADCL + $30;		// starsze bajty przyrostu offsetu dla sampla (nuta)

	VOLUME	= $de00;		// 33 tablice glosnosci (pierwsza tablica zawiera same zera)

	pattern_start = $4000;		// $4000 + $300 * PATTERN_LIMIT
	sample_start = $4000;
	sample_len = $4000;


	KOD : array [0..47] of word = (
	$6b0,$650,$5f4,$5a0,
	$54c,$500,$4b8,$474,
	$434,$3f8,$3c0,$380,
	$358,$328,$2fa,$2d0,
	$2a6,$280,$25c,$23a,
	$21a,$1fc,$1e0,$1c5,
	$1ac,$194,$17d,$168,
	$153,$140,$12e,$11d,
	$10d,$fe,$f0,$e2,
	$d6,$ca,$be,$b4,
	$aa,$a0,$97,$8f,
	$87,$7f,$78,$71
	);

var
	BUF: array [0..255] of byte absolute $0500;

	TIVOL: array [0..31] of byte absolute $0150;	// starszy adres glosnosci tablicy VOLUME = glosnosc SAMPLA

	ORDER: array [0..127] of byte absolute $0600;	// tablica SONG ORDER
	TSTRL: array [0..31] of byte absolute $0680;	// mlodszy bajt adresu poczatkowego sampla
	TSTRH: array [0..31] of byte absolute $06A0;	// starszy bajt adresu poczatkowego sampla
	TREPL: array [0..31] of byte absolute $06C0;	// mlodszy bajt adresu powtorzenia sampla
	TREPH: array [0..31] of byte absolute $06E0;	// starszy bajt adresu powtorzenia sampla

	ModName: array [0..19+1] of char;

	sampl_0, sampl_1, sampl_2, sampl_3, sampl_4,
	sampl_5, sampl_6, sampl_7, sampl_8, sampl_9,
	sampl_10, sampl_11, sampl_12, sampl_13,
	sampl_14, sampl_15, sampl_16, sampl_17,
	sampl_18, sampl_19, sampl_20, sampl_21,
	sampl_22, sampl_23, sampl_24, sampl_25,
	sampl_26, sampl_27, sampl_28, sampl_29, sampl_30: TSample;

	Sample: array [0..30] of pointer = (
	@sampl_0, @sampl_1, @sampl_2, @sampl_3, @sampl_4,
	@sampl_5, @sampl_6, @sampl_7, @sampl_8, @sampl_9,
	@sampl_10, @sampl_11, @sampl_12, @sampl_13,
	@sampl_14, @sampl_15, @sampl_16, @sampl_17,
	@sampl_18, @sampl_19, @sampl_20, @sampl_21,
	@sampl_22, @sampl_23, @sampl_24, @sampl_25,
	@sampl_26, @sampl_27, @sampl_28, @sampl_29, @sampl_30);

	gchar: char;

	SONG_LENGTH,
	SONG_RESTART,
	NUMBER_OF_PATTERNS,
	NUMBER_OF_BANKS,
	NUMBER_OF_SAMPLES	: byte;


procedure Play(pokey: Boolean); assembler;
asm
{

.zpvar = $d8

.zpvar nr0, nr1, nr2, nr3, patno, patend, cnts, pause, track_pos .byte
.zpvar pat0, pat1, pat2 .word

	stx _rx

	jsr wait

	sei

	lda #$00
	sta nmien
	sta irqen

	mva #$fe portb

	ldx #0
	mva:rne 0,x ZPAGE,x+

	ldx #0
mv0	lda .adr(playloop),x
	sta playloop,x
	inx
	cpx #.sizeof(playloop)
	bne mv0

	ldx #0
mv1	lda .adr(mainloop),x
	sta mainloop,x
	lda .adr(mainloop)+$100,x
	sta mainloop+$100,x
	inx
	bne mv1

	lda SONG_LENGTH
	sta mainloop.patmax+1

;	lda SONG_RESTART
;	sta mainloop.patres+1

	lda >volume		; silence
	sta playloop.ivol10+2
	sta playloop.ivol11+2
	sta playloop.ivol12+2
	sta playloop.ivol13+2

	lda POKEY
	bne skip

	lda >COVOX		; covox
	sta playloop.ch0+2
	sta playloop.ch1+2
	sta playloop.ch2+2
	sta playloop.ch3+2

	ldy #0
	sty playloop.ch0+1
	iny
	sty playloop.ch1+1
	iny
	sty playloop.ch2+1
	iny
	sty playloop.ch3+1

	jmp start

skip	lda >VOLUME
	sta av0+1
	sta av1+1

	ldx #32			; POKEY volume table
	ldy #0
mvol	lda VOLUME,y
av0	equ *-2
	:4 lsr @
	ora #$10
	sta VOLUME,y
av1	equ *-2
	iny
	bne mvol

	inc av0+1
	inc av1+1
	dex
	bpl mvol

start	lda #0

	sta $d400

	sta patno
	sta track_pos

	sta pat0
	sta pat1
	sta pat2

	lda #6
	sta pause
	sta cnts

	ldy adr.ORDER
	sty pat0+1
	iny
	sty pat1+1
	iny
	sty pat2+1

	mwa	#mainloop nmivec	; custom NMI handler
	mwa	#playloop irqvec	; custom IRQ handler

	mva	#1	AUDCTL		; 0=POKEY 64KHz, 1=15KHz

	mva	#0	AUDC4		; test - no polycounters + volume only
	mva	#0	AUDF4		; line-1 (0 = 1 line)

	jsr wait

	mva	#$40	nmien

	mva	#$00	SKCTL
	mva	#$03	SKCTL		; test - reset pokey and polycounters
	sta	STIMER			; start timers
	cli

	mva #4 IRQEN

	jmp stop


.local	playloop,0

	sta regA
	stx regX

bank0	lda #$fe		; ch #0
	sta portb

p_0c	ldx $ffff
ivol10	lda volume,x
ch0	sta audc1

bank1	lda #$fe		; ch #1
	sta portb

p_1c	ldx $ffff
ivol11	lda volume,x
ch1	sta audc2

bank2	lda #$fe		; ch #2
	sta portb

p_2c	ldx $ffff
ivol12	lda volume,x
ch2	sta audc3

bank3	lda #$fe		; ch #3
	sta portb

p_3c	ldx $ffff
ivol13	lda volume,x
ch3	sta audc4


; ---
; ---	AUDC 1
; ---

ist_0	lda #0
iad0_m	adc #0
	sta ist_0+1
	lda p_0c+1
iad0_s	adc #0
	bcc ext_0

	inc p_0c+2
	bpl ext_0

ire0_s	lda #0
	sta p_0c+2
ire0_m	lda #0

ext_0	sta p_0c+1

; ---
; ---	AUDC 2
; ---

ist_1	lda #0
iad1_m	adc #0
	sta ist_1+1
	lda p_1c+1
iad1_s	adc #0
	bcc ext_1

	inc p_1c+2
	bpl ext_1

ire1_s	lda #0
	sta p_1c+2
ire1_m	lda #0

ext_1	sta p_1c+1

; ---
; ---	AUDC 3
; ---

ist_2	lda #0
iad2_m	adc #0
	sta ist_2+1
	lda p_2c+1
iad2_s	adc #0
	bcc ext_2

	inc p_2c+2
	bpl ext_2

ire2_s	lda #0
	sta p_2c+2
ire2_m	lda #0

ext_2	sta p_2c+1

; ---
; ---	AUDC 4
; ---

ist_3	lda #0
iad3_m	adc #0
	sta ist_3+1
	lda p_3c+1
iad3_s	adc #0
	bcc ext_3

	inc p_3c+2
	bpl ext_3

ire3_s	lda #0
	sta p_3c+2
ire3_m	lda #0

ext_3	sta p_3c+1

	mva #0 IRQEN
	mva #4 IRQEN

	lda #0
regA	equ *-1
	ldx #0
regX	equ *-1

	rti

.endl


.local	mainloop,$0400

	bit nmist
	bpl vbl

exit	rti

vbl	dec cnts
	bne exit

	sta regA
	stx regX
	sty regY

	lda #0
	sta patend

	lda #$fe
	sta portb

	ldy track_pos

*---------------------------
* track  0

i_0	;ldy #1
	lda (pat1),y
	sta i_0c+1
	and #$1f
	beq i_0c
	tax
	sta nr0
	lda adr.tivol-1,x
	sta playloop.ivol10+2

i_0c	ldx EFFECT
	beq i_0f
	cpx #$40
	bne @+
	;ldy #2
	lda (pat2),y
	sta playloop.ivol10+2
@	cpx #$c0
	bne @+
	;ldy #2
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_0f
	stx patend

i_0f	;ldy #0
	lda (pat0),y
	beq i_1
	tax
	lda tadcl-1,x
	sta playloop.iad0_m+1
	lda tadch-1,x
	sta playloop.iad0_s+1

;	lda #0
;	sta playloop.ist_0+1

	ldx nr0
	lda main.misc.adr.banks-1,x
	sta playloop.bank0+1

	lda adr.tstrl-1,x
	sta playloop.p_0c+1
	lda adr.tstrh-1,x
	sta playloop.p_0c+2

	lda adr.trepl-1,x
	sta playloop.ire0_m+1
	lda adr.treph-1,x
	sta playloop.ire0_s+1

* track 1

i_1	iny

	;ldy #4
	lda (pat1),y
	sta i_1c+1
	and #$1f
	beq i_1c
	tax
	sta nr1
	lda adr.tivol-1,x
	sta playloop.ivol11+2

i_1c	ldx EFFECT
	beq i_1f
	cpx #$40
	bne @+
	;ldy #5
	lda (pat2),y
	sta playloop.ivol11+2
@	cpx #$c0
	bne @+
	;ldy #5
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_1f
	stx patend

i_1f	;ldy #3
	lda (pat0),y
	beq i_2
	tax
	lda tadcl-1,x
	sta playloop.iad1_m+1
	lda tadch-1,x
	sta playloop.iad1_s+1

;	lda #0
;	sta playloop.ist_1+1

	ldx nr1
	lda main.misc.adr.banks-1,x
	sta playloop.bank1+1

	lda adr.tstrl-1,x
	sta playloop.p_1c+1
	lda adr.tstrh-1,x
	sta playloop.p_1c+2

	lda adr.trepl-1,x
	sta playloop.ire1_m+1
	lda adr.treph-1,x
	sta playloop.ire1_s+1

* track 2

i_2	iny

	;ldy #7
	lda (pat1),y
	sta i_2c+1
	and #$1f
	beq i_2c
	tax
	sta nr2
	lda adr.tivol-1,x
	sta playloop.ivol12+2

i_2c	ldx EFFECT
	beq i_2f
	cpx #$40
	bne @+
	;ldy #8
	lda (pat2),y
	sta playloop.ivol12+2
@	cpx #$c0
	bne @+
	;ldy #8
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_2f
	stx patend

i_2f	;ldy #6
	lda (pat0),y
	beq i_3
	tax
	lda tadcl-1,x
	sta playloop.iad2_m+1
	lda tadch-1,x
	sta playloop.iad2_s+1

;	lda #0
;	sta playloop.ist_2+1

	ldx nr2
	lda main.misc.adr.banks-1,x
	sta playloop.bank2+1

	lda adr.tstrl-1,x
	sta playloop.p_2c+1
	lda adr.tstrh-1,x
	sta playloop.p_2c+2

	lda adr.trepl-1,x
	sta playloop.ire2_m+1
	lda adr.treph-1,x
	sta playloop.ire2_s+1

* track 3

i_3	iny

	;ldy #10
	lda (pat1),y
	sta i_3c+1
	and #$1f
	beq i_3c
	tax
	sta nr3
	lda adr.tivol-1,x
	sta playloop.ivol13+2

i_3c	ldx EFFECT
	beq i_3f
	cpx #$40
	bne @+
	;ldy #11
	lda (pat2),y
	sta playloop.ivol13+2
@	cpx #$c0
	bne @+
	;ldy #11
	lda (pat2),y
	sta pause
@	cpx #$80
	bne i_3f
	stx patend

i_3f	;ldy #9
	lda (pat0),y
	beq i_e
	tax
	lda tadcl-1,x
	sta playloop.iad3_m+1
	lda tadch-1,x
	sta playloop.iad3_s+1

;	lda #0
;	sta playloop.ist_3+1

	ldx nr3
	lda main.misc.adr.banks-1,x
	sta playloop.bank3+1

	lda adr.tstrl-1,x
	sta playloop.p_3c+1
	lda adr.tstrh-1,x
	sta playloop.p_3c+2

	lda adr.trepl-1,x
	sta playloop.ire3_m+1
	lda adr.treph-1,x
	sta playloop.ire3_s+1

i_e
	lda patend
	bne i_en

	iny
	sty track_pos
	bne i_end

i_en	inc patno
	ldx patno
patmax	cpx #0
	bcc i_ens

	lda #6
	sta pause
patres	ldx #0
	stx patno

i_ens	ldy adr.ORDER,x
	sty pat0+1
	iny
	sty pat1+1
	iny
	sty pat2+1

	lda #0
	sta track_pos

i_end
	lda pause
	sta cnts

	lda $d20f
	and #4
	bne skp

	lda #$2c	; bit *
	sta stop

skp
	lda #0
regA	equ *-1
	ldx #0
regX	equ *-1
	ldy #0
regY	equ *-1

	rti

.endl


wait	lda skstat		; wait on keypress
	and #4
	beq wait

	lda #$70
	cmp:rne vcount
	rts


stop	jmp *

	jsr wait

	sei
	lda #0
	sta AUDCTL
	sta NMIEN
	sta IRQEN

	ldx #0
	mva:rne ZPAGE,x 0,x+

	lda #$ff
	sta portb

	lda irqens
	sta IRQEN

	mva #$40 nmien
	cli

	ldx #0
_rx	equ *-1

};
end;


function CnvPattern: cardinal; assembler;
asm
{
	lda #0
	sta Result
	sta Result+1
	sta Result+2
	sta Result+3

	lda adr.BUF
	and #$f
	ora adr.BUF+1
	beq _sil

	ldy #0
_tst	lda adr.KOD,y
	cmp adr.BUF+1
	bne pls
	lda adr.BUF		;kod dzwieku
	and #$f
	cmp adr.KOD+1,y
	bne pls
	iny
	iny
	tya
	lsr @
; ldy #0
	sta Result		;czestotliwosc

	lda adr.BUF+2		;oblicz nr instr
	lsr @
	lsr @
	lsr @
	lsr @
	sta or_+1
	lda adr.BUF
	and #$f0
or_	ora #0
	and #$1f
; ldy #1
_con	sta Result+1		;numer instrumentu

; ldy #2
	lda #0
	sta Result+2
; dey
	lda adr.BUF+2
	and #$f
	cmp #$c
	beq _vol		; Effect Cxy (Set Volume)
	cmp #$f
	beq _tmp		; Effect Fxy (Set Speed)
	cmp #$d
	beq _break		; Effect Dxy (Pattern Break)
	jmp stop

_sil	sta Result
	beq _con

_break	lda #$80
	ora Result+1
	sta Result+1
	bne stop

_vol	lda #$40
	ora Result+1
	sta Result+1

	lda adr.BUF+3		;parametr komendy

	lsr @
	clc
	adc >VOLUME
	sta Result+2
	bne stop

_tmp	lda adr.BUF+3
	cmp #$20
	bcs _tq
	lda #$c0
	ora Result+1
	sta Result+1
; ldy #2
	lda adr.BUF+3		;parametr komendy
	and #$1f
	sta Result+2
_tq
	jmp stop

pls	iny
	iny
	cpy #96

	jne _tst

stop
};
end;



procedure LoadMOD(fnam: TString);
var f: file;
    name: TString;
    i, j, a, x, y, num: byte;
    offset, tmp: cardinal;
    temp, len: word;
    smp: TPSample;
    p0, p1, p2: ^byte;
    header: string[4];
    xms: TMemoryStream;


    procedure NormalizeBuf;
    begin

	for j:=0 to 255 do
		buf[j] := buf[j] + $80;

    end;


begin

 name:='D:';
 name[0]:=chr(length(fnam)+2);

 for i:=1 to length(fnam) do			// 'D:' + filename
  name[i+2]:=fnam[i];


 assign(f, name); reset(f, 1);

 blockread(f, ModName, 20);			// Load Module Name

 NUMBER_OF_SAMPLES := 0;

 for i:=0 to 30 do begin			// Load Sample Information

  smp:=Sample[i];

  blockread(f, smp.name, sizeof(TSample));

  smp.len := swap(smp.len) shl 1;
  smp.loop_start := swap(smp.loop_start) shl 1;
  smp.loop_len := swap(smp.loop_len) shl 1;

  if smp.fine_tune > 7 then dec(smp.fine_tune, 16);

  if smp.len<>0 then begin
   inc(NUMBER_OF_SAMPLES);
   NUMBER_OF_BANKS := i + 1;
  end;

  if smp.len > sample_len then begin
   writeln('Only ',sample_len,' bytes length sample');
   halt;
  end;

 end;


 blockread(f, SONG_LENGTH, 1);
 blockread(f, SONG_RESTART, 1);


 NUMBER_OF_PATTERNS := 0;			// Load Order Information

 for i:=0 to 127 do begin
  blockread(f, a, 1);

  ORDER[i]:=hi(PATTERN_START) + a shl 1+a;	// + a*3

  if a > NUMBER_OF_PATTERNS then NUMBER_OF_PATTERNS:=a;
 end;

 inc(NUMBER_OF_PATTERNS);			// pattern #0 -> +1


 blockread(f, header[1], 4);
 header[0]:=chr(4);

 if header <> 'M.K.' then begin
  writeln('Unsuported MOD file');

  halt;
 end;


 writeln('Name: ',ModName);			// Information About Module

 for i:=0 to 30 do begin

  smp:=Sample[i];

  if smp.len<>0 then
   writeln(hexStr(i+1, 2),' ',smp.name,' ', hexStr(smp.len,4),' ', hexStr(smp.fine_tune,2),' ', hexStr(smp.volume,2),' ', hexStr(smp.loop_start,4),' ', hexStr(smp.loop_len,4) );

 end;


 if NUMBER_OF_PATTERNS > PATTERN_LIMIT then begin
  writeln;
  writeln('Samples: ',NUMBER_OF_PATTERNS);
  writeln('Only ',PATTERN_LIMIT,' samples allowed');
  halt;
 end;


 if NUMBER_OF_SAMPLES > SAMPLE_LIMIT then begin
  writeln;
  writeln('Samples: ',NUMBER_OF_SAMPLES);
  writeln('Only ',SAMPLE_LIMIT,' samples allowed');
  halt;
 end;


 xms.Create;

 if xms.Size < NUMBER_OF_BANKS*$4000 then begin
  writeln;
  writeln('Need minimum ',NUMBER_OF_BANKS,' banks expanded memory');
  halt;
 end;


 temp:=pattern_start;				// $4000..$9FFF

 writeln;
 write('Load Pattern: ');
 x:=WhereX;
 y:=WhereY;

 for i:=1 to NUMBER_OF_PATTERNS do begin	// Load Pattern Data

  p0:=pointer(temp);
  p1:=pointer(temp+$100);
  p2:=pointer(temp+$200);

  GotoXY(x,y);
  write(i,'/',NUMBER_OF_PATTERNS);

  for j:=0 to 255 do begin
   blockread(f, buf, 4);

   tmp:=CnvPattern;

   p0^:=tmp;		inc(p0);
   p1^:=tmp shr 8;	inc(p1);
   p2^:=tmp shr 16;	inc(p2);
  end;

  inc(temp, $300);

 end;


 writeln;
 write('Load Sample: ');
 x:=WhereX;
 y:=WhereY;

 offset:=0;
 num:=1;

 for i:=0 to 30 do begin			// Load Sample Data

  TSTRL[i] := lo(VOLUME);
  TSTRH[i] := hi(VOLUME);
  TREPL[i] := lo(VOLUME);
  TREPH[i] := hi(VOLUME);

  TIVOL[i] := hi(VOLUME);

  smp:=Sample[i];

  len := smp.len;

  if len <> 0 then begin

  GotoXY(x,y);
  write(num,'/',NUMBER_OF_SAMPLES);

  temp:=sample_len - len;

  xms.position := temp + offset;		// sampl konczy sie na $7fff

  inc(temp, sample_start);

  TSTRL[i] := lo(temp);
  TSTRH[i] := hi(temp);

  if {(smp.loop_start = 0 ) and} (smp.loop_len < 8) then
   temp := VOLUME				// skoncz i graj cisze
  else						// sample na poczatku maja 4 zera (dla wyciszenia)
   inc(temp, smp.loop_start);

  TREPL[i] := lo(temp);
  TREPH[i] := hi(temp);

  TIVOL[i] := hi(VOLUME) + smp.volume shr 1;

  while len > 0 do begin

   if len >= 256 then
    temp:=256
   else
    temp:=len;

   BlockRead (f, buf, temp);
   NormalizeBuf;
   xms.WriteBuffer(buf, temp);

   dec(len, temp);

  end;

  inc(num);

  end;	// if len <> 0

  inc(offset, sample_len);

 end;

 writeln;

 close(f);

end;



begin

 writeln('MOD Player 2.0 (IRQ+NMI)');
 writeln;

 sdmctl := ord(dmactl.enable) + ord(dmactl.normal);

 pause;


 if ParamCount > 0 then begin

 LoadMOD(ParamStr(1));

// LoadMOD('XRAY.MOD');

// writeln;
// writeln('Select: P-okey, C-ovox');

// gchar:=UpCase(readkey);

 Play(gchar = 'P');

 end;

end.
