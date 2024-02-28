uses graph, crt;

const
  LOGO = $8000;

{$r gfx.rc}

begin
  writeln('hello world !');
  repeat until keypressed;

  InitGraph(X16_MODE_320x240);
  ClearDevice;

  DrawImage(0, 0, pointer(LOGO), 160, 100);

  repeat until keypressed;

end.
