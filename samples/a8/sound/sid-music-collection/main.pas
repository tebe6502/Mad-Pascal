{$r music/music.rc}

//-----------------------------------------------------------------------------

uses atari, aplib, crt;

//-----------------------------------------------------------------------------

const
  MUSIC_APL_LONDON     = $4300;
  MUSIC_APL_ART        = $4900;
  MUSIC_APL_BATMANIA   = $5100;
  MUSIC_APL_CONTAXIA   = $5800;
  MUSIC_APL_DOMINATION = $6000;
  MUSIC_APL_FUNCIE     = $6900;
  MUSIC_APL_CHANCE     = $7200;
  MUSIC_APL_LOVE       = $7a00;
  MUSIC_APL_PIZZA      = $8200;

  MUSIC                = $9000;
  M_INIT               = MUSIC + $48;
  M_PLAY               = MUSIC + $21;
  M_SPACE              = $1000;
  M_COUNTER            = 8;

const
  RESET_VECTOR         = $fffc;
  SID_REG_HEAD         = $d500;

  RASTER_START         = $10;

//-----------------------------------------------------------------------------

names: array [0..M_COUNTER] of string[15] = (
  'London Demo    ',
  'Batmania II 5  ',
  'Audio Art      ',
  'Contaxia       ',
  'Domination     ',
  'Funcie         ',
  'In Chance      ',
  'Lessons in Love',
  'Peppered Pizza '
);

zaks: array [0..M_COUNTER] of word = (
  MUSIC_APL_LONDON, MUSIC_APL_BATMANIA, MUSIC_APL_ART, MUSIC_APL_CONTAXIA,
  MUSIC_APL_DOMINATION, MUSIC_APL_FUNCIE, MUSIC_APL_CHANCE, MUSIC_APL_LOVE,
  MUSIC_APL_PIZZA
);

//-----------------------------------------------------------------------------

var
  music_index : byte = 0;

//-----------------------------------------------------------------------------

procedure music_play; assembler; inline;
asm
  sei
  txa \ pha
  jsr M_PLAY
  pla \ tax  
  cli
end;

procedure music_init; assembler; inline;
asm
  txa \ pha
  jsr M_INIT
  pla \ tax
end;

procedure reset_keyboard; assembler; inline;
asm
  lda #$ff \ sta kbcodes
end;

procedure reset_system; assembler; inline;
asm
  jmp (RESET_VECTOR)
end;

procedure prepare_new_music; inline;
begin
  fillbyte(pointer(MUSIC), M_SPACE, 0);
  unapl(pointer(zaks[music_index]), pointer(MUSIC));

  music_init;
end;

procedure sid_off; inline;
begin
  fillbyte(pointer(SID_REG_HEAD), $19, 0);
end;

//-----------------------------------------------------------------------------

procedure main_loop;
begin
  repeat
    reset_keyboard;

    prepare_new_music;

    writeln('No.', music_index + 1, ' ', names[music_index]);

    repeat
      pause;
      repeat until vcount = RASTER_START;
      colbk := $0e;

      music_play;
      
      colbk := 0;
    until keypressed;

    sid_off;

    inc(music_index);
  until music_index > M_COUNTER;
end;

//-----------------------------------------------------------------------------

begin
  clrscr;

  writeln('Expecting SID on $d500');
  writeln;
  writeln('Composer : Reyn Ouwehand');
  writeln('Player   : Music Assembler');
  writeln;
  writeln('press space...');
  writeln;

  main_loop;

  clrscr; write('BYE!'); pause(50);

  reset_system;
end.
