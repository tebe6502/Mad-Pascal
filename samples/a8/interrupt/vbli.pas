// https://mads.atari8.info/doc/en/interrupts/

uses crt;

var old_vbl: pointer;


procedure vbl; assembler; interrupt;
asm
	lda rtclok+2
	and #3
	bne skp

	lda $bc40
	eor #$80
	sta $bc40
skp
	jmp sysvbv
end;


begin

 GetIntVec(iVBLI, old_vbl);	// VBL immediate ($0222)

 SetIntVec(iVBLI, @vbl);


 writeln('Press any key to exit');

 repeat until keypressed;

 SetIntVec(iVBLI, old_vbl);

end.