// https://forums.atariage.com/topic/315537-rmt2lzss-convert-rmt-tunes-to-lzss-for-fast-playback/

program lzss_play_stereo;

uses
  crt,
  saplzss,
  sysutils;

  {$define romoff}

const

  //mod_r = $9000;
  //mod_l = $7000;

  play_r = $c000;    // $0000..$02FF player, $0300..$0BFF buffers
  play_l = $f000;

var
  msx_r, msx_l: TLZSSPlay;

  len: Word;

  p: pointer;

  ch: Char;

  {$r 'lzss_play_stereo.rc'}


begin
  fillchar(pointer(play_r + $300), $900, 0);    // clear sapr-lzss buffer
  fillchar(pointer(play_l + $300), $900, 0);    // clear sapr-lzss buffer

  SizeofResource(len, 'mod_r');
  GetResourceHandle(p, 'mod_r');
  writeln('modul_r length: ', len, ', address: $', hexStr(Word(p), 4));

  msx_r.modul := p;
  msx_r.player := pointer(play_r);

  SizeofResource(len, 'mod_l');
  GetResourceHandle(p, 'mod_l');
  writeln('modul_l length: ', len, ', address: $', hexStr(Word(p), 4));

  msx_l.modul := p;
  msx_l.player := pointer(play_l);

  while True do
  begin

    fillchar(pointer(play_r + $300), $900, 0);  // clear buffers
    fillchar(pointer(play_l + $300), $900, 0);  // clear buffers


    msx_r.init($00);  // $d200
    msx_l.init($10);  // $d210

    writeln;
    writeln('Pascal SAP-R LZSS 8chn player example');
    writeln(Concat(Concat('Right player under OS ROM at $', IntToHex(msx_r.player, 4)), '.'));
    writeln(Concat(Concat('Left player under OS ROM at $', IntToHex(msx_l.player, 4)), '.'));

    repeat
      pause;
      if  msx_r.decode or msx_l.decode then
      begin
        msx_r.stop($00);
        msx_l.stop($10);
        writeln('End of song reached. Press any key.');
        Break;
      end;

      msx_r.play;
      msx_l.play;

    until keypressed;

    ch := readkey();

    msx_r.stop($00);
    msx_l.stop($10);

  end;

end.
