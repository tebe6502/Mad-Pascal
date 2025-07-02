// R.O.T.O.  by Mike Stortz

program roto;

uses crt, graph, joystick, atari;

const
	bytes = 64;
	rock = 194;

	pmb_page = hi($8000);

	cb_adr = $8000;
	cb_page = hi(cb_adr);

	dl_adr = $8800;
	dl_page = hi(dl_adr);

	misc_adr = $8900;
	misc_page = hi(misc_adr);

	sc_adr = $8c00;

	pmb = pmb_page*256+1024;

cset :	array [0..407] of byte = (
	0,124,198,198,198,198,254,124,
	0,56,120,120,56,56,124,254,
	0,124,206,28,56,112,254,254,
	0,254,28,56,28,206,254,124,
	0,28,60,124,220,254,28,28,
	0,254,192,252,14,206,254,124,
	0,124,192,252,206,206,254,124,
	0,254,14,28,56,112,112,112,
	0,124,198,124,198,198,254,124,
	0,124,206,126,14,30,124,120,
	0,56,124,206,206,222,206,206,
	0,252,14,252,206,206,254,252,
	0,124,254,198,192,198,254,124,
	0,248,220,206,206,222,220,216,
	0,126,252,0,240,192,252,126,
	0,126,252,0,252,248,224,224,
	0,126,224,224,238,230,254,126,
	0,230,230,238,230,230,230,230,
	0,254,56,56,56,56,254,254,
	0,14,14,14,14,206,254,124,
	0,238,238,252,240,252,238,238,
	0,224,224,224,224,224,252,254,
	0,198,238,254,214,238,238,238,
	0,198,230,246,254,238,230,230,
	0,124,198,198,198,198,254,124,
	0,252,6,254,252,224,224,224,
	0,124,198,198,198,204,254,118,
	0,252,6,254,252,238,238,238,
	0,126,0,248,126,14,254,252,
	0,254,0,56,56,56,56,56,
	0,230,230,230,230,230,254,254,
	0,230,230,230,230,254,124,56,
	0,198,198,214,254,238,198,198,
	0,198,238,124,56,124,238,198,
	0,230,230,124,56,56,56,56,
	0,254,28,56,112,224,254,254,
	0,0,0,0,0,0,0,0,
	255,255,187,255,223,255,251,255,
	60,126,223,253,255,247,126,60,
	255,255,255,255,255,123,49,0,
	255,255,255,255,222,158,12,8,
	63,127,127,127,63,31,63,127,
	127,63,63,31,63,127,63,31,
	0,49,123,255,255,255,255,255,
	8,12,158,222,255,255,255,255,
	254,252,248,248,252,254,252,248,
	248,252,254,254,252,248,248,252,
	0,0,32,80,255,126,68,34,
	4,12,30,56,16,16,32,64,
	0,0,4,10,255,126,34,68,
	32,48,120,28,8,8,4,2);

logo :	array [0..127] of byte = (
	85,85,88,88,88,88,85,85,
	128,96,88,88,88,88,96,128,
	0,5,21,88,88,88,88,88,
	0,128,96,88,88,88,88,88,
	0,149,149,2,2,2,2,2,
	0,85,85,80,80,80,80,80,
	2,9,37,37,37,37,37,37,
	80,84,37,37,37,37,37,37,
	85,89,88,88,88,88,0,0,
	128,96,88,88,88,88,88,1,
	88,88,88,88,88,88,21,5,
	88,88,88,88,88,88,96,128,
	2,2,2,2,2,2,2,66,
	80,80,80,80,80,80,80,80,
	37,37,37,37,37,9,2,64,
	37,37,37,37,37,84,80,0);

man0 :	array [0..41] of byte = (
	0,254,16,16,28,24,28,20,
	24,36,42,46,52,0,0,8,
	8,16,16,0,0,
	0,127,8,8,56,24,56,40,
	24,36,84,116,44,0,0,16,
	16,8,8,0,0);

man1 :	array [0..41] of byte = (
	0,254,16,16,16,20,20,20,
	16,48,49,48,48,8,24,16,
	16,32,32,32,32,
	0,127,8,8,8,40,40,40,
	8,12,140,12,12,16,24,8,
	8,4,4,4,4);

