unit Targets;

interface

type

  TTargetID = (A8, C4P, C64, NEO, RAW, X16);

  TCPU = (CPU_6502, CPU_65C02, CPU_65816);

  TTarget = record
    Name: String;
    id: TTargetID;
    cpu: TCPU;
    eol: Byte;
    zpage,
    buf,
    codeorigin: Word;
    header: array[0..15] of String;
  end;

procedure Init(const id: TTargetID; var target: TTarget);

implementation


procedure Init(const id: TTargetID; var target: TTarget);
begin

  target.id := id;
  case target.id of

    TTargetID.A8: begin

      // Atari 8-bit target
      target.cpu := TCPU.cpu_6502;
      target.Name := 'ATARI';
      target.buf := $0400;
      target.zpage := $0080;
      target.eol := $0000009B;
      target.codeorigin := $2000;

    end;

    TTargetID.C64: begin

      // Commodore C64 target
      target.cpu := TCPU.cpu_6502;
      target.Name := 'C64';
      target.buf := $0800;
      target.zpage := $0002;
      target.eol := $0000000D;
      target.codeorigin := $0900;
      target.header[0] := 'opt h-f+';
      target.header[1] := 'org $801';
      target.header[2] := 'org [a($801)],$801';
      target.header[3] := 'basic_start(START)';
      target.header[4] := ''; // asm65;
      target.header[5] := 'org $900';
      target.header[6] := ''; // asm65;
      target.header[7] := 'END';

    end;

    TTargetID.C4P: begin

      // Commodore Plus/4 target
      target.cpu := TCPU.cpu_6502;
      target.Name := 'C4P';
      target.buf := $0800;
      target.zpage := $0002;
      target.eol := $0000000D;
      target.codeorigin := $100E;
      target.header[0] := 'opt h-f+';
      target.header[1] := 'org $1001';
      target.header[2] := 'org [a($1001)],$1001';
      target.header[3] := 'basic_start(START)';
      target.header[4] := ''; // asm65;
      target.header[5] := 'org $100E';
      target.header[6] := ''; // asm65;
      target.header[7] := 'END';

    end;

    TTargetID.NEO: begin

      // NEO6502 binary target
      target.cpu := TCPU.cpu_65c02;
      target.Name := 'NEO';
      target.buf := $0200;
      target.zpage := $0000;
      target.eol := $0000000D;
      target.codeorigin := $800;
      target.header[0] := 'END';

    end;

    TTargetID.RAW: begin

      // RAW binary target
      target.cpu := TCPU.cpu_6502;
      target.Name := 'RAW';
      target.buf := $0200;
      target.zpage := $0000;
      target.eol := $0000000D;
      target.codeorigin := $1000;
      target.header[0] := 'END';

    end;

    TTargetID.X16: begin

      // Commander X16 target
      target.cpu := TCPU.cpu_65c02;
      target.Name := 'X16';
      target.buf := $0400;
      target.zpage := $0022;
      target.eol := $0000000D;
      target.codeorigin := $0900;
      target.header[0] := 'opt h-f+c+';
      target.header[1] := 'org $801';
      target.header[2] := 'org [a($801)],$801';
      target.header[3] := 'basic_start(START)';
      target.header[4] := ''; // asm65;
      target.header[5] := 'org $900';
      target.header[6] := ''; // asm65;
      target.header[7] := 'END';

    end;

  end;
end;

end.
