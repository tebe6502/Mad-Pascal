// Sneak Attack by David Plotkin

uses crt, graph, atari, joystick;

const
	ShapeTable : array [0..103] of byte = (
	254, 16, 124, 71, 127, 12, 62, 0,
	127, 8, 62, 226, 254, 24, 126, 0,
	96, 96, 48, 48, 24, 60, 231, 255,
	24, 24, 24, 24, 24, 60, 231, 255,
	6, 6, 12, 12, 24, 60, 231, 255,
	128, 85, 17, 66, 24, 170, 91, 131,
	60, 126, 255, 255, 195, 66, 36, 24,
	60, 36, 24, 255, 60, 24, 36, 102,
	0, 0, 0, 0, 0, 0, 0, 0,
	60, 36, 24, 255, 60, 24, 36, 102,
	60, 36, 219, 255, 60, 24, 36, 102,
	60, 60, 24, 60, 60, 24, 24, 28,
	60, 60, 24, 60, 60, 60, 102, 195
	);

	Trooper : array [0..23] of byte = (
	60, 126, 255, 255, 195, 66, 36, 24,
	60, 36, 24, 255, 60, 24, 36, 102,
	0, 0, 0, 0, 0, 0, 0, 0
	);

	endx : array [0..4] of byte = (16, 24, 17, 23, 20);
	endy : array [0..4] of byte = (22, 22, 19, 19, 17);

var	rtclok: byte absolute $14;

	Snd1: byte absolute $D208;
	Snd2: byte absolute $D20F;
	Fate: byte absolute $D20A;

	Colbk: byte absolute $D018;

	Bkgrnd: byte absolute 710;

	Scrn: word absolute 88;
	HiMem: word absolute $2E5;
	Sdlst: word absolute $230;

	comp: word = 300;

	level: byte = 1;
	hard: byte = 15;
	Freq: byte = 169;

	score: word;

	lp, ps, Loud, Loud1, DownL, DownR, Indx: byte;

	Chopperstatus, Chopperx, Choppery,
	TrStatus, Trx, Try, MisStatus, Misx, Misy: array [0..29] of byte;

	Expx, Expy, ExpStatus: array [0..59] of byte;

	Ll, Rr: array [0..19] of byte;

	Linept: array [0..23] of word;

	Charset, Dlist: array [0..0] of byte;

	fscr: file;


procedure Print(s: TString);
begin
	blockwrite(fscr, s[1], length(s));
end;


procedure Plot0(x,y,ch: byte);
// Plot a char at location x,y
var line: array [0..0] of byte;
begin

  line:=pointer(Linept[y]);
  line[x]:=ch;

end;



procedure Noise;
// the explosion noises
begin

  IF (Loud=0) AND (Loud1=0) AND (Freq=169) THEN exit;

  IF Loud<>0 THEN begin
    dec(Loud, 2);
    Sound(0,90,8,Loud);
  end;

  IF Loud1<>0 THEN begin
    dec(Loud1, 2);
    Sound(1,150,8,Loud1);
  end;

  IF Freq<168 THEN begin
    inc(Freq, 8);
    Sound(2,Freq,10,4);
  end ELSE begin
    Freq:=169;
    Sound(2,0,0,0);
  end;

end;


procedure Dli; assembler; interrupt;
asm
{	pha
	lda #50
	sta wsync
	sta colbk
	pla
};
end;


procedure Update;
// print score and level
begin

  GotoXY(2,24);
  Write('Score: ',Score);

  GotoXY(19,24);
  Write('Level: ', Level);

end;


