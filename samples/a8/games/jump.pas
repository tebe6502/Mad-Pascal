
// JUMP!!!
// http://atariage.com/forums/blog/387/entry-10826-jump/

uses crt, joystick, graph, atari;

const	SP = $E2A0;
	PM = $A200;
	SC = $BE70;
	D  = $BE54;
	CC = 200;

	pl: array [0..83] of byte = (
	$55,$FF,$55,$FF,$00,$00,$00,$00,$FF,$FF,$00,$00,$00,$AA,$55,$AA,$55,$AA,$00,$00,$00,$00,$00,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,
	$00,$00,$AA,$FF,$AA,$00,$00,$00,$00,$00,$55,$FF,$55,$FF,$55,$FF,$55,$00,$00,$00,$79,$60,$51,$3C,$90,$79,$60,$48,$51,$40,$35,$28,
	$2D,$35,$40,$51,$48,$3C,$2D,$23,$28,$35,$40,$51,$5B,$48,$35,$2D,$28,$35,$40,$51
	);

var	s2, sb, r, e, s, h: word;

	f, j, x, y: byte;

	a, g, n, m: real;

label	loop;


begin

loop: ;

InitGraph(3);
crsinh:=1;

pmbase:=hi(pm);
gractl:=2;
sdmctl:=$2e;
gprior:=1;

POKE (704,$38);

POKE(D-3,$68);

fillByte(pointer(d), 18, $28);

MOVE (pointer(SC), pointer(PM), 128);

write('SCORE:'#$7f,S);

IF S>H then begin
	H:=S;
	write(#$7f'GREAT!');
end;

writeln;
writeln('HISCORE:'#$7f,H);

writeln(#$20#$09#$20#$0f#$09#$20#$15#$15#$20#$15#$0f#$19#$19#$19);
write(#$09#$8c#$20#$8b#$8c#$20#$89#$8f#$20#$89#$0c#$0f#$0f#$0f);

WHILE STRIG0<>0 do;

clrscr;

S2:=SC+10;
SB:=SC+190;

Y:=20;
A:=0.2;
G:=0.2;

X:=120;

N:=0.0;
M:=0.0;
S:=0;

SOUND (0,0,10,10);

R:=$FE46;
E:=R+$FF;

atract:=0;

repeat

	J:=STICK0;

	IF J<8 then begin

	  IF M<1.0 THEN M:=M+A;

	end ELSE
	   IF (J<13) AND (M>-1.0) THEN M:=M-A;

	IF p0pf<>0 then begin
		N:=-0.6;
		hitclr:=0;
	end else
		IF N<1.5 then N:=N+G;

	X:=X+round(M);
	Y:=Y+round(N);

	MOVE(pointer(SP),pointer(PM+Y),9);
	hposp0:=x;

	IF (Y>130) OR (Y<10) OR (X>250) OR (X<5) then begin
		NoSOUND;
		GOTO loop;
	end;

	inc(f);
	PAUSE;

	IF F>7 then begin
		vscrol:=0;
		MOVE (pointer(S2), pointer(SC), CC);

		IF (S and 7)=0 then begin

			MOVE(PL[PEEK(R) and 31], pointer(SB), 10);
			inc(r, 8);

			IF R>E then R:=R-$FF;
		end;

		F:=0;
		audf1 := pl[52+(S and 31)];
		inc(s);
	end;

	vscrol:=f;

until false;

end.

