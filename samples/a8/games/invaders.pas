(*
 Invaders
 2016-03-25
 (C) 2016 by Victor Parada
 <HTTP://www.vitoco.cl/atari/>

 Ported to "Mad Pascal" Tebe/Madteam 21-24.08.2016
*)

program invaders;

uses crt, graph, joystick, math;

const
	k : array [0..77] of byte =
	(
	$08,$3E,$7F,$7F,$1F,$CF,$9F,$18,$48,$C8,$96,$FF,$FF,$FF,$FF,$FF,$01,$01,$03,$03,$55,$47,$40,$BC,$07,$56,$0C,$BE,$16,$01,$03,$07,
	$0D,$0F,$02,$05,$0A,$80,$C0,$E0,$B0,$F0,$40,$A0,$50,$04,$02,$07,$0D,$1F,$17,$14,$03,$10,$20,$F0,$D8,$FC,$F4,$14,$60,$03,$1F,$3F,
	$39,$3F,$06,$0D,$30,$C0,$F8,$FC,$9C,$FC,$60,$B0,$0C,$2C
	);

var
	q, p, m, w, e, s, r, c, tmp: word;

	d, f, x, l: shortint;

	g, i, j, z, t, u, h, v, o, y, a, b: byte;

	ch: char;

	tX, tM, tF: array [0..1] of byte;
	tI: array [0..8] of byte;
	tJ: array [0..5] of byte;

begin

 InitGraph(24);			// Cleans the upper 8K of RAM memory.
 InitGraph(0);			// Sets the playfield area: 1K in the TOP of RAM.

 q:=dpeek($230) + 8;		// Replaces the beginning of the display list with new data, setting up the first 4 lines of it

 move(k[21], pointer(q-5), 8);
 fillByte(pointer(q+3), 17, peek(q+2));

 P:=$D000;
 M:=$D404;			// Sets the horizontal fine scroll to none

 POKE(M,0); POKE (M+3,184);
 POKE(559,46); POKE($D01D,3);

 MOVE(pointer($E000), pointer($B000), 512);	// Copies the first half of the charset into RAM, and replaces some chars with alien's bitmap.
 MOVE (K[29], pointer($B008), 48);

 z:=1;		// Sets the initial index value for the arrays. Z is 1 when the invaders are moving to the right, and 0 if going to the left.
 d:=1;		// Sets the initial horizontal moving direction of the invaders to the right (1=right, -1=left).
 t:=54;		// Number of aliens in the block.

 MOVE (K, pointer($BA68), 4);	// Puts the cannon bitmap in P0 data.

 MOVE (K[8], pointer(P), 13);	// Set the initial horizontal position and width for all players and missiles.

 U:=1;				// U is the delay counter. It starts from 1. When it reaches the current number of aliens, the invaders must move one step
 L:=5;				// L is the current index of the lower row of aliens.

 POKE(756,$B0);			// Enables the modified charset

 W:=$B99C;			// Memory address where begins the aliens' ammo and it will scroll down two vertical positions on each loop
 E:=$BAEC;			// Memory address of P1 for the laser (missile)
 S:=$BE0E;			// S is the static memory position of the first alien in the block of invaders
 R:=S-2;			// R is dynamic memory position of the first displayed byte of the playfield. Will be decreased to move the block to the right.

 MOVE (K[3], pointer(704), 8);	// Sets the playfield and P/M graphics colors.

 tX[1]:=8;			// Index of the right-most column of aliens. The left-most defaults to 0.

 tM[1]:=8;			// Number of the maximum number of chars to scroll to the right before to move
				// them down and start moving to the left.
				// The minimum number of chars when going to the left defaults to 0.

 tF[1]:=14;			// Number of the maximum number of fine scrolling steps before moving a whole char
				// to the right. The minimum number of steps when going to the left defaults to 0.

 A:=72;				// Initial horizontal position of the cannon.

 FOR J:=0 TO 5 do		// Loop for each row of aliens
  FOR I:=0 TO 8 do begin	// Loop for the aliens in that row
   DPOKE (S+J*48+I*2, $4242*((J+2) div 2)-1);	// Puts an alien in the block of invaders. The type of alien and its color is given by a single formula on the row number.
   tI[I]:=6;			// Sets the initial number of aliens on each row and column.
   tJ[J]:=9;
  end;

 WHILE (Y+L*2<18) AND (C and 257=0) AND (T<>0) do begin

  POKE($D01E,1);
  u:=u+2;

  H:=STICK0;

  G:=ord(H=7)-ord(H=11);

  IF (byte(A+G)>46) AND (byte(A+G)<192) then begin
   A:=A+G*2;
   POKE(P,A);
  end;

  IF V=STRIG0 then begin
   B:=A+8;
   V:=4;
   POKE(P+1, B);
  end;

  MOVE(pointer(W), pointer(W+2), 78);
  O:=(O+1) MOD 36;

  IF O MOD 9=0 then begin
   H:=O DIV 9;
   I:=random(byte(tX[1]-tX[0]+1))+tX[0];

   IF tI[I]<>0 then begin
    POKE(P+4+H,(X+I)*16+F+55);
    tmp:=W+tI[I]*8+Y*4;
    DPOKE(tmp, $0202*power(4,H));
   end;

  end;

  pause(2);

  C:=DPEEK(P+8) or DPEEK(P+10);

  IF V<>0 then begin

    IF PEEK(P+5)<>0 then begin
     I:=(B-F) DIV 16-X-3;
     J:=((76-V) DIV 4-Y) DIV 2;
     SOUND(1,8,8,9);
     DPOKE( S+J*48+I*2,0);
     tI[I]:=tI[I]-1;
     tJ[J]:=tJ[J]-1;
     T:=T-1;
     C:=C or 2;
    end;

   DPOKE(E-V,0);

   IF (V<84) AND (C and  514=0) then begin
    V:=V+2;
    DPOKE( E-V,$8080);
   end else
    V:=0;

  end;


 IF U>T then begin

  SOUND(0,255,10,8);
  U:=1;

  IF F=tF[Z] then begin
   tX[Z]:=tX[Z]-D*ord(tI[tX[Z]]=0);

   IF tX[Z]+X=tM[Z] then begin
    D:=-D;
    Z:=1-Z;
    L:=L-ord(tJ[L]=0);
    R:=R-24;
    Y:=Y+1;
   end ELSE begin
    R:=R-D-D;
    X:=X+D;
    F:=tF[1-Z];
   end;

   PAUSE;
   DPOKE(Q,R);

 end ELSE begin
  F:=F+D+D;
  PAUSE;
 end;

 POKE(M,F);
end;

NoSound;

end;  // while

 IF T<>0 then
  DPOKE($BA69, $2A55)
 ELSE
  writeln('WIN');


repeat until keypressed;
ch:=readkey;

asm
{	jmp ($2e0)		// run again
};

end.
