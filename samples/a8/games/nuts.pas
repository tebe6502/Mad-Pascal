(*
900 REM NUTS!
901 REM BY JEFF.PIEPMEIER@GMAIL.COM
902 REM WRITTEN FEBRUARY 27 2016
903 REM FOR THE 2016 NOMAM 10-LINE
904 REM PROGRAMMING CONTEST (PURE)
905 REM PROGRAM NOTES AT
906 REM JEFFPIEPMEIER.BLOGSPOT.COM
907 REM GITHUB.COM/JEFFPIEP
*)

// Mad Pascal conversion Tebe/Madteam

uses crt, graph, joystick, sysutils;

const
	fntos = $e000;
	fnt = $a000;

	pmg = $a400;

	dlist_data: array [0..18] of byte = (
	$70,$70,$70,$46,$40,$bc,$06,$27,$27,$27,$27,$27,$27,$27,$27,$27,
	$27,$07,$41 );

	data: array [0..75] of byte = (
	$67,$B5,$FD,$3C,$7C,$3C,$38,$F0,$E6,$AD,$BF,$3C,$3E,$3C,$1C,$0F,
	$00,$00,$78,$D0,$70,$60,$F0,$78,$88,$04,$00,$00,$00,$00,$1E,$0B,
	$0E,$06,$0F,$1E,$11,$20,$00,$00,$00,$00,$00,$00,$18,$10,$7C,$7C,
	$38,$38,$38,$10,$00,$00,$00,$00,$4A,$49,$49,$49,$A9,$AD,$B6,$B2,
	$27,$27,$27,$27,$27,$27,$27,$27,$27,$27,$07,$41 );

	rnd: array [0..15] of shortint = (0,0,0,0,1,0,0,0,0,0,0,0,0,-1,0,0);

	dlist = $0600;

var
	fscr: file;

	x, z, a, h: byte;

	f, s, b, d, e, g: shortint;

	k, j: cardinal;

	hposp0: byte absolute $d000;
	kolp0p: byte absolute $d00c;
	hitclr: byte absolute $d01e;
	vscrol: byte absolute $d405;


procedure print(s: TString);
begin

 blockwrite(fscr, s[1], length(s));

end;


begin

 assign(fscr, 'S:'); rewrite(fscr, 1);

 InitGraph(1);

 move(dlist_data, pointer(dlist), sizeof(dlist_data));
 dpoke(dlist+4, dpeek(88));

 dpoke(dlist+length(dlist_data), dlist);
 dpoke($230, dlist);

 move(pointer(fntOS), pointer(fnt), 1024);
 move(data[56], pointer(fnt+264), 8);

 poke($d407, hi(pmg)); poke($d01d, 3);
 poke(559, 46);

 poke(756, hi(fnt));
 dpoke(708,$12C4);

 dpoke($d000,$6868);
 dpoke($d002,$7888);

 dpoke($d008, 257);
 dpoke($d00a, 257);

 dpoke(704,$850A);
 dpoke(706,$1D85);

 randomize;

repeat

 fillchar(pointer(pmg),$400,0);

 gotoxy(1,1);

 print('NUTS!     HI:'); print(IntToStr(j)); print(' '#$9b);
 print('SCORE:       '#$9b);

 FOR X:=0 TO 10 do print(' aaaaaa      aaaaaa'#$9b);

 F:=1; S:=16; H:=104; B:=1; E:=0; D:=12; G:=16; Z:=1; K:=0;

 repeat

   pause;

   hitclr:=1;

   a:=strig0 shl 1;

   if f=0 then f:=ptrig0-ptrig1;

   if a=0 then begin
     move(pointer(pmg+664), pointer(pmg+666), 78);
     move(pointer(pmg+792), pointer(pmg+794), 78);

     SOUND (1,0,Z,2); z:=ord(z=0);

     inc(k);

     dec(s,4);
     if s<0 then s:=15;

     vscrol:=s;

   if b<>0 then begin
     dec(d, 2);

     move(pointer(word(@data)+22-b*6+d), pointer(pmg+728-64*b), 2);
     b:=b*ord(d>0);
   end else begin
     b:=rnd[random(15)];
     d:=12;
   end;   // if b

   end;   // if a

   if e<>0 then begin
     g:=g-4+a;
     move(pointer(word(@data)+40+g), pointer(pmg+920), 4-a);
     e:=ord(g>0);
   end else begin
     g:=16;
     e:=(2-a)*ord(random>0.58);
   end;

   move(pointer(pmg+920), pointer(pmg+924-a), 78);

   case f of
    -1:			// left

    if h=104 then
     f:=0
    else begin
     dec(h, 8);
     move(data[0], pointer(pmg+589), 8)
    end;

     1:			// right

    if h=136 then
     f:=0
    else begin
     inc(h, 8);
     move(data[8], pointer(pmg+589), 8)
    end;

   end;

    hposp0:=h;

    if f<>0 then sound (2,h,10,6);

    pause;

    sound(0,0,0,0);
    sound(1,0,0,0);

    x:=kolp0p;		// collision detection

    if x and 8<>0 then begin
     sound(0,50,10,15);

     inc(k, 100);
     move(pointer(pmg), pointer(pmg+964), 28);
    end else
     if x and 6<>0 then
      Break
     else begin
      gotoxy(7,2);
      print(inttostr(k));	// score
     end;

  sound (2,0,0,0);

 until false;

  if k>j then j:=k;

until false;   // loop

close(fscr);

end.

