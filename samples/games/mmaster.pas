{------------------------------------------------------------------------------
  Game title: Asteroids
  Ported from the book Mirko tipka na radirko
  Publisher: Moj mikro magazine
  Original author: Ivan Zrimsek

  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE in Mad Pascal by Bostjan Gorisek 2019

  Version releases:
  1.0: Initial version
------------------------------------------------------------------------------}

uses
  graph, crt, joystick, sysutils, zxlib;

var
   // Data for your ship
   _shipPart01 : array[0..7] of byte = (0, 3, 15, 15, 120, 200, 255, 56);
   _shipPart02 : array[0..7] of byte = (0, 192, 240, 240, 30, 19, 255, 28);

   // Explosion data
   _explosion01 : array[0..7] of byte = (0, 4, 34, 18, 1, 68, 50, 9);
   _explosion02 : array[0..7] of byte = (9, 50, 68, 1, 18, 34, 4, 0);
   _explosion03 : array[0..7] of byte = (0, 8, 170, 42, 73, 65, 137, 137);
   _explosion04 : array[0..7] of byte = (144, 7, 34, 128, 72, 68, 32, 0);
   _explosion05 : array[0..7] of byte = (0, 32, 68, 72, 128, 3, 76, 144);

   // Asteroid data
   _asteroid01 : array[0..7] of byte = (62,33,255,129,129,65,37,26);
   _asteroid02 : array[0..7] of byte = (112,148,138,65,129,129,94,32);
   _asteroid03 : array[0..7] of byte = (0,0,24,36,36,56,0,0);
   _asteroid04 : array[0..7] of byte = (0,0,48,40,48,32,0,0);
   _asteroid05 : array[0..7] of byte = (0,24,40,40,16,0,0,0);
   _asteroid06 : array[0..7] of byte = (112,136,136,68,40,48,0,0);
   _asteroid07 : array[0..7] of byte = (0,0,0,56,44,6,0,0);
   _asteroid08 : array[0..7] of byte = (0,0,30,18,34,84,232,0);
   _asteroid09 : array[0..7] of byte = (94,177,130,228,34,65,66,60);
   _asteroid10 : array[0..7] of byte = (0,62,65,66,34,17,14,0);
   _asteroid11 : array[0..7] of byte = (96,144,144,116,10,49,65,126);
   _asteroid12 : array[0..7] of byte = (62,65,242,9,247,136,144,96);
   _asteroid13 : array[0..7] of byte = (145,82,16,7,244,8,74,137);
   _asteroid14 : array[0..7] of byte = (100,24,198,0,222,0,24,102);

  t : integer;         // Your score
  b : integer = 13;    // Initial high score
  p : byte;            // Number of lives
  l : byte;            // Your ship's x coordinate
  f : byte;            // Number of shields
  ship : string[3];    // Ship data holder
  ll : byte;           // Asteroid x coordinate
  isShield : boolean;  // Flag to check if shield was used
  playerName : string[15];  // Player's name
  descr : string = '';
  i : byte;

procedure InitPrg;
var
  topMem : word;  // Memory handling variable
begin
  // Set new top RAM address for character set
  topMem := SetRAM(8);

  // Redefine characters for the game
  // Your ship
  Move(_shipPart01, pointer(topMem + 3*8), SizeOf(_shipPart01));
  Move(_shipPart02, pointer(topMem + 4*8), SizeOf(_shipPart02));
  // Asteroids
  Move(_asteroid01, pointer(topMem + 64*8), SizeOf(_asteroid01));
  Move(_asteroid02, pointer(topMem + 65*8), SizeOf(_asteroid01));
  Move(_asteroid03, pointer(topMem + 66*8), SizeOf(_asteroid01));
  Move(_asteroid04, pointer(topMem + 67*8), SizeOf(_asteroid01));
  Move(_asteroid05, pointer(topMem + 68*8), SizeOf(_asteroid01));
  Move(_asteroid06, pointer(topMem + 69*8), SizeOf(_asteroid01));
  Move(_asteroid07, pointer(topMem + 70*8), SizeOf(_asteroid01));
  Move(_asteroid08, pointer(topMem + 71*8), SizeOf(_asteroid01));
  Move(_asteroid09, pointer(topMem + 72*8), SizeOf(_asteroid01));
  Move(_asteroid10, pointer(topMem + 73*8), SizeOf(_asteroid01));
  Move(_asteroid11, pointer(topMem + 74*8), SizeOf(_asteroid01));
  Move(_asteroid12, pointer(topMem + 75*8), SizeOf(_asteroid01));
  Move(_asteroid13, pointer(topMem + 76*8), SizeOf(_asteroid01));
  Move(_asteroid14, pointer(topMem + 77*8), SizeOf(_asteroid01));
  // Explosion
  Move(_explosion01, pointer(topMem + 78*8), SizeOf(_explosion01));
  Move(_explosion02, pointer(topMem + 79*8), SizeOf(_explosion01));
  Move(_explosion03, pointer(topMem + 80*8), SizeOf(_explosion01));
  Move(_explosion04, pointer(topMem + 81*8), SizeOf(_explosion01));
  Move(_explosion05, pointer(topMem + 82*8), SizeOf(_explosion01));

  Randomize;