rotor :	array [0..11] of byte = (
	254,124,56,16,56,124,
	127,62,28,8,28,62);

can :	array [0..7] of byte = (24,60,126,90,195,195,219,255);

dldata	: array [0..11] of byte = (
	112,112,112,68,0,misc_page,
	4,6,11,6,139,48);

dldata2 : array [0..7] of byte = (
	112,70,160,misc_page,136,
	65,0,dl_page);

manadr : array [0..1] of byte = (0,21);

rotoradr : array [0..1] of  byte = (0,6);

mdata	: array [0..3] of byte = (3,12,48,192);

var
	rtclock: byte absolute $14;
	pcolr0: byte absolute $2C0;
	pcolr1: byte absolute $2C1;
	colr0: byte absolute $2C4;
	colr1: byte absolute $2C5;
	colr2: byte absolute $2C6;
	colr3: byte absolute $2C7;
	colr4: byte absolute $2C8;

	xd, yd, oxd, oyd, ii, score, highs, shield: smallint;

	a, temp, b: word;

	i,j,k,l,cx,cy,x,y,xs,xsm,ys,joy,
	phase,mc,face,flag,bak,fore,
	fuel,packs,enabled, whine,
	carried,endg,fallc,shake,
	shakec: byte;

	screen, dlist, ary: array [0..0] of byte;

	mxd: array [0..3] of smallint;

	table: array [0..79] of word;
	fall: array [0..19] of word;

	id: array [0..19] of byte;

	mx, my: array [0..3] of byte;

	missile: array [0..255] of byte absolute pmb-256;

	hposp: array [0..3] of byte absolute $d000;
	mxpf: array [0..3] of byte absolute $d000;

	hposm: array [0..3] of byte absolute $d004;
	pxpf: array [0..3] of byte absolute $d004;

	fscr: file;
	tmp_s: TString;


procedure Print(s: TString);
begin
	blockwrite(fscr, s[1], length(s));
end;


procedure Vblank; assembler; interrupt;
asm
{	mva ys vscrol
	adb xs xsm hscrol

	jmp xitvbv
};
end;


procedure Dli; assembler; interrupt;
asm
{	pha

	sta wsync

	lda vcount
	cmp #64
	bcs skp

	adb chbas #2 chbase

	mva fore colpf0
	mva bak colpf4

	lda enabled
	beq skp2

	mva #202 colpf1

	lda rtclock
	lsr @
	and #$3a
	sta colpf2			; can color

	mva #6 colpf3			; rock color
	bne stop
skp2
	sta colpf1
	sta colpf2
	sta colpf3

	beq stop

skp	mva chbas chbase
	mva #202 colpf1
	mva #64 colpf4

stop	pla
};
end;


procedure Init;
begin

  skstat:=3;
  audctl:=0;
  highs:=0;
  score:=0;
  rtclock:=0;

  move(pointer($e000), pointer(cb_adr), 1024);
  move(cset, pointer(cb_adr+128), 80);
  move(pointer(word(@cset)+80), pointer(cb_adr+264), 208);
  move(pointer(word(@cset)+288), pointer(cb_adr+512), 120);
  move(logo[0], pointer(cb_adr+632), 128);
  move(can[0], pointer(cb_adr+760), 8);

  a:=0;
  for i:=0 to 79 do begin
    table[i]:=a;
    inc(a, bytes);
  end;

  SetIntVec(iVBL, @Vblank);
  SetIntVec(iDLI, @Dli);
  nmien:=192;
end;


procedure PmSet;
begin
  sdmctl:=62;
  gractl:=3;
  hitclr:=0;
  pcolr0:=152;
  pcolr1:=118;
  gprior:=33;
  pmbase:=pmb_page;
  chbas:=cb_page;
end;


procedure ZeroOut;
begin

  fillByte(@missile, 1280, 0);

  for i:=0 TO 3 do begin
    hposp[i]:=0;
    hposm[i]:=0;
  end;

  NoSound;
end;


