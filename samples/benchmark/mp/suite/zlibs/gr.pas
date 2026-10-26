unit gr;

//---------------------- INTERFACE ---------------------------------------------

interface

const
  charset        = $8000;
  counterCharset = charset + $400;
  counterLms     = $20;
  scoreLms       = $e000;
  lms            = $a010;

var
  color4        : byte absolute $d01a;
  gprior        : byte absolute $d01b;
  dmactl        : byte absolute $d400;
  sdlstl        : word absolute $d402;
  chbas         : byte absolute $d409;

  procedure mode8;
  procedure mode4;
  procedure mode2;
  procedure counterRow;
  procedure showScore;

//---------------------- IMPLEMENTATION ----------------------------------------

implementation

const
  dl8: array [0..205] of byte = (
    $f0,$70,$70,
    $42,counterLms,$00,
    $f0,
    $4f,lo(lms),hi(lms),
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,
    $4f,0,hi(lms)+$10,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,
    $0f,
    $41,lo(word(@dl8)),hi(word(@dl8))
  );

  dl4: array [0..46] of byte = (
    $70,$70,$70,
    $42,counterLms,$00,
    $70,
    $49,lo(lms),hi(lms),
    $09,$09,$09,$09,$09,$09,$09,$09,
    $09,$09,$09,$09,$09,$09,$09,$09,
    $09,$09,$09,$09,$09,$09,$09,$09,
    $09,$09,$09,$09,$09,$09,$09,$09,
    $09,$09,
    $41,lo(word(@dl4)),hi(word(@dl4))
  );

  dlScore : array [0..31] of byte = (
    $70,$70,$70,
    $42,lo(scoreLms),hi(scoreLms),
    $02,$02,$02,$02,$02,$02,$02,$02,
    $02,$02,$02,$02,$02,$02,$02,$02,
    $02,$02,$02,$02,$02,$02,$02,
    $41,lo(word(@dlScore)),hi(word(@dlScore))
  );

  dl2: array [0..32] of byte = (
    $f0,$70,$70,
    $42,counterLms,$00,
    $f0,
    $42,lo(lms)-$10,hi(lms)+4,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    $41,lo(word(@dl2)),hi(word(@dl2))
  );

  dlCounter: array [0..8] of byte = (
    $70,$70,$70,
    $42,counterLms,$00,
    $41,lo(word(@dlCounter)),hi(word(@dlCounter))
  );

procedure mode8;
begin
  sdlstl := word(@dl8)
end;

procedure mode4;
begin
  sdlstl := word(@dl4)
end;

procedure mode2;
begin
  sdlstl := word(@dl2)
end;

procedure counterRow;
begin
  sdlstl := word(@dlCounter)
end;

procedure showScore;
begin
  pause;
  chbas := hi(charset);
  sdlstl := word(@dlScore)
end;

//---------------------- INITIALIZATION ----------------------------------------

initialization

end.