end;

procedure InitGame;
begin
  Poke(622, 1);
  InitGraph(0);
  Poke(710, 0); Poke(752, 1);
  InitPrg;
  Poke(622, 1);

  p := 5;   // You have 5 lives at the start
  l := 15;  // Ship's starting x position
  f := 6;   // Number of available shields - 1
  t := 0;   // Your inicial score
  isShield := false;
end;

procedure GameOver;
var
  ch : char;
begin
  InitGraph(0);
  Poke(710, 9*16 + 2);
  Poke(712, 9*16 + 2);

  if t > b then begin
    b := t;
    Write(eol, 'You have new high score!',
          eol, eol, 'Enter your name:');
    if KeyPressed then ReadKey;
    ReadLn(playerName);
  end;

  ClrScr;
  Write('Your score = ', t,
        eol, 'Best score = ', b, ' (', playerName, ')');

  ch := #255;
  PrintAt(10, 0, 'Do you want to play again (Y/N)?');

  repeat
    if KeyPressed then begin
      ch := UpCase(ReadKey);
    end;
  until (ch = 'Y') or (ch = 'N');

  if ch = 'N' then begin
    ClrScr;
    Writeln('Thank you for the game, goodbye!',
            eol, 'Press any key to continue!');
    repeat until keypressed;
    if KeyPressed then ReadKey;
    Halt(0);
  end;

  //repeat until keypressed;
  if KeyPressed then ReadKey;

  InitGame;
end;

begin
  descr := Concat(descr, 'USE JOYSTICK TO MOVE');
  descr := Concat(descr, 'YOUR SHIP LEFT OR   ');
  descr := Concat(descr, 'RIGHT AND PRESS     ');
  descr := Concat(descr, 'JOYSTICK TRIGGER TO ');
  descr := Concat(descr, 'USE AVAILABLE SHIELD');
  descr := Concat(descr, 'TO PROTECT YOU FROM ');
  descr := Concat(descr, 'ASTEROIDS');
  ZXTitle('moj mikro asteroids', 0, 0, 'Ivan Zrimsek', 'Bostjan Gorisek 2019',
          descr, 'Originally published by Moj Mikro');
  InitGame;

  repeat
    // Draw your ship
    ship := Concat('#', Chr(p + 48 + $80));
    ship := Concat(ship, '$');
    PrintAt(7, l, ship);
    PrintAt(6, l, '   ');

    // Move your ship
    case STICK0 of
      // To the left
      11: begin
        Dec(l);
        PrintAt(7, l + 3, ' ');
        PrintAt(7, l, ship);
        PrintAt(6, l, '   ');
      end;
      // To the right
      7: begin
        Inc(l);
        PrintAt(7, l - 1, ' ');
        PrintAt(7, l, ship);
        PrintAt(6, l, '   ');
      end;
    end;

    // Check if shield is used
    if (STRIG0 = 0) and (f > 0) then begin
      Dec(f);
      if f > 0 then begin
        isShield := true;
        PrintAt(8, l, #15#16#17);
      end;
    end;

    // Check ship's x coordinate boundaries
    if l < 2 then
      l := 2
    else if l > 34 then begin
      l := 34;
    end;

    // Shield was used to protect you from asteroid collision
    if isShield then begin
      isShield := false;
    end
    // Shield was not used while your ship was hit by asteroid
    else if (GetPixel(l, 8) <> 32)
       or (GetPixel(l + 1, 8) <> 32)
       or (GetPixel(l + 2, 8) <> 32) then
    begin
      Dec(p);

      // Game over
      if p < 1 then begin
        for i := 1 to 3 do begin
          // Explosion
          PrintAt(6, l, #32#32#32);
          PrintAt(7, l, #32#17#32);
          PrintAt(8, l, #32#32#32);
          Pause(3);
          PrintAt(6, l, #14#16#18);
          PrintAt(7, l, #13#32#13);
          PrintAt(8, l, #15#16#17);
          Pause(3);
        end;
        for i := 6 to 8 do begin
          PrintAt(i, l, '   ');
          Pause(3);
        end;

        GameOver;
        continue;
      end;
    end;

    // Draw two new asteroids on each iteration
    ll := l;
    PrintAt(21, Random(38) + 1, Chr(Random(ll)));
    PrintAt(21, Random(38) + 1, Chr(Random(ll)));

    // You score
    Inc(t);

    // Set lines for scroll
    Write(EOL, EOL, EOL);
  until false;
end.