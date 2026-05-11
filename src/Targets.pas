unit Targets;

interface

{$SCOPEDENUMS ON}

type

  TTargetID = (NONE, A8, C4P, C64, NEO, RAW, X16);

  TCPU = (NONE, CPU_6502, CPU_65C02, CPU_65816);

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

// Target-specific string handling.
procedure ConvertStringToInternal(const id: TTargetID; var s: String; const startPosition: Integer);
procedure ConvertStringToInverse(const id: TTargetID; var s: String; const startPosition: Integer);

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

procedure ConvertStringToInternal(const id: TTargetID; var s: String; const startPosition: Integer);
var
  i: Integer;

// Conversion of ATASCII characters to Atari INTERNAL characters
// Preserves inverse bit.
  function ata2int(const a: Byte): Byte;
  begin
    Result := a;

    case (a and $7f) of
      0..31: Inc(Result, 64);  // Control characters
      32..95: Dec(Result, 32); // Number, uppercase and lowercase letters
    end;

  end;

  // Conversion of PETSCII characters to CBM screen codes.
  function cbm(const a: Char): Byte;
  begin
    Result := Ord(a);

    case a of
      'a'..'z': Dec(Result, 96);
      '['..'_': Dec(Result, 64);
      '`': Result := 64;
      '@': Result := 0;
    end;

  end;

begin

  if id = TTargetID.A8 then
  begin

    for i := startPosition to length(s) do
      s[i] := chr(ata2int(Ord(s[i])));

  end
  else
  begin

    for i := startPosition to length(s) do
      s[i] := chr(cbm(s[i]));

  end;

end;

procedure ConvertStringToInverse(const id: TTargetID; var s: String; const startPosition: Integer);
var
  i: Integer;
begin

  for i := startPosition to length(s) do
    if Ord(s[i]) < 128 then
      s[i] := chr(Ord(s[i]) + $80);

end;


end.
