unit md5;
(*
 @type: unit
 @author: Free Pascal development team, Tomasz Biela (Tebe)
 @name: MD5

 @version: 1.2 (2025-09-24) MD5Print
           1.1 (2022-09-28)

 @description:
 Implements a MD5 digest algorithm (RFC 1321)

 <https://github.com/alrieckert/freepascal/blob/master/packages/hash/src/md5.pp>

*)

{
Original implementor copyright:
Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All
rights reserved.

License to copy and use this software is granted provided that it
is identified as the "RSA Data Security, Inc. MD5 Message-Digest
Algorithm" in all material mentioning or referencing this software
or this function.

License is also granted to make and use derivative works provided
that such works are identified as "derived from the RSA Data
Security, Inc. MD5 Message-Digest Algorithm" in all material
mentioning or referencing the derived work.

RSA Data Security, Inc. makes no representations concerning either
the merchantability of this software or the suitability of this
software for any particular purpose. It is provided "as is"
without express or implied warranty of any kind.

These notices must be retained in any copies of any part of this
documentation and/or software.
}


interface

type

 FourBytes = array[0..3] of byte;

 TMD5 = record
    Align,
    BufCnt,
    Len     : word;
    State   : array [0..3] of cardinal;
    Buffer  : array [0..63] of byte;
  end;

procedure MD5Buffer(var Buffer; BufLen: word; var MD5: TMD5);
(*
@description:
*)

procedure MD5String(var txt: String; var MD5: TMD5);
(*
@description:
*)

procedure MD5File(const Filename: TString; var MD5: TMD5);
(*
@description:
*)

function MD5Print(var MD5: TMD5): TString;
(*
@description:
*)


implementation


const

s: array[0..63] of byte = (
	7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
	5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
	4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
	6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21 );

K: array[0..63] of cardinal = (
	$d76aa478, $e8c7b756, $242070db, $c1bdceee,
	$f57c0faf, $4787c62a, $a8304613, $fd469501,
	$698098d8, $8b44f7af, $ffff5bb1, $895cd7be,
	$6b901122, $fd987193, $a679438e, $49b40821,
	$f61e2562, $c040b340, $265e5a51, $e9b6c7aa,
	$d62f105d, $02441453, $d8a1e681, $e7d3fbc8,
	$21e1cde6, $c33707d6, $f4d50d87, $455a14ed,
	$a9e3e905, $fcefa3f8, $676f02d9, $8d2a4c8a,
	$fffa3942, $8771f681, $6d9d6122, $fde5380c,
	$a4beea44, $4bdecfa9, $f6bb4b60, $bebfbc70,
	$289b7ec6, $eaa127fa, $d4ef3085, $04881d05,
	$d9d4d039, $e6db99e5, $1fa27cf8, $c4ac5665,
	$f4292244, $432aff97, $ab9423a7, $fc93a039,
	$655b59c3, $8f0ccc92, $ffeff47d, $85845dd1,
	$6fa87e4f, $fe2ce6e0, $a3014314, $4e0811a1,
	$f7537e82, $bd3af235, $2ad7d2bb, $eb86d391 );


function reverse32(v: cardinal): cardinal; register;
begin
 reverse32 := byte(v shr 24) + byte(v shr 16) shl 8 + byte(v shr 8) shl 16 + byte(v) shl 24;
end;


procedure MDInit(var Context: TMD5);
begin

 Context.Align := 64;
 Context.State[0] := $67452301;
 Context.State[1] := $efcdab89;
 Context.State[2] := $98badcfe;
 Context.State[3] := $10325476;
 Context.Len := 0;
 Context.BufCnt := 0;

end;


procedure MDHash(var Context: TMD5; var Buffer);
type
  TBlock = array[0..15] of Cardinal;
  PBlock = ^TBlock;
var
  a: cardinal register;
  b: cardinal register;
  c: cardinal register;
  d: cardinal register;

  f, x, y: Cardinal;
  Block: PBlock absolute Buffer;
  i, g: byte;

begin

  a := Context.State[0];
  b := Context.State[1];
  c := Context.State[2];
  d := Context.State[3];

