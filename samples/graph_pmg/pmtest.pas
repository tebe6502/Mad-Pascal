{
  P/M Graphics demonstration
  by Bostjan Gorisek 2015
  
  Developed in Mad-Pascal by Tebe / Madteam
}
uses crt, graph, pmg;

var
  // Player data
  p0Data : array [0.._P_MAX] of byte = (60, 66, 129, 165, 129, 153, 129, 165, 153, 66, 60, 0, 0, 0, 0);
  p1Data : array [0.._P_MAX] of byte = (124,130,254,254,124,56,16,16,16,16,16,16,16,124,254);
  p2Data : array [0.._P_MAX] of byte = (60,102,110,118,118,118,102,60,24,0,0,0,0,0,0);
  p3Data : array [0.._P_MAX] of byte = (10, 20, 30, 40, 50, 60, 70, 80, 55, 28, 255,0, 0, 0, 0);
    
// Main code
begin
  // Set graphics mode and playfield colors
  InitGraph(0);
  
  p_data[0]:=@p0Data;
  p_data[1]:=@p1Data;
  p_data[2]:=@p2Data;
  p_data[3]:=@p3Data;
  
  // Initialize P/M graphics
  SetPM(_PM_DOUBLE_RES);
  InitPM(_PM_DOUBLE_RES);  
  
  // Set program colors
  Poke(710, 0); Poke(712, 0);
  // Cursor off
  Poke(752, 1);
  
  writeln(eol,'P/M Graphics demonstration');
  writeln(eol,'by Bostjan Gorisek 2015',eol);

  // Turn on P/M graphics
  ShowPM(_PM_SHOW_ON);        
            
  // Draw players
  ColorPM(0, 202);
  ColorPM(1, 250);
  ColorPM(2, 136);
  ColorPM(3, 36);

  SizeP(0, _PM_DOUBLE_SIZE);
  SizeP(1, _PM_DOUBLE_SIZE);
  SizeP(2, _PM_QUAD_SIZE);
  SizeP(3, _PM_NORMAL_SIZE);

  MoveP(0, 60, 70);
  MoveP(1, 170, 90);
  MoveP(2, 100, 85);
  MoveP(3, 140, 100);
    
  repeat until keypressed;

  // Reset P/M graphics
  ShowPM(_PM_SHOW_OFF);        
end.
