
(*

 DISPLAY ANSI FILE

*)


// !!! 'vbxeansi' at the beginning of the USES list

uses vbxeansi, crt, sysutils;

type

   TShortFilename = string[16];


var f: file;

    num, i: word;

    x,
    cfnam: byte;			// maximum number of file names

    stop, next: Boolean;

    bf: array [0..255] of char;

    row0: array [0..255] of byte absolute $0400;	// ROW #0 buffer, filled if 'row_slide_status = true'

    fnam: array [0..99] of TShortFilename;

    vram, src: TVBXEMemoryStream;

    vadr, ansiend : cardinal;


procedure ReadDIR;
var Info : TSearchRec;
    fn: TShortFilename;
begin

  if FindFirst('D:*.ANS', faAnyFile, Info) = 0 then
  begin
    repeat

      fn:=Info.Name;				// FILENAME
      fn:=Concat('D:', fn);			// D:FILENAME

      if cfnam <= High(fnam) then begin		// maximum 100 files [0..99]
       fnam[cfnam]:=fn;
       inc(cfnam);
      end;

    until FindNext(Info) <> 0;

    FindClose(Info);
  end;

end;


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
	  28: stop:=true;	// ESC
	  33: next:=true;	// SPACE

	  46: a:=1;		// W
	  62: a:=2;		// S
	 end;

	end;

	onKey:=0;

	case a of
	  1: if vadr > VBXE_ANSIFRE then dec(vadr, 160);
	  2: if vadr < ansiend then inc(vadr, 160);
	end;

END;



begin

ReadDIR;

vram.create;

(*--------------------------------------------------------------------*)

while true do begin

SetOverlayAddress(VBXE_ANSIADR);

clrscr;

vram.position:=VBXE_ANSIFRE;

row_slide_status:=false;


assign(f, fnam[x]); reset(f, 1);

repeat

 blockread(f, bf, 256, num);

 if num > 0 then
  for i:=0 to num-1 do begin
   AnsiChar(bf[i]);


   if row_slide_status then begin

    vram.WriteBuffer(row0, 160);	// copy ROW #0 to VRAM

    row_slide_status:=false;

   end;


  end;

until num = 0;

close(f);

NoSound;	// reset POKEY-s

(*--------------------------------------------------------------------*)

src.create;
src.position:=VBXE_ANSIADR;		// copy whole console window to VRAM row by row (x24)

for i:=0 to 23 do begin

 src.ReadBuffer(bf, 160);		// SRC -> BF

 vram.WriteBuffer(bf, 160);		// BF -> VRAM

end;

(*--------------------------------------------------------------------*)

ansiend := vram.position - 24*160;	// end

vadr:=ansiend;

next:=false;

(*--------------------------------------------------------------------*)

repeat

 pause;

 KeyScan;

 SetOverlayAddress(vadr);		// XDLC_OVADR

 if stop or next then Break;

until false;

(*--------------------------------------------------------------------*)

inc(x);

if x >= cfnam then x:=0;

if stop then Break;			// program exit

end;	// while


NormVideo;				// disable VBXE

end.