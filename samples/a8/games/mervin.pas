{------------------------------------------------------------------------------
  Game title: Mouse Mervin
  Ported from the book Mirko tipka na radirko
  Publisher: Moj mikro magazine
  Original author: Marko Jeric

  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE in Mad Pascal by Bostjan Gorisek 2019

  Version releases:
  1.0: Initial version
------------------------------------------------------------------------------}

uses
  graph, crt, joystick, zxlib, sysutils;

var
   // Mervin
   _mervin : array[0..7] of byte = (65, 65, 85, 20, 85, 85, 65, 20);

   // Cheese
   _cheese : array[0..7] of byte = (0, 40, 170, 162, 170, 138, 40, 0);

   // Ship
   _ship01 : array[0..7] of byte = (48, 48, 240, 255, 255, 240, 48, 48);
   _ship02 : array[0..7] of byte = (0, 60, 255, 255, 255, 255, 60, 0);
   _ship03 : array[0..7] of byte = (12, 12, 15, 255, 255, 15, 12, 12);

   // Antic 4 font set
   _char_s : array[0..7] of byte = (0, 60, 64, 48, 4, 4, 112, 0);
   _char_c : array[0..7] of byte = (0, 60, 64, 64, 64, 64, 60, 0);
   _char_o : array[0..7] of byte = (0, 48, 68, 68, 68, 68, 48, 0);
   _char_r : array[0..7] of byte = (0, 112, 68, 68, 112, 76, 68, 0);
   _char_e : array[0..7] of byte = (0, 124, 64, 124, 64, 64, 124, 0);
   _char_h : array[0..7] of byte = (0, 68, 68, 116, 68, 68, 68, 0);
   _char_i : array[0..7] of byte = (0, 124, 16, 16, 16, 16, 124, 0);
   _char_g : array[0..7] of byte = (0, 60, 64, 64, 76, 68, 60, 0);
   _char_v : array[0..7] of byte = (0, 68, 68, 68, 68, 48, 16, 0);
   _char_l : array[0..7] of byte = (0, 64, 64, 64, 64, 64, 124, 0);
   _num_0 : array[0..7] of byte = (0, 60, 195, 195, 195, 195, 60, 0);
   _num_1 : array[0..7] of byte = (0, 12, 60, 12, 12, 12, 63, 0);
   _num_2 : array[0..7] of byte = (0, 60, 195, 3, 60, 240, 255, 0);
   _num_3 : array[0..7] of byte = (0, 60, 3, 60, 3, 3, 60, 0);
   _num_4 : array[0..7] of byte = (0, 12, 60, 60, 236, 255, 12, 0);
   _num_5 : array[0..7] of byte = (0, 63, 48, 60, 3, 51, 12, 0);
   _num_6 : array[0..7] of byte = (0, 48, 192, 240, 204, 252, 48, 0);
   _num_7 : array[0..7] of byte = (0, 252, 12, 12, 48, 48, 48, 0);
   _num_8 : array[0..7] of byte = (0, 60, 195, 60, 255, 195, 60, 0);
   _num_9 : array[0..7] of byte = (0, 252, 204, 252, 12, 12, 240, 0);

  fn : file;  // Variable handler for device 'S:' for displaying text mode 1
  ch : char;  // Character holder

  n : byte;        // Ship x coordinate
  y, x : byte;     // Mervin coordinates
  dy, dx : byte;   // Erase previous Mervin position
  b, a : integer;  // Mervin direction
  level : byte;    // Level of play (1 - easy, 2 - hard)
  s : integer;     // Your score
  c : integer;     // Number of cheese hit
  highScore : integer = 0;    // High score
  loop : integer = 34*7;  // Number of cheese required to finish a screen (eat all cheese)
  m : real;     // Random number to move Mervin more randomly in x position
  i, j : byte;  // for counter variables
  cnt : byte;   // Indicator for third screen to make game more interesting
  q : byte;     // Number of lives
  mervin : string[1] = '#';  // Mouse Mervin
  _space : string[1] = ' ';  // Space
  part01 : string[1] = #22;  // Mouse Mervin
  part02 : string[1] = #13;  // Mouse Mervin
  part03 : string[1] = #6;  // Mouse Mervin
  part04 : string[1] = #7;  // Mouse Mervin
  videoPtr : ^byte;
  pt : ^byte;


