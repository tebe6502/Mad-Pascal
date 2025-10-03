if t = 'A8' then target.id := TTargetID.a8 else
  if t = 'C64' then target.id := TTargetID.c64 else
    if t = 'C4P' then target.id := TTargetID.c4p else
      if t = 'RAW' then target.id := TTargetID.raw else
        if t = 'NEO' then target.id := TTargetID.neo else
          if t = 'X16' then target.id := TTargetID.x16 else
          Syntax(3);
