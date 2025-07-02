{-------------------------------------------------------------------------------
  Game title: Wolves
  Ported from the book Mirko tipka na radirko
  Original author: Primoz Petrlin
  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE/400/800 in Mad Pascal: Bostjan Gorisek 2016

  Version 1.1:
    - Joystick control
    - Label referencing dead wolves renamed to Dead wolves
-------------------------------------------------------------------------------}

uses
  graph, crt, sysutils, joystick;

var
  topMem : word;
  CHBAS : byte absolute $2F4;
  RAMTOP : byte absolute $6A;
  playerName : string[15] = 'M.M';
  playerScore : shortInt = 10;
  score, lives,
  a, b,          // Our hero's coordinates
  s, d  : byte;  // Wolf coordinates
  isNewGame : boolean = true;

  // Data for new characters
  _grave : array[0..6] of byte = (
    %01111100, %10000010, %10000010, %10000010, %10000010, %01010100, %11111110);  // character g
  _hero02 : array[0..7] of byte = (
    %00011100, %00101010, %00010100, %00001000, %00111111, %01001000, %00010100, %00110110);  // character c
  _dead_wolf : array[0..7] of byte = (
    %00010000, %00010000, %11111110, %00010000, %00010000, %00010000, %00010000, %00010000);  // character j
  _hero : array[0..7] of byte = (
    %00011100, %00101010, %10010100, %01001001, %00111110, %00001000, %00010100, %00110110);  // character p
  _weapon : array[0..7] of byte = (
    0, %01100000, %01100000, %01000000, %11000000, %01000000, %01000000, 0);  // character o
  _wolf : array[0..6] of byte = (
    0, %00100000, %11100010, %01111100, %00111100, %00100100, %00100100);  // character d
  _tree : array[0..7] of byte = (
    0, %00011100, %00111110, %01111111, %00111110, %00010100, %00010100, 0);  // character h

// Custom write routines
procedure PrintAt(x, y : byte; t : string); overload; begin GotoXY(x+1, y+1); Write(t); end;
procedure PrintAt(x, y : byte; t : char); overload; begin GotoXY(x+1, y+1); Write(t); end;

// New game?
function NewGame : boolean;
var
  ch : char;
