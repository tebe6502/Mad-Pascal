type

  tCPU = (CPU_6502, CPU_65C02, CPU_65816);

  tComputer = (___c64, ___c4p, ___a8, ___raw, ___neo, ___x16);

  TTarget = Record
    name : string;
    id: tComputer;
    cpu: tCPU;
    eol: byte;
    zpage,
    buf,
    codeorigin : word;
    header          : array[0..15] of string;
  end;
