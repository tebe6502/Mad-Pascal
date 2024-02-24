
// ----------------------
// SNAKE
// ----------------------
// Instruction:
// 'A' - left
// 'D' - right
// 'W' - up
// 'S' - down

Program Snake;

Uses CRT;

const

 SnakeBody = chr(ord('o'));
 SnakeFood = 'x';

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

  MoveDelay : Word;
  Lifes : byte;
  Len : Byte;


Procedure VarSet;
begin
  Len := 10;
  X0 := 0;
  Y0 := -1;
  EX := 35;
  EY := 21;

  For a := 1 to Len do begin
   X[a] := 20;
   Y[a] := a+12;
  end;

end;


Procedure Obj;
var ok: Boolean;

begin

  repeat
    Q := Random (21)+2;
    W := Random (37)+2;

    ok:=true;

    for a:=1 to len do
      if (X[a] = W) and (Y[a] = Q) then begin
        ok:=false; Break 
      end;

  until ok;

  GotoXY (W, Q);
  Write ( SnakeFood );
end;


procedure GameOver;
begin

  GotoXY(X[1],Y[1]);
  write('*');

  gotoxy(13,11);
  write(X16_REVERSE_ON);
  write('  g a m e o v e r  ');
  write(X16_REVERSE_OFF);
  gotoxy(16,14);
  write('score: ',SC);
  delay(2000);

  repeat until keypressed;

  halt;

end;


procedure StatusScore;
begin
 GotoXY (2, 1); Write ('score: ',SC);
end;


procedure StatusLifes;
begin
 GotoXY (31,1); Write ('lifes: ',Lifes);
end;


Procedure PutSnakeVars;
begin

 GotoXY (EX, EY);
 Write (' ');

 For A := Len downto 1 do
    begin
      GotoXY (X[A], Y[A]);
      Write ( SnakeBody );
    end;

 StatusScore;
 StatusLifes;

 DX := X0;
 DY := Y0;
end;


Procedure KeyScan;
var c2: char;
begin

If KeyPressed then
    begin
      C2 := UpCase(ReadKey);

	case C2 of
	'A': begin X0 := -1; Y0 := 0 end;	{left}
	'D': begin X0 := 1; Y0 := 0 end;	{right}
	'S': begin X0 := 0; Y0 := 1 end;	{down}
	'W': begin X0 := 0; Y0 := -1 end;	{up}
	end;

      stop := (C2 = X16_KEY_ESC);
    end
end;


Function CheckRun: Boolean;
begin

  Result := false;

  if (Y[1] = 1) or (X[1] = 1) or (Y[1] = 24) or (X[1] = 40) then begin
    Result := true;

    if Lifes = 0 then GameOver;

    dec(Lifes);
    StatusLifes;
  end;

end;


Function CheckEat: Boolean;
begin
 Result := false;

  For A := 2 to Len do
    If (X[1] = X[A]) and (Y[1] = Y[A]) then begin
      Result := true;

      if Lifes = 0 then GameOver;

      dec(Lifes);
      StatusLifes;
    end;

end;


Function CheckObj: Boolean;
begin

 Result := (W = HX) and (Q = HY);

end;


Procedure MoveSnake;
begin
  EX := X[Len];
  EY := Y[Len];
  For A := Len downto 2 do
    begin
      X[A] := X[A-1];
      Y[A] := Y[A-1]
    end;
  X[1] := HX;
  Y[1] := HY
end;


Procedure Fat;
begin
  Inc (Len);
  For A := Len downto 2 do
    begin
      X[A] := X[A-1];
      Y[A] := Y[A-1]
    end
end;


begin
  clrscr;

  CursorOff;
  TextMode(CX16_40x30);

  randomize;

  Lifes:=3;
  MoveDelay:=1500;
  PutSnakeVars;

  Repeat
    KeyScan;

    // begin
    clrscr;

    VarSet;
    Obj;
    While true do
    begin
      PutSnakeVars;
      KeyScan;
      If DX = byte(-X0) then X0 := DX;
      If DY = byte(-Y0) then Y0 := DY;
      HX := X[1] + X0;
      HY := Y[1] + Y0;

      If CheckObj then
        begin
          Inc (SC);
          if MoveDelay > 500 then
          if (SC mod 5 = 0) then dec(MoveDelay, 250);
          Fat;
          Obj;
        end;
        
      If CheckRun then Break;
      MoveSnake;
      If CheckEat then Break;
      If stop then Break;
      Delay (MoveDelay);
    end;
      // end;

  Until stop;

end.

