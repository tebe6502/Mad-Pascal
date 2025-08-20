// 66/88

program chessboard;
uses crt, graph;

var i, stop                       : byte;
    rtClock                       : byte absolute 20;
    col1                          : byte absolute 709;
    col2                          : byte absolute 710;
    colB                          : byte absolute 712;
    bmpAdr                        : word absolute 88;


{$define fast}

procedure drawBoard;
var

{$ifdef fast}
    p: PByte absolute $e0;

    i1b: byte absolute $e2;
    i2b: byte absolute $e3;
    i3b: byte absolute $e4;
{$else}
    p: PByte;

    i1b: byte;
    i2b: byte;
    i3b: byte;
{$endif}

begin
  p := pointer(bmpAdr);

  for i3b := 7 downto 0 do begin
    for i2b := 23 downto 0 do begin

      for i1b := 3 downto 0 do begin
          p[0]:= 255;
          p[1]:= 255;
          p[2]:= 255;
          Inc(p,6);
      end;
      Inc(p,16);
    end;
    if (i3b and %1) = 0 then Dec(p,3) else Inc(p,3);
  end;
end;

begin
  InitGraph(8 + 16);
  col1 := 1;
  col2 := 11;
  colB := 12;

  pause;
  rtClock := 0;

  while rtClock < 150 do begin
    drawBoard;
    inc(i);
  end;

  stop:=rtClock;

  InitGraph(0);
  writeln('Drawing iterations: ', i);
  ReadKey;
end.
