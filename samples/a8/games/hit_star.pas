{-------------------------------------------------------------------------------
  Game title: Hit Star
  Ported from the book Mirko tipka na radirko
  Publisher: Moj mikro magazine
  Original author: Stanislav Ogrinc
  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE in Mad Pascal
  by Bostjan Gorisek 2017

  Version releases:
  1.0: Initial version
-------------------------------------------------------------------------------}

uses
  graph, crt, joystick, zxlib, sysutils;

const
  notes : array[0..18] of byte = (
    7, 7, 7, 1, 7, 5, 4, 2, 1, 7, 5, 4, 2, 12, 7, 5, 4, 5, 2);

  delays : array[0..18] of byte = (
    15, 15, 15, 90, 90, 15, 15, 15, 90,
    45, 15, 15, 15, 90, 45, 15, 15, 15, 100);

var
  // Data for laser shoot
  _shoot : array[0..7] of byte =
    (0, 24, 24, 24, 24, 24, 24, 0);
  // Data for a hit
  _hit : array[0..7] of byte =
    (153, 66, 36, 129, 129, 36, 66, 153);

  f : file;
  ay, by, beepx,
  a, b, s, sc : byte;
  hsc : byte = 50;
  name : string[15] = 'Atari';
  isGame : boolean;

procedure InitPrg;
var
  topMem : word;  // Memory handling variable
begin
  InitGraph(0);
  Poke(710, 14); Poke(709, 50);
  Poke(752, 1);

  // Set new top RAM address and character set
  topMem := SetRAM(8);

  // Redefine characters for the game
  // # - Car
  Move(_shoot, pointer(topMem + 3*8), SizeOf(_shoot));
  // $ - Terrain tile
  Move(_hit, pointer(topMem + 4*8), SizeOf(_hit));
end;

procedure InitGame;
begin
  // Init variables
  beepx := 0; sc := 0;
  ay := 0; by := 31;
  a := 0; b := 0;
  isGame := true;

  // Start of terrain
  PrintAt(0, 0, '****************');
  PrintAt(21, ay, '*');
  PrintAt(21, by, '*');
  PrintAt(23, 2, 'Number of shoots: 0');
end;

procedure Shoot;
var
  n : byte;
begin
  s := ay;

  if screen(0, s) = '*' then beepx := 1;

  for n := 0 to 20 do begin
    PrintAt(20 - n, s, '#');
    PrintAt(20 - n + 1, s, ' ');
    Sound(0, 180 - n*3, 10, 8);
    Delay(40);
  end;

  Sound(0, 0, 0, 0);

  PrintAt(21, 0, '*');
  PrintAt(21, 31, '*');

  if beepx = 1 then begin
    PrintAt(0, s, '$');
    Sound(0, 140, 8, 8); Pause(20);
    Sound(0, 0, 0, 0);
  end;

  Inc(sc);
  PrintAt(23, 20, IntToStr(sc));

  PrintAt(0, s, ' ');
  beepx := 0;
  a := 0; b := 0;
  ay := 0; by := 31;

  isGame := false;

  for n := 0 to 31 do begin
    if screen(0, n) = '*' then begin
      isGame := true;
      break;
    end;
  end;
end;

procedure GameOver;
var
  str : string;
  ch : char;
begin
  if KeyPressed then ReadKey;

  PrintAt(7, 1, 'Hurray!');
  str := Concat('You shot all stars after ', IntToStr(sc));
  str := Concat(str, ' shoots.');
  PrintAt(8, 1, str);
  PrintAt(12, 8, Concat('High record:    ', IntToStr(hsc)));
  PrintAt(13, 8, name);

  // High score reached
  if sc < hsc then begin
    hsc := sc;
    Poke(752, 0);
    PrintAt(19, 1, 'Please enter your name: ');
    Readln(name);
    PrintAt(12, 24, IntToStr(hsc));
    PrintAt(13, 8, Concat(name, '         '));
    Poke(752, 1);
  end;

  ch := #255;

  repeat
    Flash(20, 3, 'Do you want to play again (Y/N)?');

    if KeyPressed then ch := UpCase(ReadKey);
  until (ch = 'Y') or (ch = 'N');

  if ch = 'N' then begin
    Halt(0);
  end;

  InitPrg;
  InitGame;
end;

procedure TitleScreen;
var
  n : byte;
begin
  ZXTitle('hit star', 0, 6, 'Stanislav Ogrinc', 'Bostjan Gorisek 2017',
          'YOUR MISSION IS TO  SHOOT ALL STARS ON  TOP OF THE SCREEN   WITH TWO SHIPS ON   LEFT AND RIGHT SIDE.USE JOYSTICK TO MOVEYOUR SHIPS.',
          'Publisher: Moj Mikro magazine');

  // Title sound
  for n := 0 to 18 do begin
    Sound(0, 120 - notes[n]*5, 10, 8); Delay(delays[n]*7);
    Sound(0, 0, 0, 0); Delay(delays[n]*2);
  end;

  Sound(0, 0, 0, 0);
end;

begin
  TitleScreen;
  InitPrg;
  InitGame;

  repeat
    // Joystick control
    if (STICK0 = 11) and (a = 0) then begin
      a := 1;
    end;
    if (STICK0 = 7) and (b = 0) then begin
      b := 1;
    end;

    if a = 1 then begin
      if ay <> by then begin
        PrintAt(21, ay, ' *');
        Inc(ay);
        Delay(30 - 15*b);
      end;

      if ay = by then Shoot;
    end;

    if b = 1 then begin
      if by <> ay then begin
        Dec(by);
        PrintAt(21, by, '* ');
        Delay(30 - 15*a);
      end;

      if by = ay then Shoot;
    end;

    if not isGame then GameOver;
  until false;
end.

