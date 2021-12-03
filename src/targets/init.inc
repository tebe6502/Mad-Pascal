// Commodore C64 target
c64.id         := 'c64';
c64.name       := 'C64';
c64.zpage      := 'org $02';
c64.eol        := $0000000D;
c64.codeorigin := $0900;
c64.header[0]  := 'opt h-f+';
c64.header[1]  := 'org $801';
c64.header[2]  := 'org [a($801)],$801';
c64.header[3]  := 'basic_start(START)';
c64.header[4]  := ''; // asm65;
c64.header[5]  := 'org $900';
c64.header[6]  := ''; // asm65;
c64.header[7]  := 'END';

// Commodore Plus/4 target
c4p.id         := 'c4p';
c4p.name       := 'C4P';
c4p.zpage      := 'org $02';
c4p.eol        := $0000000D;
c4p.codeorigin := $100E;
c4p.header[0]  := 'opt h-f+';
c4p.header[1]  := 'org $1001';
c4p.header[2]  := 'org [a($1001)],$1001';
c4p.header[3]  := 'basic_start(START)';
c4p.header[4]  := ''; // asm65;
c4p.header[5]  := 'org $100E';
c4p.header[6]  := ''; // asm65;
c4p.header[7]  := 'END';

// Atari 8-bit target
a8.id         := 'a8';
a8.name       := 'ATARI';
a8.zpage      := 'org $80';
a8.eol        := $0000009B;

// RAW binary target
raw.id         := 'raw';
raw.name       := 'RAW';
raw.zpage      := 'org $00';
raw.eol        := $0000000D;
raw.codeorigin := $1000;
raw.header[0]  := 'END';
