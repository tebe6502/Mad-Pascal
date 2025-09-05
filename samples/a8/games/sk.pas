{-------------------------------------------------------------------------------
  Game title: Stupid Kangaroo
  Version: 1.1
  Ported from the book Mirko tipka na radirko
  Original author: Marjan Music
  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE/400/800 in Mad Pascal: Bostjan Gorisek 2016

  Version releases:
  1.0: Original version
  1.1: - Additional level added
       - High score tracking added
       - Final score when game is over
       - Modified story text
       - Some level modifications to make playing a bit harder (but not to much)
       - Fixed disappearance of kangaroo in some cases
       - Background layer box on finishing all levels to make text more clearer
-------------------------------------------------------------------------------}

uses
  graph, crt, sysutils, joystick, zxlib;

var
  f      : file;
  topMem : word;
  CHBAS  : byte absolute $2F4;
  RAMTOP : byte absolute $6A;

  // Data for new characters
  // Brick
  _brick : array[0..7] of byte = (255, 129, 129, 129, 129, 129, 129, 255);
  // Kangaroo - right side
  _hero_right : array[0..7] of byte = (24, 24, 16, 60, 48, 120, 136, 4);
  // Kangaroo - left side
  _hero_left : array[0..7] of byte = (24, 24, 8, 60, 12, 30, 17, 32);
  // Water
  _water : array[0..7] of byte = (255, 255, 255, 255, 255, 255, 255, 255);

  score, highScore : word;  // Score and high score
  level,        // Level
  men,          // Lives
  y, x,         // Kangaroo position
  kx, ky,       // Target brick position
  e, r,
  q,
  qw : byte;  // Flag to detect all levels finished
  hero : char = Chr(Ord('$') + $80);   // Our kangaroo hero

procedure SetGame(flag : byte);
begin
  if flag = 1 then begin
    // Set channel for text in mode 1
    assign(f, 'S:'); rewrite(f, 1);
    // Set text mode 1 (20 x 24)
    InitGraph(1 + 16);

    // Set new character set
    topMem := RAMTOP - 8;
    topMem := topMem * 256;
    CHBAS := topMem div 256;
    move(pointer(57344), pointer(topMem), 1023);

    // Redefine characters for the game
    move(_brick, pointer(topMem+3*8), sizeOf(_brick));            // Brick (char #)
    move(_hero_right, pointer(topMem+4*8), sizeOf(_hero_right));  // Kangaroo - right side (char $)
    move(_hero_left, pointer(topMem+5*8), sizeOf(_hero_left));    // Kangaroo - left side (char %)
    move(_water, pointer(topMem+49*8), sizeOf(_water));           // Water (char q inverse)

    highScore := 0;
  end else begin
    score := 0;  // Score
    level := 1;  // Level
    men := 3;    // Lives
    q := 0;
    qw := 0;
  end;
end;

procedure TitleMusic;
begin
  repeat
    Sound(0, 91, 7, 10); Pause(14); Sound(0, 121, 7, 10); Pause(14);
    Sound(0, 72, 7, 10); Pause(14); Sound(0, 64, 7, 10); Pause(14);
    Sound(0, 121, 7, 10); Pause(14); Sound(0, 81, 7, 10); Pause(14);
    Sound(0, 60, 7, 10); Pause(14); Sound(0, 121, 7, 10); Pause(14);
  until keypressed;
  ReadKey; Sound(0, 0, 0, 0);
end;

procedure TitleScreen;
begin
  Poke(710, 92);  // Kangaroo color
  PrintAt(f, 0, 10, hero);
  PrintAt(f, 2, 3, 'stupid kangaroo');
  PrintAt(f, 4, 5, 'VERSION 1.1');
  PrintAt(f, 7, 0, 'YOU ARE A KANGAROO,');
  PrintAt(f, 8, 0, 'CAPTURED BY EVIL');
  PrintAt(f, 9, 0, 'KING WHO DECIDED TO');
  PrintAt(f, 10, 0, 'TEST YOUR PSYCHICAL');
  PrintAt(f, 11, 0, 'ABILITIES AND');
  PrintAt(f, 12, 0, 'INTELLIGENCE. HE WAS');
  PrintAt(f, 13, 0, 'CONVINCED YOU ARE');
  PrintAt(f, 14, 0, 'STUPID KANGAROO,');
  PrintAt(f, 15, 0, 'WHICH IS, OF COURSE');
  PrintAt(f, 16, 0, 'ABSOLUTELY NOT TRUE.');

  PrintAt(f, 18, 0, 'YOUR MISSION IS TO');
  PrintAt(f, 19, 0, 'FIND EXIT DOORS WITH');
  PrintAt(f, 20, 0, 'THE HELP OF KEYS');
  PrintAt(f, 21, 0, 'HIDDEN IN RED BRICKS');

  PrintAt(f, 23, 2, 'press any key...');
  TitleMusic;