procedure LoopInit;
begin

  colr0:=68; colr1:=40; colr4:=64;

  screen:=pointer(sc_adr);
  dlist:=pointer(dl_adr);

  savmsc:=misc_adr;

  PmSet; ZeroOut;

  bak:=0; phase:=0; face:=0; flag:=0;
  cx:=0; cy:=0; ys:=0; score:=0;
  whine:=0; carried:=0; endg:=0;
  shake:=0; shakec:=0; xsm:=0;

  xs:=7; x:=84; y:=110;
  fore:=36; packs:=3;
  mc:=1; enabled:=1; fallc:=1;
  fuel:=50; shield:=50;

  FOR i:=0 TO 19 DO begin
    id[i]:=0; fall[i]:=0;
  end;

  mx[0]:=0; mx[1]:=0;

end;


procedure EndGame;
begin

 fillchar(pointer(Misc_adr+80),80, 0); ZeroOut;

 dindex:=2; rowcrs:=4; colcrs:=0;

 case endg of
  1: Print('    NO PACKS LEFT'#$9b);
  2: Print('   SHIELD DEPLETED'#$9b);
  3: Print(' CANNISTER RUPTURED'#$9b);
  4: Print('TOO MANY CANNISTERS'#$9b);
  5: Print(' ARCADIA THANKS YOU'#$9b);
 end;

 Print(#$9b'      game over'#$9b);

 FOR a:=1 TO 400 DO begin
  Sound(0,a shr 1,8,6);

  repeat UNTIL vcount=128;

  FOR i:=0 TO 60 DO begin
   colpf0:=vcount+rtclock;
   wsync:=0;
  end;
 end;

end;


procedure DoPhase;
begin

  inc(phase);
  IF phase=6 THEN phase:=0;

end;


procedure MoveMan;
begin

  temp := pmb+y;
  fillByte(pointer(temp), 26, 0);

  inc(temp, $100);
  fillByte(pointer(temp), 26, 0);

  inc(x, xd);
  inc(y, yd);

  hposp[0]:=x; hposp[1]:=x;

  IF xd>0 THEN face:=0 else
   IF xd<0 THEN face:=1;

  a:=pmb+y+(phase shr 2);
  temp:=manadr[face];

  move(man0[temp], pointer(a), 21);
  inc(a, $100);
  move(man1[temp], pointer(a), 21);

  a:=pmb+y+1;
  inc(a, phase shr 2);
  i:=rotor[rotoradr[face]+phase];

  Poke(a,i);
  Poke(a+256,i);

  Sound(0,phase shl 2-(yd shl 3),8,2);

end;


procedure DrawWall(st: word; cc,inn,len: byte);
var ii, jj: byte;
    tt: word;
begin

  screen[st]:=1;

  tt:=st+inn;

  FOR ii:=1 TO len-2 DO begin
    jj:=Random(2);
    screen[tt]:=cc+jj;
    inc(tt, inn);
  end;

  screen[tt]:=1;

end;


procedure Status;
begin

    SetColor(1);
    Line(0,5,fuel,5);
    Line(0,7,shield,7);
    SetColor(0);

end;


procedure DrawCaves;
var k: byte;
begin

  sdmctl:=0;
  sdlstl:=word(@dlist);

  fillByte(pointer(sc_adr), 5120, 0);
  fillByte(pointer(misc_adr), 512, 0);

  FOR i:=0 TO 11 DO dlist[i]:=dldata[i];

  a:=word(@screen);
  j:=12;

  FOR i:=0 TO 17 DO begin
    dlist[j]:=64+32+16+6;
    dlist[j+1]:=lo(a);
    dlist[j+2]:=hi(a);
    inc(j, 3);
    inc(a, bytes);
  end;

  dlist[j-3]:=128+64+16+6;

  FOR i:=0 to 7 DO dlist[j+i]:=dldata2[i];

  txtmsc:=misc_adr;

  FOR i:=0 TO 7 DO begin
    Poke(misc_adr+17+i,79+i);
    Poke(misc_adr+57+i,87+i);
  end;

  rowcrs:=2;
  colcrs:=0;

  Print('fuel    packs:'#$9b);
  colcrs:=0;
  Print('shield  score:'#$9b);
  Print('   by mike stortz'#$9b);

  dindex:=6;

  Status;

  a:=0;

  FOR i:=0 TO 7 DO begin
    FOR j:=0 TO 15 DO begin

      k:=Random(32);

      IF (k and 16)<>0 THEN k:=k or 4;

      IF (k and 1)<>0 THEN DrawWall(a,3,1,4);

      IF (k and 2)<>0 THEN DrawWall(a+3,5,bytes,10);

      IF (k and 4)<>0 THEN begin
        DrawWall(a+576,7,1,4);
        IF Random(5)=0 THEN screen[a+514]:=rock;
      end;

      IF (k and 8)<>0 THEN DrawWall(a,9,bytes,10);

      IF ((K and 16)<>0) AND (j>0) AND (j<15) THEN screen[a+513]:=159;

      inc(a, 4);
    end;

    inc(a, 576);
  end;

  k:=8;
  FOR a:=0 TO 5 DO begin
    i:=(Random(14)+1) shl 2;

    FOR j:=i+1 TO i+2 DO begin
      screen[table[k]+j]:=0;
      screen[table[k+1]+j]:=0;
      screen[table[k+2]+j]:=0;
    end;

    inc(k, 10);
  end;

  screen[69]:=95; screen[70]:=95;
  screen[133]:=95; screen[134]:=95;

  PmSet;
end;


procedure DoScore;
begin

  IF score>1000 THEN endg:=5;

  dindex:=2;

  str(packs, tmp_s);
  rowcrs:=4; colcrs:=14; Print(tmp_s);
  rowcrs:=6; colcrs:=14; Print('     ');

  str(score, tmp_s);
  rowcrs:=6; colcrs:=14; Print(tmp_s);

  dindex:=6;

  PutPixel(fuel,5); PutPixel(shield,7);

end;


procedure Title;
var t: byte;
begin

  InitGraph(5);
  PmSet;
  ZeroOut;

  fillByte(@missile,1280,0);
  fillByte(pointer(misc_adr),3000,0);

  screen:=pointer(savmsc);
  dlist:=pointer(sdlstl);

  colr0:=150; colr1:=146; colr2:=40; colr3:=68; colr4:=64;

  k:=0;

  FOR i:=6 TO 13 DO
    FOR j:=8 TO 15 DO begin
      screen[j*20+i]:=logo[k];
      inc(k);
    end;

  FOR i:=6 TO 13 DO
    FOR j:=16 TO 23 DO begin
      screen[j*20+i]:=logo[k];
      inc(k);
    end;

  dlist[31]:=$20;
  dlist[32]:=$40+$20+6;
  dlist[33]:=0;
  dlist[34]:=misc_page;

  b:=misc_adr;

  FOR i:=35 TO 43 DO dlist[i]:=$20+6;

  dlist[44]:=6;

  FOR i:=45 TO 50 DO dlist[i]:=0;

  dindex:=0;
  lmargin:=1;

  dlist[10]:=6;

  inc(savmsc, 100);

  str(score, tmp_s);
  Print(' last '*); Print(tmp_s);

  colcrs:=10;

  str(highs, tmp_s);
  Print('high '*); Print(tmp_s);

  savmsc:=misc_adr+300;
  rowcrs:=0; colcrs:=1;

  Print('    reserve ore   '*#$9b);
  Print('transport operation'*#$9b);
  Print('    THE CITY OF   '*#$9b);
  Print('ARCADIA IS UNDER  '*#$9b);
  Print('ATTACK.  YOUR JOB '*#$9b);
  Print('IS TO RECOVER FUEL'*#$9b);
  Print('CANNISTERS OF HYKE'*#$9b);
  Print('AND RETURN THEM TO'*#$9b);
  Print('THE UPPER LEFT END'*#$9b);
  Print('OF THE CAVERNS. IF'*#$9b);

  inc(savmsc, 400);
  rowcrs:=0; colcrs:=1;

  Print('YOUR SCORE EXCEEDS'*#$9b);
  Print('1000, ARCADIA HAS '*#$9b);
  Print('HELD OUT LONG     '*#$9b);
  Print('ENOUGH FOR HELP TO'*#$9b);
  Print('ARRIVE.  DON''T    '*#$9b);
  Print('SHOOT A CANNISTER '*#$9b);
  Print('OR CARRY MORE THAN'*#$9b);
  Print('10 AT A TIME, AND '*#$9b);
  Print('DON''T RUN INTO A  '*#$9b);
  Print('WALL. GOOD LUCK!  '*#$9b);

  inc(savmsc, 400);
  rowcrs:=0; colcrs:=1;

  Print(#$9b'    press'*' START'#$9b);
  Print('      to play'*#$9b);

  x:=86; y:=58; yd:=-1;
  xd:=0; ys:=0; xs:=0; phase:=0; l:=0;

  repeat

    IF yd=-1 THEN begin
      yd:=0; xd:=2; gprior:=36;
    end else
    IF yd=1 THEN begin
      yd:=0; xd:=-2; gprior:=33;
    end else
    IF xd=-2 THEN begin
      xd:=0; yd:=-1;
    end else begin
     xd:=0; yd:=1;
    end;

    FOR t:=0 TO 39 DO begin
      IF (xd=-2) and (x=150) THEN gprior:=36;
      IF (xd=-2) and (x=116) THEN gprior:=33;

      MoveMan;
      DoPhase;

      inc(l);

      IF l=2 THEN begin
        l:=0;
	inc(ys);
      end;

      IF ys=8 THEN begin
        ys:=0;
        inc(b, 20);

        IF b=misc_adr+1320 THEN b:=misc_adr;

        repeat UNTIL vcount=128;

        dlist[33]:=lo(b);
        dlist[34]:=hi(b);
      end;

      Pause(2);
      IF (consol=CN_START) OR (Strig0=0) THEN exit;

    end;

  UNTIL (consol=CN_START) OR (Strig0=0);

  ch:=255;
  NoSound;

end;



procedure GetDir;
begin

  xd:=0;
  yd:=0;

  joy:=joy_1;

  case joy_1 of
   joy_right: xd:=1;
    joy_left: xd:=-1;
    joy_down: yd:=2;
      joy_up: yd:=-1;
  end;

  IF (xd<>0) or (yd<>0) THEN begin
    oxd:=xd;
    oyd:=yd;
  end;

end;


procedure Scroll;
var tmp: word;
begin

  IF joy=joy_left THEN begin

    inc(xs);
    inc(x);

    IF xs=8 THEN
      IF cx=0 THEN
       dec(xs)
      ELSE begin
       dec(cx);
       xs:=0;
      end;

  end else
  IF joy=joy_right THEN begin
    dec(xs);
    dec(x);

    IF xs=255 THEN
      IF cx=44 THEN
       inc(xs)
      ELSE begin
       inc(cx);
       xs:=7;
      end;

  end;

  IF joy=joy_down THEN begin
    inc(ys);
    dec(y, 2);

    IF ys=8 THEN
      IF cy=68 THEN
       dec(ys)
      ELSE begin
       inc(cy);
       ys:=0;
      end;

  end else
  IF joy=joy_up THEN begin
    dec(ys);
    inc(y);

    IF ys=255 THEN
      IF cy=0 THEN
       inc(ys)
      ELSE begin
       dec(cy);
       ys:=7;
      end;

  end;

  repeat UNTIL vcount=128;

  tmp:=word(@screen)+table[cy]+cx;

  j:=12;
  FOR i:=0 TO 17 DO begin
    dlist[j+1]:=lo(tmp);
    dlist[j+2]:=hi(tmp);
    inc(j, 3);
    inc(tmp, bytes);
  end;

end;



procedure CheckShake;
begin

  IF (Random(0)=255) AND (Random(5)=0) AND (shake=0) THEN begin

    shake:=Random(10)+10;
    shield:=shield - Random(20);

    IF shield<=0 THEN begin shield:=0; endg:=2 end;

    Line(159,7,shield,7);

  end;

  IF shakec<>0 THEN
    dec(shakec)
  ELSE begin
    shakec:=60;

    IF shake<>0 THEN begin
      dec(shake);
      j:=Random(10);
      IF fall[j]=0 THEN begin
        a:=table[cy]+cx+Random(20);
        IF screen[a]=0 THEN begin
          fall[j]:=a;
	  id[j]:=rock;
          screen[a]:=rock;
        end;
      end;

      Sound(2,255-shake,2,6);
      xsm:=Random(5);
    end ELSE begin
      xsm:=0;
      Sound(2,0,0,0);
    end;

  end;

end;


procedure GoBoom;
begin

  NoSound;
  fillchar(missile, 256, 0);
  mx[0]:=0; mx[1]:=0;

  Pause(30);

  ary:=pointer(pmb+y);

  FOR i:=0 TO 170 DO begin
    FOR j:=1 to 20 DO begin
      colpm0:=64+Random(8) shl 1;
      colpm1:=64+Random(8) shl 1;
      wsync:=0;
    end;
    k:=Random(24); ary[k]:=ary[k] and Random(0);
    k:=Random(24); ary[k+256]:=ary[k+256] and Random(0);
    Sound(1,i,4,6);
    Pause;
  end;

  fillchar(pointer(pmb),512, 0);
  NoSound;
  pcolr0:=152; pcolr1:=118;

  Pause(20);

  enabled:=0;
  FOR i:=0 TO 7 DO begin
    fore:=46-i shl 1;
    Pause(5);
  end;

  fore:=0;
  Pause(60);

  hitclr:=0; carried:=0; whine:=0; shake:=0; face:=0;

  dec(packs);
  IF packs=0 THEN endg:=1;

  FOR i:=0 TO 19 DO begin
    screen[fall[i]]:=0;
    fall[i]:=0;
  end;

  fuel:=50;

  Status;

  cx:=0; cy:=0; ys:=0;
  x:=84; y:=110; xs:=7;

  DoScore; Scroll; MoveMan;
  fore:=36; enabled:=1;

end;


procedure ChargeShield;
begin

  IF carried<>0 THEN begin

    inc(shield, carried shl 2);
    inc(score, word(carried*50)); DoScore;
    NoSound;

    FOR i:=1 TO 25 DO begin
      Sound(3,250-byte(i*10),10,6);
      Pause;
    end;

    Sound(3,0,0,0);
    fuel:=50;
    carried:=0; whine:=0;

    Status;
  end;

  hitclr:=0;

end;


procedure GetCan;
begin

  i:=x-35; j:=y-50;
  i:=i shr 3; j:=j shr 3;

  a:=table[j+cy]+i+cx;

  IF screen[a]=159 THEN begin
    screen[a]:=0;
    inc(carried);
    IF carried=11 THEN endg:=4;
    whine:=200; hitclr:=0;
  end;

end;


procedure Falling(bb: word);
begin

  j:=screen[bb-64];

  IF (j=159) OR (j=rock) THEN begin
    FOR k:=10 TO 19 DO begin
      IF fall[k]=0 THEN begin
        fall[k]:=bb-64;
	id[k]:=j;
	EXIT;
      end;
    end;
  Falling(bb-64);
  end;

end;


procedure ZapIt(zz: byte);
begin

  atract:=0;

  l:=mxd[zz]+2;

  j:=mx[zz]-31-l shr 2-xs;
  k:=my[zz]-72+ys;

  j:=j shr 3; k:=k shr 3;

  missile[my[zz]]:=missile[my[zz]] and 255-mdata[zz];
  mx[zz]:=0;

  a:=table[cy+k]+cx+j;

  IF screen[a]=159 THEN endg:=3;
  IF screen[a]=rock THEN inc(score, 2);

  bak:=70; fore:=12;

  FOR j:=0 TO 10 DO begin
    screen[a]:=65;
    FOR k:=1 TO 100 DO begin end;
    screen[a]:=0;
    FOR k:=1 TO 100 DO begin end;
    Sound(1,200,2,15-j);
  end;

  fore:=36; bak:=0; screen[a]:=0;
  Sound(1,0,0,0);
  hitclr:=0; dec(score); DoScore;
  Falling(a);

end;


procedure Bump;
begin

  i:=pxpf[0];
  j:=pxpf[1];

  IF ((i and 1)<>0) OR ((j and 1)<>0) OR ((i and 8)<>0) OR ((j and 8)<>0) THEN

    GoBoom

  ELSE
  IF ((i and 2)<>0) OR ((j and 2)<>0) THEN

     ChargeShield

  ELSE
  IF ((i and 4)<>0) OR ((j and 4)<>0) THEN

    GetCan;

  IF mxpf[0]<>0 THEN ZapIt(0);
  IF mxpf[1]<>0 THEN ZapIt(1);

end;


procedure StartMiss;
begin

  IF (Strig0=0) AND (flag=0) THEN begin
    flag:=1;
    mc:=mc xor 1;

    IF mx[mc]=0 THEN begin
      missile[my[mc]]:=missile[my[mc]] and (255 xor mdata[mc]);
      my[mc]:=y+10;
      missile[my[mc]]:=missile[my[mc]] or mdata[mc];
      mx[mc]:=(x+4+face shr 3) and 254;
      mxd[mc]:=face shl 2-2;
    end;

  end;

  flag:=Strig0 xor 1;

end;


procedure MoveMiss;
begin

  j:=2;
  FOR i:=0 TO 1 DO begin
    temp:=mx[i];

    IF temp<>0 THEN begin
      dec(temp, mxd[i]);
      hposm[i]:=temp;

      IF x>temp THEN
        k:=x-temp
      ELSE
        k:=temp-x;

      Sound(1,k,12,8);
    end ELSE
      dec(j);

    mx[i]:=temp;

    IF j=0 THEN Sound(1,0,0,0);

  end;

end;


procedure MoveRocks;
begin

  FOR i:=0 TO 19 DO begin
    temp:=fall[i];

    IF temp<>0 THEN begin
      IF screen[temp]=0 THEN
        temp:=0
      ELSE begin
        a:=temp+64;
        IF screen[a]<>0 THEN begin
          temp:=0;
          IF id[i]=159 THEN endg:=3;
        end ELSE begin
          screen[temp]:=0;
          screen[a]:=id[i];
	  inc(temp, 64);
        end;
      end;
    end;

    fall[i]:=temp;
  end;

end;


procedure CheckRocks;
begin

  dec(fallc);

  IF fallc=0 THEN begin
    fallc:=20;
    MoveRocks;
  end;

end;


procedure CheckFuel;
begin

  IF ((rtclock=0) or (rtclock=128)) AND (fuel<>0) THEN begin
     DoScore;
     dec(fuel);
  end;

end;


procedure GameLoop;
begin

    SetIntVec(iDLI, @dli);
    nmien:=192;

    GetDir;

    IF fuel=0 THEN begin
      yd:=2; joy:=joy or 2;
    end ELSE
      DoPhase;

    MoveMan;

    IF (x<70) OR (x>176) OR (y<90) OR (y>172) THEN
      Scroll
    ELSE
      Pause;

    CheckFuel;
    CheckShake;
    CheckRocks;
    StartMiss;
    MoveMiss;
    Bump;

    IF whine<>0 THEN begin
      dec(whine);
      Sound(3,whine,10,4);
      IF whine=0 THEN Sound(3,0,0,0);
    end;

    IF ch<255 THEN begin
      ch:=255;
      NoSound;

      repeat UNTIL (ch<255) OR (consol<>CN_NONE) OR (Strig0=0);

      ch:=255;
    end;

end;


begin

  assign(fscr, 'S:'); rewrite(fscr, 1);

  Init;

  repeat

    Title;
    InitGraph(0); crsinh:=1;
    LoopInit;
    DrawCaves;
    DoScore;
    SetColor(0);

    repeat
     GameLoop;
    until (consol<>CN_NONE) or (endg<>0);

    if endg<>0 then EndGame;
    if (score>0) and (score>highs) then highs:=score;

  until false;

  SetIntVec(iVBL, pointer($E462));
  ZeroOut;

  InitGraph(0);

  close(fscr);

end.
