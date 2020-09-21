// https://bitbucket.org/paul_nicholls/pas6502/src/master/projects/UpUpAndAway.dpr

program UpUpAndAway;
//UP, UP, AND AWAY
const
  v = 53248; //start of display chip

  sprite : array[0..62] of Byte = (
    0,127,0,1,255,192,3,255,224,3,231,224,
    7,217,240,7,223,240,7,217,240,3,231,224,
    3,255,224,3,255,224,2,255,160,1,127,64,
    1,62,64,0,156,128,0,156,128,0,73,0,0,73,0,
    0,62,0,0,62,0,0,62,0,0,28,0
  );

var
  i,d : Integer;
begin
  Poke(v + 21,4); //ENABLE SPRITE 2
  Poke(2042,13);  //SPRITE 2 DATA FROM BLOCK 13

  // copy sprite data into block 13
  i := 0;
  while i <= 62 do begin
    Poke(832 + i,sprite[i]);
    Inc(i);
  end;

  while True do begin
    i := 0;
    while i <= 240 do begin
      pause;

      Poke(v + 4,i); //UPDATE X COORDINATES
      Poke(v + 5,i); //UPDATE Y COORDINATES
      Inc(i);

    end;
  end;
end.