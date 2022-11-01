
(*

 DISPLAY *.ANS FILE

*)

uses vbxe, crt, sysutils;

{$r vbxe_ansi.rc}

const

    ANSI_BUFFER = VBXE_OVRADR + $1000;

    ibmfnt = $8000;


var f: file;

    Info : TSearchRec;
    fn: TString;

    num, i: word;

    stop, next: Boolean;

    bf: array [0..255] of char;

    vram, src: TVBXEMemoryStream;

    vadr, ansiend : cardinal;


Procedure KeyScan;
var a, onKey: byte;


procedure get_key; assembler;
asm
key_delay = 1

	lda $d20f
	and #4
	bne @exit

	lda $d209

	cmp onKey_: #0
	bne skp

	ldy delay: #key_delay
	dey
	sty delay
	bne @exit
skp
	sta onKey
	sta onKey_

	mva #key_delay delay
end;

begin
	get_key;

	a:=0;

	if onKey <> 0 then begin

	 case onKey of
	  28: stop:=true;	// ESC
	  33: next:=true;	// SPACE

	  46: a:=1;		// W
	  62: a:=2;		// S
	 end;

	end;

	onKey:=0;

	case a of
	  1: if vadr > ANSI_BUFFER then dec(vadr, 160);
	  2: if vadr < ansiend then inc(vadr, 160);
	end;

end;



procedure LoadANSI;
var f: file;

    num, i: word;

    bf: array [0..255] of char;

begin


vbxe.clrscr;

vram.create;


(*--------------------------------------------------------------------*)

SetOverlayAddress(VBXE_OVRADR);

vram.position := ANSI_BUFFER;

scrollback_fill:=false;

assign(f, fn); reset(f, 1);

repeat

 blockread(f, bf, 256, num);

 if num > 0 then
  for i:=0 to num-1 do begin
   AnsiChar(bf[i]);


   if scrollback_fill then begin

    vram.WriteBuffer(scrollback_buffer, 160);	// copy ROW #0 to VRAM

    scrollback_fill:=false;

   end;


  end;

until num = 0;

close(f);

NoSound;	// reset POKEY-s

(*--------------------------------------------------------------------*)

src.create;
src.position := VBXE_OVRADR;		// copy whole console window to VRAM row by row (x24)

for i:=0 to 23 do begin

 src.ReadBuffer(bf, 160);		// SRC -> BF

 vram.WriteBuffer(bf, 160);		// BF -> VRAM

end;

ansiend := vram.position - 24*160;	// end

vadr:=ansiend;

(*--------------------------------------------------------------------*)

repeat

 pause;

 KeyScan;

 SetOverlayAddress(vadr);		// XDLC_OVADR

 if stop or next then Break;

until false;

end;



begin

 Poke(756, hi(ibmfnt));

 EnableANSIMode;

 vbxe.CursorOff;


  if FindFirst('D:*.ANS', faAnyFile, Info) = 0 then
  begin
    repeat

      fn:=Info.Name;				// FILENAME
      fn:=Concat('D:', fn);			// D:FILENAME

      next := false;

      LoadANSI;

      if stop then Break;

    until FindNext(Info) <> 0;

    FindClose(Info);
  end;


  repeat until keypressed;

  NormVideo;

end.