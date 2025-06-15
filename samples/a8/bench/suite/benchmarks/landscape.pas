unit landscape;

//---------------------- COMMON INTERFACE --------------------------------------

{$i '../inc/header.inc'}

//---------------------- IMPLEMENTATION ----------------------------------------

const
  base: array[0..13] of byte = (170,150,144,144,122,122,110,110,94,94,86,86,82,80);

procedure g9off; assembler; interrupt;
asm
  pha
  mva #0 gr.gprior
  mwa #G9ON __dlivec
  pla
end;

procedure g9on; assembler; interrupt;
asm
  pha
  mva #$40 gr.gprior
  mwa #G9OFF __dlivec
  pla
end;

{$codealign proc = $100}

procedure benchmark;
var
  stop     : byte  absolute $e0;
  start    : byte  absolute $e1;

  c        : byte  register;
  x        : byte  register;
  i        : byte  register;
  z        : byte  register;
  p        : PByte register;

  colheight: array[0..13] of byte absolute $e2;

begin
  EnableDLI(@g9off); mode8;
  gprior := $40; color4 := $b0;

  for z := 9 downto 0 do begin
    move(base, colheight, 14);
    for x := 39 downto 0 do begin
      for i := 1 downto 0 do begin
        p := pointer(lms + x); start := 0;
        for c := 13 downto 0 do begin

          stop := colheight[c];
          if start > stop then begin
            dec(p,byte(start - stop) * 40);
            stop := start;
            start := colheight[c];
          end;

          if i > 0 then begin
            while start < stop do begin
              p^ := c;
              inc(p,40); inc(start);
            end;
          end else begin
            while start < stop do begin
              p^ := (p^ and %00001111) or (c shl 4);
              inc(p,40); inc(start);
            end;
          end;

          start := stop;
          if rnd < 128 then dec(colheight[c]);
          if rnd < 128 then inc(colheight[c]);

        end;
      end;
    end;
  end;
  DisableDLI; gprior := 0;
end;

{$codealign proc = 0}

//---------------------- COMMON PROCEDURE --------------------------------------

{$i '../inc/run.inc'}

//---------------------- INITIALIZATION ----------------------------------------

initialization
  name := #$5d'Quatari Landscape GR9 10x'~;
end.