procedure InitChars;
var
  topMem : word;  // Memory handling variable
begin
  // Set new top RAM address for character set
  topMem := SetRAM(14);

  // Redefine characters for the game
  Move(_mervin, pointer(topMem + 3*8), SizeOf(_mervin));
  Move(_cheese, pointer(topMem + 4*8), SizeOf(_mervin));
  Move(_ship01, pointer(topMem + 5*8), SizeOf(_ship01));
  Move(_ship02, pointer(topMem + 6*8), SizeOf(_ship01));
  Move(_ship03, pointer(topMem + 7*8), SizeOf(_ship01));

  Move(_char_s, pointer(topMem + 51*8), SizeOf(_char_s));
  Move(_char_c, pointer(topMem + 35*8), SizeOf(_char_s));
  Move(_char_o, pointer(topMem + 47*8), SizeOf(_char_s));
  Move(_char_r, pointer(topMem + 50*8), SizeOf(_char_s));
  Move(_char_e, pointer(topMem + 37*8), SizeOf(_char_s));
  Move(_char_h, pointer(topMem + 40*8), SizeOf(_char_s));
  Move(_char_i, pointer(topMem + 41*8), SizeOf(_char_s));
  Move(_char_g, pointer(topMem + 39*8), SizeOf(_char_s));
  Move(_char_v, pointer(topMem + 54*8), SizeOf(_char_s));
  Move(_char_l, pointer(topMem + 44*8), SizeOf(_char_s));

  Move(_num_0, pointer(topMem + 16*8), SizeOf(_num_0));
  Move(_num_1, pointer(topMem + 17*8), SizeOf(_num_0));
  Move(_num_2, pointer(topMem + 18*8), SizeOf(_num_0));
  Move(_num_3, pointer(topMem + 19*8), SizeOf(_num_0));
  Move(_num_4, pointer(topMem + 20*8), SizeOf(_num_0));
  Move(_num_5, pointer(topMem + 21*8), SizeOf(_num_0));
  Move(_num_6, pointer(topMem + 22*8), SizeOf(_num_0));
  Move(_num_7, pointer(topMem + 23*8), SizeOf(_num_0));
  Move(_num_8, pointer(topMem + 24*8), SizeOf(_num_0));
  Move(_num_9, pointer(topMem + 25*8), SizeOf(_num_0));

  Randomize;
end;

procedure PrintAtEx(y, x : byte; t : string);
begin
  GotoXY(x + 1, y + 1);
  blockwrite(fn, t[1], length(t));
end;

procedure Score;
begin
  PrintAtEx(0, 9, IntToStr(s));
  PrintAtEx(0, 25, IntToStr(highScore));
  PrintAtEx(0, 36, IntToStr(q));
end;