procedure Title;
begin

  InitGraph(2 + 16);

  GotoXY(5,4);
  Print('SNEAK ATTACK');
  GotoXY(10,5);
  Print('BY');
  GotoXY(4,7);
  Print('david plotkin');
  GotoXY(5,9);
  Print('PRESS'*#32'start'*);

  WHILE Consol<>cn_start DO begin
    colpf3:=Fate;
    Wsync:=0;
    colpf0:=128-vcount+rtclok shr 2;
    colpf1:=vcount+rtclok shr 2;
  end;

end;


procedure Gr0Init;
// Set up the address of each screen
// line and initialize
var xx: byte;
begin

  InitGraph(0);
  CursorOff;

  FOR xx:=0 TO 23 DO Linept[xx]:=Scrn+(40*xx);

  FOR xx:=0 TO 29 DO begin
    Chopperstatus[xx]:=0;
    Chopperx[xx]:=0;
    Choppery[xx]:=0;
    Misx[xx]:=0;
    Misy[xx]:=0;
    MisStatus[xx]:=0;
    TrStatus[xx]:=0;
  end;

  FOR xx:=0 TO 59 DO ExpStatus[xx]:=0;

  FOR xx:=0 TO 19 DO begin
    Ll[xx]:=0;
    Rr[xx]:=0;
  end;

  Bkgrnd:=0;
  Update;
end;


procedure Download;
// Step back HiMem and move the
// character set into RAM
var RamSet: word;
begin

  RamSet:=(HiMem-$400) and $FC00;
  chbas:=hi(RamSet);
  HiMem:=RamSet;

  move(pointer($e000), pointer(RamSet), 1024);

  Charset:=pointer(RamSet);

end;


procedure Modify;
// Modify the RAM character set
begin

  move(ShapeTable, pointer(word(@Charset)+8), 104);

end;


procedure DrawBase;
// draw the base
var lp: byte;
begin

  FOR lp:=19 TO 21 DO Plot0(lp,22,128);

  Plot0(20,21,4);

end;


procedure AimGun;
// read the joystick and move the base
begin

 case Stick0 of
   joy_left: Ps:=3;
  joy_right: Ps:=5
 else
  Ps:=4
 end;

 Plot0(20,21,Ps);

end;


procedure ScoreLine;
// set up the dli
begin

  Dlist:=pointer(Sdlst);
  SetIntVec(iDLI, @Dli);
  Dlist[27]:=$82;
  Nmien:=$C0;

end;


procedure LaunchTrooper(wh: byte);
// drop a paratrooper from chopper wh
var lp: byte;
begin

  IF Fate>240-(Level shl 1) THEN
    FOR lp:=0 TO 29 DO			// find MT trooper
      IF TrStatus[lp]=0 THEN begin	// got one
        TrStatus[lp]:=1;
        Trx[lp]:=Chopperx[wh];

        IF Trx[lp]=0 THEN Trx[lp]:=1;

        Try[lp]:=Choppery[wh]+1;
        Plot0(Trx[lp],Try[lp],7);
        Plot0(Trx[lp],Try[lp]+1,8);
        Plot0(Trx[lp],Try[lp]+2,9);
        EXIT;
      end;

end;


procedure EraseChopper(wh: byte);
// erase chopper number wh
begin
  Plot0(Chopperx[wh],Choppery[wh],0);
  Plot0(Chopperx[wh]+1,Choppery[wh],0);
  Chopperstatus[wh]:=0;
  Chopperx[wh]:=0;
  Choppery[wh]:=0;
end;


procedure DrawChopper(wh: byte);
// draw chopper number wh
begin

  Plot0(Chopperx[wh],Choppery[wh],1);
  Plot0(Chopperx[wh]+1,Choppery[wh],2);

end;


procedure LaunchChopper;
// Decide whether to send off a new
// chopper, which side, how high up
var lp: byte;
begin

  IF Fate>230-(Level shl 1) THEN begin

    FOR lp:=0 TO 29 DO begin		// find MT chopper
      IF Chopperstatus[lp]=0 THEN begin
        Choppery[lp]:=Random(Hard);
        IF Fate>128 THEN begin
          Chopperx[lp]:=38;		// right side
          Chopperstatus[lp]:=2;
        end ELSE begin
          Chopperx[lp]:=0;		// left side
          Chopperstatus[lp]:=1;
        end;
        DrawChopper(lp);
        EXIT
      end;
    end;
  end;

end;


procedure ClearScreen;
// clear the screen
var lp, i: byte;
begin

  FOR lp:=0 TO 29 DO begin

    IF Chopperstatus[lp]<>0 THEN EraseChopper(lp);

    IF TrStatus[lp]<>0 THEN begin
      TrStatus[lp]:=0;
      Plot0(Trx[lp],Try[lp],0);
      Plot0(Trx[lp],Try[lp]+1,0);
      Plot0(Trx[lp],Try[lp]+2,0);
    end;

    IF MisStatus[lp]=1 THEN begin
      MisStatus[lp]:=0;
      Plot0(Misx[lp],Misy[lp],0);
    end;

  end;

  FOR i:=0 TO 29 DO begin
    lp:=i shl 1;

    IF ExpStatus[lp]=1 THEN begin
      ExpStatus[lp]:=0;
      ExpStatus[lp+1]:=0;
      Plot0(Expx[lp],Expy[lp],0);
      Plot0(Expx[lp+1],Expy[lp+1],0);
    end;
  end;

end;


procedure MoveChopper;
// move the choppers
var lp: byte;
begin

  FOR lp:=0 TO 29 DO begin

    IF Chopperstatus[lp]=1 THEN begin		// right
      IF Chopperx[lp]=38 THEN
        EraseChopper(lp)
      ELSE begin
        Plot0(Chopperx[lp], Choppery[lp],0);
        inc(Chopperx[lp]);
        DrawChopper(lp);
        LaunchTrooper(lp);
      end;
    end;

    IF Chopperstatus[lp]=2 THEN	begin	// left
      IF Chopperx[lp]=0 THEN
        EraseChopper(lp)
      ELSE begin
        Plot0(Chopperx[lp]+1, Choppery[lp],0);
        dec(Chopperx[lp]);
        DrawChopper(lp);
        LaunchTrooper(lp);
      end;
    end;

  end;

  IF ps=0 THEN begin
    Charset[8]:=56;
    Charset[16]:=28;
    ps:=1;
  end ELSE begin
    ps:=0;
    Charset[8]:=254;
    Charset[16]:=127;
  end;

end;


function Locate0(x,y: byte): byte;
// Returns the value of the char at x,y
var line: array [0..0] of byte;
begin

 line:=pointer(Linept[y]);

 Result:=line[x];

end;


procedure HitChute(wh: byte);
// see which chute was hit by missile wh
var lp: byte;
begin

  FOR lp:=0 TO 29 DO
    IF (Misx[wh]=Trx[lp]) AND ((Misy[wh]=Try[lp]) OR (Misy[wh]=Try[lp]+1)) THEN begin
      TrStatus[lp]:=2;
      Plot0(Trx[lp],Try[lp],0);
      Plot0(Trx[lp],Try[lp]+1,10);
      Plot0(Trx[lp],Try[lp]+2,0);
      EXIT
    end;

  IF Try[lp] shr 3 < Freq THEN Freq:=Try[lp] shl 3;

end;


procedure HitMan(wh: byte);
// see which man was hit by missile wh
var lp: byte;
begin

  FOR lp:=0 TO 29 DO
    IF (Misx[wh]=Trx[lp]) AND ((Misy[wh]=Try[lp]+1) OR (Misy[wh]=Try[lp]+2)) THEN begin
      TrStatus[lp]:=3;
      Plot0(Trx[lp],Try[lp]+1,6);
      Plot0(Trx[lp],Try[lp],0);
      Plot0(Trx[lp],Try[lp]+2,0);
    end;

  Loud1:=12;

end;



procedure ExplodeChopper(lp: byte);
// explosions in place of Chopper lp
var lq, i: byte;
begin

  FOR i:=0 TO 29 DO begin	// find empty

    lq:=i shl 1;

    IF ExpStatus[lq]=0 THEN begin
      ExpStatus[lq]:=1;
      ExpStatus[lq+1]:=1;
      Expx[lq]:=Chopperx[lp];
      Expx[lq+1]:=Chopperx[lp]+1;
      Expy[lq]:=Choppery[lp];
      Expy[lq+1]:=Choppery[lp];
      Chopperstatus[lp]:=0;
      Plot0(Expx[lq],Expy[lq],6);
      Plot0(Expx[lq+1],Expy[lq+1],6);
      EXIT;
    end;

  end;

end;


procedure HitChopper(wh: byte);
// which chopper was hit by missile wh
var lp: byte;
begin

  FOR lp:=0 TO 29 DO
    IF (Misy[wh]=Choppery[lp]) AND ((Misx[wh]=Chopperx[lp]) OR (Misx[wh]=Chopperx[lp]+1)) THEN begin
      ExplodeChopper(lp);
      EXIT;
    end;

  Loud:=12;
end;

procedure MissileHit(wh: byte);
// see if missile wh hit anything
var dum: byte;
begin

  dum:=Locate0(Misx[wh],Misy[wh]);

  IF dum=0 THEN begin
    Plot0(Misx[wh],Misy[wh],84);
    exit;
  end;

  MisStatus[wh]:=0;
  IF (dum=1) OR (dum=2) THEN begin
    HitChopper(wh);
    inc(Score);
  end else
  IF ((dum=7) AND (Indx<6)) OR ((dum=8) AND (Indx>3)) THEN begin
    HitChute(wh);
    inc(Score, 2);
  end else
  IF ((dum=8) AND (Indx<4)) OR ((dum=9) AND (Indx>1)) THEN begin
    HitMan(wh);
    inc(Score);
  end;

end;


procedure Shoot;
// send off a bullet
var lp: byte;
begin

  IF (Strig0=1) THEN exit;

  FOR lp:=0 TO 29 DO			// find empty shot
    IF MisStatus[lp]=0 THEN begin	// got one
      MisStatus[lp]:=1;
      Misy[lp]:=20;

      case Ps of
       3: Misx[lp]:=19;
       5: Misx[lp]:=21
      ELSE
        Misx[lp]:=20
      end;

      MissileHit(lp);
      EXIT;
    end;

end;


procedure MoveShots;
// move the fired bullets
var lp: byte;
begin

  FOR lp:=0 TO 29 DO			// for each shot
    IF MisStatus[lp]=1 THEN begin
      Plot0(Misx[lp],Misy[lp],0);

      case Stick0 of
        joy_left: dec(Misx[lp]);
       joy_right: inc(Misx[lp])
      ELSE
        dec(Misy[lp])
      end;

      IF (Misx[lp]<>39) AND (Misy[lp]<>255) AND (Misx[lp]<>0) THEN
        MissileHit(lp)
      ELSE
        MisStatus[lp]:=0;

    end;

end;

procedure MoveExplosions;
// move the explosions
var lp, i: byte;
begin

  FOR i:=0 TO 29 DO begin
    lp:=i shl 1;

    IF ExpStatus[lp]=1 THEN begin
      Plot0(Expx[lp],Expy[lp],0);
      Plot0(Expx[lp+1],Expy[lp+1],0);

      inc(Expy[lp]);
      inc(Expy[lp+1]);
      dec(Expx[lp]);
      inc(Expx[lp+1]);

      IF (Expy[lp]<>22) AND (Expx[lp]<>0) AND (Expx[lp+1]<>39) THEN begin
        Plot0(Expx[lp],Expy[lp],6);
        Plot0(Expx[lp+1],Expy[lp+1],6);
      end ELSE begin
        ExpStatus[lp]:=0;
        ExpStatus[lp+1]:=0;
      end;

    end;

  end;

end;


procedure BaseExplode;
// explode the base
var lp: byte;
begin

  SetColor(38);

  FOR lp:=0 TO 4 DO Line(20,22,endx[lp],endy[lp]);

  FOR lp:=0 TO 16 DO begin
    Sound(0,Fate,8,16-lp);
    Sound(1,Fate,8,16-lp);
    Pause(15);
  end;

  NoSound;
  SetColor(32);

  FOR lp:=0 TO 4 DO Line(20,22,endx[lp],endy[lp]);

end;


procedure EndRight;
// move the troopers from the right
// to the base
var lp,lq,nn: byte;
begin

  FOR lp:=0 TO 19 DO
    IF Rr[lp]=1 THEN begin

      lq:=21+lp;
      WHILE lq>20 DO begin

	IF nn=12 THEN
	  nn:=13
	ELSE
	  nn:=12;

        Plot0(lq,22,nn);
        Pause(10);
        Plot0(lq,22,0);

        dec(lq);
      end;
      Plot0(21,22,11);
    end;

  FOR lp:=0 TO 3 DO begin
    Plot0(21,22-lp,11);
    Pause(10);
  end;

  BaseExplode;
end;


procedure EndLeft;
// Move the troopers from the left to
// the base
var lp,lq,lc,nn: byte;
begin

  FOR lp:=0 TO 19 DO begin
    lq:=19-lp;
    IF Ll[lq]=1 THEN begin

      FOR lc:=lq TO 19 DO begin

	IF nn=12 THEN
	  nn:=13
        ELSE
	  nn:=12;

        Plot0(lc,22,nn);
        Pause(10);
        Plot0(lc,22,0);
      end;

      Plot0(19,22,11);
    end;
  end;

  FOR lp:=0 TO 3 DO begin
    Plot0(19,22-lp,11);
    Pause(10);
  end;

  BaseExplode;

end;


procedure EndPrint;
// print the end of game message and
// test for new game
var lp: byte;
begin

  GotoXY(10,8); Write('Game Over...Final Score:');
  GotoXY(15,9); Write(Score);
  GotoXY(15,10); Write('FINAL LEVEL :', Level);
  GotoXY(10,21); Write('Press FIRE to play again');

  repeat until strig0=0;

  DownL:=0;
  DownR:=0;

  Write(#125);

  FOR lp:=0 TO 19 DO begin
    Ll[lp]:=0;
    Rr[lp]:=0;
  end;

  Score:=0;
  Level:=1;
  DrawBase;
  Update;
  Hard:=15;
end;


procedure GameOverTwo;
// game over when four troopers down
var lp: byte;
begin

  NoSound;
  ClearScreen;
  Loud:=0;
  Loud1:=0;
  Freq:=169;

  FOR lp:=0 TO 19 DO begin
    IF Ll[lp]=1 THEN Plot0(lp,22,11);
    IF Rr[lp]=1 THEN Plot0(lp+21,22,11);
  end;

  IF DownL=4 THEN
    EndLeft
  ELSE
    EndRight;

  EndPrint;
end;


procedure GameOverOne;
// game over when trooper lands on base
var lp: byte;
begin

  NoSound;
  ClearScreen;
  Loud:=0;
  Loud1:=0;
  Freq:=169;

  FOR lp:=0 TO 19 DO begin
    IF Ll[lp]=1 THEN Plot0(lp,22,11);
    IF Rr[lp]=1 THEN Plot0(lp+21,22,11);
  end;

  BaseExplode;
  EndPrint;

end;


procedure TrooperDown(wh: byte);
// redraw trooper wh at bottom of screen
var cc: byte;
begin

  TrStatus[wh]:=0;
  cc:=Trx[wh];

  Plot0(Trx[wh],Try[wh],0);	// erase chute
  Plot0(Trx[wh],Try[wh]+1,11);	//replace

  IF (Trx[wh]<20) AND (Ll[cc]=0) THEN begin
    Ll[cc]:=1;
    inc(DownL);
  end else
  IF (Trx[wh]>20) AND (Rr[cc-21]=0) THEN begin
    Rr[cc-21]:=1;
    inc(DownR);
  end else
  IF Trx[wh]=20 THEN GameOverOne;

  IF (DownL=4) OR (DownR=4) THEN GameOverTwo;

end;


procedure TrooperFall;
// make trooper fall when chute hit
var lp, cc: byte;
begin

  FOR lp:=0 TO 29 DO
    IF TrStatus[lp]=2 THEN begin
      Plot0(Trx[lp],Try[lp]+1,0);
      inc(Try[lp]);
      IF Try[lp]=21 THEN begin
        cc:=Trx[lp];
        IF (Trx[lp]<20) AND (Ll[cc]=1) THEN begin
          dec(DownL);
          Ll[cc]:=0;
	end else
        IF (Trx[lp]>20) AND (Rr[cc-21]=1) THEN begin
          Rr[cc-21]:=0;
          dec(DownR);
        end;
      end;

      IF ((Try[lp]<22) AND (Trx[lp]<>20)) OR ((Try[lp]<20) AND (Trx[lp]=20)) THEN
        Plot0(Trx[lp],Try[lp]+1,10)
      ELSE
        TrStatus[lp]:=0;

    end;

end;


procedure MoveTroopers;
// move paratroopers down screen
var lp: byte;
begin

  FOR lp:=0 TO Indx DO Charset[56+lp]:=0;

  move(Trooper, pointer(word(@Charset)+56+Indx+1), 16);

  inc(Indx);
  IF Indx<8 THEN exit;

  Indx:=0;
  FOR lp:=0 TO 29 DO begin
    IF TrStatus[lp]=1 THEN begin
      Plot0(Trx[lp],Try[lp],0);
      inc(Try[lp]);
      IF Try[lp]=21 THEN TrooperDown(lp);
    end;

    IF TrStatus[lp]=3 THEN begin
      TrStatus[lp]:=0;
      Plot0(Trx[lp],Try[lp]+1,0);
    end;
  end;

  move(Trooper, pointer(word(@Charset)+56),24);

  FOR lp:=0 TO 29 DO
    IF TrStatus[lp]=1 THEN begin
      Plot0(Trx[lp],Try[lp],7);
      Plot0(Trx[lp],Try[lp]+1,8);
      Plot0(Trx[lp],Try[lp]+2,9);
    end;

end;


begin

  assign(fscr, 'S:'); rewrite(fscr, 1);

  Title;
  Gr0Init;
  Snd1:=0;
  Snd2:=3;
  Download;
  Modify;
  DrawBase;
  ScoreLine;
  repeat

    LaunchChopper;
    MoveChopper;
    MoveExplosions;
    Noise;
    TrooperFall;
    MoveTroopers;

    GotoXY(9,24); Write(Score);

 {   IF Score>Comp THEN NewLevel;}

    FOR lp:=1 TO 3 DO begin
      AimGun;
      Shoot;
      MoveShots;
      Pause;//(lp shl 1);
    end;

  until false;

end.

