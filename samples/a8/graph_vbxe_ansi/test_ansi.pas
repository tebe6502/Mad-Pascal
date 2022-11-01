
uses vbxe, crt;

var f: file;

    num, i: word;

    stop: Boolean;

    bf: array [0..255] of char;

    row0: array [0..255] of byte absolute $0400;

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


BEGIN
	get_key;

	a:=0;

	if onKey <> 0 then begin

	 case onKey of
	  28: stop:=true;

	  46: a:=1;	// W
	  62: a:=2;	// S
	 end;

	end;

	onKey:=0;

	case a of
	  1: if vadr > VBXE_ANSIFRE then dec(vadr, 160);
	  2: if vadr < ansiend then inc(vadr, 160);
	end;

END;



begin

EnableANSIMode;

vram.create;
vram.position:=VBXE_ANSIFRE;

row_slide_status:=false;


assign(f, 'D:CESPLAT.ANS'); reset(f, 1);

repeat

 blockread(f, bf, 256, num);

 if num > 0 then
  for i:=0 to num-1 do begin
   AnsiChar(bf[i]);


   if row_slide_status then begin

    vram.WriteBuffer(row0, 160);

    row_slide_status:=false;

   end;


  end;

until num = 0;

close(f);

NoSound;	// reset POKEY-s


src.create;
src.position:=VBXE_ANSIADR;


for i:=0 to 23 do begin

 src.ReadBuffer(bf, 160);

 vram.WriteBuffer(bf, 160);

end;


ansiend := vram.position - 24*160;

vadr:=ansiend;

stop:=false;

repeat

 pause;

 KeyScan;

 SetOverlayAddress(vadr);

 if stop then Break;

until false;


NormVideo;

end.
