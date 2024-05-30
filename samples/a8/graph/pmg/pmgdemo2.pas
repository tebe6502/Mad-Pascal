//
// P/M Graphics demonstration 2
// by Bostjan Gorisek 2015
//
// Developed in Mad-Pascal by Tebe / Madteam
//

uses crt, graph, joystick;

const
  _max = 7;     // Number of player 0 data values
  _speed = 16;  // Player 0 movement speed

var
  p0Data : array [0.._max] of byte = (48,120,252,48,48,48,48,48);  // Draw player 0 image
  px0 : byte = 120;  // Sprite X position
  py0 : byte = 60;   // Sprite Y position
  pmgMem : Word;

procedure moveSprite;
begin

   Poke(pmgMem+512+py0-1, 0);
   Poke(pmgMem+512+py0+_max+1, 0);

   move(p0Data, pointer(pmgMem+512+py0), sizeof(p0Data));

end;

  
begin
  // Set graphics mode and playfield colors
  InitGraph(8);

  Poke(710, 122); Poke(712, 130);
  Poke(709, 64);
 
  // Set playfield graphics
  SetColor(1);
  Line(10,10,300,10);
  
  Rectangle(30,50,100,130);

  Circle(250,60,20);  

  // Initialize P/M graphics
  Poke(53277, 0);
  pmgMem := Peek(106) - 4;
  Poke(54279, pmgMem);    
  pmgMem := pmgMem shl 8;
  Poke(559, 46);
 
  // Clear player 0 memory
  fillchar(pointer(pmgMem+512), 128, 0);

  // Draw player 0

  // Vertical position of player 0
  moveSprite;

  Poke(53277,3);  // Turn on P/M graphics  
  Poke(53256,0);  // Size of player 0 (normal size)
  Poke(704,44);   // Player 0 color
  Poke(53248,px0);  // Horizontal position of player 0

  repeat

    case joy_1 of

    joy_left:
	begin			    // Move player 0 left
		Dec(px0);
		if px0 < 45 then px0 := 45;
		Poke(53248,px0);
		Delay(_speed);
	end;

     joy_right:
	begin			    // Move player 0 right
		Inc(px0);
		if px0 > 203 then px0 := 203;
		Poke(53248,px0);
		Delay(_speed);
	end;

    joy_up:
	begin			    // Move player 0 up
		Dec(py0);
		if py0 < 16 then py0 := 16;

		moveSprite;
		Delay(_speed);
	end;

    joy_down:
	begin			    // Move player 0 down
		Inc(py0);
		if py0 > 97 then py0 := 97;

		moveSprite;
		Delay(_speed);
	end;

    end;

  until keypressed;

  // Reset P/M graphics
  InitGraph(0);
  Poke(53277, 0);
end.
