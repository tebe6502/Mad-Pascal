{-------------------------------------------------------------------------------
  Game title: Parachute
  Version: 1.0
  Ported from the book Mirko tipka na radirko
  Original author: Bostjan Jerko
  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE/400/800 in Mad Pascal 1.3.1
  by Bostjan Gorisek 2016
  
  Version releases:
  1.0: Initial version
-------------------------------------------------------------------------------}

uses
  graph, crt, joystick, zxlib;

var  
  CHBAS  : byte absolute $2F4;  // Character base address
  RAMTOP : byte absolute $6A;   // RAM top memory address
  topMem, pmgMem : word;        // Memory handling variables
  py : byte = 16;               // Color bar y position
  CHBAS_temp : byte;            // Character base temporary variable
  tempScore : word;             // Temporary score storage

  // Data for new characters
  _planeP1 : array[0..7] of byte =
    (%00000000, %11000000, %11000111, %11111100, %11111110, %11111101, %00000111, %00000000);
  _planeP2 : array[0..7] of byte = 
    (%00000000, %00000000, %11100000, %00111111, %01011111, %10011110, %11100000, %00000000);
  _soldier : array[0..7] of byte =
    (%00011100, %01011101, %01001001, %00111110, %00001000, %00010100, %00100010, %00100010);
  _parachute : array[0..7] of byte =  
    (%01111110, %01111110, %10000001, %11111111, %01000010, %01000010, %01000010, %00100100);
  
  // Draw color bar pattern
  colorBarData : array [0..3] of byte = (255, 255, 255, 255);

  // Game variables
  score : word;           // Player score
  lives,                  // Soldier lives
  planeY : byte;          // Y positon of the plane - level measurement
  speed : byte = 0;       // Plane speed
  islandX,                // Island x position
  a, b,         // Plane position
  c, d : byte;  // Soldier position
  loop, i, jmp, z : byte;               // Misc variables
  soldier : char = Chr(Ord('r'));       // Soldier
  soldier01 : char = Chr(Ord('o'));     // Soldier with parachute
  ground : char = Chr(Ord(' ') + $80);  // Ground
  isDead : boolean;      
  
// Set game parameters
procedure SetGame(flag : byte);
begin
  if flag = 1 then begin
    InitGraph(0);
    
    // Set new character set
    topMem := RAMTOP - 12; pmgMem := topMem;
    topMem := topMem shl 8;
    CHBAS := topMem shr 8;
    CHBAS_temp := CHBAS; 
    move(pointer(57344), pointer(topMem), 1023);
         
    // Redefine characters for the game
    move(_planeP1, pointer(topMem+112*8), sizeOf(_planeP1));      // Plane part 1
    move(_planeP2, pointer(topMem+116*8), sizeOf(_planeP2));      // Plane part 2
    move(_soldier, pointer(topMem+114*8), sizeOf(_soldier));      // Soldier
    move(_parachute, pointer(topMem+111*8), sizeOf(_parachute));  // Parachute
  end else if flag = 2 then begin
    InitGraph(0);

    // Initialize P/M graphics
    Poke(53277, 0);
    Dec(pmgMem, 4);    
    Poke(54279, pmgMem);
    pmgMem := pmgMem shl 8;
    Poke(559, 46); Poke(623, 8);

    // Vertical position of color bar
    fillchar(pointer(pmgMem+512), 512, 0);
    for i := 0 to 3 do
      move(colorBarData, pointer(pmgMem+512+(i*128)+py), sizeof(colorBarData));
       
    // Size of color bar (triple size)
    fillchar(pointer(53256), 4, 3);
    // Color bar color
    fillchar( pointer(704), 4, 38);
    // Horizontal position of color bar
    Poke(53248,48); Poke(53249,48+32); Poke(53250,48+64); Poke(53251,48+96);
    
    CHBAS := CHBAS_temp;
  end else if flag = 3 then begin
    // Reset game
    ClrScr; SetGame(0);
    // Draw ground
    GotoXY(1, 22); for i := 0 to 39*3+1 do Write(ground);  
  end else begin
    planeY := 2; jmp := 0;
    score := 0; lives := 3;
    loop := 5; isDead := false;
  end;

  CursorOff; Poke(82, 0);
  TextBackground(COLOR_LIGHTBLUE);
  TextColor(COLOR_BLACK);
  Poke(712, COLOR_GRAY3);  
end;

procedure TitleScreen;
begin
  SetGame(0); SetGame(1);
  PrintAt(1, 16, 'PARACHUTE');
  PrintAt(2, 12, soldier01); PrintAt(3, 12, soldier);
  PrintAt(5, 1, 'PLAYER CONTROL:');
  PrintAt(6, 2, 'JUMP - TRIGGER BUTTON FIRST TIME');
  PrintAt(7, 2, 'PARACHUTE - TRIGGER BUTTON SECOND TIME');
  PrintAt(9, 1, 'STICK USAGE AFTER PARACHUTE IS OPENED:');
  PrintAt(10, 2, 'MOVE SOLDIER LEFT - JOYSTICK LEFT');
  PrintAt(11, 2, 'MOVE SOLDIER RIGHT - JOYSTICK RIGHT');
  PrintAt(14, 1, 'HINT:');
  PrintAt(15, 1, 'JUMP AND OPEN PARACHUTE BEFORE LANDING');
  PrintAt(16, 1, 'IN THE CENTER OF THE ISLAND.');
  PrintAt(18, 1, 'YOU GET MORE POINTS BY OPENING');
  PrintAt(19, 1, 'PARACHUTE AS LATE AS POSSIBLE.');
  PrintAt(21, 3, 'PRESS ANY KEY TO START THE GAME...');
  repeat until keypressed;
  ReadKey;
