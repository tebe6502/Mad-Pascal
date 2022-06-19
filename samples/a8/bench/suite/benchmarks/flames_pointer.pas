unit flames_pointer;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

const
  fireScreen   = lms + $400;
  fireCharset  = lms - $10;

procedure gtiaOff; assembler; interrupt;
asm
  pha
  mva #0 gr.gprior
  mva #$22 DMACTL
  mva #>gr.counterCharset CHBASE
  mwa #GTIAON __dlivec
  pla
end;

procedure gtiaOn; assembler; interrupt;
asm
  pha
  mva #$40 gr.gprior
  mva #$21 DMACTL
  mva #>fireCharset CHBASE
  mwa #GTIAOFF __dlivec
  pla
end;

{$codealign proc = $100}

procedure benchmark;
var
  ze       : byte absolute counterLms + $25;
  zf       : byte absolute counterLms + $26;
  zg       : byte absolute counterLms + $27;
  b0i      : byte absolute $e0;
  b1i      : byte absolute $e1;
  tmp      : byte absolute $e2;
  p0       : PByte absolute $f0;
  p1       : PByte absolute $f2;
  p2       : PByte absolute $f4;
begin
  EnableDLI(@gtiaOff); mode2;
  gprior := $40; color4 := $20; tmp := 0;

  p0 := pointer(fireCharset);
  for b0i := 0 to $f do begin
    for b1i := 0 to 7 do p0[b1i] := tmp;
    inc(tmp,$11); inc(p0,8);
  end;

  FillChar(pointer(counterLms + $23), 5, 0);

  rtclok := 0;
  while rtclok < 250 do begin
    p0 := pointer(fireScreen - 31);
    p1 := pointer(fireScreen - 31 + $100);
    p2 := pointer(fireScreen - 31 + $200);

    for b0i := 255 downto 0 do begin
      p0^ := byte(p0[30] + p0[31] + p0[32] + p0[63]) shr 2;
      p1^ := byte(p1[30] + p1[31] + p1[32] + p1[63]) shr 2;
      p2^ := byte(p2[30] + p2[31] + p2[32] + p2[63]) shr 2;
      inc(p0); inc(p1); inc(p2);
    end;

    p0 := pointer(fireScreen + $2e0);
    for b0i := $1f downto 0 do p0[b0i] := rnd and 15;

    inc(zg);
    if zg = 10 then begin inc(zf); zg := 0 end;
    if zf = 10 then begin inc(ze); zf := 0 end;
  end;

  DisableDLI; gprior := 0; dmactl := $22;
end;

{$codealign proc = 0}

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5c'Flames P GTIA 250 frames'~;
  isRewritable := true;
end.
