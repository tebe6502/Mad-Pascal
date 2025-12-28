program cmc_play;

uses
  crt,
  cmc,
  SysUtils;

  {$define romoff}

const
  cmc_player = $f000;
  cmc_modul = $4000;

var
  msx: TCMC;

  ch: Char;

  {$r 'cmc_play.rc'}


begin

  while True do
  begin

    msx.player := pointer(cmc_player);
    msx.modul := pointer(cmc_modul);

    msx.init;

    writeln('Pascal CMC player example.');
    writeln(Concat(Concat('Player under OS ROM at $', IntToHex(msx.player, 4)), '.'));
    repeat
      pause;

      msx.play;

    until keypressed;
    writeln('Song stopped. Press any key.');
    ch := readkey();

    msx.stop;

  end;

end.
