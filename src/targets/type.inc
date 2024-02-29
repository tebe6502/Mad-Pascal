type
  TTarget = Record
    id, name, zpage : string;
    eol: byte;
    buf,
    codeorigin : word;
    header          : array[0..15] of string;
  end;
