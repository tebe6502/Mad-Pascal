{ ==================================
  Demo program - PETSCII Art (c64)
  Created: 12/1/2022
  Artwork: Dr. TerrorZ, 2017
  URL:     https://csdb.dk/release/?id=159911
   ================================== }
program FantasyLand;
uses c64;

var
  Characters : array of byte = [{$BIN2CSV FantasyLand.chr}];
  Colors     : array of byte = [{$BIN2CSV FantasyLand.col}];

  vram_Char  : array[0..1000-1] of byte absolute $400;
  vram_Color : array[0..1000-1] of byte absolute $D800;

  i: word;

begin
  MemorySetup     := $14;

  BorderColor     := $00;
  BackgroundColor := $00;

  for i:= 0 to 999 do begin
    vram_Char[i] := Characters[i];
    vram_Color[i] := Colors[i];
  end;

  repeat
  until 1=0;
end.
