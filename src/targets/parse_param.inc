if t = 'A8' then target := a8 else
  if t = 'C64' then target := c64 else
    if t = 'C4P' then target := c4p else
      if t = 'RAW' then target := raw else
        if t = 'NEO' then target := neo else
          Syntax(3);
