// https://github.com/drmortalwombat/oscar64/blob/main/samples/particles/fireworks_ptr.c

program Fireworks;

uses crt, fastgraph;

const
  MAX_PARTICLES = 256;

type
  PParticle = ^TParticle;

  TParticle = record
    next   : PParticle;
    px, py : smallint;
    vx, vy : smallint;
  end;

var
  [striped] particles : array[0..MAX_PARTICLES-1] of PParticle;

  pfirst : PParticle;
  pfree  : PParticle;

  k: byte;


procedure particle_init;
var
  i : byte;
begin

  for i:=0 to 255 do begin
   particles[i] := GetMem(sizeof(TParticle));
  end;

  { initialize list heads }
  pfirst := nil;

  pfree := particles[0];

  { link all particles into free list }
  for i := 0 to 254 do
    particles[i].next := particles[i + 1];

  particles[255].next := nil;

end;


procedure particle_add(px, py, vx, vy: smallint);
var
  p : PParticle;
begin

  { check if particle is available }

  if pfree <> nil then
  begin
    { remove from free list }
    p := pfree;
    pfree := pfree^.next;

    { add to used list }
    p^.next := pfirst;
    pfirst := p;

    { initialize particle }
    p^.px  := px;
    p^.py  := py;
    p^.vx  := vx;
    p^.vy  := vy;
  end;

end;


procedure particle_move;
var
  p, pp, pn : PParticle;
begin

  pp := nil;

  { first particle, previous particle }

  p := pfirst;

  { process used particle list }
  while p <> nil do
  begin
    { clear old particle image }
    SetColor(0);
    PutPixel(p^.px, p^.py);

    { advance position }
    p^.px := p^.px + (p^.vx shl 1) shr 8;	// shl 1) shr 8 -> shr 7
    p^.py := p^.py + (p^.vy shl 1) shr 8;	// shl 1) shr 8 -> shr 7

    { gravity }
    p^.vy := p^.vy + 8;

    { check screen boundaries }
    if (p^.px < 0) or
       (p^.px >= 320) or
       (p^.py < 0) or
       (p^.py >= 192) then
    begin
      { remember next particle }
      pn := p^.next;

      { remove from used list }
      if pp <> nil then
        pp^.next := pn
      else
        pfirst := pn;

      { return to free list }
      p^.next := pfree;
      pfree := p;

      { next particle }
      p := pn;

    end
    else
    begin
      { draw particle at new position }
      SetColor(15);
      PutPixel(p^.px, p^.py);

      { next particle }
      pp := p;
      p := p^.next;

    end;
  end;


end;


function rnorm: smallint;
var
  l0, l1, l2, l3 : smallint;
begin
  l0 := Random(32);
  l1 := Random(48);
  l2 := Random(16);
  l3 := Random(64);

  rnorm := l0 + l1 + l2 + l3;

end;


begin

  randomize;


  InitGraph(8);

  { initialize particle system }
  particle_init;

  k := 0;

  repeat

    pause;

    { advance particles }
    particle_move;


     if k < 25 then
    begin
      { particle from left }
      particle_add(
        4 ,
        188 ,
        rnorm + 256,
        -(rnorm + 384)
      );
    end
    else
    if k < 50 then
    begin
      { particle from right }
      particle_add(
        316 ,
        188 ,
        -(rnorm + 256),
        -(rnorm + 384)
      );
    end
    else
    if k < 75 then
    begin
      { particle from middle }

{
      particle_add(
        160 ,
        188 ,
        rnorm,
        -(rnorm + 384)
      );
}

    end;

    { advance thirds counter }
    Inc(k);

    if k = 75 then
      k := 0;

  until keypressed;


  repeat until keypressed;

end.
