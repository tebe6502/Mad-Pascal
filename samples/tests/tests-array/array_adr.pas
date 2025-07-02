{
 252
 253
 254
 255
 0
 0
 0
 0
 252
 253
 254
 255
 0
 1
 2
 3
}

uses crt;

var
 qb: array [0..255] of byte;
 qw: array [0..127] of word;
 qc: array [0..63] of cardinal;

 b, i: byte;
 w: word;
 c: cardinal;

{$define _byte}
//{$define _word}
//{$define _card}

begin


// byte

{$ifdef _byte}
for i:=0 to 255 do qb[i]:=i;

for i:=248 to 255 do begin
 b:=qb[i+4];
 writeln(b);
end;

for i:=248 to 255 do begin
 b:=qb[byte(i+4)];
 writeln(b);
end;
{$endif}

// word

{$ifdef _word}
for i:=0 to 127 do qw[i]:=i;

for i:=118 to 127 do begin
 w:=qw[i+4];
 writeln(w);
end;

for i:=118 to 127 do begin
 w:=qw[byte(i+4)] ;
 writeln(w);
end;
{$endif}


// cardinal

{$ifdef _card}
for i:=0 to 63 do qc[i]:=i;

for i:=53 to 63 do begin
 c:=qc[i+4];
 writeln(c);
end;

for i:=53 to 63 do begin
 c:=qc[byte(i+4)] ;
 writeln(c);
end;
{$endif}

repeat until keypressed;

end.