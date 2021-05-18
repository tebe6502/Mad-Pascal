{-------------------------------------------------------------------------------
  Game title         : MVSBC Galactica
  Original game title: MVSBC Galaktika
  Publisher          : Moj mikro magazine
                       Ported from the book Mirko tipka na radirko
  Original author    : Ludvik Ilovar

  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE in Mad Pascal by Bostjan Gorisek 2017

  This version is compiled with Mad Pascal 1.4.9

  Version releases:
  1.0: Initial version
-------------------------------------------------------------------------------}

uses
  graph, crt, joystick, zxlib, sysutils;

var
  // Data
  _ship01       : array[0..7] of byte = (1,3,63,127,212,127,19,32);
  _enemyShot    : array[0..7] of byte = (0,40,16,16,16,56,16,0);
  _ship02       : array[0..7] of byte = (128,192,252,254,43,254,200,4);
  _enemy        : array[0..7] of byte = (0,24,60,102,195,0,0,0);
  _key          : array[0..7] of byte = (60,66,66,60,24,24,28,30);
  _obstacle     : array[0..7] of byte = (0,153,231,90,102,36,90,219);
  _lockedDoor01 : array[0..7] of byte = (15,25,15,6,6,6,6,6);
  _lockedDoor02 : array[0..7] of byte = (6,6,6,6,6,6,3,1);
  _openedDoor01 : array[0..7] of byte = (0,64,224,191,191,224,64,0);
  _openedDoor02 : array[0..7] of byte = (0,1,3,254,252,0,0,0);
  _floor01      : array[0..7] of byte = (0, 255, 255, 255, 0, 0, 0, 0);
  _floor02      : array[0..7] of byte = (255, 255, 255, 255, 255, 255, 255, 255);

  f : file;  // Variable handler for device 'S:' for displaying text mode 1
  a : byte;  // Ships rescued
  o : byte;  // Time status
  d : word;  // Score
  q, w : byte;  // Your space ship coordinates Y and X
  y, c : byte;  // Enemy rocket coordinates Y and X
  isGame : boolean;  // Is game over?
  isShot : boolean;  // Did enemy shoot at you?
  keyStatus : byte;  // Key status
  oldChar, oldChar02, oldChar03 : char;  // Old character values

  ship : string;

procedure InitPrg;
var
  topMem : word;  // Memory handling variable
begin
  // Set text in mode 1 (20 x 24)
  Assign(f, 'S:'); Rewrite(f, 1);
  InitGraph(1 + 16);

  // Set colors
  Poke(708, 116);
  Poke(709, 50);
  Poke(710, 152);

  // Set new top RAM address and character set
  topMem := SetRAM(8);

  // Redefine characters for the game
  Move(_ship01, pointer(topMem + 3*8), SizeOf(_ship01));        // #
  Move(_enemyShot, pointer(topMem + 4*8), SizeOf(_enemyShot));  // $
  Move(_ship02, pointer(topMem + 5*8), SizeOf(_ship02));        // %
  Move(_enemy, pointer(topMem + 6*8), SizeOf(_enemy));          // &
  Move(_key, pointer(topMem + 15*8), SizeOf(_key));             // /
  Move(_obstacle, pointer(topMem + 58*8), SizeOf(_obstacle));   // Z
  Move(_lockedDoor01, pointer(topMem + 60*8), SizeOf(_lockedDoor01));  // \
  Move(_lockedDoor02, pointer(topMem + 61*8), SizeOf(_lockedDoor02));  // ]
  Move(_openedDoor01, pointer(topMem + 8*8), SizeOf(_openedDoor01));   // (
  Move(_openedDoor02, pointer(topMem + 9*8), SizeOf(_openedDoor02));   // )
  Move(_floor01, pointer(topMem + 11*8), SizeOf(_floor01));     // +
  Move(_floor02, pointer(topMem + 13*8), SizeOf(_floor02));     // -
end;

