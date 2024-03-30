uses x16_zsmkit, x16, crt;


begin
  writeln('ZSM INIT');
  zsmInit(50);
  writeln('SETTING ISR');
  zsmSetISR;
  writeln('LOADING SOUND...');
  zsmDirectLoad('music.zsm', 52, $A000);
  writeln('SET RAM BANK');
  zsmSetMem(0, 52, $A000);
  writeln('PLAY?');
  zsmPlay(0);

  writeln;
  writeln('PLAYING MUSIC IN BACKGROUND.');
end.