begin
  if KeyPressed then ReadKey;
  Writeln(#$9b#$9b'ANOTHER GAME? (Y/N)');
  isNewGame := false;
  ch := #255;
  repeat
    if KeyPressed then begin
      ch := UpCase(ReadKey);
      isNewGame := (ch = 'Y');
    end;
  until (ch = 'Y') or (ch = 'N');

  result := isNewGame;
end;

// High score code block
function HighScore : boolean;
var
  i, j : byte;
begin
  Poke($D201, 168);
  for i:=200 downTo 100 do begin
    Poke($D200, i); Delay(10);
  end;
  ClrScr;
  for j:=1 to 10 do begin
    PrintAt(18, 16, 'HURA!'); PrintAt(18, 6, 'HURA!');
    PrintAt(20, 11, 'P');
    Delay(40);
    Poke($D200, 90);
    ClrScr;
    PrintAt(20, 11, 'c');
    Delay(40);
    Poke($D200, 154);
    for i:=6 to 16 do begin
      PrintAt(11, i, 'HURA'); PrintAt(26, i, 'HURA');
    end;
  end;
  for i:=255 downTo 60 do begin
    Poke($D200, i); Delay(10);
  end;
  FillChar(Pointer($D200), 2, 0);
  Delay(40); ClrScr; CursorOn;
  if KeyPressed then ReadKey;
  Writeln('YOU REACHED HIGH SCORE!'#$9b'ENTER YOUR NAME:');
  ReadLn(playerName);
  CursorOff;
  playerScore := score;
  result := NewGame;
end;

// Game is on
procedure Game;
var
  y, x, z, n, m : byte;
begin
  FillChar(Pointer($D200), 8, 0);
  ClrScr;
  PrintAt(1, 0, 'ppppp');
  score := 0;  // Initialize score
  lives := 5;  // You have 5 lives
  Randomize;

  // Draw trees on random locations
  for y := 1 to 38 do begin
    z := Random(22);
    x := Random(38);
    PrintAt(x, z+1, 'h');
  end;
  // Row of trees
  for y := 0 to 22 do PrintAt(38, y, 'h');

  // Hero position
  a := 11; b := 11;

  // Wolf coordinates
  d := 36; s := Random(22) + 1;

  // Game play loop
  repeat
    PrintAt(b, a, 'po');  // Hero position

    // Keep track of hero deaths
    if lives < 5 then
      PrintAt(lives+1, 0, ' g');

    PrintAt(d, s, 'd');  // Draw attacking wolf

    Dec(d);
    //if d = 0 then Continue;
    // Wolf reached your village :(
    if d = 0 then begin
      PrintAt(d+2, s, ' '); PrintAt(d, s, ' ');
      Dec(lives);
      d := 36; s := Random(22) + 1;
      if lives = 0 then begin
        break;
      end;
    end;

    PrintAt(d+2, s, ' ');

    // Hero control
    case joy_1 of
      joy_right: begin
        Inc(b);
        if b = 37 then b := 36;
        PrintAt(b-1, a, '  ');
      end;
      joy_left: begin
        Dec(b);
        if b = 1 then b := 2;
        PrintAt(b+1, a, '  ');
      end;
      joy_down: begin
        Inc(a);
        if a = 23 then a := 22;
        PrintAt(b, a-1, '  ');
      end;
      joy_up: begin
        Dec(a);
        if a = 0 then a := 1;
        PrintAt(b, a+1, '  ');
      end;
    end;

    PrintAt(b, a, 'po');  // Hero position

    // You hit a wolf
    if (a = s) and (b = d) then begin
      // beep beep
      PrintAt(d, a, ' ');
      Poke($D201, 168);
      for m := 1 to 50 do begin
        for n:=40 to 100 do Poke($D200, n);
      end;
      Poke($D200, 0);  Poke($D201, 0);
      d := 36; s := Random(22) + 1;
      Inc(score);
      GotoXY(24, 1); Write('DEAD WOLVES=', score);
      PrintAt(b+2, a, 'j');
    end;

    Delay(60);
  until lives = 0;

  ClrScr;
  if score <= playerScore then begin
    PrintAt(1, 11, 'VILLAGE PEOPLE ARE DEAD.'#$9b'YOU KILLED ');
    Write(IntToStr(score), ' WOLVES!');
    NewGame;
    //if not NewGame then Halt(0);
  end else begin
    // If you break new record...
    HighScore;
  end;
end;

begin
  // Set display mode, colors and left margin
  InitGraph(0); CursorOff;
  Poke(710, 34); Poke(709, 30); Poke(82, 1);
  //Poke($D201, 168);  // sound channel 0 volume and distortion

  // Prepare new character set
  topMem := RAMTOP - 8;
  topMem := topMem * 256;
  CHBAS := topMem div 256;
  move(pointer(57344), pointer(topMem), 1023);

  // Redefine characters for the game
  move(_grave, pointer(topMem+103*8), sizeOf(_grave));          // g
  move(_hero02, pointer(topMem+99*8), sizeOf(_hero02));         // c
  move(_dead_wolf, pointer(topMem+106*8), sizeOf(_dead_wolf));  // j
  move(_hero, pointer(topMem+112*8), sizeOf(_hero));            // p
  move(_weapon, pointer(topMem+111*8), sizeOf(_weapon));        // o
  move(_wolf, pointer(topMem+100*8), sizeOf(_wolf));            // d
  move(_tree, pointer(topMem+104*8), sizeOf(_tree));            // h

  // Title screen
  Writeln(#$9b'           ddd WOLVES ddd' +
          #$9b#$9b'SMALL VILLAGE IN BOSNIAN MOUNTAINS IS' +
          #$9b'ATTACKED BY HORD OF HUNGRY WOLVES.' +
          #$9b'YOU MUST DEFEND YOUR PEOPLE BY STOPPING' +
              'WOLVES BY ANY COST.' +
          #$9b#$9b'                  po'#$9b +
          #$9b'WHEN FIVE OF THEM REACH THE VILLAGE,' +
          #$9b'PEOPLE ARE EATEN AND GAME IS OVER.');

  // Some title music
  // Taken from the book De Re Atari
  Poke(53768, 24); Poke( 53761, 168); Poke( 53763, 168); Poke( 53765, 168);
  Poke(53767, 168); Poke( 53760, 240); Poke( 53764, 252); Poke( 53762, 28);
  Poke(53766, 49);

  // Main game loop
  repeat
    // Best score information
    Writeln(#$9b'BEST SCORE ', playerScore, ' HOLDS ', playerName);
    Writeln(#$9b#$9b'PRESS ANY KEY...');
    repeat until keypressed;
    // Game
    Game;
  until not isNewGame;
end.