procedure NewKey;
begin
  isShot := false;
  q := 4; w := 17;

  // Draw space ship
  ship := Concat(Chr(Ord('#') + $80), Chr(Ord('%') + $80));
  PrintAt(f, q, w, ship);

  // Draw locked door
  PrintAt(f, 18, 5, Chr(Ord('\') + $80));
  PrintAt(f, 19, 5, Chr(Ord(']') + $80));
  keyStatus := 5;

  // Draw key
  PrintAt(f, 16, 1, Chr(Ord('/') + $80));
end;

procedure ShipSafeSound;
var
  i : byte;
begin
  for i := 10 to 36 do begin
    Sound(0, 180 - i*4, 10, 8);
    Delay(36);
    Sound(0, 0, 0, 0);
    Delay(36);
  end;
end;

procedure InitGame;
var
  i, j, k : byte;
begin
  Randomize;

  // Init variables
  a := 0;   // No ships currently saved
  o := 20;  // Time counter status
  d := 0;   // Score
  isGame := true;  // Game is on

  // Playground
  //
  for k := 0 to 19 do begin
    PrintAt(f, 22, k, '&');
    PrintAt(f, 0, k, Chr(Ord('+') + $80));
  end;

  PrintAt(f, 17, 0, '++++++');
  PrintAt(f, 20, 0, '-------');
  PrintAt(f, 5, 17, '+++');
  PrintAt(f, 23, 10, 'SCORE: 0');

  // Obstacles - enemies
  //
  for i := 0 to 8 do begin
    k := 3 + i*2;
    j := 2 + i;
    PrintAt(f, k, j, Chr(Ord('Z') + $80));
  end;

  for i := 0 to 9 do begin
    j := 2 + i*2;
    k := 7 + i;
    PrintAt(f, j, k, 'z');
  end;

  for i := 0 to 5 do begin
    j := 3 + i*2;
    k := 13 + i;
    PrintAt(f, j, k, 'Z');
  end;

  // Set a key to open the door
  NewKey;

  ShipSafeSound;
end;

// Clear screen
procedure Cls;
var
  i, j : byte;
  scr : word;
begin
  scr := dpeek(88);

  for i := 0 to 23 do begin
    for j := 0 to 19 do begin
      Poke(scr + j, 0);
    end;
    Inc(scr, 20);
  end;
end;

procedure GameOver;
var
  i, j : byte;
  ch : char;
begin
  // You didn't manage to collect all three space ships
  if a < 4 then begin
    for i := 10 to 32 do begin
      Sound(0, 0 + i*3, 10, 8);
      Delay(40);
      Sound(0, 0, 0, 0);
      Delay(40);
    end;
  end;

  if KeyPressed then ReadKey;

  Cls;

  // Bravo! You completed your mission to prepare three space ships for a fight
  if a = 4 then begin
    ship := Concat(Chr(Ord('#') + $80), Chr(Ord('%') + $80));

    for i := 0 to 9 do begin
      j := 0 + i*2;
      PrintAt(f, 5, j, ship);
    end;

    PrintAt(f, 10, 0, 'congratulations!!!');
    PrintAt(f, 11, 0, 'you saved the planet');
    d := d + 10*o;
  end
  // Not!
  else begin
    PrintAt(f, 9, 0, 'SORRY... YOU FAILED');
  end;

  PrintAt(f, 14, 1, 'your score is:');
  PrintAt(f, 14, 16, IntToStr(d));

  ch := #255;
  PrintAt(f, 22, 1, 'ANOTHER GAME: Y,N?');

  repeat
    if KeyPressed then begin
      ch := UpCase(ReadKey);
    end;
  until (ch = 'Y') or (ch = 'N');

  if ch = 'N' then begin
    Halt(0);
  end;

  Cls;
  InitGame;
end;

procedure TitleScreen;
var
  str : string;
begin
  str := 'YOUR MISSION IS TO  ';
  str := Concat(str, 'BRING ALL FOUR SPACE');
  str := Concat(str, 'SHIPS TO SAFETY TO  ');
  str := Concat(str, 'PREPARE THEM FOR A  ');
  str := Concat(str, 'FIGHT AGAINST ENEMY ');
  str := Concat(str, 'FROM OUTER SPACE WHO');
  str := Concat(str, 'WANTS TO DESTROY    ');
  str := Concat(str, 'YOUR PLANET.        ');
  str := Concat(str, '                    ');
  str := Concat(str, 'GOOD LUCK, HERO!');

  ZXTitle('mvsbc galactica', 0, 2, 'Ludvik Ilovar', 'Bostjan Gorisek 2017',
          str, 'Publisher: Moj Mikro magazine');
end;

procedure Obstacle(flag : byte);
begin
  if flag = 0 then begin
    if (((UpCase(oldChar02) = 'Z') or (oldChar02 = Chr(Ord('Z') + $80))
        and (UpCase(oldChar03) = ' ')))
       or
       (((UpCase(oldChar03) = 'Z') or (oldChar03 = Chr(Ord('Z') + $80))
        and (UpCase(oldChar02) = ' '))) then
    begin
      isGame := false;
    end;
  end
  else begin
    if (UpCase(oldChar02) = 'Z') or (oldChar02 = Chr(Ord('Z') + $80)) then begin
      isGame := false;
    end;
  end;
end;

begin
  TitleScreen;
  InitPrg;
  InitGame;

  repeat
    // Enemy shot from random X position
    if not isShot then begin
      isShot := true;
      y := 1;
      c := Random(17);
    end;

    // Joystick control
    case STICK0 of
      // Go left
      11: begin
            // Collision detection
            if ((keyStatus > 1) and (q > 16) and (q < 20) and (w = 6))
               or ((keyStatus = 1) and (q = 17) and (w < 7))
               or ((q = 20) and (w = 7)) then
            begin end
            // Space ship is automatically moved down when it collides with opened door
            else if (keyStatus = 1) and (q = 18) and (w = 7) then begin
              PrintAt(f, q, w, '  ');
              Inc(q); Dec(w);
              PrintAt(f, q, w, ship);
            end
            // Space ship is safe, time for new key
            else if (keyStatus = 1) and (q = 19) and (w = 4) then begin
              if KeyPressed then ReadKey;
              Inc(a);
              Inc(o);
              Inc(d, 100); PrintAt(f, 23, 17, IntToStr(d));

              PrintAt(f, 18, 5, '  ');
              PrintAt(f, q, w, '  ');
              PrintAt(f, y - 1, c, ' ');

              case a of
                1: PrintAt(f, 18, 0, ship);
                2: PrintAt(f, 19, 0, ship);
                3: PrintAt(f, 18, 2, ship);
                4: begin
                     PrintAt(f, 19, 2, ship);
                     isGame := false;
                   end;
              end;

              NewKey;

              ShipSafeSound;
            end
            else if w > 1 then begin
              Dec(w);
              oldChar02 := Screen(f, q, w);
              oldChar03 := oldChar02;
              PrintAt(f, q, w + 1, '  ');
              PrintAt(f, q, w, ship);
              Obstacle(1);
            end;
          end;
       // Go right
       7: begin
            // Collision detection
            if (q = 5) and (w = 15) then
            begin end
            else if w < 18 then begin
              Inc(w);
              oldChar02 := Screen(f, q, w + 1);
              oldChar03 := Screen(f, q, w);
              PrintAt(f, q, w - 1, '  ');
              PrintAt(f, q, w, ship);
              Obstacle(1);
            end;
          end;
      // Go up
      14: begin
            // Collision detection
            if (q = 6) and (w > 15) then
            begin end
            // Check movement limits
            else if q > 1 then begin
              Dec(q);
              oldChar02 := Screen(f, q, w);
              oldChar03 := Screen(f, q, w + 1);
              PrintAt(f, q + 1, w, '  ');
              PrintAt(f, q, w, ship);
              Obstacle(0);
            end;
          end;
      // Go down
      13: begin
            // Collision detection
            if ((q = 4) and (w > 15))
               or ((q = 16) and (w > 0) and (w < 6))
               or ((q = 19) and (w = 6))
               or ((keyStatus = 1) and (q = 17) and (w < 7)) then
            begin end
            // Check movement limits
            else if q < 20 then begin
              Inc(q);
              oldChar02 := Screen(f, q, w);
              oldChar03 := Screen(f, q, w + 1);
              PrintAt(f, q - 1, w, '  ');
              PrintAt(f, q, w, ship);
              Obstacle(0);
            end
            else
              isGame := false;
          end;
    end;

    // You picked a key - stage 1: the door is still locked
    if (keyStatus = 5) and (q = 16) and (w < 2) then begin
      for keyStatus := 10 to 30 do begin
        Sound(0, 150 - keyStatus*3, 10, 8);
        Delay(10);
        Sound(0, 0, 0, 0);
        Delay(10);
      end;

      PrintAt(f, 4, 17, Chr(Ord('/') + $80));
      ship := '#%'; PrintAt(f, q, w, ship);
      keyStatus := 2;
      Inc(d, 25); PrintAt(f, 23, 17, IntToStr(d));
    end;

    // You picked a key again - stage 2: the door is opened
    if (keyStatus = 2) and (q = 4) and (w > 15) then begin
      w := 17;
      ship := Concat(Chr(Ord('#') + $80), Chr(Ord('%') + $80));
      PrintAt(f, q, w, ship);
      PrintAt(f, q, w - 1, ' ');

      PrintAt(f, 19, 5, ' ');
      PrintAt(f, 18, 5, Concat(Chr(Ord('(') + $80), Chr(Ord(')') + $80)));
      Inc(d, 25); PrintAt(f, 23, 17, IntToStr(d));

      for keyStatus := 10 to 30 do begin
        Sound(0, 150 - keyStatus*3, 10, 8);
        Delay(10);
        Sound(0, 0, 0, 0);
        Delay(10);
      end;

      keyStatus := 1;
    end;

    // Enemy fired a laser beam at you
    if isShot then begin
      if y < 20 then begin
        // Enemy shot can't damage space ship shelter
        if (y = 17) and (c < 6) then begin
          isShot := false;
          PrintAt(f, y - 1, c, ' ');
        end
        // Key is also protected from enemy shot
        else if (y = 15) and (c = 1) then begin
          isShot := false;
          PrintAt(f, y - 1, c, ' ');
        end
        // Opened door cannot be hurt either
        else if (keyStatus = 1) and (y = 17) and (c = 6) then begin
          isShot := false;
          PrintAt(f, y - 1, c, ' ');
        end
        // Enemy shot
        else begin
          oldChar := Screen(f, y, c);

          if (UpCase(oldChar) = 'Z') or (oldChar = Chr(Ord('Z') + $80)) then begin
            if y > 1 then PrintAt(f, y - 1, c, ' ');
            PrintAt(f, y, c, oldChar);
          end
          else begin
            oldChar := Screen(f, y - 1, c);

            if (UpCase(oldChar) = 'Z') or (oldChar = Chr(Ord('Z') + $80)) then begin
              PrintAt(f, y - 1, c, oldChar);
            end
            else begin
              if y > 1 then PrintAt(f, y - 1, c, ' ');
              PrintAt(f, y, c, '$');
            end;
          end;
        end;
      end
      // Enemy shot missed you
      else begin
        isShot := false;
        PrintAt(f, y - 1, c, ' ');
      end;

      // Check if space ship is hit by enemy shot
      if (y = q) and ((c = w) or (c = w + 1)) then begin
        isGame := false;
      end;

      if not isShot then begin
        Sound(0, 180, 10, 8);
        Delay(20);
        Sound(0, 0, 0, 0);
      end;

      Inc(y);
    end;

    Pause(7);

    if not isShot then begin
      Dec(o);
      PrintAt(f, 0, o, ' ');
    end;

    if o = 0 then begin
      isGame := false;
    end;

    if not isGame then GameOver;
  until false;
end.

