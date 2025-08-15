unit sha256;
(*
@type: unit
@author: Stijn Sanders, Tomasz 'Tebe' Biela
@name: SHA256

@version: 1.0

@description:

  sha256
  by Stijn Sanders (https://github.com/stijnsanders)
  http://yoy.be/md5
  2013-2018
  v1.0.4

  based on http://en.wikipedia.org/wiki/SHA-2

  License: no license, free for any use

*)


interface

type
   SHA256Result = array [0..31] of byte;

function SHA256Hash(x: string): SHA256Result;

implementation


function SwapEndian32(Value: cardinal): cardinal;
var
  x:array[0..3] of byte absolute Result;
  y:array[0..3] of byte absolute Value;
begin
  x[0]:=y[3];
  x[1]:=y[2];
  x[2]:=y[1];
  x[3]:=y[0];
end;


function SHA256Hash(x: string): SHA256Result;
const
  base:array[0..63] of cardinal=(
    $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5,
    $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
    $d807aa98, $12835b01, $243185be, $550c7dc3,
    $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
    $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc,
    $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
    $983e5152, $a831c66d, $b00327c8, $bf597fc7,
    $c6e00bf3, $d5a79147, $06ca6351, $14292967,
    $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13,
    $650a7354, $766a0abb, $81c2c92e, $92722c85,
    $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3,
    $d192e819, $d6990624, $f40e3585, $106aa070,
    $19a4c116, $1e376c08, $2748774c, $34b0bcb5,
    $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
    $748f82ee, $78a5636f, $84c87814, $8cc70208,
    $90befffa, $a4506ceb, $bef9a3f7, $c67178f2);
var
  a,b:cardinal;
  dl:word;
  i, j: byte;
  d: array [0..255] of cardinal;
  [striped] e: array[0..63] of cardinal;
  [striped] g: array[0..7] of cardinal;
  [striped] h: array[0..7] of cardinal;
begin

  a:=Length(x);

  dl:=a+9;
  if (dl and $3f) <> 0 then dl := ((dl shr 6) + 1) shl 6;
  
  if dl > 255 then exit;		// string[255] limit
  
  i:=dl;
  dl:=dl shr 2;

  SetLength(x,i);

  j:=a+1;

  x[j]:=#$80;
  while j<i do
   begin
    inc(j);
    x[j]:=#0;
   end;

  Move(x[1],d[0],i);
  
  d[dl-1]:=SwapEndian32(a shl 3);

  h[0]:=$6a09e667;
  h[1]:=$bb67ae85;
  h[2]:=$3c6ef372;
  h[3]:=$a54ff53a;
  h[4]:=$510e527f;
  h[5]:=$9b05688c;
  h[6]:=$1f83d9ab;
  h[7]:=$5be0cd19;

  i:=0;
  while i<dl do
   begin

    j:=0;

    while j<16 do
     begin
      e[j]:=SwapEndian32(d[i]);
      inc(i);
      inc(j);
     end;

    while j<64 do
     begin

      a:=e[j-15];
      b:=e[j-2];

      e[j]:=e[j-16]+
        (((a shr  7) or (a shl 25)) xor
         ((a shr 18) or (a shl 14)) xor
          (a shr  3))+
        e[j-7]+
        (((b shr 17) or (b shl 15)) xor
         ((b shr 19) or (b shl 13)) xor
          (b shr 10));

      inc(j);
     end;

    g:=h;
    j:=0;

    while j<64 do
     begin

      a:=g[4];

      b:=g[0];

      a:=g[7]+
        (((a shr  6) or (a shl 26)) xor
         ((a shr 11) or (a shl 21)) xor
         ((a shr 25) or (a shl  7)))+
        ((g[4] and g[5]) or (not(g[4]) and g[6]))+
        base[j]+e[j];

      inc(g[3],a);

      a:=a+
        (((b shr  2) or (b shl 30)) xor
         ((b shr 13) or (b shl 19)) xor
         ((b shr 22) or (b shl 10)))+
        ((g[0] and g[1]) or (g[1] and g[2]) or (g[2] and g[0]));

      g[7]:=g[6];
      g[6]:=g[5];
      g[5]:=g[4];
      g[4]:=g[3];
      g[3]:=g[2];
      g[2]:=g[1];
      g[1]:=g[0];
      g[0]:=a;

      inc(j);
     end;

    for j:=7 downto 0 do inc(h[j],g[j]);

   end;

  i:=0;
  for j:=0 to 7 do begin
   Result[i]   := h[j] shr 24;
   Result[i+1] := h[j] shr 16;
   Result[i+2] := h[j] shr 8;
   Result[i+3] := h[j];

   inc(i, 4);
  end;

end;

end.
