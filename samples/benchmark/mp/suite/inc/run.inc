procedure run;
begin
  FillChar(pointer(lms), $1ff0, 0);
  counter.prepare(name);
  pause;
  counter.stop := false;
  benchmark;
  counter.stop := true;
  pause(50);
  if isRewritable then counter.overwrite;
  counter.print;
end;