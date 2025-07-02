{
  Color Picker by Bostjan Gorisek
  16.10.2015 Gury
  03.07.2016 Tebe
}
uses crt, pmg, graph, sysutils, joystick;

const
   y = 3;

  // Memory location map
   pcol : array[0..6] of word = ($2C6, $2C8, $2C5, $02C0, $02C1, $02C2, $02C3);

  // Player data
  p0Data : array [0.._P_MAX] of byte = (255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0);
  p1Data : array [0.._P_MAX] of byte = (255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0);
  p2Data : array [0.._P_MAX] of byte = (255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0);
  p3Data : array [0.._P_MAX] of byte = (255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0);

var
  // Selected color memory location
  CurrPlyr : byte = 0;

procedure StatusReg(a: word);
begin
	ClrEol;
	write(IntToStr(a),' $',IntToHex(a, 3));
end;


procedure StatusVal(a: byte);
begin
	write(' dec:',peek(pcol[a]),' hex:',IntToHex(peek(pcol[a]), 2));
end;


procedure SetColors;
begin
  poke(pcol[0], 0);	// Background color
  poke(pcol[1], 160);	// Border color
  poke(pcol[2], 10);	// Text color
  poke(pcol[3], 50);	// Player 0 color
  poke(pcol[4], 134);	// Player 1 color
  poke(pcol[5], 164);	// Player 2 color
  poke(pcol[6], 232);	// Player 3 color

  GotoXY(3, y);     Write('Background   '); StatusReg(710); StatusVal(0);
  GotoXY(3, y+3);   Write('Border       '); StatusReg(712); StatusVal(1);
  GotoXY(3, y+3*2); Write('Text         '); StatusReg(709); StatusVal(2);
  GotoXY(6, y+3*3); Write('Player 0  '); StatusReg(704); StatusVal(3);
  GotoXY(6, y+3*4); Write('Player 1  '); StatusReg(705); StatusVal(4);
  GotoXY(6, y+3*5); Write('Player 2  '); StatusReg(706); StatusVal(5);
  GotoXY(6, y+3*6); Write('Player 3  '); StatusReg(707); StatusVal(6);

end;


procedure SetCursor;
begin
  if CurrPlyr = 0 then
    GotoXY(1, y+3*6)
  else begin
    GotoXY(1, y+3*(CurrPlyr-1))
  end;
  Write('  ');
  GotoXY(1, y+3*CurrPlyr);
  Write('=>');
end;


Procedure KeyScan;
var
  ch : char;
  n : byte;
begin
  If KeyPressed or (joy_1 <> 15) then begin
    if Keypressed then
      ch := UpCase(ReadKey)
    else begin

	case joy_1 of
	    joy_up: ch := #28;
	  joy_down: ch := #29;
	  joy_left: ch := #30;
	 joy_right: ch := #31;
	end;

	Delay(160);
    end;
    n := Peek(pcol[CurrPlyr]);

	case ch of
	#28: begin Inc(n, 10); Poke(pcol[CurrPlyr], n) end;	{up}
	#29: begin Dec(n, 10); Poke(pcol[CurrPlyr], n) end;	{down}
	#30: begin Dec(n, 2); Poke(pcol[CurrPlyr], n) end;	{left}
	#31: begin Inc(n, 2); Poke(pcol[CurrPlyr], n) end;	{right}
	#68: SetColors;
	end;

    n := Peek(pcol[CurrPlyr]);
    GotoXY(24, y+3*(CurrPlyr)); ClrEol;

    StatusVal(CurrPlyr);
  end
end;


procedure ConsoleKeys;
var
  CONSOL : byte absolute $D01F;
begin
  if CONSOL = 5 then begin
    Inc(CurrPlyr);
    if CurrPlyr = 7 then
      CurrPlyr := 0
    else if CurrPlyr = 0 then begin
      CurrPlyr := 6;
    end;
    SetCursor;
    Delay(400);
  end;
end;

procedure SetupPM;
begin
  // Initialize P/M custom variables
  p_data[0] := @p0Data;
  p_data[1] := @p1Data;
  p_data[2] := @p2Data;
  p_data[3] := @p3Data;

  // Initialize P/M graphics
  SetPM(_PM_DOUBLE_RES);
  InitPM(_PM_DOUBLE_RES);

  // Turn on P/M graphics
  ShowPM(_PM_SHOW_ON);

  // Set player sizes
  SizeP(0, _PM_NORMAL_SIZE);
  SizeP(1, _PM_NORMAL_SIZE);
  SizeP(2, _PM_NORMAL_SIZE);
  SizeP(3, _PM_NORMAL_SIZE);

  // Position and show players
  MoveP(0, 57, 57);
  MoveP(1, 57, 69);
  MoveP(2, 57, 81);
  MoveP(3, 57, 93);
end;


procedure SetText;
begin
  GotoXY(14,0); Write(' Color Picker '*);
  SetColors;
  GotoXY(1, 23); Write(' Select '*' Select color location');
  GotoXY(1, 24); Write(' D '*' Default colors');
  Write('  '#160#27#156#27#157#27#158#27#159#160' Select color')
end;

begin
  InitGraph(0); CursorOff;

  SetupPM;
  SetText; SetCursor;
  // Main loop
  repeat
    ConsoleKeys;
  	KeyScan;
  until false;
  // Reset P/M graphics
  ShowPM(_PM_SHOW_OFF);
end.
