
// ----------------------
// SNAKE VBXE
// ----------------------

Program Snake;

Uses CRT, joystick, vbxe;

const
	SnakeBody = 'O';
	SnakeHead = '*';
	SnakeFood = 'X';

Var
 stop: Boolean;

 a: byte;

 Q,W : byte;
 DX,DY : byte;
 X0,Y0 : byte;
 EX,EY : byte;
 HX,HY : byte;

 SC : byte;

 X, Y: Array [0..255] of byte;

 MoveDelay : byte;
 Lifes : byte;
 Len : Byte;


Procedure VarSet;
BEGIN
  Len := 10;
  X0 := 0;
  Y0 := -1;
  EX := 35;
  EY := 21;

  For a := 1 to Len do begin
   X[a] := 20;
   Y[a] := a+12;
  END;

END;


Procedure Obj;
var ok: Boolean;
BEGIN

 repeat

  Q := Random (21)+2;
  W := Random (37)+2;

  ok:=true;

  for a:=1 to len do
   if (X[a] = W) and (Y[a] = Q) then begin ok:=false; Break end;

 until ok;

 TextBackground($9a);
 TextColor($c6);

 GotoXY (W, Q);
 Write ( SnakeFood );
END;


procedure GameOver;
begin

 TextColor($2a);

 GotoXY(X[1],Y[1]);
 write('*');

 gotoxy(13,11);
 write('G A M E O V E R');
 gotoxy(16,14);
 write('Score: ',SC);
 delay(2000);

 repeat until keypressed;

 halt;

end;


procedure StatusScore;
begin
 TextBackground($ff);
 TextColor($14);
 GotoXY (2, 1); Write ('Score: ',SC);
end;


procedure StatusLifes;
begin
 TextBackground($ff);
 TextColor($14);
 GotoXY (31,1); Write ('Lifes: ',Lifes);

 TextBackground($94);

end;


Procedure PutSnakeVars;
BEGIN

 TextBackground($94);
 TextColor($8a);

 GotoXY (EX, EY);
 Write (' ');

 TextBackground($74);

 For A := Len downto 2 do
    BEGIN
      GotoXY (X[A], Y[A]);
      Write ( SnakeBody );
    END;

 TextBackground($46);
 GotoXY (X[1], Y[1]);

 Write( SnakeHead);

 StatusScore;
 StatusLifes;

 DX := X0;
 DY := Y0;
END;


Procedure JoyScan;
BEGIN

    //  C2 := UpCase(ReadKey);

	case joy_1 of
	  joy_left: begin X0 := -1; Y0 := 0 end;	{left}
	 joy_right: begin X0 := 1; Y0 := 0 end;		{right}
	  joy_down: begin X0 := 0; Y0 := 1 end;		{down}
	    joy_up: begin X0 := 0; Y0 := -1 end;	{up}
	end;

//      stop := (C2 = #27);

END;


Function CheckRun: Boolean;
BEGIN

 Result := false;

 if (Y[1] = 1) or (X[1] = 1) or (Y[1] = 24) or (X[1] = 40) then begin
  Result := true;

  if Lifes = 0 then GameOver;

  dec(Lifes);
  StatusLifes;
 end;

END;


Function CheckEat: Boolean;
BEGIN
 Result := false;

 For A := 2 to Len do
   If (X[1] = X[A]) and (Y[1] = Y[A]) then begin
     Result := true;

     if Lifes = 0 then GameOver;

     dec(Lifes);
     StatusLifes;
   end;

END;


Function CheckObj: Boolean;
BEGIN

 Result := (W = HX) and (Q = HY);

END;


Procedure MoveSnake;
BEGIN
  EX := X[Len];
  EY := Y[Len];
  For A := Len downto 2 do
    BEGIN
      X[A] := X[A-1];
      Y[A] := Y[A-1]
    END;
  X[1] := HX;
  Y[1] := HY
END;


Procedure Fat;
Begin
  Inc (Len);
  For A := Len downto 2 do
    Begin
      X[A] := X[A-1];
      Y[A] := Y[A-1]
    End
End;


BEGIN

if VBXE.GraphResult <> VBXE.grOK then begin
 writeln('VBXE not detected');
 halt;
end;

CursorOff;

randomize;

Lifes:=3;
MoveDelay:=150;
PutSnakeVars;

  Repeat
	JoyScan;

      BEGIN
	write(ch_clr);

	VarSet;
	Obj;

        While true do
          BEGIN
            PutSnakeVars;
            JoyScan;
            If DX = byte(-X0) then X0 := DX;
            If DY = byte(-Y0) then Y0 := DY;
            HX := X[1] + X0;
            HY := Y[1] + Y0;

            If CheckObj then
              BEGIN
                Inc (SC);

		if MoveDelay > 50 then
		 if (SC mod 5 = 0) then dec(MoveDelay, 25);

                Fat;
                Obj;
              END;
            If CheckRun then Break;
            MoveSnake;
            If CheckEat then Break;

            If stop then Break;
            Delay (MoveDelay);
          END;
      END;

  Until stop;

 VBXEOff;

END.

