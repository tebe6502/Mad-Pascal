// VBXE Color Map Graphics

uses crt, graph, vbxe;

const
	charsets = $8000;

var f: file;
    p: ^byte;
    chrAdr, i: byte;
    buf: array [0..0] of byte absolute $0400;

    old_vbl, old_dli: pointer;

    vram: TVBXEMemoryStream;

procedure vbl; interrupt; assembler;
asm
{	mva >charsets chrAdr

	jmp xitvbv
};
end;


procedure dli; interrupt; assembler;
asm
{	pha

	lda chrAdr
	sta wsync
	sta chbase

	add #4
	sta chrAdr

	pla
};
end;


begin

 GetIntVec(iDLI, old_dli);
 GetIntVec(iVBL, old_vbl);

 InitGraph(mVBXE, 12 + 16, '');

 if GraphResult <> grOK then begin
  writeln('VBXE not detected');
  halt;
 end;

 p:=pointer(dpeek(88));
 assign(f, 'D:DONTTURN.SCR'); reset(f, 1);
 blockread(f, p, 40*24);
 close(f);

 p:=pointer(charsets);
 assign(f, 'D:DONTTURN.FNT'); reset(f, 1);
 blockread(f, p, 1024*8);
 close(f);

 vram.position:=VBXE_MAPADR;

 assign(f, 'D:DONTTURN.CMP'); reset(f, 1);
 for i:=0 to 23 do begin
  blockread(f, buf, 160);

  vram.WriteBuffer(buf, $100);
 end;
 close(f);

 VBXEMemoryBank(0);		// disable vbxe bank

 SetIntVec(iVBL, @vbl);
 SetIntVec(iDLI, @dli);

 p:=pointer(dpeek($230)+2);

 p^:=$f0;

 inc(p, 5);

 for i:=0 to 6 do begin
  p^:=$84;
  inc(p, 3);
 end;

 poke($d40e, $c0);

 SetBkColor(6);

 repeat until keypressed;

 VBXEOff;

 SetIntVec(iDLI, old_dli);
 SetIntVec(iVBL, old_vbl);

end.