procedure InitGame;
begin
  for n := 1 to 23 do begin
    PrintAtEx(n, 2, part01);
    PrintAtEx(n, 38, part01);
  end;

  PrintAtEx(0, 2, part03);
  PrintAtEx(0, 37, part04);
  for n := 3 to 36 do begin
    PrintAtEx(0, n, part02);
  end;

  PrintAtEx(0, 3, 'SCORE');
  PrintAtEx(0, 14, 'HIGH SCORE');
  PrintAtEx(0, 30, 'LIVES');

  // Reposition cheese
  for n := 2 to 8 do begin
    PrintAtEx(n, 3, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
  end;

  c := 0; a := 1; b := 1;

  // Ship x position
  n := 15;
  // Mervin position
  x := 20;
  y := Random(10) + 5;
  dx := x; dy := y;

  Score;
end;

procedure NewGame;
begin
  InitGraph(0);
  Poke(82, 1);
  Poke(83, 38);
  Poke(752, 1);
  TextBackground(COLOR_LIGHTBLUE);
  TextColor(COLOR_GRAY1);
  Writeln(eol, 'Mouse Mervin'*);
  Writeln(eol, 'Original author: Marko Jeric',
          eol, 'Ported to Atari: Bostjan Gorisek 2019',
          eol, eol, 'Originally published by Moj Mikro');
  Write(eol, 'You control mouse Mervin, who tries to',
        'eat all cheese from the moon. To reach',
        'this goal he must use a ship which has',
        'enough rockets with fuel to launch him',
        'to the stars. You move ship left and',
        eol, 'right with the joystick to help Mervin',
        'to eat as many cheese as he can.',
        eol, eol, 'Press number (1-2) for level in which you want play a game',
        eol, eol, 'or press ''Esc'' button to exit the game');
  if KeyPressed then ReadKey;
  ch := #255;
  repeat
    if KeyPressed then begin
      ch := UpCase(ReadKey);
    end;
  until (ch = '1') or (ch = '2') or (ch = Chr(27));

  if ch = Chr(27) then begin
    Close(fn);
    Halt(0);
  end;

  level := Ord(ch) - 48;

  InitGraph(12 + 16);
  InitChars;

  q := 5;  // Mervin has 5 lives
  s := 0;
  cnt := 1;

  InitGame;
  videoPtr := pointer(DPeek(88));
end;

begin
  Assign(fn, 'S:'); Rewrite(fn, 1);
  NewGame;

  repeat
    // Mervin boundaries
    if y > 35 then begin
      Beep(0.008, 30);
      Dec(b, 2);
    end
    else if y < 4 then begin
      Beep(0.008, 30);
      Inc(b, 2);
    end;
    if x < 2 then a := -a;

    pt := pointer(word(videoPtr) + y + 40*x);

    // Mervin found cheese
    if pt^ = 4 then begin
      if (x > 1) and (x < 9) then begin
        Beep(0.008, 20);
        if level = 2 then a := -1;
        Inc(s);
        Inc(c);
        // Mervin got all cheese
        if c > loop - 4 then begin
          PrintAtEx(14, 14, 'NEW SCREEN');
          for j := 1 to 40 do begin
            Beep(0.008, j);
            Pause(2);
          end;
          InitGame;
          level := 2;
          Inc(cnt);
          PrintAtEx(14, 14, '          ');
          PrintAtEx(21, 3, '                                 2');
        end;
      end;
      Score;
    end;

    // Check if Mervin collide with your ship
    if (x > 20) and ((y > n) and (y < n + 4)) then begin
      a := -a;
      Beep(0.008, 10);
      Inc(y);
    end;

    PrintAtEx(dx, dy, _space);
    PrintAtEx(x, y, mervin);
    PrintAtEx(21, n, ' %&'' ');
    dx := x; dy := y;

    // Move your ship
    if cnt <= 2 then begin
      case STICK0 of
        11: Dec(n);  // To the left
        7: Inc(n);   // To the right
      end;
    end
    // A twist when Mervin reaches a third screen
    else begin
      case STICK0 of
        11: Inc(n);
        7: Dec(n);
      end;
    end;

    // Check ship's x coordinate boundaries
    if n < 2 then begin
      n := 2;
      PrintAtEx(21, n, part01);
    end
    else if n > 33 then begin
      n := 33;
    end;

    x := x - a;
    y := y + b;

    // Your ship didn't catch Mervin
    if x > 21 then begin
      Dec(q);
      Score;
      for i := 0 to 6 do begin
        for j := 6 downto 0 do begin
          Beep(0.009, i);
          Beep(0.009, j);
          Pause(1);
        end;
      end;
      if q = 0 then begin
        if s > highScore then highScore := s;

        PrintAtEx(13, 15, 'GAME OVER');
        for i := 1 to 6 do begin
          for j := 40 downto 0 do begin
            if j mod 5 = 0 then begin
              Beep(0.009, j);
            end;
          end;
        end;

        NewGame;
      end;

      m := Random;
      PrintAtEx(21, 3, '                                   ');
      a := 1;

      if m < 0.5 then begin
        Dec(b);
        if b = 0 then Dec(b);
      end
      else if m >= 0.5 then begin
        Inc(b);
        if b = 0 then Inc(b);
        //Dec(x);
        //y := n;
      end;

      n := 15; x := 20;
      y := Random(10) + 5;
      dx := x; dy := y;
    end
    // Some slow down
    else begin
      Pause(4);
    end;

    // Stabilize Mervin when he goes out of control :)
    if b >= 2 then
      b := 1
    else if b <= -2 then begin
      b := -1;
    end;
  until false;
end.