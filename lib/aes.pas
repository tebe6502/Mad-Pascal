unit aes;
(*
@type: unit
@author: Stijn Sanders, Tomasz 'Tebe' Biela
@name: AES encryption unit

@version: 1.3

@description:

  aes
  by Stijn Sanders (https://github.com/stijnsanders)
  http://yoy.be/md5
  2016-2021
  v1.0.2

  based on http://csrc.nist.gov/publications/fips/fips197/fips-197.pdf

  License: no license, free for any use
*)

interface

type
  AESBlock=array[0..3] of cardinal;
  AES128Key=array[0..3] of cardinal;
  AES192Key=array[0..5] of cardinal;
  AES256Key=array[0..7] of cardinal;

function AES128Cipher(InBlock:AESBlock;Key:AES128Key):AESBlock;
function AES128Decipher(InBlock:AESBlock;Key:AES128Key):AESBlock;
function AES192Cipher(InBlock:AESBlock;Key:AES192Key):AESBlock;
function AES192Decipher(InBlock:AESBlock;Key:AES192Key):AESBlock;
function AES256Cipher(InBlock:AESBlock;Key:AES256Key):AESBlock;
function AES256Decipher(InBlock:AESBlock;Key:AES256Key):AESBlock;


implementation


const
  rcon:array[0..31] of byte=(
    $8d,$01,$02,$04,$08,$10,$20,$40,$80,$1b,$36,$6c,$d8,$ab,$4d,$9a,
    $2f,$5e,$bc,$63,$c6,$97,$35,$6a,$d4,$b3,$7d,$fa,$ef,$c5,$91,$39);
  sbox:array[0..255] of byte=(
    $63,$7c,$77,$7b,$f2,$6b,$6f,$c5,$30,$01,$67,$2b,$fe,$d7,$ab,$76,
    $ca,$82,$c9,$7d,$fa,$59,$47,$f0,$ad,$d4,$a2,$af,$9c,$a4,$72,$c0,
    $b7,$fd,$93,$26,$36,$3f,$f7,$cc,$34,$a5,$e5,$f1,$71,$d8,$31,$15,
    $04,$c7,$23,$c3,$18,$96,$05,$9a,$07,$12,$80,$e2,$eb,$27,$b2,$75,
    $09,$83,$2c,$1a,$1b,$6e,$5a,$a0,$52,$3b,$d6,$b3,$29,$e3,$2f,$84,
    $53,$d1,$00,$ed,$20,$fc,$b1,$5b,$6a,$cb,$be,$39,$4a,$4c,$58,$cf,
    $d0,$ef,$aa,$fb,$43,$4d,$33,$85,$45,$f9,$02,$7f,$50,$3c,$9f,$a8,
    $51,$a3,$40,$8f,$92,$9d,$38,$f5,$bc,$b6,$da,$21,$10,$ff,$f3,$d2,
    $cd,$0c,$13,$ec,$5f,$97,$44,$17,$c4,$a7,$7e,$3d,$64,$5d,$19,$73,
    $60,$81,$4f,$dc,$22,$2a,$90,$88,$46,$ee,$b8,$14,$de,$5e,$0b,$db,
    $e0,$32,$3a,$0a,$49,$06,$24,$5c,$c2,$d3,$ac,$62,$91,$95,$e4,$79,
    $e7,$c8,$37,$6d,$8d,$d5,$4e,$a9,$6c,$56,$f4,$ea,$65,$7a,$ae,$08,
    $ba,$78,$25,$2e,$1c,$a6,$b4,$c6,$e8,$dd,$74,$1f,$4b,$bd,$8b,$8a,
    $70,$3e,$b5,$66,$48,$03,$f6,$0e,$61,$35,$57,$b9,$86,$c1,$1d,$9e,
    $e1,$f8,$98,$11,$69,$d9,$8e,$94,$9b,$1e,$87,$e9,$ce,$55,$28,$df,
    $8c,$a1,$89,$0d,$bf,$e6,$42,$68,$41,$99,$2d,$0f,$b0,$54,$bb,$16);
  ibox:array[0..255] of byte=(
    $52,$09,$6a,$d5,$30,$36,$a5,$38,$bf,$40,$a3,$9e,$81,$f3,$d7,$fb,
    $7c,$e3,$39,$82,$9b,$2f,$ff,$87,$34,$8e,$43,$44,$c4,$de,$e9,$cb,
    $54,$7b,$94,$32,$a6,$c2,$23,$3d,$ee,$4c,$95,$0b,$42,$fa,$c3,$4e,
    $08,$2e,$a1,$66,$28,$d9,$24,$b2,$76,$5b,$a2,$49,$6d,$8b,$d1,$25,
    $72,$f8,$f6,$64,$86,$68,$98,$16,$d4,$a4,$5c,$cc,$5d,$65,$b6,$92,
    $6c,$70,$48,$50,$fd,$ed,$b9,$da,$5e,$15,$46,$57,$a7,$8d,$9d,$84,
    $90,$d8,$ab,$00,$8c,$bc,$d3,$0a,$f7,$e4,$58,$05,$b8,$b3,$45,$06,
    $d0,$2c,$1e,$8f,$ca,$3f,$0f,$02,$c1,$af,$bd,$03,$01,$13,$8a,$6b,
    $3a,$91,$11,$41,$4f,$67,$dc,$ea,$97,$f2,$cf,$ce,$f0,$b4,$e6,$73,
    $96,$ac,$74,$22,$e7,$ad,$35,$85,$e2,$f9,$37,$e8,$1c,$75,$df,$6e,
    $47,$f1,$1a,$71,$1d,$29,$c5,$89,$6f,$b7,$62,$0e,$aa,$18,$be,$1b,
    $fc,$56,$3e,$4b,$c6,$d2,$79,$20,$9a,$db,$c0,$fe,$78,$cd,$5a,$f4,
    $1f,$dd,$a8,$33,$88,$07,$c7,$31,$b1,$12,$10,$59,$27,$80,$ec,$5f,
    $60,$51,$7f,$a9,$19,$b5,$4a,$0d,$2d,$e5,$7a,$9f,$93,$c9,$9c,$ef,
    $a0,$e0,$3b,$4d,$ae,$2a,$f5,$b0,$c8,$eb,$bb,$3c,$83,$53,$99,$61,
    $17,$2b,$04,$7e,$ba,$77,$d6,$26,$e1,$69,$14,$63,$55,$21,$0c,$7d);

type
  AESColumn=cardinal;
  FourBytes=array[0..3] of byte;


function GMul4(a:AESColumn; b:byte): AESColumn;
var
  c:AESColumn absolute Result;
  d: AESColumn register;
  i:byte;
begin
//  c:=a * (b and 1);

  if (b and 1) = 0 then
    c:=0
  else
    c:=a;

  for i:=6 downto 0 do //while b<>0 do
   begin
//    a:=((a and $7F7F7F7F) shl 1) xor ($1b * ((a and $80808080) shr 7));

    d := ((a and $80808080) shr 8) shl 1;	// 'shr 8) shl 1' is faster then 'shr 7'
    if a and $80 <> 0 then d:=d or 1;

    a:=((a and $7F7F7F7F) shl 1) xor ($1b * d);

    b:=b shr 1;

    if (b and 1) <> 0 then c:=c xor a;
//    c:=c xor (a * (b and 1));
   end;

end;

function AES128Cipher(InBlock:AESBlock;Key:AES128Key):AESBlock;
var
  r,i:byte;
  c,d: cardinal;
  State:AESBlock absolute Result;
  RoundKey:AES128Key absolute Key;
  MixBase:AESBlock;
begin
  State:=InBlock;
  //RoundKey:=Key;//see absolute

  //AddRoundKey
  for i:=3 downto 0 do
    State[i]:=State[i] xor RoundKey[i];

  for r:=1 to 10 do
   begin
    //SubBytes+ShiftRows
    for i:=3 downto 0 do
     begin
      FourBytes(MixBase[i])[0]:=sbox[FourBytes(State[ i and $ff ])[0]];
      FourBytes(MixBase[i])[1]:=sbox[FourBytes(State[(i+1) and 3])[1]];
      FourBytes(MixBase[i])[2]:=sbox[FourBytes(State[(i+2) and 3])[2]];
      FourBytes(MixBase[i])[3]:=sbox[FourBytes(State[(i+3) and 3])[3]];
     end;

    //MixColumns
    if r=10 then
      State:=MixBase
    else
      for i:=3 downto 0 do begin

        c:=(MixBase[i] shr 8) or (MixBase[i] shl 24);
	d:=((MixBase[i] shr 16) or (MixBase[i] shl 16)) xor ((MixBase[i] shr 24) or (MixBase[i] shl 8));

        State[i]:= GMul4(MixBase[i],2) xor GMul4(c,3) xor d;
      end;

    //ExpandKey
    FourBytes(RoundKey[0])[0]:=FourBytes(RoundKey[0])[0] xor sbox[FourBytes(RoundKey[3])[1]] xor rcon[r];
    FourBytes(RoundKey[0])[1]:=FourBytes(RoundKey[0])[1] xor sbox[FourBytes(RoundKey[3])[2]];
    FourBytes(RoundKey[0])[2]:=FourBytes(RoundKey[0])[2] xor sbox[FourBytes(RoundKey[3])[3]];
    FourBytes(RoundKey[0])[3]:=FourBytes(RoundKey[0])[3] xor sbox[FourBytes(RoundKey[3])[0]];

    RoundKey[1]:=RoundKey[1] xor RoundKey[0];
    RoundKey[2]:=RoundKey[2] xor RoundKey[1];
    RoundKey[3]:=RoundKey[3] xor RoundKey[2];

    //AddRoundKey
    for i:=3 downto 0 do
      State[i]:=State[i] xor RoundKey[i];

   end;

end;

function AES128Decipher(InBlock:AESBlock;Key:AES128Key):AESBlock;
var
  r,i:byte;
  c,d,e: cardinal;
  State:AESBlock absolute Result;
  RoundKey:AESBlock absolute Key;
  RoundKeys:array[0..10] of AESBlock;
  MixBase:AESBlock;
begin
  State:=InBlock;
  //RoundKey:=Key;//see absolute

  //ExpandKey (up front, need them in reverse order)
  for r:=1 to 10 do
   begin
    RoundKeys[r]:=RoundKey;

    FourBytes(RoundKey[0])[0]:=FourBytes(RoundKey[0])[0] xor sbox[FourBytes(RoundKey[3])[1]] xor rcon[r];
    FourBytes(RoundKey[0])[1]:=FourBytes(RoundKey[0])[1] xor sbox[FourBytes(RoundKey[3])[2]];
    FourBytes(RoundKey[0])[2]:=FourBytes(RoundKey[0])[2] xor sbox[FourBytes(RoundKey[3])[3]];
    FourBytes(RoundKey[0])[3]:=FourBytes(RoundKey[0])[3] xor sbox[FourBytes(RoundKey[3])[0]];

    RoundKey[1]:=RoundKey[1] xor RoundKey[0];
    RoundKey[2]:=RoundKey[2] xor RoundKey[1];
    RoundKey[3]:=RoundKey[3] xor RoundKey[2];
   end;

  //AddRoundKey
  for i:=3 downto 0 do
    State[i]:=State[i] xor RoundKey[i];

  for r:=10 downto 1 do
   begin
    //InvShiftRows+InvSubBytes
    for i:=3 downto 0 do
     begin
      FourBytes(MixBase[i])[0]:=ibox[FourBytes(State[ i         ])[0]];
      FourBytes(MixBase[i])[1]:=ibox[FourBytes(State[(i+3) and 3])[1]];
      FourBytes(MixBase[i])[2]:=ibox[FourBytes(State[(i+2) and 3])[2]];
      FourBytes(MixBase[i])[3]:=ibox[FourBytes(State[(i+1) and 3])[3]];
     end;

    //AddRoundKey
    RoundKey:=RoundKeys[r];

    for i:=3 downto 0 do
      MixBase[i]:=MixBase[i] xor RoundKey[i];

    //InvMixColumns
    if r=1 then
      State:=MixBase
    else
      for i:=3 downto 0 do begin

        c:=(MixBase[i] shr 8) or (MixBase[i] shl 24);
	d:=(MixBase[i] shr 16) or (MixBase[i] shl 16);
	e:=(MixBase[i] shr 24) or (MixBase[i] shl 8);

        State[i] := GMul4(MixBase[i],$e) xor GMul4(c,$b) xor GMul4(d,$d) xor GMul4(e,$9);
      end;
   end;
end;


function AES192Cipher(InBlock:AESBlock;Key:AES192Key):AESBlock;
var
  r,i,ri,rk:byte;
  c,d: cardinal;
  State:AESBlock absolute Result;
  RoundKey:AES192Key absolute Key;
  MixBase:AESBlock;
begin
  State:=InBlock;
  //RoundKey:=Key;//see absolute

  //AddRoundKey
  for i:=3 downto 0 do
    State[i]:=State[i] xor RoundKey[i];

  ri:=4;
  rk:=0;
  for r:=1 to 12 do
   begin

    //SubBytes+ShiftRows
    for i:=3 downto 0 do
     begin
      FourBytes(MixBase[i])[0]:=sbox[FourBytes(State[ i         ])[0]];
      FourBytes(MixBase[i])[1]:=sbox[FourBytes(State[(i+1) and 3])[1]];
      FourBytes(MixBase[i])[2]:=sbox[FourBytes(State[(i+2) and 3])[2]];
      FourBytes(MixBase[i])[3]:=sbox[FourBytes(State[(i+3) and 3])[3]];
     end;

    //MixColumns
    if r=12 then
      State:=MixBase
    else
      for i:=3 downto 0 do begin

	c := (MixBase[i] shr 8) or (MixBase[i] shl 24);
	d := ((MixBase[i] shr 16) or (MixBase[i] shl 16)) xor ((MixBase[i] shr 24) or (MixBase[i] shl 8));

        State[i]:= GMul4(MixBase[i],2) xor GMul4(c,3) xor d;
      end;

    //ExpandKey+AddRoundKey
    for i:=0 to 3 do
     begin
      if ri=6 then
       begin
        ri:=0;
        inc(rk);
        FourBytes(RoundKey[0])[0]:=FourBytes(RoundKey[0])[0] xor sbox[FourBytes(RoundKey[5])[1]] xor rcon[rk];
        FourBytes(RoundKey[0])[1]:=FourBytes(RoundKey[0])[1] xor sbox[FourBytes(RoundKey[5])[2]];
        FourBytes(RoundKey[0])[2]:=FourBytes(RoundKey[0])[2] xor sbox[FourBytes(RoundKey[5])[3]];
        FourBytes(RoundKey[0])[3]:=FourBytes(RoundKey[0])[3] xor sbox[FourBytes(RoundKey[5])[0]];
       end
      else
        if not((r=1) and (ri>3)) then
          RoundKey[ri]:=RoundKey[ri] xor RoundKey[ri-1];

      State[i]:=State[i] xor RoundKey[ri];
      inc(ri);
     end;
   end;
end;

function AES192Decipher(InBlock:AESBlock;Key:AES192Key):AESBlock;
var
  r,i,ri,rk:byte;
  c,d,e: cardinal;
  State:AESBlock absolute Result;
  RoundKey:AES192Key absolute Key;
  RoundKeys:array[0..8] of AES192Key;
  MixBase:AESBlock;
begin
  State:=InBlock;
  //RoundKey:=Key;//see absolute

  //ExpandKey (up front, need them in reverse order)
  for rk:=1 to 8 do
   begin
    RoundKeys[rk]:=RoundKey;

    FourBytes(RoundKey[0])[0]:=FourBytes(RoundKey[0])[0] xor sbox[FourBytes(RoundKey[5])[1]] xor rcon[rk];
    FourBytes(RoundKey[0])[1]:=FourBytes(RoundKey[0])[1] xor sbox[FourBytes(RoundKey[5])[2]];
    FourBytes(RoundKey[0])[2]:=FourBytes(RoundKey[0])[2] xor sbox[FourBytes(RoundKey[5])[3]];
    FourBytes(RoundKey[0])[3]:=FourBytes(RoundKey[0])[3] xor sbox[FourBytes(RoundKey[5])[0]];

    for i:=1 to 5 do
      RoundKey[i]:=RoundKey[i] xor RoundKey[i-1];
   end;

  //AddRoundKey
  for i:=3 downto 0 do
    State[i]:=State[i] xor RoundKey[i];

  ri:=0;
  rk:=8;
  for r:=12 downto 1 do
   begin

    //InvShiftRows+InvSubBytes
    for i:=3 downto 0 do
     begin
      FourBytes(MixBase[i])[0]:=ibox[FourBytes(State[ i         ])[0]];
      FourBytes(MixBase[i])[1]:=ibox[FourBytes(State[(i+3) and 3])[1]];
      FourBytes(MixBase[i])[2]:=ibox[FourBytes(State[(i+2) and 3])[2]];
      FourBytes(MixBase[i])[3]:=ibox[FourBytes(State[(i+1) and 3])[3]];
     end;

    //AddRoundKey
    for i:=0 to 3 do
     begin
      if ri=0 then
       begin
        RoundKey:=RoundKeys[rk];

	dec(rk);
        ri:=5;
       end
      else
        dec(ri);

      MixBase[3-i]:=MixBase[3-i] xor RoundKey[ri];
     end;

    //InvMixColumns
    if r=1 then
      State:=MixBase
    else
      for i:=3 downto 0 do begin

        c := (MixBase[i] shr 8) or (MixBase[i] shl 24);
	d := (MixBase[i] shr 16) or (MixBase[i] shl 16);
	e := (MixBase[i] shr 24) or (MixBase[i] shl 8);

        State[i] := GMul4(MixBase[i],$e) xor GMul4(c,$b) xor GMul4(d,$d) xor GMul4(e,$9);
      end;
   end;
end;


function AES256Cipher(InBlock:AESBlock;Key:AES256Key):AESBlock;
var
  r,i:byte;
  c,d: cardinal;
  State:AESBlock absolute Result;
  RoundKey:AES256Key absolute Key;
  MixBase:AESBlock;
begin
  State:=InBlock;
  //RoundKey:=Key;//see absolute

  //AddRoundKey
  for i:=3 downto 0 do
    State[i]:=State[i] xor RoundKey[i];

  for r:=1 to 14 do
   begin

    //SubBytes+ShiftRows
    for i:=3 downto 0 do
     begin
      FourBytes(MixBase[i])[0]:=sbox[FourBytes(State[ i         ])[0]];
      FourBytes(MixBase[i])[1]:=sbox[FourBytes(State[(i+1) and 3])[1]];
      FourBytes(MixBase[i])[2]:=sbox[FourBytes(State[(i+2) and 3])[2]];
      FourBytes(MixBase[i])[3]:=sbox[FourBytes(State[(i+3) and 3])[3]];
     end;

    //MixColumns
    if r=14 then
      State:=MixBase
    else
      for i:=3 downto 0 do begin

	c := (MixBase[i] shr 8) or (MixBase[i] shl 24);
	d := ((MixBase[i] shr 16) or (MixBase[i] shl 16)) xor ((MixBase[i] shr 24) or (MixBase[i] shl 8));

        State[i] := GMul4(MixBase[i],2) xor GMul4(c,3) xor d;
      end;

    if (r and 1)=0 then
     begin
      //ExpandKey
      FourBytes(RoundKey[0])[0]:=FourBytes(RoundKey[0])[0] xor sbox[FourBytes(RoundKey[7])[1]] xor rcon[r div 2];
      FourBytes(RoundKey[0])[1]:=FourBytes(RoundKey[0])[1] xor sbox[FourBytes(RoundKey[7])[2]];
      FourBytes(RoundKey[0])[2]:=FourBytes(RoundKey[0])[2] xor sbox[FourBytes(RoundKey[7])[3]];
      FourBytes(RoundKey[0])[3]:=FourBytes(RoundKey[0])[3] xor sbox[FourBytes(RoundKey[7])[0]];
      RoundKey[1]:=RoundKey[1] xor RoundKey[0];
      RoundKey[2]:=RoundKey[2] xor RoundKey[1];
      RoundKey[3]:=RoundKey[3] xor RoundKey[2];

      for i:=3 downto 0 do
        FourBytes(RoundKey[4])[i]:=FourBytes(RoundKey[4])[i] xor sbox[FourBytes(RoundKey[3])[i]];

      RoundKey[5]:=RoundKey[5] xor RoundKey[4];
      RoundKey[6]:=RoundKey[6] xor RoundKey[5];
      RoundKey[7]:=RoundKey[7] xor RoundKey[6];
      //AddRoundKey
      for i:=3 downto 0 do
        State[i]:=State[i] xor RoundKey[i];
     end
    else
      //AddRoundKey
      for i:=3 downto 0 do
        State[i]:=State[i] xor RoundKey[4+i];
   end;
end;


function AES256Decipher(InBlock:AESBlock;Key:AES256Key):AESBlock;
var
  r,i,ri,rk:byte;
  c,d,e: cardinal;
  State:AESBlock absolute Result;
  RoundKey:AES256Key absolute Key;
  RoundKeys:array[0..7] of AES256Key;
  MixBase:AESBlock;
begin
  State:=InBlock;
  //RoundKey:=Key;//see absolute

  //ExpandKey (up front, need them in reverse order)
  for r:=1 to 7 do
   begin
    RoundKeys[r]:=RoundKey;

    FourBytes(RoundKey[0])[0]:=FourBytes(RoundKey[0])[0] xor sbox[FourBytes(RoundKey[7])[1]] xor rcon[r];
    FourBytes(RoundKey[0])[1]:=FourBytes(RoundKey[0])[1] xor sbox[FourBytes(RoundKey[7])[2]];
    FourBytes(RoundKey[0])[2]:=FourBytes(RoundKey[0])[2] xor sbox[FourBytes(RoundKey[7])[3]];
    FourBytes(RoundKey[0])[3]:=FourBytes(RoundKey[0])[3] xor sbox[FourBytes(RoundKey[7])[0]];

    RoundKey[1]:=RoundKey[1] xor RoundKey[0];
    RoundKey[2]:=RoundKey[2] xor RoundKey[1];
    RoundKey[3]:=RoundKey[3] xor RoundKey[2];

    for i:=3 downto 0 do
      FourBytes(RoundKey[4])[i]:=FourBytes(RoundKey[4])[i] xor sbox[FourBytes(RoundKey[3])[i]];

    RoundKey[5]:=RoundKey[5] xor RoundKey[4];
    RoundKey[6]:=RoundKey[6] xor RoundKey[5];
    RoundKey[7]:=RoundKey[7] xor RoundKey[6];
   end;

  //AddRoundKey
  for i:=3 downto 0 do
    State[i] := State[i] xor RoundKey[i];

  ri:=0;
  rk:=7;
  for r:=14 downto 1 do
   begin

    //InvShiftRows+InvSubBytes
    for i:=3 downto 0 do
     begin
      FourBytes(MixBase[i])[0]:=ibox[FourBytes(State[ i         ])[0]];
      FourBytes(MixBase[i])[1]:=ibox[FourBytes(State[(i+3) and 3])[1]];
      FourBytes(MixBase[i])[2]:=ibox[FourBytes(State[(i+2) and 3])[2]];
      FourBytes(MixBase[i])[3]:=ibox[FourBytes(State[(i+1) and 3])[3]];
     end;

    //AddRoundKey
    for i:=0 to 3 do
     begin
      if ri=0 then
       begin
        RoundKey:=RoundKeys[rk];

        dec(rk);
        ri:=7;
       end
      else
        dec(ri);

      MixBase[3-i]:=MixBase[3-i] xor RoundKey[ri];
     end;

    //InvMixColumns
    if r=1 then
      State:=MixBase
    else
      for i:=3 downto 0 do begin

	c := (MixBase[i] shr 8) or (MixBase[i] shl 24);
	d := (MixBase[i] shr 16) or (MixBase[i] shl 16);
	e := (MixBase[i] shr 24) or (MixBase[i] shl 8);

        State[i] := GMul4(MixBase[i],$e) xor GMul4(c,$b) xor GMul4(d,$d) xor GMul4(e,$9);
      end;
   end;
end;

end.
