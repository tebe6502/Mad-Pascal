unit sha1;
(*
 @type: unit
 @author: Free Pascal development team, Tomasz Biela (Tebe)
 @name: SHA1

 @version: 1.1 (2022-10-09)

 @description:
 Implements a SHA-1 digest algorithm (RFC 3174)

 <https://github.com/alrieckert/freepascal/blob/master/packages/hash/src/sha1.pp>

 <https://emn178.github.io/online-tools/index.html>

*)

{
    This file is part of the Free Pascal packages.
    Copyright (c) 2009-2014 by the Free Pascal development team

    Implements a SHA-1 digest algorithm (RFC 3174)

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    https://github.com/transmission-remote-gui/transgui/blob/master/COPYING.FPC
}


interface

type
  TSHAString = string[40];

  TSHA1Context = record
    State: array[0..4] of Cardinal;
    Buffer: array[0..63] of Byte;
    BufCnt: PtrUInt;   { in current block, i.e. in range of 0..63 }
    Len: Word;         { total count of bytes processed }
  end;

  TSHA1Digest = array[0..19] of Byte;

{ core }
procedure SHA1Init(var ctx: TSHA1Context);
(*
@description:
*)
procedure SHA1Update(var ctx: TSHA1Context; var Buf; BufLen: PtrUInt);
(*
@description:
*)
procedure SHA1Final(var ctx: TSHA1Context; var Digest: TSHA1Digest);
(*
@description:
*)

{ auxiliary }
function SHA1String(const S: String): TSHA1Digest;
(*
@description:
*)
function SHA1Buffer(var Buf; BufLen: PtrUInt): TSHA1Digest;
(*
@description:
*)
function SHA1File(const Filename: TString): TSHA1Digest;
(*
@description:
*)

{ helpers }
function SHA1Print(const Digest: TSHA1Digest): TSHAString;
(*
@description:
*)
function SHA1Match(const Digest1, Digest2: TSHA1Digest): Boolean;
(*
@description:
*)

implementation

const
  K20 = $5A827999;
  K40 = $6ED9EBA1;
  K60 = $8F1BBCDC;
  K80 = $CA62C1D6;

  HexTbl: array[0..15] of char='0123456789abcdef';     // lowercase

  PADDING: array[0..63] of Byte =
    ($80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    );


// inverts the bytes of (Count div 4) cardinals from source to target.
procedure Invert(Source, Dest: Pointer; Count: PtrUInt);
var
  S: PByte;
  T: PCardinal;
  I: PtrUInt;
begin
  S := Source;
  T := Dest;
  for I := 1 to (Count shr 2) do
  begin
    T^ := S[3] or (S[2] shl 8) or (S[1] shl 16) or (S[0] shl 24);
    inc(S,4);
    inc(T);
  end;
end;


procedure SHA1Init(var ctx: TSHA1Context);
begin
  FillChar(ctx, sizeof(TSHA1Context), 0);
  ctx.State[0] := $67452301;
  ctx.State[1] := $efcdab89;
  ctx.State[2] := $98badcfe;
  ctx.State[3] := $10325476;
  ctx.State[4] := $c3d2e1f0;
end;


// Use original version if asked for, or when we have no optimized assembler version
procedure SHA1Transform(var ctx: TSHA1Context; Buf: Pointer);
var
  A, B, C, D, E, T: Cardinal;
  Data: array[0..15] of Cardinal;
  i: byte;
begin
  A := ctx.State[0];
  B := ctx.State[1];
  C := ctx.State[2];
  D := ctx.State[3];
  E := ctx.State[4];
  Invert(Buf, @Data, 64);

  i := 0;
  repeat
    T := (B and C) or (not B and D) + K20 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15]);
    Inc(i);
  until i > 19;

  repeat
    T := (B xor C xor D) + K40 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15]);
    Inc(i);
  until i > 39;

  repeat
    T := (B and C) or (B and D) or (C and D) + K60 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15]);
    Inc(i);
  until i > 59;

  repeat
    T := (B xor C xor D) + K80 + E;
    E := D;
    D := C;
    C := rordword(B, 2);
    B := A;
    A := T + roldword(A, 5) + Data[i and 15];
    Data[i and 15] := roldword(Data[i and 15] xor Data[(i+2) and 15] xor Data[(i+8) and 15] xor Data[(i+13) and 15]);
    Inc(i);
  until i > 79;

  Inc(ctx.State[0], A);
  Inc(ctx.State[1], B);
  Inc(ctx.State[2], C);
  Inc(ctx.State[3], D);
  Inc(ctx.State[4], E);

  Inc(ctx.Len,64);
