//10 REM Skyscrapers (c) Borek
//15 REM Atari version (o) Pirx


uses crt;

const
	S_max = 7;
	W = '|/-\'; 
	snd_data = #3#162#1#162#3#121#1#162#3#121#1#96#4#121#3#121#1#121#3#96#1#121#3#96#1#81#4#96#3#121#1#96#4#81#3#96#1#121#4#162#3#162#1#162#4#121#3#121#1#121#4#121;
var
	S : byte;
	Wi : integer;
	C, G, M : array [0..(S_max+1)*(S_max+1)] of byte;
	E : string;
	L, R, T, B : array [0..S_max+1] of byte;
	SUM, PROD : word;
	I, J, P, R1, R2, C1, C2 : byte;
	LE, RI, TOP, BOT, LH, RH, TH, BH : byte;
	S1 : byte;
	CL, CC : byte;
	K : char;
	KV : byte;
	quitMe : boolean;
//-----------------------------------------------------------------------------
function Initialize : integer;
	var
		S_tmp : integer;
	begin
		ClrScr;
		GotoXY(3,21); write('Enter city size (3-',S_max,'):');
		repeat
			S_tmp := Ord(ReadKey) - Ord('0');
		until (S_tmp >= 3) and (S_tmp <= S_max);
		GotoXY(3,21); write('                        ');
		GotoXY(27,3); write('C'*'heck');
		GotoXY(27,4); write('R'*'estart');
		GotoXY(27,5); write('N'*'ew');
		GotoXY(27,6); write('S'*'ave');
		GotoXY(27,7); write('L'*'oad');
		GotoXY(27,8); write('Esc'*'ape');
		GotoXY(27,10); write(#27#28#27#29#27#30#27#31,', +-, 0-',S_tmp);//cursor keys, +-, ...
		Result := S_tmp;
	end;
//-----------------------------------------------------------------------------
procedure roto;
begin
	GotoXY(25,22); 
	write(W[Wi]);
	inc(Wi);
	IF Wi > Length(W) THEN Wi := 1;
end;

procedure roto_clr; //1160
begin
	GotoXY(25,22);
	write (' ');
end;
//-----------------------------------------------------------------------------
procedure press_any; //1170
begin
	roto_clr;
	GotoXY(1,24);
	write('Press any key...');
	K := ReadKey;
	GotoXY(1,24);
	write('                ');
end;
//-----------------------------------------------------------------------------
procedure PrintGameBuffer;
begin
	FOR I:=1 TO S do begin
		FOR J:=1 TO S do begin
			GotoXY(1+3*J,3*I);
			IF G[I+J*S_max]<>0 THEN write(G[I+J*S_max])
			else write(' ');
		end;
	end;
end;

//-----------------------------------------------------------------------------
procedure GoSpritesGo;
var i : word;
begin
	for i := 53248 to 53255 do poke(i,0);
end;	
	
//-----------------------------------------------------------------------------
procedure Sprites; //4000
var
PMB : word;

begin
	GoSpritesGo;
	PMB := (PEEK(106)-8)*256;
	//clean sprt
	FOR I:=21 TO 20+12*S_max do Begin
		POKE(PMB+512+I,0);POKE(PMB+640+I,0);
		POKE(PMB+768+I,0);POKE(PMB+896+I,0);POKE(PMB+384+I,0);
	end; //NEXT I
	
	POKE (704,6);POKE (705,2);POKE (706,4);POKE (707,8);POKE (709,15);POKE (711,10);
	FOR I:=21 TO 20+12*S do Begin
		POKE(PMB+512+I,192);POKE(PMB+640+I,192);
		POKE(PMB+768+I,192);POKE(PMB+896+I,192);POKE(PMB+384+I,255);
	end; //NEXT I
	i:=31;
	while i<104 do begin
		DPOKE(PMB+512+I,0);
		DPOKE(PMB+640+I,0);
		DPOKE(PMB+768+I,0);
		DPOKE(PMB+896+I,0);
		DPOKE(PMB+384+I,0);
		i := i+12;
	end;
	POKE(54279,PMB div 256);
	POKE(623,1+16); POKE(53260,255);
	POKE(53277,3); POKE(53256,3); POKE(53257,3); POKE(53258,3); POKE(53259,3);
	//REM Sprite positions
	POKE(53249,58); POKE(53250,70); POKE(53251,82);
	if s>6 then POKE(53248,130);
	if s>5 then POKE(53253,118);
	if s>4 then POKE(53254,106);
	if s>3 then POKE(53255,94 );
	
end;
//-----------------------------------------------------------------------------
procedure Restart; //420
begin
	E := '                   ';
	SetLength(E,3*S-2);
	FOR I:=1 TO S do begin
		FOR J:=1 TO S do G[I+J*S_max]:=0;
	end;
	FOR I:=3 TO 3*S do begin
		GotoXY(4,I); write(E);
	end;
	PrintGameBuffer;
	CL:=1;CC:=1;
end;
//-----------------------------------------------------------------------------
procedure NewGame;
begin
	GoSpritesGo;
	CursorOff;
	S  := Initialize;
	quitMe := False;
	Wi := 1;
	SUM := 0; PROD := 1;
	Sprites;
	
	for i := 1 to S do begin
		roto;
		SUM := SUM+I; PROD := PROD*I;
		for j := 1 to S do begin
			C[I+J*S_max] := I + j;
			if C[I+J*S_max] > S THEN C[I+J*S_max] := C[I+J*S_max] - S;
		end;
	end;
	FOR I := 1 TO S do begin
		roto;
		R1 := 1+Random(S); R2 := 1+Random(S);
		FOR J := 1 TO S do begin
			P := C[R1+J*S_max];
			C[R1+J*S_max] := C[R2+J*S_max];
			C[R2+J*S_max] := P;
		end;
		C1 := 1+Random(S); C2 := 1+Random(S);
		FOR J := 1 TO S do begin
			P := C[J+C1*S_max];
			C[J+C1*S_max] := C[J+C2*S_max];
			C[J+C2*S_max] :=P;
		end;
	end;
	FOR I := 1 TO S do begin
		roto;
		LE := 1; RI:= 1; TOP := 1; BOT := 1;
		LH := C[I+1*S_max]; RH:= C[I+S*S_max]; TH := C[1+I*S_max]; BH := C[S+I*S_max];
		FOR J := 2 TO S do begin
			S1 := S+1-J;
			IF C[I+J*S_max]>LH THEN begin LE := LE+1; LH := C[I+J*S_max];end;
			IF C[I+S1*S_max]>RH THEN begin RI := RI+1; RH := C[I+S1*S_max];end;
			IF C[J+I*S_max]>TH THEN begin TOP := TOP+1; TH := C[J+I*S_max];end;
			IF C[S1+I*S_max]>BH THEN begin BOT := BOT+1; BH := C[S1+I*S_max];end;
		end;
		L[I] := LE; R[I] := RI; T[I] := TOP; B[I] := BOT;
	end;

	roto_clr;
	FOR I := 1 TO S do begin
		GotoXY(2,3*I); write(L[I]);
		GotoXY(3*S+3,3*I); write(R[I]);
		GotoXY(1+3*I,1); write(T[I]);
		GotoXY(1+3*I,3*S+2); write(B[I]);
	end;
	Restart;
	CursorOn;
end;
//-----------------------------------------------------------------------------
procedure SaveGame;
begin
	FOR I:=1 TO S do begin
		roto;
		FOR J:=1 TO S do M[I+J*S_max]:=G[I+J*S_max]
	end;
	roto_clr;
end;
//-----------------------------------------------------------------------------
procedure LoadGame;
begin
	FOR I:=1 TO S do begin
		roto;
		FOR J:=1 TO S do G[I+J*S_max]:=M[I+J*S_max]
	end;
	PrintGameBuffer;
	roto_clr;
end;
//-----------------------------------------------------------------------------
function Check : Boolean;
var 
	SUMV, SUMH, PRODH, PRODV : WORD;
	Z : Byte;
	Finis : Boolean;
	
begin
	Finis := True;
	FOR I:=1 TO S do begin
		roto;
		if not Finis then Continue;
		SUMV:=0; PRODV:=1; SUMH:=0; PRODH:=1;
		FOR J:=1 TO S do begin
			SUMH:=SUMH+G[I+J*S_max]; PRODH:=PRODH*G[I+J*S_max];
			SUMV:=SUMV+G[J+I*S_max]; PRODV:=PRODV*G[J+I*S_max];
		end; //for J
		IF (SUMV<>SUM) or (PRODV<>PROD) THEN Begin //???IF SUMV<>SUM OR PRODV<>PROD THEN Begin
			FINIS:=False;
			GotoXY(3*I,1); Write('!',T[I],'!');
			GotoXY(3*I,3*S+2); Write('!',B[I],'!');
			press_any;
			GotoXY(3*I,1); Write(' ',T[I],' ');
			GotoXY(3*I,3*S+2); Write(' ',B[I],' ');
			Continue;
		end; //if
		IF (SUMH<>SUM) or (PRODH<>PROD) THEN Begin
			FINIS:=False;
			GotoXY(1,3*I); write('!',L[I],'!');
			GotoXY(3*S+2,3*I); write('!',R[I],'!');
			press_any;
			GotoXY(1,3*I); write(' ',L[I],' ');
			GotoXY(3*S+2,3*I); write(' ',R[I],' ');
			Continue;
		end;
	end; //for I
	
	IF Finis THEN Begin
		FOR I:=1 TO S do Begin
			IF NOT FINIS THEN Continue;
			roto;
			TOP:=1; BOT:=1; LE:=1; RI:=1;
			TH:=G[1+I*S_max]; BH:=G[S+I*S_max]; LH:=G[I+1*S_max]; RH:=G[I+S*S_max];
			FOR Z:=2 TO S do Begin
				IF G[Z+I*S_max]>TH THEN Begin; TOP:=TOP+1; TH:=G[Z+I*S_max]; end;
				IF G[S+1-Z+I*S_max]>BH THEN Begin; BOT:=BOT+1; BH:=G[S+1-Z+I*S_max]; end;
				IF G[I+Z*S_max]>LH THEN Begin; LE:=LE+1; LH:=G[I+Z*S_max]; end;
				IF G[I+(S+1-Z)*S_max]>RH THEN Begin; RI:=RI+1; RH:=G[I+(S+1-Z)*S_max]; end;
			end; //FOR Z
			IF L[I]<>LE THEN begin
				GotoXY(1,3*I); write('!',L[I],'!');
				press_any;
				GotoXY(1,3*I); write(' ',L[I],' ');
				FINIS := False;
				Continue;
			end; // if L[]
			IF R[I]<>RI THEN Begin
				GotoXY(3*S+2,3*I); write('!',R[I],'!');
				press_any;
				GotoXY(3*S+2,3*I); write(' ',R[I],' ');
				FINIS:= False;
				Continue;
			end; // if R[]
			IF T[I]<>TOP THEN Begin
				GotoXY(3*I,1); write('!',T[I],'!');
				press_any;
				GotoXY(3*I,1); write(' ',T[I],' ');
				FINIS:=False;
				Continue;
			end; //IF T[]
			IF B[I]<>BOT THEN Begin
				GotoXY(3*I,3*S+2); write('!',B[I],'!');
				press_any;
				GotoXY(3*I,3*S+2); write(' ',B[I],' ');
				FINIS := False;
			end; //IF B[]
		end; //FOR I
	end; //if Finis
	roto_clr;
	Result := Finis
end;
//-----------------------------------------------------------------------------
procedure QuitQuestion;
begin
	GotoXY(1,24);
	write('Are you a quitter? [y/n]');
	K := ReadKey;
	if (K = 'Y') or (K = 'y') Then quitMe := True;
	GotoXY(1,24);
	write('                        ');
end;
//-----------------------------------------------------------------------------
procedure Triumph; //1170
var
	T, N: byte;
begin
	GotoXY(1,24);
	write('The winner is you!!!');
	for I:=1 to (Length(snd_data) DIV 2) do Begin
		T := ord(snd_data[i*2-1]); N := ord(snd_data[i*2]);
		sound (0,N,10,10);
		pause(T*5);
		sound (0,0,0,0);
	end; //for I

	K := ReadKey;
	if K = #27 Then QuitQuestion;
	GotoXY(1,24);
	write('                    ');
end;

//=====================================================================
//                   main game
//=====================================================================

begin
	POKE(559,46); //sprite DMA setting

	NewGame;
	repeat begin
		
		IF G[CL+CC*S_max]<>0 THEN begin
			GotoXY(1+3*CC,3*CL); write( G[CL+CC*S_max],'');
			end
		else begin
			GotoXY(1+3*CC,3*CL);write(' ');
		end;
	//500
		K := ReadKey;
		case K of
			#31: begin inc(CC);IF CC>S THEN CC:=1; end;//right
			#30: begin dec(CC);IF CC=0 THEN CC:=S; end;//left
			#29, #$9b: begin inc(CL);IF CL>S THEN CL:=1; end;//down
			#28: begin dec(CL);IF CL=0 THEN CL:=S; end;//up
			'0'..'9': begin KV := Ord(K) - Ord('0'); if KV <= S then G[CL+CC*S_max] := KV; end;
			'+': begin inc(G[CL+CC*S_max]); if G[CL+CC*S_max] > S THEN G[CL+CC*S_max] := 0; end;
			'-': begin dec(G[CL+CC*S_max]); if G[CL+CC*S_max] > 127 THEN G[CL+CC*S_max] := S; end; // <0, byte style
			' ': G[CL+CC*S_max] := 0;
			'R', 'r': Restart;
			'N', 'n': NewGame;
			'S', 's': SaveGame;
			'L', 'l': LoadGame;
			'C', 'c': Begin
						if Check Then Begin Triumph; NewGame; end;
					end; //'C'
			#27: quitQuestion; //Esc
		end;

	end; // repeat
	until quitMe; 
	GoSpritesGo;
end.


