unit flames2;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

const
  fireScreen   = lms + $400;
  fireCharset  = lms - $10;

procedure gtiaOff; assembler; interrupt;
asm
{
  pha
  mva #0 gr.gprior
  mva #$22 DMACTL
  mva #>gr.counterCharset CHBASE
  lda >GTIAON
  sta __dlivec+1
  lda <GTIAON
  sta __dlivec
  pla
};
end;

procedure gtiaOn; assembler; interrupt;
asm
{
  pha
  mva #$40 gr.gprior
  mva #$21 DMACTL
  mva #>fireCharset CHBASE
  lda >GTIAOFF
  sta __dlivec+1
  lda <GTIAOFF
  sta __dlivec
  pla
};
end;


procedure benchmark;
var
  ze       : byte absolute counterLms + $25;
  zf       : byte absolute counterLms + $26;
  zg       : byte absolute counterLms + $27;
  b0i      : byte absolute $e0;
  b1i      : byte absolute $e1;
  tmp      : byte absolute $e2;

  row0: array [0..255] of byte absolute fireScreen - 31;
  row1: array [0..255] of byte absolute fireScreen - 31 + $100;
  row2: array [0..255] of byte absolute fireScreen - 31 + $200;

  row3: array [0..255] of byte absolute fireScreen + $2e0;


begin
  EnableDLI(@gtiaOff); mode2;
  gprior := $40; color4 := $20; tmp := 0;

  for b0i := 0 to $f do begin
    for b1i := 0 to 7 do poke(fireCharset + b1i + b0i * 8, tmp);
    inc(tmp,$11);
  end;

  FillChar(pointer(counterLms + $23), 5, 0);

  rtclok := 0;
  while rtclok < 250 do begin

    for b0i := 0 to 255 do begin
      row0[b0i] := byte(row0[30+b0i] + row0[31+b0i]+ row0[32+b0i]+ row0[63+b0i]) shr 2;
      row1[b0i] := byte(row1[30+b0i] + row1[31+b0i]+ row1[32+b0i]+ row1[63+b0i]) shr 2;
      row2[b0i] := byte(row2[30+b0i] + row2[31+b0i]+ row2[32+b0i]+ row2[63+b0i]) shr 2;
    end;

    for b0i := $1f downto 0 do row3[b0i] := rnd and 15;

    inc(zg);
    if zg = 10 then begin inc(zf); zg := 0 end;
    if zf = 10 then begin inc(ze); zf := 0 end;
  end;

  DisableDLI; gprior := 0; dmactl := $22;
end;

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5c'Flames2 GTIA 250 frames'~;
  isRewritable := true;
end.
