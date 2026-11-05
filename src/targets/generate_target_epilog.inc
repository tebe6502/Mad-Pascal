// Included in Compiler.pas
procedure GenerateTargetEpilog;
begin

  if target.id = TTargetID.X65 then begin
    asm65;
    asm65('VECTORS = $FFE0');
    asm65('VEC_END = $010000');
    asm65(#9'org [a(VECTORS), a(VEC_END-1)], VECTORS');
    asm65;
    asm65(#9':14 .word 0');
    asm65(#9'.word $' + IntToHex(target.codeorigin, 4));
    asm65(#9'.word 0');
  end;

  asm65;
  asm65(#9'end');

end;
