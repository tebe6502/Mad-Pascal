uses graph, crt;

const
  LOGO = $2000;

{$r gfx.rc}

begin
  writeln('hello world !');
  repeat until keypressed;

  InitGraph(X16_MODE_320x240);

  ClearDevice;

  DrawImage(100, 100, pointer(LOGO), 100, 100);

  repeat until keypressed;
  // repeat until false;

end.
