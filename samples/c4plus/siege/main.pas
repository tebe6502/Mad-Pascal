// set Z flag to 2

{$i 'inc/const.inc'}
{$i 'inc/types.inc'}
{$i 'inc/globals.inc'}
{$i 'inc/tools.inc'}
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

    animateObstacles; animateBackground;

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
  initPlayfield;

  setPlayer(@player1,  3, Random(18) + 3, direction[Random(4)], AI_SAPPER, PLY1_COLOUR, true);
  setPlayer(@player2, 36, Random(18) + 3, direction[Random(4)], AI_SAPPER, PLY2_COLOUR, true);

  printXY('ai calibration, computing,'~, 2, 0, $71);
  printXY(' * wait * '~, 28, 0, $71 + $80);

  printBigXY(3, 3, $51, 'tron'~);
  printBigXY(11, 13, $51, '+4'~);

  repeat
    pause(4);

    ply := @player1; playerMove;
    ply := @player2; playerMove;

    animateBackground;
  until (not player1.isAlive) or (not player2.isAlive);
end;

//-----------------------------------------------------------------------------

begin
  initFonts;

  repeat
    welcome;

    initScore; gameOver := false; level := 1;

    repeat mainLoop until isGameOver;

    showScore; endScreen;
  until false;

end.

//-----------------------------------------------------------------------------