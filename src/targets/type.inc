type
  TTarget = Record
    id, name, zpage : string;
    eol, codeorigin : integer;
    header          : array[0..15] of string;
  end;