end;

// Soldier died
procedure Dead;
begin
  isDead := true;
  Dec(lives);
  Sound(0, 114, 7, 10);
  Pause(24); Sound(0, 0, 0, 0);  
  if lives = 0 then begin
    // Game status
    GotoXY(1, 1);
    Writeln('SCORE=', score, ' LIVES=', lives, ' JUMPS=', loop, '  ');
    // Game over
    PrintAt(10, 15, 'GAME OVER');
    PrintAt(13, 6, 'PRESS ANY KEY FOR NEW GAME...');

    for i := 0 to 12 do begin
      Sound(0, 130+i*8, 7, 10); Pause(4);
    end;
    Sound(0, 0, 0, 0);
    
    repeat until keypressed;
    ReadKey;
    speed := 0;
  end;
end;

procedure Jump;
begin
  Pause(10);
  c := a; d := b;
  repeat
    // Parachute is opened
    if jmp = 1 then begin
      Pause(16);
      // Joystick control
      case stick0 of
        joy_right: begin
          PrintAt(c, d, ' ');
          Inc(d); if d > 37 then d := 37;
        end;
        joy_left: begin
          PrintAt(c, d, ' ');
          Dec(d); if d < 1 then d := 1;
        end;
      end;
      // Draw soldier in jump
      PrintAt(c, d, soldier01);
      PrintAt(c+1, d, soldier);
    // Parachute is not yet opened
    end else begin
      PrintAt(c, d, soldier);
    end;
    PrintAt(c-1, d-1, '   ');
    // Soldier opened a parachute
    if (strig0 = 0) and (jmp = 0) then begin
      jmp := 1;
      z := c;
    end;
    
    // Soldier successfully landed
    if (c = 19) and (d = islandX+1) and (jmp = 1) then begin
      PrintAt(c, d, ' ');
      PrintAt(c-1, d, ' ');
      Inc(score, z);
      Sound(0, 108, 7, 10);
      Pause(5); Sound(0, 0, 0, 0);
      Break;
    end;

    Pause(4);
    Inc(c);
  until c > 19;
    
  // Soldier didn't succeed
  if c > 19 then begin
    PrintAt(c, d, ' ');
    PrintAt(c-1, d, ' ');
    Dead;
  end;
  jmp := 0;
end;

begin
  TitleScreen;
  SetGame(2);
  Poke(53277, 3);  // Turn on P/M graphics
  Randomize;

  // Draw ground
  GotoXY(1, 23); for i := 0 to 39*3+1 do Write(ground);
  
  // Main loop
  repeat
    loop := 5;
    repeat
      // Initialize object positions
      a := planeY; b := 0;
      islandX := Random(37);
      
      // Game status
      GotoXY(1, 1);
      Writeln('SCORE=', score, ' LIVES=', lives, ' JUMPS=', loop, '  ');
      
      repeat
        PrintAt(20, islandX, 'XXX');
        PrintAt(a, b, ' pt');
        Pause(6 - speed);
        Inc(b);
        
        // Soldier jumped
        if strig0 = 0 then begin
          Jump;
          Break;
        end;
      until (b > 37) or (lives = 0);

      // The plane has gone over range
      if b > 37 then begin
        Dead;
        if lives > 0 then begin
          PrintAt(10, 7, 'TOO LATE!');
          Pause(40);
          PrintAt(10, 7, '         ');
        end;
      end;

      // No more soldiers... game over!
      if lives = 0 then begin
        SetGame(3);
        Continue;
      end;

      // Clear objects
      PrintAt(20, islandX, '   ');
      PrintAt(a, b, '   ');
      // Draw ground
      GotoXY(1, 22); for i := 0 to 39*3+1 do Write(ground);

      if (loop = 1) and not isDead then begin
        if a > 13 then begin
          PrintAt(10, 10, 'CONGRATULATIONS!');
          PrintAt(12, 2, 'YOUR MISSION IS COMPLETED.');
          PrintAt(13, 2, 'YOU SUCCEEDED TO LAND ENOUGH MEN TO');
          PrintAt(14, 2, 'PROCEED WITH ANOTHER WAVE!');
          PrintAt(18, 6, 'PRESS ANY KEY FOR NEW GAME...');
          
          for i := 0 to 18 do begin
            Sound(0, 180-i*8, 7, 10); Pause(4);
          end;
          Sound(0, 0, 0, 0);

          repeat until keypressed;
          ReadKey;
          
          tempScore := score;
          SetGame(3);
          score := tempScore;
          Inc(speed, 3);
          if speed >= 6 then speed := 6;
  
          Continue;
        end else
          Inc(planeY, 2);
      end;      
      isDead := false;
      Dec(loop);
    until loop = 0;

  // Infinite loop
  until 1=0;
end.
