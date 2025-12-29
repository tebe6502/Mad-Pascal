// https://forums.atariage.com/topic/315537-rmt2lzss-convert-rmt-tunes-to-lzss-for-fast-playback/

program lzss_play;

uses
  crt,
  saplzss,
  SysUtils;

  {$define romoff}

const

  sapr_player = $f000;  // $0000..$02FF player ($300), $0300..$0BFF buffers ($900)
  sapr_modul = $6c00;

var
  msx: TLZSSPlay;

  ch: Char;

  i: Word;

  {$r 'lzss_play.rc'}


begin
  msx.modul := pointer(sapr_modul);
  msx.player := pointer(sapr_player);

  msx.Clear;  // clear buffers

  while True do
  begin

    msx.init($00);

    writeln('Pascal SAP-R LZSS player example.');
    writeln(Concat(Concat('Player under OS ROM at $', IntToHex(msx.player, 4)), '.'));

    repeat
      pause;

      if msx.decode then
      begin
        msx.stop($00);
        writeln('End of song reached. Press any key.');
        Break;
      end;

      msx.play;

    until keypressed;

    ch := readkey();

    msx.stop($00);

  end;

end.
