uses crt;

const

	range = 511;

var
 rcp: array [0..RANGE] of word;

 f:file;

 i: integer;

 v: byte;


begin


 for i:=1 to RANGE do
  rcp[i] := trunc( (1/i) * 65536 + 0.99999);


 assign(f, 'lrcp.bin'); rewrite(f, 1);
 for i:=0 to RANGE do begin
  v:=rcp[i] and $ff;
  blockwrite(f, v, 1);
 end;
 closefile(f);


 assign(f, 'hrcp.bin'); rewrite(f, 1);
 for i:=0 to RANGE do begin
  v:=rcp[i] shr 8;
  blockwrite(f, v, 1);
 end;
 closefile(f);

end.
