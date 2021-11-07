uses atari;

var a: byte;

begin
  repeat
    a := RTCLOK3 + VCOUNT shl 1;
    wsync := a; COLPF2 := a; COLBK := a;
  until false;
end.