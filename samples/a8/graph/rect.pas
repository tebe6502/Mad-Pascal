//Mad pascal 18-05-2017
//
//OPTION = ADVANCE TO NEXT GTIA MODE
//SELECT = CLEAR SCREEN
//START = FREEZE OR RESTART
uses crt, fastgraph;

procedure dli; interrupt; 		//30 FOR I=1768 TO 1791:READ A:POKE I,A:NEXT I
 begin
 asm
 {
		pha
		sta		$d40f
		sta		$d40a	//220 DATA 72,141,15,212,141,10,212
		lda		$2c0
		eor		$4f
		and		$4e
		sta		$d01a	//230 DATA 173,192,2,69,79,37,78,141,26,208
		lda		#$00
		sta		$d01b
		pla
 };
 end; 					//240 DATA 169,0,141,27,208,104,64

var m,c,t,i,j,a,b:byte;

label line80,line90,line190;

procedure gosub210;
 begin
 ClrScr;
 FillChar(pointer(DPeek(Dpeek(560)+4)),94*40,0);
 FillChar(pointer(DPeek(Dpeek(560)+100)),66*40,0);
 for i:=1 to 200 do;
end;					//210 PRINT #6;CHR$(125):FOR I=1 TO 200:NEXT I:RETURN

begin
 Poke(54286,64); 
 Initgraph(8);				//10 POKE 54286,64:GRAPHICS 8
 Poke(Peek(560)+Peek(561)*256+166,143);	//20 POKE PEEK(560)+256*PEEK(561)+166,143
 SetIntVec(iDLI, @dli); 		//40 POKE 512,232:POKE 513,6
 Poke(54286,192);
 Poke(87,9);
 m:=1; 					//50 POKE 54286,192:POKE 87,9:M=1
 Poke(704,0);
 Poke(705,26);
 Poke(706,54);
 Poke(707,84); 				//60 POKE 704,0:POKE 705,26:POKE 706,54:POKE 707,84
 Poke(708,104);
 Poke(709,130);
 Poke(710,184);
 Poke(711,218); 			//70 POKE 708,104:POKE 709,130:POKE 710,184:POKE 711,218
line80:;
 if m=1 then t:=128;
 if m=2 then t:=12;
 if m=3 then t:=6;
 Poke(712,t);
 Poke(623,m*64);
 c:=0; 					//80 POKE 712,6+122*(M=1)+6*(M=2):POKE 623,64*M:C=0
line90:;
 t:=8;
 if m<>2 then t:=14;
 SetColor(Random(t)+1);			//90 COLOR (8+6*(M<>2))*RND(0)+1
 i:=Random(72)+4;
 j:=Random(72)+4; 			//100 I=INT(72*RND(0))+4:J=INT(72*RND(0))+4
 a:=Random(144)+8;
 b:=Random(144)+8;			//110 A=INT(144*RND(0))+8:B=INT(144*RND(0))+8
 MoveTo(i,a+1);
 LineTo(j,a+1);
 LineTo(j,b+1);
 LineTo(i,b+1);				//120 PLOT I,A+1:DRAWTO J,A+1:DRAWTO J,B+1:DRAWTO I,B+1
 MoveTo(j,b);
 LineTo(i,b);
 LineTo(i,a);
 LineTo(j,a); 				//130 PLOT J,B:DRAWTO I,B:DRAWTO I,A:DRAWTO J,A
 Inc(c);
 Poke(752,1);
 WriteLn('   MODE=',m+8,' #',c);  	//140 C=C+1:POKE 752,1:PRINT "   MODE=";M+8;" #";C
 a:=Consol;
 if a=7 then goto line90; 		//150 A=PEEK(53279):IF A=7 THEN 90
 Poke(77,0);
 if a<4 then
 begin
	gosub210;
	Inc(m);
	if m=4 then Dec(m,3);
	goto line80;
 end;  					//160 POKE 77,0:IF A<4 THEN GOSUB 210:M=M+1-3*(M=3):GOTO 80
 if a<6 then
 begin
	gosub210;
	c:=0;
	goto line90;
 end;					//170 IF A<6 THEN GOSUB 210:C=0:GOTO 90
 writeln(' **** FREEZE ****');
 for i:=1 to 200 do;			//180 PRINT " **** FREEZE ****":FOR I=1 TO 200:NEXT I
line190:;
 if Consol<>6 then goto line190; 	//190 IF PEEK(53279)<>6 THEN 190
 Poke(77,0);
 for i:=1 to 50 do;
 goto line90; 				//200 POKE 77,0:FOR I=1 TO 50:NEXT I:GOTO 90
end.
