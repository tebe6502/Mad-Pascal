uses crt, cmc;

{$define romoff}

const
	cmc_player = $4000;
	cmc_modul = $5000;

var
	msx: TCMC;

	ch: char;

{$r 'cmc_play.rc'}

var
  i: byte;


begin

	writeln('Pascal CMC player example');
  writeln('press any key to switch song');

	while true do begin

    msx.player:=pointer(cmc_player);
    msx.modul:=pointer(cmc_modul);

    msx.initnosong;

    for i := 0 to 2 do
    begin
      writeln('Playing song ', i);
      msx.song(i);
      repeat
        pause;

        msx.play;

      until keypressed;
      ch:=readkey();
      msx.stop;
    end;

	end;

end.