end;


procedure SHA1Update(var ctx: TSHA1Context; var Buf; BufLen: PtrUInt);
var
  Src: PByte;
  Num: PtrUInt;
begin
  if BufLen = 0 then
    Exit;

  Src := @Buf;
  Num := 0;

  // 1. Transform existing data in buffer
  if ctx.BufCnt > 0 then
  begin
    // 1.1 Try to fill buffer up to block size
    Num := 64 - ctx.BufCnt;
    if Num > BufLen then
      Num := BufLen;

    Move(Src^, ctx.Buffer[ctx.BufCnt], Num);
    Inc(ctx.BufCnt, Num);
    Inc(Src, Num);

    // 1.2 If buffer is filled, transform it
    if ctx.BufCnt = 64 then
    begin
      SHA1Transform(ctx, @ctx.Buffer);
      ctx.BufCnt := 0;
    end;
  end;

  // 2. Transform input data in 64-byte blocks
  Num := BufLen - Num;
  while Num >= 64 do
  begin
    SHA1Transform(ctx, Src);
    Inc(Src, 64);
    Dec(Num, 64);
  end;

  // 3. If there's less than 64 bytes left, add it to buffer
  if Num > 0 then
  begin
    ctx.BufCnt := Num;
    Move(Src^, ctx.Buffer, Num);
  end;

end;


procedure SHA1Final(var ctx: TSHA1Context; var Digest: TSHA1Digest);
var
  Len: Cardinal;
  Pads: Cardinal;
  tmp: array [0..7] of byte;
begin
  // 1. Compute length of the whole stream in bits
  Len := (ctx.Len + ctx.BufCnt) shl 3;

  // 2. Append padding bits
  if ctx.BufCnt >= 56 then
    Pads := 120 - ctx.BufCnt
  else
    Pads := 56 - ctx.BufCnt;

  SHA1Update(ctx, PADDING, Pads);

  // 3. Append length of the stream (8 bytes)
  //Len := NtoBE(Len);

  tmp[0]:=0;
  tmp[1]:=0;
  tmp[2]:=0;
  tmp[3]:=0;
  tmp[4]:=len shr 24;
  tmp[5]:=len shr 16;
  tmp[6]:=len shr 8;
  tmp[7]:=len;

  SHA1Update(ctx, Tmp, 8);

  // 4. Invert state to digest
  Invert(@ctx.State, @Digest, 20);
  FillChar(ctx, sizeof(TSHA1Context), 0);
end;


function SHA1String(const S: String): TSHA1Digest;
var
  Context: TSHA1Context;
begin
  SHA1Init(Context);
  SHA1Update(Context, PChar(@S[1])^, length(S));
  SHA1Final(Context, Result);
end;


function SHA1Buffer(var Buf; BufLen: PtrUInt): TSHA1Digest;
var
  Context: TSHA1Context;
begin
  SHA1Init(Context);
  SHA1Update(Context, buf, buflen);
  SHA1Final(Context, Result);
end;


function SHA1File(const Filename: TString): TSHA1Digest;
var
  F: File;
  Buf: Pchar;
  Context: TSHA1Context;
  Count: Word;

const
  Bufsize = 256;

begin

  SHA1Init(Context);

  Assign(F, Filename);
  Reset(F, 1);

  if IOResult = 1 then		// PC -> IORESULT=0 ; ATARI -> IORESULT = 1
  begin
    GetMem(Buf, BufSize);
    repeat
      BlockRead(F, Buf^, Bufsize, Count);

      if Count > 0 then
        SHA1Update(Context, Buf^, Count);
    until Count < BufSize;

    FreeMem(Buf, BufSize);
    Close(F);
  end;

  SHA1Final(Context, Result);
end;


function SHA1Print(const Digest: TSHA1Digest): TSHAString;
var
  I: byte;
  P: PChar;
begin
  SetLength(Result, 40);
  P := @Result[1];
  for I := 0 to 19 do
  begin
    P[0] := HexTbl[(Digest[i] shr 4) and 15];
    P[1] := HexTbl[Digest[i] and 15];
    Inc(P,2);
  end;
end;


function SHA1Match(const Digest1, Digest2: TSHA1Digest): Boolean;
var
  A: array[0..4] of Cardinal absolute Digest1;
  B: array[0..4] of Cardinal absolute Digest2;
begin

  Result := (A[0] = B[0]) and (A[1] = B[1]) and (A[2] = B[2]) and (A[3] = B[3]) and (A[4] = B[4]);

end;

end.
