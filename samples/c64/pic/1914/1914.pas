{ ==================================
 Demo program - Graphics (c64)
  Created: 12/2/2022
  Artwork: Errazking, 2014
  URL:     https://csdb.dk/release/?id=148957
   ================================== }
program HateAndWar_1914;
uses c64, graph;

var
  Characters : array of byte = [{$BIN2CSV '1914.dat'}];
  Colors     : array of byte = [{$BIN2CSV '1914.col'}];
  Pixels     : array of byte = [{$BIN2CSV '1914.bin'}];

begin
  InitGraph(VGAMed);

  BorderColor     := $00;
  BackgroundColor := $00;

  move(Pixels, VideoRam, 8000);
  move(Characters, ScreenRAM, 1000);
  move(Colors, ColorRAM, 1000);

  repeat
  until 1=0;  // keeps the screen intact

end.
