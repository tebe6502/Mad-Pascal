// https://bitbucket.org/paul_nicholls/pas6502/src/master/projects/UpUpAndAway.dpr

program UpUpAndAway;
//UP, UP, AND AWAY

{$r sprite2.rc}

const
  v = 53248; //start of display chip

var
//  sprite: array [0..62] of byte absolute $2100;
  sprite2: array [0..62] of byte absolute $2000;


var
  i,d : Integer;

begin
  Poke(v + 21,4); //ENABLE SPRITE 2
  Poke(2042,13);  //SPRITE 2 DATA FROM BLOCK 13

  // copy sprite data into block 13
  i := 0;
  while i <= 62 do begin
    Poke(832 + i,sprite2[i]);
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