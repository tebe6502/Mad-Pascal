if t = 'A8' then target.id := TComputer.A8 else
  if t = 'C64' then target.id := TComputer.C64 else
    if t = 'C4P' then target.id := TComputer.C4P else
      if t = 'RAW' then target.id := TComputer.RAW else
        if t = 'NEO' then target.id := TComputer.NEO else
          if t = 'X16' then target.id := TComputer.X16 else
          Syntax(THaltException.COMPILING_NOT_STARTED);
