{$r gr0pp.rc}

uses crt, atari, gr0pp, graph;

const

DISPLAY_LIST_ADDRESS	= $b800;
CHARSET_RAM_ADDRESS	= $a000;
VIDEO_RAM_ADDRESS	= $a400;


procedure vbl; assembler; interrupt;
asm
{
	lda VS_Upper
	sta vscrol

	mva >CHARSET_RAM_ADDRESS	chbase

	jmp xitvbv
};
end;


begin

gr0init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 60, 4, 0);

SetIntVec(iVBL, @vbl);

colbk := $00;

color1 := $00;
color2 := $0f;

repeat until keypressed;

end.
