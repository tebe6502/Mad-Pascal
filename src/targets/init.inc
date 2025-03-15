case target.id of

TComputer.A8: begin

// Atari 8-bit target
target.cpu        := TCPU.cpu_6502;
target.name       := 'ATARI';
target.buf        := $0400;
target.zpage      := $0080;
target.eol        := $0000009B;
target.codeorigin := $2000;

end;

TComputer.C64: begin

// Commodore C64 target
target.cpu        := TCPU.cpu_6502;
target.name       := 'C64';
target.buf        := $0800;
target.zpage      := $0002;
target.eol        := $0000000D;
target.codeorigin := $0900;
target.header[0]  := 'opt h-f+';
target.header[1]  := 'org $801';
target.header[2]  := 'org [a($801)],$801';
target.header[3]  := 'basic_start(START)';
target.header[4]  := ''; // asm65;
target.header[5]  := 'org $900';
target.header[6]  := ''; // asm65;
target.header[7]  := 'END';

end;

TComputer.C4P: begin

// Commodore Plus/4 target
target.cpu        := TCPU.cpu_6502;
target.name       := 'C4P';
target.buf        := $0800;
target.zpage      := $0002;
target.eol        := $0000000D;
target.codeorigin := $100E;
target.header[0]  := 'opt h-f+';
target.header[1]  := 'org $1001';
target.header[2]  := 'org [a($1001)],$1001';
target.header[3]  := 'basic_start(START)';
target.header[4]  := ''; // asm65;
target.header[5]  := 'org $100E';
target.header[6]  := ''; // asm65;
target.header[7]  := 'END';

end;

TComputer.RAW: begin

// RAW binary target
target.cpu        := TCPU.cpu_6502;
target.name       := 'RAW';
target.buf        := $0200;
target.zpage      := $0000;
target.eol        := $0000000D;
target.codeorigin := $1000;
target.header[0]  := 'END';

end;

TComputer.NEO: begin

// NEO6502 binary target
target.cpu        := TCPU.cpu_65c02;
target.name       := 'NEO';
target.buf        := $0200;
target.zpage      := $0000;
target.eol        := $0000000D;
target.codeorigin := $800;
target.header[0]  := 'END';

end;

TComputer.X16: begin

// Commander X16 target
target.cpu        := TCPU.cpu_65c02;
target.name       := 'X16';
target.buf        := $0400;
target.zpage      := $0022;
target.eol        := $0000000D;
target.codeorigin := $0900;
target.header[0]  := 'opt h-f+c+';
target.header[1]  := 'org $801';
target.header[2]  := 'org [a($801)],$801';
target.header[3]  := 'basic_start(START)';
target.header[4]  := ''; // asm65;
target.header[5]  := 'org $900';
target.header[6]  := ''; // asm65;
target.header[7]  := 'END';

end;


end;
