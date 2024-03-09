uses x16_zsmkit, x16, crt;


begin
  writeln('zsm init');
  zsmInit;
  writeln('setting isr');
  zsmSetISR;
  writeln('loading sound...');
  zsmDirectLoad('music.zsm', 2, $A000);
  writeln('set ram bank');
  zsmSetMem(1, 2, $A000);
  writeln('play?');
  zsmPlay(1);

  writeln;
  writeln('playing music in background.');
end.