//-----------------------------------------------------------------------------

{$r media/media.rc}

//-----------------------------------------------------------------------------

uses aplib;

//-----------------------------------------------------------------------------

{$i 'inc/const.inc'}
{$i 'inc/types.inc'}
{$i 'inc/globals.inc'}
{$i 'inc/tools.inc'}
{$i 'inc/interrupts.inc'}
{$i 'inc/ai.inc'}
{$i 'inc/levels.inc'}
{$i 'inc/init.inc'}

//-----------------------------------------------------------------------------

procedure playerMove;
begin
  if ply.isAlive then begin

    checkAvailDir;
    if availDir = 0 then playerBusted
    else begin

      case ply.brain of
        PLY_CTRL    : human;
        AI_STRAIGHT : aiStraight;
        AI_SAPPER   : aiSapper;
        AI_BULLY    : aiBully;
        AI_MIRROR   : aiMirror;
      end;

      drawPlayer;
    end;

  end;
end;

//-----------------------------------------------------------------------------

procedure mainLoop;
begin
  initArena; startScreen;

  repeat
    pause; ply := @player1; playerMove;

    pause(2); // 1 fast; 2 normal; 3 slow
    ply := @player2; playerMove;
    ply := @player3; playerMove;
    ply := @player4; playerMove;
  until isOneLeft;

  updateScore; pause(100); nextLevel;
end;

//-----------------------------------------------------------------------------

procedure welcome;
begin
  pause;
  initPlayfield;

  setPlayer(@player1,  3, Random(18) + 3, direction[Random(4)], AI_SAPPER, PLY1_COLOUR, true);
  setPlayer(@player2, 36, Random(18) + 3, direction[Random(4)], AI_SAPPER, PLY2_COLOUR, true);

  pause;
  printXY('ai calibration, computing,'~, 2, 0, $71);
  printXY(' * wait * '~, 28, 0, $71 + $80);

  pause;
  printBigXY(3, 3, $51, 'tron'~);
  printBigXY(11, 13, $51, '+4'~);

  repeat
    pause(4);

    ply := @player1; playerMove;
    ply := @player2; playerMove;

  until (not player1.isAlive) or (not player2.isAlive);
end;

//-----------------------------------------------------------------------------

procedure showGFX;
begin
  t0b := SETBITMAP; t1b := VIDEOMATRIX; i0b := SETMCOLOR; i1b := TED_FF12;

  SETBITMAP := 0;
  SETMCOLOR := (SETMCOLOR and $40) or $18;
  VIDEOMATRIX := %01011000;
  TED_FF12 := %00011000 or (TED_FF12 and %00000011);
  BORDER := 0;
  BACKGROUND := 0;
  COLOUR1 := 1;
  SETBITMAP := t0b or $20;

  pause(400);

  SETBITMAP := 0;
  unapl(pointer(MP_LOGO_APL), pointer(GFX));
  SETMCOLOR := (SETMCOLOR and $40) or $8;
  BORDER := $3d;
  SETBITMAP := t0b or $20;

  pause(200);

  SETBITMAP := t0b; VIDEOMATRIX := t1b; SETMCOLOR := i0b; TED_FF12 := i1b;
end;

//-----------------------------------------------------------------------------

begin

  initSystem; showGFX;

  repeat
    welcome; initScore; gameOver := false; level := 1;

    pause;
    repeat mainLoop until isGameOver;

    showScore; endScreen;
  until false;

end.

//-----------------------------------------------------------------------------