//main loop:
    for i := 0 to 63 do begin

	if i < 16 then begin
	  g := i;
	  f := (b and c) or ((not b) and d);
	end else
	if i < 32 then begin
	  g := (5*i + 1) and $0f;
	  f := (d and b) or ((not d) and c);
	end else
	if i < 48 then begin
	  g := (3*i + 5) and $0f;
	  f := b xor c xor d;
	end else begin
	  g := (7*i) and $0f;
	  f := c xor (b or (not d));
	end;

	f:=f+a;

	a := d;
        d := c;
        c := b;

	x := (f + K[i] + Block[g]);

	g:=32-s[i];

        y := (x shl s[i]) or (x shr g);

        b := b + y;
    end;

  inc(Context.State[0], a);
  inc(Context.State[1], b);
  inc(Context.State[2], c);
  inc(Context.State[3], d);

  inc(Context.Len,64);

end;


procedure MDUpdate(var Context: TMD5; var Buf; const BufLen: Word);
var
  Align, Num: word;
  Src: PByte;
begin

  if BufLen = 0 then
    Exit;

  Align := Context.Align;
  Src := @Buf;
  Num := 0;

  // 1. Transform existing data in buffer
  if Context.BufCnt <> 0 then
  begin
    // 1.1 Try to fill buffer to "Align" bytes
    Num := Align - Context.BufCnt;
    if Num > BufLen then
      Num := BufLen;

    move(Src^, Context.Buffer[Context.BufCnt], Num);

    Context.BufCnt := Context.BufCnt + Num;
    Src := Pointer(PtrUInt(Src) + Num);

    // 1.2 If buffer contains "Align" bytes, transform it
    if Context.BufCnt = Align then
    begin
      MDHash(Context, Context.Buffer);
      Context.BufCnt := 0;
    end;
  end;

  // 2. Transform "Align"-Byte blocks of Buf
  Num := BufLen - Num;

  while Num >= Align do
  begin
    MDHash(Context, Src^);
    Src := Pointer(PtrUInt(Src) + Align);
    Num := Num - Align;
  end;


  // 3. If there's a block smaller than "Align" Bytes left, add it to buffer
  if Num > 0 then
  begin
    Context.BufCnt := Num;

    move(Src^, Context.Buffer, Num);
  end;
end;


procedure MDFinal(var Context: TMD5);
const
  PADDING_MD45: array[0..15] of Cardinal = ($80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
var
  Len: cardinal;
  Pads: word;
begin

  // 1. Compute length of the whole stream in bits
  Len := word(Context.Len + Context.BufCnt) shl 3;

  // 2. Append padding bits
  if Context.BufCnt >= 56 then
    Pads := 120 - Context.BufCnt
  else
    Pads := 56 - Context.BufCnt;

  MDUpdate(Context, PADDING_MD45, Pads);

  // 3. Append length of the stream
  MDUpdate(Context, Len, 4);

  Len:=0;

  MDUpdate(Context, Len, 4);

  // 4. Invert state to digest
  Context.State[0]:=reverse32(Context.State[0]);
  Context.State[1]:=reverse32(Context.State[1]);
  Context.State[2]:=reverse32(Context.State[2]);
  Context.State[3]:=reverse32(Context.State[3]);

end;


procedure MD5Buffer(var Buffer; BufLen: word; var MD5: TMD5);
begin

  MDInit(md5);
  MDUpdate(md5, Buffer, BufLen);
  MDFinal(md5);

end;


procedure MD5String(var txt: String; var MD5: TMD5);
begin

  MDInit(md5);
  MDUpdate(md5, txt[1], length(txt));
  MDFinal(md5);

end;


procedure MD5File(const Filename: TString; var MD5: TMD5);
var
  F: File;
  Buf: PByte;
  Count: word;
begin
  MDInit(md5);

  Assign(F, Filename); reset(F,1);

  if IOResult < 128 then
  begin
    GetMem(Buf, 256);

    repeat

      BlockRead(F, Buf^, 256, Count);

      if Count > 0 then
        MDUpdate(md5, Buf^, Count);

    until Count < 256;

    FreeMem(Buf, 256);
    Close(F);
  end;

  MDFinal(md5);
end;


function MD5Print(var MD5: TMD5): TString;
const
    thex: array [0..15] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

var i, a: byte;
    c: cardinal;


 procedure AddByte;
 var j: byte;
 begin
 
   for j:=3 downto 0 do begin

    a := FourBytes( c )[j];
  
    Result[i]:=thex[a shr 4];
    Result[i+1]:=thex[a and $0f];
    
    inc(i, 2);
   end; 
  
 end;


begin

 Result[0]:=#32;
 i:=1;

 c := md5.State[0]; AddByte;
 c := md5.State[1]; AddByte;
 c := md5.State[2]; AddByte;
 c := md5.State[3]; AddByte;

end;


end.
