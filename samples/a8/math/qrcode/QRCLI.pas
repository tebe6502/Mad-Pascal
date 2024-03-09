program QRCLI;
{
  Simple QR Code Generator in console window

  Developed by bookhanming@outlook.my, Nov 2020
  With reference to Wikipedia QR Code entry.

  This program contains simple Reed-Solomon encoder written by Cliff Hones.
  And its Pascal port done by Jose Mejuto through Robin Stuart's Zint API.
}

uses Crt,sysutils;

var
  qr:array[0..23*23] of byte=
 (0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,0,
  0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,
  0,1,0,1,1,1,0,1,0,0,1,1,1,1,0,1,0,1,1,1,0,1,0,
  0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,
  0,1,0,1,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,1,0,1,0,
  0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,
  0,1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,0,
  0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,1,1,0,0,1,1,0,1,1,1,0,0,1,1,1,1,0,0,1,1,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,0,1,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,1,1,1,1,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
 {EC=Low, Mask Pattern= 0 on even rows, 1 on odd rows}
 i:word;
 s:string;
 data:array [0..20] of byte;
 ecc:array [0..8] of byte;
 matrix:array of byte;
 logmod: integer;              // 2**symsize - 1
 rlen: smallint;
 logt: PInteger;// = nil;
 alog: PInteger;// = nil;
 rspoly: PInteger;// = nil;

{  This is a simple Reed-Solomon encoder
  (C) Cliff Hones 2004

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
    3. Neither the name of the project nor the names of its contributors
       may be used to endorse or promote products derived from this software
       without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.}

procedure rs_init_gf(poly: Integer);
var
  b: Integer;
  p: Integer;
  v: Integer;
  m: Integer;
begin
  b := 1;
  m := 0;
  while b <= poly do
  begin
    Inc (m);
    b := b shl 1;
  end;
  b := b shr 1;
  Dec (m);
//  gfpoly := poly;
//  symsize := m;
  logmod := (1 shl m) - 1;

  logt := PInteger (GetMem (SizeOf (Integer) * (logmod + 1)));
  alog := PInteger (GetMem (SizeOf (Integer) * logmod));
  p := 1;
  v := 0;
  while v < logmod do
  begin
    alog[v] := p;
    logt[p] := v;
    p := p shl 1;
    if (p and b)<>0 then
    begin
			p:=p xor poly;
    end;
    Inc (v);
  end;
end;

procedure rs_init_code(nsym: smallint; index: smallint);
var
  k: smallint;
  i: smallint;
begin
  rspoly := PInteger (GetMem (SizeOf (Integer) * (nsym + 1)));

  rlen := nsym;
  rspoly[0] := 1;
  i := 1;
  while i <= nsym do
  begin
    rspoly[i] := 1;
    k := i - 1;
    while k > 0 do
    begin
      if rspoly[k]<>0 then
      begin
        rspoly[k] := alog[(logt[rspoly[k]] + index) mod logmod];
      end;
			rspoly[k] := rspoly[k] xor rspoly[k - 1];
      Dec (k);
    end;
    rspoly[0] := alog[(logt[rspoly[0]] + index) mod logmod];
    Inc (index);
    Inc (i);
  end;
end;

procedure rs_encode(len: smallint; data: PBYTE; res: PBYTE);
var
  k: smallint;
  m: smallint;
  i: smallint;
begin
  i := 0;
  while i < rlen do
  begin
    res[i] := 0;
    Inc (i);
  end;
  i := 0;
  while i < len do
  begin
    m := res[rlen - 1] xor data[i];
    k := rlen - 1;
    while k > 0 do
    begin
      if (m<>0) and (rspoly[k]<>0) then
      begin
        res[k] := integer(res[k - 1]) xor alog[(logt[m] + logt[rspoly[k]]) mod logmod];
      end else begin
        res[k] := integer(res[k - 1]);
      end;
      Dec (k);
    end;
    if (m<>0) and (rspoly[0]<>0) then
    begin
      res[0] := alog[(logt[m] + logt[rspoly[0]]) mod logmod];
    end else begin
      res[0] := 0;
    end;
    Inc (i);
  end;
end;

procedure rs_encode_long(len: smallint; data: PCardinal; res: PCardinal);
var
  k: smallint;
  m: smallint;
  i: smallint;
begin
  i := 0;
  while i < rlen do
  begin
    res[i] := 0;
    Inc (i);
  end;
  i := 0;
  while i < len do
  begin
    m := res[rlen - 1] xor data[i];
    k := rlen - 1;
    while k > 0 do
    begin
      if (m<>0) and (rspoly[k]<>0) then
      begin
        res[k] := Integer(res[k - 1]) xor alog[(logt[m] + logt[rspoly[k]]) mod logmod];
      end else begin
        res[k] := res[k - 1];
      end;
      Dec (k);
    end;
    if (m<>0) and (rspoly[0]<>0) then
    begin
      res[0] := alog[(logt[m] + logt[rspoly[0]]) mod logmod];
    end else begin
      res[0] := 0;
    end;
    Inc (i);
  end;
end;

procedure rs_free();
begin
//  freeMem (logt);
//  freeMem (alog);
//  freeMem (rspoly);
  rspoly := nil;
end;

procedure Bit(c:char;vert:boolean;up:boolean);
var
  i: byte;
  ret:array [0..8] of byte;
begin

  for i:=1 to 8 do
  begin
    ret[8-(i-1)]:=(Byte(c) and (1 shl (i-1))) shr (i-1);

    if vert then
    begin
      if (up) then
      begin

        case i of
	 3,4,7,8: if ret[8-(i-1)]=1 then ret[8-(i-1)]:=0 else ret[8-(i-1)]:=1;
	end;

      end
      else if (not up) then
      begin

        case i of
         1,2,5,6: if ret[8-(i-1)]=1 then ret[8-(i-1)]:=0 else ret[8-(i-1)]:=1;
	end;

      end;
    end
    else if (not vert) then
    begin
      if (up) then
      begin

        case i of
	 3,4,5,6: if ret[8-(i-1)]=1 then ret[8-(i-1)]:=0 else ret[8-(i-1)]:=1;
	end;

      end
      else if (not up) then
      begin

        case i of
         1,2,7,8: if ret[8-(i-1)]=1 then ret[8-(i-1)]:=0 else ret[8-(i-1)]:=1;
	end;

      end;
    end;
  end;

  matrix:=@ret[0];
end;

begin
  WriteLn('QRCLI <your own text string>');
  WriteLn;
  if ParamCount>0 then
    s:=ParamStr(1)
  else
    s:='FreePascal.org'; {Max Length=14}

//  SetLength(data,19+1);
  data[0]:=$40;
  data[1]:=14 shl 4;
  for i:=2 to 15 do
  begin
    if Byte(s[i-1])=0 then
      data[i]:=0
    else
    begin
      data[i-1]:=data[i-1] or (((Byte(s[i-1]) and $f0) shr 4));
      data[i]:=(Byte(s[i-1]) and $0f) shl 4;
    end;
  end;
//  SetLength(ecc,7+1);
  for i:=0 to 6 do
    ecc[i]:=0;


  rs_init_gf(285);
  rs_init_code(7,0);
  rs_encode(19,@data[0],@ecc[0]);
  rs_free;

  for i:=0 to 18 do
  begin
    Write(IntToHex(data[i],2));
    Write(' ');
  end;
  WriteLn;

  for i:=0 to 6 do
  begin
    Write(IntToHex(ecc[i],2));
    Write(' ');
  end;
  WriteLn;


  Bit(Chr(14),true,true);

  qr[23*17-2]:=matrix[8];
  qr[23*17-1]:=matrix[7];
  qr[23*18-2]:=matrix[6];
  qr[23*18-1]:=matrix[5];
  qr[23*19-2]:=matrix[4];
  qr[23*19-1]:=matrix[3];
  qr[23*20-2]:=matrix[2];
  qr[23*20-1]:=matrix[1];

  Bit(s[1],true,true);

  qr[23*13-2]:=matrix[8];
  qr[23*13-1]:=matrix[7];
  qr[23*14-2]:=matrix[6];
  qr[23*14-1]:=matrix[5];
  qr[23*15-2]:=matrix[4];
  qr[23*15-1]:=matrix[3];
  qr[23*16-2]:=matrix[2];
  qr[23*16-1]:=matrix[1];

  Bit(s[2],false,false);

  qr[23*12-4]:=matrix[8];
  qr[23*12-3]:=matrix[7];
  qr[23*12-2]:=matrix[2];
  qr[23*12-1]:=matrix[1];
  qr[23*11-4]:=matrix[6];
  qr[23*11-3]:=matrix[5];
  qr[23*11-2]:=matrix[4];
  qr[23*11-1]:=matrix[3];

  Bit(s[3],true,false);

  qr[23*13-4]:=matrix[2];
  qr[23*13-3]:=matrix[1];
  qr[23*14-4]:=matrix[4];
  qr[23*14-3]:=matrix[3];
  qr[23*15-4]:=matrix[6];
  qr[23*15-3]:=matrix[5];
  qr[23*16-4]:=matrix[8];
  qr[23*16-3]:=matrix[7];

  Bit(s[4],true,false);

  qr[23*17-4]:=matrix[2];
  qr[23*17-3]:=matrix[1];
  qr[23*18-4]:=matrix[4];
  qr[23*18-3]:=matrix[3];
  qr[23*19-4]:=matrix[6];
  qr[23*19-3]:=matrix[5];
  qr[23*20-4]:=matrix[8];
  qr[23*20-3]:=matrix[7];

  Bit(s[5],false,true);
  qr[23*21-6]:=matrix[8];
  qr[23*21-5]:=matrix[7];
  qr[23*21-4]:=matrix[2];
  qr[23*21-3]:=matrix[1];
  qr[23*22-6]:=matrix[6];
  qr[23*22-5]:=matrix[5];
  qr[23*22-4]:=matrix[4];
  qr[23*22-3]:=matrix[3];

  Bit(s[6],true,true);

  qr[23*17-6]:=matrix[8];
  qr[23*17-5]:=matrix[7];
  qr[23*18-6]:=matrix[6];
  qr[23*18-5]:=matrix[5];
  qr[23*19-6]:=matrix[4];
  qr[23*19-5]:=matrix[3];
  qr[23*20-6]:=matrix[2];
  qr[23*20-5]:=matrix[1];

  Bit(s[7],true,true);

  qr[23*13-6]:=matrix[8];
  qr[23*13-5]:=matrix[7];
  qr[23*14-6]:=matrix[6];
  qr[23*14-5]:=matrix[5];
  qr[23*15-6]:=matrix[4];
  qr[23*15-5]:=matrix[3];
  qr[23*16-6]:=matrix[2];
  qr[23*16-5]:=matrix[1];

  Bit(s[8],false,false);

  qr[23*12-8]:=matrix[8];
  qr[23*12-7]:=matrix[7];
  qr[23*12-6]:=matrix[2];
  qr[23*12-5]:=matrix[1];
  qr[23*11-8]:=matrix[6];
  qr[23*11-7]:=matrix[5];
  qr[23*11-6]:=matrix[4];
  qr[23*11-5]:=matrix[3];

  Bit(s[9],true,false);

  qr[23*13-8]:=matrix[2];
  qr[23*13-7]:=matrix[1];
  qr[23*14-8]:=matrix[4];
  qr[23*14-7]:=matrix[3];
  qr[23*15-8]:=matrix[6];
  qr[23*15-7]:=matrix[5];
  qr[23*16-8]:=matrix[8];
  qr[23*16-7]:=matrix[7];

  Bit(s[10],true,false);

  qr[23*17-8]:=matrix[2];
  qr[23*17-7]:=matrix[1];
  qr[23*18-8]:=matrix[4];
  qr[23*18-7]:=matrix[3];
  qr[23*19-8]:=matrix[6];
  qr[23*19-7]:=matrix[5];
  qr[23*20-8]:=matrix[8];
  qr[23*20-7]:=matrix[7];

  Bit(s[11],false,true);
  qr[23*21-10]:=matrix[8];
  qr[23*21-9]:=matrix[7];
  qr[23*21-8]:=matrix[2];
  qr[23*21-7]:=matrix[1];
  qr[23*22-10]:=matrix[6];
  qr[23*22-9]:=matrix[5];
  qr[23*22-8]:=matrix[4];
  qr[23*22-7]:=matrix[3];

  Bit(s[12],true,true);

  qr[23*17-10]:=matrix[8];
  qr[23*17-9]:=matrix[7];
  qr[23*18-10]:=matrix[6];
  qr[23*18-9]:=matrix[5];
  qr[23*19-10]:=matrix[4];
  qr[23*19-9]:=matrix[3];
  qr[23*20-10]:=matrix[2];
  qr[23*20-9]:=matrix[1];

  Bit(s[13],true,true);

  qr[23*13-10]:=matrix[8];
  qr[23*13-9]:=matrix[7];
  qr[23*14-10]:=matrix[6];
  qr[23*14-9]:=matrix[5];
  qr[23*15-10]:=matrix[4];
  qr[23*15-9]:=matrix[3];
  qr[23*16-10]:=matrix[2];
  qr[23*16-9]:=matrix[1];

  Bit(s[14],true,true);

  qr[23*9-10]:=matrix[8];
  qr[23*9-9]:=matrix[7];
  qr[23*10-10]:=matrix[6];
  qr[23*10-9]:=matrix[5];
  qr[23*11-10]:=matrix[4];
  qr[23*11-9]:=matrix[3];
  qr[23*12-10]:=matrix[2];
  qr[23*12-9]:=matrix[1];

  Bit(Chr(ecc[6]),true,false);

  qr[23*11-12]:=matrix[2];
  qr[23*11-11]:=matrix[1];
  qr[23*12-12]:=matrix[4];
  qr[23*12-11]:=matrix[3];
  qr[23*13-12]:=matrix[6];
  qr[23*13-11]:=matrix[5];
  qr[23*14-12]:=matrix[8];
  qr[23*14-11]:=matrix[7];

  Bit(Chr(ecc[5]),true,false);

  qr[23*15-12]:=matrix[2];
  qr[23*15-11]:=matrix[1];
  qr[23*16-12]:=matrix[4];
  qr[23*16-11]:=matrix[3];
  qr[23*17-12]:=matrix[6];
  qr[23*17-11]:=matrix[5];
  qr[23*18-12]:=matrix[8];
  qr[23*18-11]:=matrix[7];

  Bit(Chr(ecc[4]),true,false);

  qr[23*19-12]:=matrix[2];
  qr[23*19-11]:=matrix[1];
  qr[23*20-12]:=matrix[4];
  qr[23*20-11]:=matrix[3];
  qr[23*21-12]:=matrix[6];
  qr[23*21-11]:=matrix[5];
  qr[23*22-12]:=matrix[8];
  qr[23*22-11]:=matrix[7];

  Bit(Chr(ecc[3]),true,true);

  qr[23*11-14]:=matrix[8];
  qr[23*11-13]:=matrix[7];
  qr[23*12-14]:=matrix[6];
  qr[23*12-13]:=matrix[5];
  qr[23*13-14]:=matrix[4];
  qr[23*13-13]:=matrix[3];
  qr[23*14-14]:=matrix[2];
  qr[23*14-13]:=matrix[1];

  Bit(Chr(ecc[2]),true,false);

  qr[23*11-17]:=matrix[2];
  qr[23*11-16]:=matrix[1];
  qr[23*12-17]:=matrix[4];
  qr[23*12-16]:=matrix[3];
  qr[23*13-17]:=matrix[6];
  qr[23*13-16]:=matrix[5];
  qr[23*14-17]:=matrix[8];
  qr[23*14-16]:=matrix[7];

  Bit(Chr(ecc[1]),true,true);

  qr[23*11-19]:=matrix[8];
  qr[23*11-18]:=matrix[7];
  qr[23*12-19]:=matrix[6];
  qr[23*12-18]:=matrix[5];
  qr[23*13-19]:=matrix[4];
  qr[23*13-18]:=matrix[3];
  qr[23*14-19]:=matrix[2];
  qr[23*14-18]:=matrix[1];

  Bit(Chr(ecc[0]),true,false);

  qr[23*11-21]:=matrix[2];
  qr[23*11-20]:=matrix[1];
  qr[23*12-21]:=matrix[4];
  qr[23*12-20]:=matrix[3];
  qr[23*13-21]:=matrix[6];
  qr[23*13-20]:=matrix[5];
  qr[23*14-21]:=matrix[8];
  qr[23*14-20]:=matrix[7];


  CursorOff;

  for i:=1 to 23*23 do
  begin

    if qr[i]=0 then
      TextBackground(15)
    else
      TextBackground(0);

    Write(' ');

    if (i mod 23)=0 then
    begin
      TextBackground(0);
      WriteLn;
    end;
  end;

  ReadKey;

end.