end;

// When one life of kangaroo is lost...
function Dead : boolean;
begin
  Dec(men);
  InitGraph(1 + 16);
  CHBAS := topMem div 256;

  if score > highScore then highScore := score;

  PrintAt(f, 6, 0, 'YOU JUST REALIZED');
  PrintAt(f, 7, 0, 'THAT WATER IS FULL');
  PrintAt(f, 8, 0, 'OF CROCODILES, WHO');
  PrintAt(f, 9, 0, 'EAT KANGAROOS!');
  if men > 0 then begin
    PrintAt(f, 11, 0, 'YOU HAVE');
    PrintAt(f, 11, 9, IntToStr(men));
    PrintAt(f, 11, 11, 'MEN LEFT!');
  end else begin
    PrintAt(f, 11, 5, 'game over!');
    PrintAt(f, 14, 3, 'YOUR SCORE:');
    PrintAt(f, 14, 15, IntToStr(score));
    PrintAt(f, 16, 3, 'HIGH SCORE:');
    PrintAt(f, 16, 15, IntToStr(highScore));
  end;
  PrintAt(f, 19, 2, 'press any key...');
  if KeyPressed then ReadKey;
  repeat until KeyPressed;
  ReadKey;

  if men = 0 then begin
    InitGraph(1 + 16);
    CHBAS := topMem div 256;
    TitleScreen;
    SetGame(0);
  end;
end;

// Game playfield and levels
procedure Playfield;
var
  i : byte;
begin
  // All levels are completed. Ready for a surprise?
  if level = 6 then begin
    qw := 1;
    Level := 1;  // Level 1 again, but with a twist
    Inc(Men);    // New man for all levels finished
    for i := 5 to 14 do PrintAt(f, i, 0, '                    ');
    Flash(f, 5, 4, 6, 'FASCINATING');
    PrintAt(f, 7, 0, 'BUT EVIL KING');
    PrintAt(f, 8, 0, 'DECIDED TO TEST YOUR');
    PrintAt(f, 9, 0, 'SKILLS AGAIN!');
    PrintAt(f, 11, 0, 'you may find some');
    PrintAt(f, 12, 0, 'changes on your way.');
    Pause(170);
    PrintAt(f, 14, 2, 'PRESS ANY KEY...');
    TitleMusic;
  end;

  InitGraph(1 + 16);
  CHBAS := topMem div 256;
  Poke(708, 216);  // Playfield color
  Poke(709, 36);   // Target brick color
  Poke(710, 92);   // Kangaroo color
  Poke(711, 116);  // Water color

  x := 2; y := 17;
  PrintAt(f, 0, 0, 'LEVEL');
  PrintAt(f, 0, 6, IntToStr(level));
  for i := 1 to men do begin
    PrintAt(f, 0, 7+i, Chr(Ord('$') + $80));
  end;
  PrintAt(f, 0, 12, 'SCORE');
  PrintAt(f, 0, 18, IntToStr(score));
  e := x; r := y; q := 0;

  // Game playfield
  PrintAt(f,  1, 0, '####################');
  PrintAt(f, 19, 0, '#####            ###');
  PrintAt(f, 20, 0, '#####            ###');
  PrintAt(f, 21, 0, '#####            ###');
  PrintAt(f, 22, 0, '####################');
  for i := 2 to 18 do begin
    PrintAt(f, i, 0, '#');
    PrintAt(f, i, 19, '#');
  end;
  for i := 5 to 16 do begin
    PrintAt(f, 20, i, Chr(Ord('q') + $80));
    PrintAt(f, 21, i, Chr(Ord('q') + $80));
  end;

  Sound(0, 121, 7, 10); Pause(22); Sound(0, 114, 7, 10); Pause(22);
  Sound(0, 108, 7, 10); Pause(22); Sound(0, 102, 7, 10); Pause(22);
  Sound(0, 114, 7, 10); Pause(22); Sound(0, 121, 7, 10); Pause(16);
  Sound(0, 136, 7, 10); Pause(16); Sound(0, 144, 7, 10); Pause(16);
  Sound(0, 0, 0, 0);

  // Level constructor
  case level of
    1: begin
         PrintAt(f, 11, 7, '#####'); PrintAt(f, 14, 1, '####');
         PrintAt(f, 14, 16, '##'); PrintAt(f, 16, 7, '#####');
         ky := 11; kx := 9;
       end;
    2: begin
         PrintAt(f, 14, 1, '##'); PrintAt(f, 13, 6, '#');
         PrintAt(f, 14, 10, '#'); PrintAt(f, 13, 15, '##');
         PrintAt(f, 16, 12, '##'); PrintAt(f, 17, 7, '##');
         PrintAt(f, 16, 16, '#'); PrintAt(f, 17, 16, '#');
         PrintAt(f, 18, 16, '#');
         ky := 14; kx := 1;
       end;
    3: begin
         PrintAt(f, 4, 1, '####');
         for i := 1 to 3 do begin
           PrintAt(f, 21-i*3, i*4, '##');
           PrintAt(f, i*3+3, i*4+3, '##');
         end;
         PrintAt(f, 7, 16, '#'); PrintAt(f, 8, 16, '#');
         ky := 4; kx := 1;
       end;
    4: begin
         PrintAt(f, 19, 8, '#'); PrintAt(f, 19, 13, '#');
         for i := 1 to 3 do begin
           PrintAt(f, i*5+1, 1, '#');
           if i > 1 then PrintAt(f, i*5-1, 4, '#');
         end;
         PrintAt(f, 12, 16, '#');
         PrintAt(f, 13, 16, '#'); PrintAt(f, 14, 16, '#');
         ky := 4; kx := 4;
       end;
    5: begin
         for i := 1 to 3 do begin
           PrintAt(f, i+16, 6, '#');
           PrintAt(f, i+14, 9, '#');
           PrintAt(f, i+12, 11, '#');
         end;
         for i := 1 to 8 do PrintAt(f, i+8, 15, '#');
         PrintAt(f, 10, 6, '#'); PrintAt(f, 8, 3, '#'); PrintAt(f, 6, 7, '#');
         for i := 1 to 12 do PrintAt(f, i+4, 17, '#');
         PrintAt(f, 11, 10, '#');
         ky := 5; kx := 11;
       end;
  end;
  // Target brick
  PrintAt(f, ky, kx, 'q');
