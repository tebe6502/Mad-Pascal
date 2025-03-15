if t = 'A8' then target.id := TComputer.___a8 else
  if t = 'C64' then target.id := TComputer.___c64 else
    if t = 'C4P' then target.id := TComputer.___c4p else
      if t = 'RAW' then target.id := TComputer.___raw else
        if t = 'NEO' then target.id := TComputer.___neo else
          if t = 'X16' then target.id := TComputer.___x16 else
          Syntax(THaltException.COMPILING_NOT_STARTED);
