
// Program: VANSI.COM
// SDX: RUNEXT.CFG
// ANS,CAR:X.COM,A:\PATHPROGRAM\VANSI.COM %

uses crt, vbxe, sysutils;

{$r vbxe_ansi.rc}

const

    ANSI_BUFFER = VBXE_OVRADR + $1000;

    ibmfnt = $8000;


var i: byte;

    stop: Boolean;

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
	  28: stop:=true;	// ESC
	  33: stop:=true;	// SPACE

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


procedure Syntax;
begin

 NormVideo;

 writeln('VBXE Display ANSI v1.2');
 writeln('Syntax: VANSI.EXE filename.ans');
 writeln();
 writeln('Key W   - scroll UP');
 writeln('Key S   - scroll DOWN');
 writeln('Key ESC - exit');

 repeat until keypressed;

 halt(2);

end;


procedure LoadANSI;
var f: file;

    fn: TString;

    num, i: word;

    bf: array [0..255] of char;

begin

if ParamCount = 0 then

 Syntax

else begin

 fn:=ParamStr(1);

 fn:=concat('D:',fn);

 if not(FileExists(fn)) then begin

  NormVideo;

  writeln('File ', fn, ' not found.');
  writeln;

  exit;
 end;

end;


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

 if stop then Break;

until false;

(*--------------------------------------------------------------------*)

ReadKey();

NormVideo;				// disable VBXE

end;



begin

 Poke(756, hi(ibmfnt));

 EnableANSIMode;

 vbxe.CursorOff;

 LoadANSI;

end.