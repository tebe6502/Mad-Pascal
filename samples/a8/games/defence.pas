{------------------------------------------------------------------------------
  Game title: Defence
  Ported from the book Mirko tipka na radirko
  Publisher: Moj mikro magazine
  Original author: Ales horvat

  Original game written for ZX Spectrum in Sinclair BASIC
  Ported to Atari XL/XE in Mad Pascal by Bostjan Gorisek 2019

  Version releases:
  1.0: Initial version
------------------------------------------------------------------------------}

uses
  graph, crt, joystick, zxlib;

var
  // Data for enemy ship
  _enemyShip : array[0..7] of byte =
    (0, 1, 30, 255, 30, 1, 0, 0);
  // Data for enemy explosion
  _explosion : array[0..7] of byte =
    (153, 66, 36, 129, 129, 36, 66, 153);

  f : file;
  x, y : byte;  // Your ship's coordinates
  a, b : byte;  // Bullet coordinates
  q : byte;     // Number of your winning hits
  i : byte;     // Number of times an enemy destroyed you
  e, p : byte;  // Enemy ship coordinates
  offset : integer;
  isEnemy : boolean;
  isShoot : boolean;  // Your ship fired a beam
  n1 : integer;
  n2 : byte;
  descr : string = '';

procedure InitPrg;
var
  topMem : word;  // Memory handling variable
begin
  // Set new top RAM address and character set
  topMem := SetRAM(8);

  // Redefine characters for the game
  Move(_enemyShip, pointer(topMem + 3*8), SizeOf(_enemyShip));
  Move(_explosion, pointer(topMem + 4*8), SizeOf(_explosion));
end;

procedure InitGame;
begin
  // Set text in text mode 1 (20 x 24)
  assign(f, 'S:'); rewrite(f, 1);
  InitGraph(1 + 16);

  InitPrg;

  // Init variables
  y := 10; x := 0;
  a := y; b := x;
  offset := 1; q := 0; i := 0;
  isEnemy := false;
  isShoot := false;

  // Screen playfield
  PrintAt(f, 3, 0, '********************');
  PrintAt(f, 19, 0, '********************');
  PrintAt(f, 0, 0, 'enemy score');
  PrintAt(f, 22, 0, 'your score');

  // Earth defender
  PrintAt(f, y, x, 'D');
end;

function NewGame : boolean;
var
  ch : char;
begin
  if KeyPressed then ReadKey;

  ch := #255;
  PrintAt(f, 10, 0, 'do you want to play again (Y/N)?');

  repeat
    if KeyPressed then begin
      ch := UpCase(ReadKey);
      result := (ch = 'Y');
    end;
  until (ch = 'Y') or (ch = 'N');

  if ch = 'N' then begin
    Halt(0);
  end;

  InitGame;
end;

begin
  descr := Concat(descr, 'DEFEND PLANET EARTH ');
  descr := Concat(descr, 'FROM ENEMY ATTACK   ');
  descr := Concat(descr, 'FROM OUTER SPACE!   ');
  ZXTitle('defence', 0, 6, 'Ales Horvat', 'Bostjan Gorisek 2019',
          descr, 'Originally published by Moj Mikro');

  for n1 := -20 to 30 do begin
    Beep(0.1, n1);
    Beep(0.01, n1 - 10);
  end;

  InitGame;

  repeat
    if not isEnemy then begin
      Randomize;
      e := Random(11) + 4;
      p := Random(10) + 11;
      isEnemy := true;
    end;

    // Joystick control
    if STRIG0 = 1 then begin
      case STICK0 of
        14: begin Dec(y); offset := 1; end;
        13: begin Inc(y); offset := -1; end;
      end;
    end;

    // Our ship coordinate Y limits
    if y < 4 then begin
      y := 4
    end else if y > 18 then begin
      y := 18;
    end;

    // New enemy approaching...
    if isEnemy then begin
      Dec(p);

      // Draw enemy ship
      PrintAt(f, e, p, '# ');
      Beep(0.01, 0);

      // Enemy ship destroyed you
      if p = 3 then begin
        PrintAt(f, e, p, ' ');
        PrintAt(f, 2, i, '#');
        Inc(i, 2);
        isEnemy := false;
        isShoot := false;
        // Sound indication that enemy ship reached you
        for n1 := 0 to 2 do begin
          n2 := 30;
          while n2 > 0 do begin
            if n2 mod 3 = 0 then Beep(0.01, n2);
            Dec(n2);
          end;
        end;
      end
      // You shot at enemy ship
      else if (p >= 3) and (STRIG0 = 0) then begin
        isShoot := true;
        a := y;
        b := 1;
        PrintAt(f, a, b, '----------------');
      end;

      // You hit an enemy ship
      if isShoot and (e = a) then begin
        PrintAt(f, a, b, '                ');
        PrintAt(f, e, p, '$');
        for n1 := 0 to 5 do begin
          n2 := 0;
          while n2 < 30 do begin
            if n2 mod 6 = 0 then Beep(0.01, n2);
            Inc(n2);
          end;
        end;
        PrintAt(f, e, p, ' ');
        PrintAt(f, 21, q, Chr(Ord('#') + $80));
        Inc(q, 2);
        isEnemy := false;
        isShoot := false;
      end;
    end;

    // You saved the planet
    if q = 20 then begin
      PrintAt(f, y, x, ' ');    
      PrintAt(f, 10, 0, 'The rockets are     destroyed!');
      Delay(2000);
      PrintAt(f, 14, 0, 'congratulations!!!');
      Beep(0.1, 20); Beep(0.1, 17); Beep(2, 13); Beep(0.2, 13);
      Beep(0.1, 13); Beep(0.1, 15); Beep(0.1, 17); Beep(0.1, 18);
      Beep(0.2, 20); Beep(0.2, 20); Beep(0.2, 20); Beep(0.2, 17);
      Flash(f, 14, 0, 7, 'congratulations!!!');
      //Pause(240);
      NewGame;
      Continue;
    end
    // Enemy destroyed your world
    else if i = 20 then begin
      PrintAt(f, y, x, ' ');
      PrintAt(f, 10, 1, 'enemy destroyed    your world!');
      Pause(140);
      NewGame;
      Continue;
    end;

    // Draw earth defender
    PrintAt(f, y, x, 'D');
    PrintAt(f, y + offset, x, ' ');

    // Make some delay
    Pause(5);

    // Clear your shoot
    PrintAt(f, a, b, '                ');
  until false;
end.