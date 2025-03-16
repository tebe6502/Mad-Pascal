type

  TCPU = (CPU_6502, CPU_65C02, CPU_65816);

  TComputer = (A8, C4P, C64, NEO, RAW, X16);

  TTarget = Record
    name : string;
    id: TComputer;
    cpu: TCPU;
    eol: byte;
    zpage,
    buf,
    codeorigin : word;
    header          : array[0..15] of string;
  end;
