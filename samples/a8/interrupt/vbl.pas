// https://mads.atari8.info/doc/en/interrupts/

uses crt;

var old_vbl: pointer;


procedure vbl; assembler; interrupt;
asm

 lda rtclok+2
 sta colbak

 jmp xitvbv

end;


begin

 GetIntVec(iVBL, old_vbl);	// VBL deferred ($0224)

 SetIntVec(iVBL, @vbl);


 writeln('Press any key to exit');

 repeat until keypressed;

 SetIntVec(iVBL, old_vbl);

end.