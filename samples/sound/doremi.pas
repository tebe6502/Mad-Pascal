{-------------------------------------------------------------------------------
  ZX Spectrum Beep Demonstration - Middle C Test
  by Bostjan Gorisek 2019
-------------------------------------------------------------------------------}

uses
  graph, crt, zxlib;

begin
  InitGraph(0);
  Writeln('ZX Spectrum Beep Demonstration',
          eol, 'Middle C Test',
          eol, eol, 'Press any key...', eol);
  repeat until KeyPressed;
  Writeln('DO');
  Beep(0.5, 0);
  Writeln('RE');
  Beep(0.5, 2);
  Writeln('MI');
  Beep(0.5, 4);
  Writeln('FA');
  Beep(0.5, 5);
  Writeln('SO');
  Beep(0.5, 7);
  Writeln('LA');
  Beep(0.5, 9);
  Writeln('TI');
  Beep(0.5, 11);
  Writeln('DO');
  Beep(0.5, 12);
  Writeln(eol, eol, 'Finished!', eol, eol);

  Writeln('Press any key to exit...');
  if KeyPressed then ReadKey;
  repeat until KeyPressed;
end.