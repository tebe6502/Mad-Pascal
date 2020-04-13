// 70

program chessboard;
uses crt, graph;

var i, stop                       : byte;
    rtClock                       : byte absolute 20;
    col1                          : byte absolute 709;
    col2                          : byte absolute 710;
    colB                          : byte absolute 712;
    bmpAdr                        : word absolute 88;

procedure drawBoard;
var i1b, i2b, i3b, x, color          : byte;
    p                                : PByte absolute $e0;
begin
  p := pointer(bmpAdr);
  for i3b := 1 to 8 do begin
    for i2b := 1 to 24 do begin

      for i1b := 1 to 4 do begin
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
