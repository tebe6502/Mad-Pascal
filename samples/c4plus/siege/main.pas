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

    animateObstacles;

    pause(2); // 1 fast; 2 normal; 3 slow
    ply := @player2; playerMove;
    ply := @player3; playerMove;
    ply := @player4; playerMove;
  until isOneLeft;

  updateScore; pause(100); nextLevel;
end;

//-----------------------------------------------------------------------------

begin
  initFonts;

  repeat
    initScore; gameOver := false; level := 1;

    repeat mainLoop until isGameOver;

    showScore; endScreen; pause(200);
  until false;

end.

//-----------------------------------------------------------------------------