{-------------------------------------------------------------------------------
  Game title: Formula 126PZ
  Ported from the book Mirko tipka na radirko
  Original author: Branislav Milosavljevic
  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE in Mad Pascal
  by Bostjan Gorisek 2017

  Version release:
  1.0: Initial version
-------------------------------------------------------------------------------}

uses
  graph, crt, joystick, zxlib;

var
  // Data for your formula 1
  _formula1 : array[0..7] of byte =
    (%00111000, %10010010, %10111010, %00111000,
     %10111010, %10010010, %00010000, %01111100);
  // Data for terrain
  _terrain : array[0..7] of byte =
    (%11111111, %11111111, %11111111, %11111111,
     %11111111, %11111111, %11111111, %11111111);

  r : byte;       // Car X coordinate
  l : byte;       // Terrain coordinate
  w : integer;    // Player score
  a : integer;    // Random number for generating dynamic terrain
  offset : byte;  // Position of erased a car

procedure InitPrg;
var
  topMem : word;  // Memory handling variable
begin
  // Set new top RAM address and character set
  topMem := SetRAM(8);

  // Redefine characters for the game
  // # - Car
  Move(_formula1, pointer(topMem + 3*8), SizeOf(_formula1));
  // $ - Terrain tile
  Move(_terrain, pointer(topMem + 4*8), SizeOf(_terrain));
end;

procedure SetGame;
begin
  ClrScr;
  Randomize;

  // Start of terrain
  PrintAt(21, 0, '$$$$$$$$$$$$$$$$$$$      $$$$$$$$');

  // Init variables
  w := -21;
  l := 16;
  r := 20;
end;

// Your car crashed
function Crash : boolean;
var
  ch : char;
begin
  if KeyPressed then ReadKey;

  ch := #255;
  Write(' Score: ', w);
  PrintAt(22, 2, 'Do you want to play again (Y/N)?');
  Sound(0, 140, 10, 8); Pause(19);
  Sound(0, 180, 10, 8); Pause(19);
  Sound(0, 100, 10, 8); Pause(20);
  Sound(0, 0, 0, 0);

  repeat
    Flash(1, r, '#', '#');

    if KeyPressed then begin
      ch := UpCase(ReadKey);
      result := (ch = 'Y');
    end;
  until (ch = 'Y') or (ch = 'N');

  if ch = 'N' then Halt(0);
end;

begin
  // Set vertical scroll feature
  Poke(622,255);

  // Set screen
  InitGraph(0);
  TextBackground(0); Poke(752, 1);

  InitPrg;

  // Title
  Write(eol, 'Game title: Formula 126PZ',
        eol, eol, 'Original author:',
        eol, 'Branislav Milosavljevic',
        eol, eol, 'Ported to Atari XL/XE in Mad Pascal',
        eol, 'by Bostjan Gorisek 2017');
  PrintAt(12, 12, '#');
  PrintAt(22, 2, 'Press any key to start a game');

  // Wait until key is pressed and start a game
  repeat until KeyPressed;
  ReadKey;

  SetGame;

  // Main game loop
  repeat
    // Joystick control
    if STICK0 = 11 then begin
      Dec(r); offset := 0;
    end;
    if STICK0 = 7 then begin
      Inc(r); offset := 1;
    end;

    // New terrain offset
    a := Random(4) - 2;
    l := l + sgn(a);
    Inc(w);  // Increase score

    if l >= 19 then l := 19;
    if l <= 1 then l := 1;
    PrintAt(21, l, '$$        $$');

    // Terrain and other car obstacles
    // plus score calculation
    if Random < .3 then begin
      PrintAt(21, l + 5, '#');
      Inc(w, 2);
    end
    else if Random < .2 then begin
      PrintAt(21, l + 3, '##');
      Inc(w, 3);
    end
    else if Random < .1 then begin
      PrintAt(21, l + 5, '#  #');
      Inc(w, 4);
    end;

    // Set lines for scroll
    Write(EOL, EOL, EOL);

    // Check if car crashes
    if GetPixel(r, 1) <> 32 then begin
       if Crash then begin
         SetGame;
         Continue;
       end;
    end;

    // Draw our car
    PrintAt(0, r - offset, '  ');
    PrintAt(1, r, '#');
  until false;
end.