end;

// Brick is reached, time for new level of game
procedure BrickFound;
begin
  Sound(0,144,7,10); Delay(100); Sound(0, 0, 0, 0);
  Sound(0,96,7,10); Delay(100); Sound(0, 0, 0, 0);
  PrintAt(f, 15, 19, ' '); PrintAt(f, 16, 19, ' ');
  PrintAt(f, ky, kx, '#');
  Inc(Score);  // One point for finding red brick
  PrintAt(f, 0, 18, IntToStr(score));
  kx := 0; ky := 0;
end;

begin
  SetGame(0); SetGame(1);
  TitleScreen;
  Playfield;

  // Main loop
  repeat
    if qw = 1 then Randomize;
    e := x; r := y;
    if (y > 18) and (x > 4) then begin
      Dead;
      Playfield;
      Continue;
    end;
    if Screen(f, y+1, x) <> ' ' then begin
      q := 2;
      // A bitter surprise in case kangaroo finished all levels
      // to make game more challenging
      if (qw = 1) and (Random(10) = 1) then begin
        PrintAt(f, y+1, x, ' ');
        PrintAt(f, Random(18)+1, Random(15)+2, '#');
      end;
    end;
    if q <> -1 then begin
      Dec(r); Dec(q);
      if q = 1 then begin
        Sound(0, 121, 7, 10); Delay(55); Sound(0, 0, 0, 0);
      end;
    end;
    PrintAt(f, y, x, ' ');

    // Joystick control
    case joy_1 of
      joy_right: begin
        hero := Chr(Ord('$') + $80);
        Inc(e);
        if (e > 18) and (kx > 0) then e := 18;
      end;
      joy_left: begin
        hero := Chr(Ord('%') + $80);
        Dec(e);
        if e < 1 then e := 1;
      end;
    end;

    // Level finished
    if e > 19 then begin
      Inc(level);  // New level
      Score := Score + level*2;  // Score adds up
      Playfield;
      Continue;
    end;

    if Screen(f, r, e) <> ' ' then begin
      PrintAt(f, y, x, hero);
      Continue;
    end else if (Screen(f, r+1, e) = ' ') and (q = byte(-1)) then begin
      Inc(r);
    end;

    // Make kangaroo to move constantly
    y := r; x := e;
    PrintAt(f, y, x, hero);
    delay(60);

    // Brick is reached
    if  (y = ky - 1) and (x = kx) then BrickFound;

  // Infinite loop
  until 1=0;
  Close(f);
end.
