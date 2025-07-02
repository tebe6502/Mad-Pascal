//
// P/M Graphics demonstration
// by Bostjan Gorisek 2015
//
// Developed in Mad-Pascal by Tebe / Madteam
//

uses crt, graph;

const
  max = 10;  // Number of player 0 data values

var
  p0Data : array [0..max] of byte =		// Draw player 0 image
  (
  60,
  66,
  129,
  165,
  129,
  153,
  129,
  165,
  153,
  66,
  60
  );

  px0 : byte = 120;  // Sprite X position
  py0 : byte = 60;   // Sprite Y position
  pmgMem : Word;

begin
  // Set graphics mode and playfield colors

  Poke(710, 0); Poke(712, 0);
  Poke(752, 1);  // Cursor off

  writeln(eol,'P/M Graphics demonstration');
  writeln(eol,'by Bostjan Gorisek 2015',eol);

  // Initialize P/M graphics
  Poke(53277, 0);
  pmgMem := Peek(106) - 8;
  Poke(54279, pmgMem);

  pmgMem := pmgMem * 256;
  Poke(559, 46);


  // Clear player 0 memory
  fillchar(pointer(pmgMem+512), 128, 0);

  // Draw player 0

  // Vertical position of player 0
  Move(p0Data, pointer(pmgMem+512+py0), sizeof(p0Data));

  Poke(53277,3);  // Turn on P/M graphics
  Poke(53256,1);  // Size of player 0 (double size)
  Poke(704,183);  // Player 0 color
  Poke(53248,px0);  // Horizontal position of player 0


  repeat until keypressed;

  // Reset P/M graphics
  InitGraph(0);
  Poke(53277, 0);
end.
