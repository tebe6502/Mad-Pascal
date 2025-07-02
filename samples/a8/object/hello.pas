// 1296

program Hello;

uses crt;

Type 
  TPosition = Record
    posx: cardinal;
  End;

Type 
  TPlayer = Record
    pos: TPosition;
  End;
  
Type 
  TGame = Object
    player: TPlayer;
    Constructor Build;
  End;  

Function Position_New(x, y: Byte): TPosition;
Begin
  Result.posx := x + (Word(y) shl 8);
End;

Procedure Player_Init(Var player: TPlayer; x, y: Byte);
var tt: TPlayer;
Begin
  player.pos := Position_New(x, y); 
End;

Constructor TGame.Build;
Begin
  Player_Init(player, 16, 5);
End;

Var 
  g: TGame;

begin
  g.Build;
  
  writeln(g.player.pos.posx);
  
  repeat until keypressed;
end.

