unit f16;
(*
 @type: unit
 @author: Tomasz Biela (Tebe), Artyom Beilis, Marek Mauder
 @name: Half Float IEEE Library
 @version: 1.0

 @description:

 <http://www.fox-toolkit.org/ftp/fasthalffloatconversion.pdf>

 <https://github.com/artyom-beilis/float16>

 <https://galfar.vevb.net/wp/2011/16bit-half-float-in-pascaldelphi/>

 <http://weitz.de/ieee/>
*)


{

 f16_add
 f16_sub
 f16_mul
 f16_div
 f16_from_int
 f16_int
 f16_neg
 f16_gt
 f16_gte
 f16_lt
 f16_lte
 f16_eq
 f16_neq
 f32Tof16
 FloatToHalf
 HalfToFloat

}

interface

	function f16_add(a, b: word): word;
	function f16_sub(a, b: word): word;
	function f16_mul(a, b: word): word;
	function f16_div(a,b: word): word;

	function f16_from_int(sv: integer): float16;
	function f16_int(a: word): integer;

	function f32Tof16(f: single): word;

	function f16_gte(a,b: word): Boolean;
	function f16_gt(a, b: word): Boolean;
	function f16_eq(a, b: word): Boolean;
	function f16_lte(a, b: word): Boolean;
	function f16_lt(a, b: word): Boolean;
	function f16_neq(a, b: word): Boolean;


	function FloatToHalf(f: Single): word;
	function HalfToFloat(Half: float16): Single;


implementation

type
	PFloat16 = ^float16;


function f16_sub(a, b: word): word;
(*
@description:
*)
var sign, x, res, ax, bx, exp_diff, exp_part, r, am, new_m: word;
    shift: byte;
begin

//    if(((a ^ b) & 0x8000) != 0)
//        return f16_add(a,b ^ 0x8000);

 if (a xor b) and $8000 <> 0 then begin Result := f16_add(a, b xor $8000); exit end;

//    unsigned short sign = a & 0x8000;

 sign := a and $8000;

//    a = a << 1;
//    b = b << 1;

 a := a shl 1;
 b := b shl 1;

//    if(a < b) {
//        unsigned short x=a;
//        a=b;
//        b=x;
//        sign ^= 0x8000;
//    }

 if a < b then begin
  x:=a;
  a:=b;
  b:=x;
  sign := sign xor $8000;
 end;

//    unsigned short ax = a & 0xF800;
//    unsigned short bx = b & 0xF800;

  ax := a and $f800;
  bx := b and $f800;

//    if(a >=0xf800 || b>=0xf800) {
//        if(a > 0xF800 || b > 0xF800 || a==b)
//            return 0x7FFF;
//        unsigned short res = sign | 0x7C00;
//        if(a == 0xf800)
//            return res;
//        else
//            return res ^ 0x8000;
//    }

 if (a >= $f800) or (b >= $f800) then begin

  if (a > $f800) or (b > $f800) or (a=b) then exit($7fff);

  res := sign or $7c00;

  if a = $f800 then
   exit(res)
  else
   exit(res xor $8000);

 end;

//    int exp_diff = ax - bx;
//    unsigned short exp_part  = ax;

 exp_diff := ax - bx;
 exp_part := ax;

//    if(exp_diff != 0) {
//        int shift = exp_diff >> 11;
//        if(bx != 0)
//            b = ((b & 2047) | 2048) >> shift;
//        else
//            b >>= (shift - 1);
//    }

 if exp_diff <> 0 then begin
  shift := exp_diff shr 11;

  if bx <> 0 then
   b := ((b and 2047) or 2048)
  else
   dec(shift);

  b:=b shr shift;

 end else begin

//    else {
//        if(bx == 0) {
//           unsigned short res = (a-b) >> 1;
//            if(res == 0)
//                return res;
//            return res | sign;
//        }
//        else {
//            b=(b & 2047) | 2048;
//        }

    if bx = 0 then begin
      res := (a-b) shr 1;

      if res = 0 then exit(res);

      exit(res or sign);

    end else
     b := (b and 2047) or 2048;

  end;

//    unsigned short r=a - b;

 r := a-b;

//   if((r & 0xF800) == exp_part) {
//        return (r>>1) | sign;
//    }

 if r and $f800 = exp_part then begin
  r:=r shr 1;
  Result:=r or sign;
  exit;
 end;

//    unsigned short am = (a & 2047) | 2048;
//    unsigned short new_m = am - b;

 am := (a and 2047) or 2048;
 new_m := am - b;

//    if(new_m == 0)
//        return 0;

 if new_m = 0 then exit(0);

//    while(exp_part !=0 && !(new_m & (2048))) {
//        exp_part-=0x800;
//        if(exp_part!=0)
//            new_m<<=1;
//    }

 while (exp_part <> 0) and (new_m and 2048 = 0) do begin
  exp_part := exp_part - $0800;

  if exp_part <> 0 then new_m := new_m shl 1;
 end;

//    return (((new_m & 2047) | exp_part) >> 1) | sign;

 new_m := new_m and 2047;
 new_m := new_m or exp_part;
 new_m := new_m shr 1;

 Result := new_m or sign;

// Result := (((new_m and 2047) or exp_part) shr 1) or sign;

end;


function f16_add(a,b: word): word;
(*
@description:
*)
var sign, x, ax, bx, exp_diff, exp_part, r, am, new_m: word;
    shift: byte;
begin

//    if (((a ^ b) & 0x8000) != 0)
//        return f16_sub(a,b ^ 0x8000);

 if (a xor b) and $8000 <> 0 then begin Result := f16_sub(a, b xor $8000); exit end;

//    short sign = a & 0x8000;
 sign := a and $8000;

//    a &= 0x7FFF;
 a := a and $7fff;

//    b &= 0x7FFF;
 b := b and $7fff;

//    if(a<b) {
//        short x=a;
//        a=b;
//        b=x;
//    }
 if a < b then begin
  x := a;
  a := b;
  b := x;
 end;

//    if(a >= 0x7C00 || b>=0x7C00) {
//        if(a>0x7C00 || b>0x7C00)
//            return 0x7FFF;
//        return 0x7C00 | sign;
//    }
 if (a >= $7c00) or (b >= $7c00) then begin

  if (a > $7c00) or (b > $7c00) then exit($7fff);

  exit(sign or $7c00);

 end;

//    short ax = (a & 0x7C00);
 ax := a and $7c00;

//    short bx = (b & 0x7C00);
 bx := b and $7c00;

//    short exp_diff = ax - bx;
 exp_diff := ax - bx;

//    short exp_part = ax;
 exp_part := ax;

//    if(exp_diff != 0) {
//        int shift = exp_diff >> 10;
//        if(bx != 0)
//            b = ((b & 1023) | 1024) >> shift;
//        else
//            b >>= (shift - 1);
//    }
//    else {
//        if(bx == 0) {
//            return (a + b) | sign;
//        }
//        else {
//            b=(b & 1023) | 1024;
//        }
//    }
 if exp_diff <> 0 then begin

  shift := exp_diff shr 10;

  if bx <> 0 then
    b := (b and 1023) or 1024
  else
    dec(shift);

  b := b shr shift;

 end else begin

  if bx = 0 then begin
    Result := (a + b) or sign;
    exit;
  end else
    b := (b and 1023) or 1024;

 end;

//    short r=a+b;
 r := a + b;

//    if ((r & 0x7C00) != exp_part) {
//        unsigned short am = (a & 1023) | 1024;
//        unsigned short new_m = (am + b) >> 1;
//        r =( exp_part + 0x400) | (1023 & new_m);
//    }
 if (r and $7c00) <> exp_part then begin
   am := (a and 1023) or 1024;
   new_m := (am + b) shr 1;
   inc(exp_part, $400);
   r := exp_part or (1023 and new_m);
 end;

//    if((unsigned short)r >= 0x7C00u) {
//        return sign | 0x7C00;
//    }
 if r >= $7c00 then exit(sign or $7c00);

//    return r | sign;
 Result := r or sign;

end;


function f16_mul(a, b: word): word;
(*
@description:
*)
var sign, m1, m2: word;
    ax, bx: byte;
    new_exp: shortint;
    v: cardinal;
begin

//    int sign = (a ^ b) & SIGN_MASK;
 sign := (a xor b) and $8000;

//    if(IS_INVALID(a) || IS_INVALID(b)) {
//        if(IS_NAN(a) || IS_NAN(b) || IS_ZERO(a) || IS_ZERO(b))
//            return NAN_VALUE;
//        return sign | 0x7C00;
//    }
 if (a and $7fff >= $7c00) or (b and $7fff >= $7c00) then begin
  if (a and $7fff > $7c00) or (b and $7fff > $7c00) then exit($7fff);

  exit(sign or $7c00);
 end;

//    if(IS_ZERO(a) || IS_ZERO(b))
//        return 0;
 if (a and $7fff = 0) or (b and $7fff = 0) then exit(0);

//    unsigned short m1 = MANTISSA(a);
//    unsigned short m2 = MANTISSA(b);
 if a and $7c00 = 0 then
  m1 := a and 1023
 else
  m1 := (a and 1023) or 1024;

 if b and $7c00 = 0 then
  m2 := b and 1023
 else
  m2 := (b and 1023) or 1024;

//    uint32_t v=m1;
 v := m1;

//    v*=m2;
 v := word(v) * m2;

//    int ax = EXPONENT(a);
 ax := (a and $7c00) shr 10;

//    int bx = EXPONENT(b);
 bx := (b and $7c00) shr 10;

//    ax += (ax==0);
 if ax = 0 then inc(ax);

//    bx += (bx==0);
 if bx = 0 then inc(bx);

//    int new_exp = ax + bx - 15;
 new_exp := ax + bx - 15;

//    if(v & ((uint32_t)1<<21)) {
//        v >>= 11;
//        new_exp++;
//    }
 if v and $00200000 <> 0 then begin
  v:=v shr 11;
  inc(new_exp);
 end else

//    else if(v & ((uint32_t)1<<20)) {
//        v >>= 10;
//    }
 if v and $00100000 <> 0 then
  v:=v shr 10
 else
  begin

//    e1se { // denormal
//        new_exp -= 10;
//        while(v >= 2048) {
//            v>>=1;
//            new_exp++;
//        }
//    }
   dec(new_exp, 10);

   while v >= 2048 do begin
    v:=v shr 1;
    inc(new_exp);
   end;

  end;

//    if(new_exp <= 0) {
//        v>>=(-new_exp + 1);
//        new_exp = 0;
//    }
 if new_exp <= 0 then begin
  v := v shr byte(-new_exp + 1);
  new_exp := 0;
 end else

//    else if(new_exp >= 31) {
//        return SIGNED_INF_VALUE(sign);
//    }
 if new_exp >= 31 then exit( (sign and $8000) or $7c00 );

//    return (sign) | (new_exp << 10) | (v & 1023);
 Result := byte(new_exp);
 Result := sign or (Result shl 10) or (v and 1023);

end;


function f16_div(a,b: word): word;
(*
@description:
*)
var sign, m1, m2, rem, v: word;
    ax, bx: byte;
    m1_shifted: cardinal;
    new_exp: shortint;
begin

//    short sign = (a ^ b) & SIGN_MASK;
 sign := (a xor b) and $8000;

//    if(IS_NAN(a) || IS_NAN(b) || (IS_INVALID(a) && IS_INVALID(b)) || (IS_ZERO(a) && IS_ZERO(b)))
//        return 0x7FFF;
 if (a and $7fff >= $7c00) or (b and $7fff >= $7c00) then //or ((a and $7c00 = $7c00) and (b and $7c00 = $7c00)) or ((a and $7fff = 0) and (b and $7fff = 0)) then
  exit($7fff);

//    if(IS_INVALID(a) || IS_ZERO(b))
//        return sign | 0x7C00;
 if (a and $7c00 = $7c00) or (b and $7fff = 0) then
  exit(sign or $7c00);

//    if(IS_INVALID(b))
//        return 0;
 if b and $7c00 = $7c00 then
  exit(0);

//    if(IS_ZERO(a))
//        return 0;
 if a and $7fff = 0 then
  exit(0);

//    unsigned short m1 = MANTISSA(a);
//    unsigned short m2 = MANTISSA(b);
 if a and $7c00 = 0 then
  m1 := a and 1023
 else
  m1 := (a and 1023) or 1024;

 if b and $7c00 = 0 then
  m2 := b and 1023
 else
  m2 := (b and 1023) or 1024;

//    uint32_t m1_shifted = m1;
 m1_shifted := m1;

//    m1_shifted <<= 10;
 m1_shifted := m1_shifted shl 10;

//    uint32_t v= m1_shifted / m2;
 v := m1_shifted div m2;

//    unsigned short rem = m1_shifted % m2;
 {$ifdef ATARI}
 asm
  mwa :TMP rem
 end;
 {$else}
  rem := m1_shifted mod m2;
 {$endif}

//    int ax = EXPONENT(a);
 ax := (a and $7c00) shr 10;

//    int bx = EXPONENT(b);
 bx := (b and $7c00) shr 10;

//    ax += (ax==0);
 if ax = 0 then inc(ax);

//    bx += (bx==0);
 if bx = 0 then inc(bx);

//    int new_exp = ax - bx + 15 ;
 new_exp := ax - bx + 15;

//    if(v == 0 && rem==0)
//        return 0;
 if (v = 0) and (rem = 0) then
  exit(0);

//    while(v < 1024 && new_exp > 0) {
//        v<<=1;
//        rem<<=1;
//        if(rem >= m2) {
//            v++;
//            rem -= m2;
//        }
//        new_exp--;
//    }
 while (v < 1024) and (new_exp > 0) do begin

  v := v shl 1;
  rem := rem shl 1;

  if rem >= m2 then begin
   inc(v);
   rem := rem - m2;
  end;

  dec(new_exp);

 end;

//    while(v >= 2048) {
//        v>>=1;
//        new_exp++;
//    }
 while v >= 2048 do begin
  v := v shr 1;
  inc(new_exp);
 end;

//    if(new_exp <= 0) {
//        v>>=(-new_exp + 1);
//        new_exp = 0;
//    }
 if new_exp <= 0 then begin
  v := v shr byte(-new_exp + 1);
  new_exp := 0;
 end else

//    else if(new_exp >= 31) {
//        return SIGNED_INF_VALUE(sign);
//    }
 if new_exp >= 31 then
  exit(sign or $7c00);

//    return sign | (v & 1023) | (new_exp << 10);
 Result := byte(new_exp) shl 10;
 Result := sign or Result or (v and 1023);

end;


function f16_neg(v: word): word;
(*
@description:
*)
begin
 Result := $8000 xor v;
end;


function f16_from_int(sv: integer): float16;
(*
@description:
*)
var v: cardinal;
    sig: word;
    e: integer;
begin

 sig:=0;

 if sv < 0 then begin
  v:=-sv;
  sig:=$8000;
 end else
  v:=sv;

 if v=0 then begin Result:=0; exit end;

 e:=25;

 while v >= 2048 do begin
  v:=v shr 1;
  inc(e);
 end;

 while v < 1024 do begin
  v:=v shl 1;
  dec(e);
 end;

// #define SIGNED_INF_VALUE(x)  ((x & SIGN_MASK) | 0x7C00)

 if e >= 31 then begin
  sig := (sig and $8000) or $7C00;

  Result:=PFloat16(@sig)^;

  exit;
 end;

 sig := sig or (e shl 10) or (v and 1023);

 Result:=PFloat16(@sig)^;

end;


function f16_int(a: word): integer;
(*
@description:
*)
var value: word;
    shift: smallint;
begin

//#define MANTISSA(x) (((x) & 1023) | (((x) & 0x7C00) == 0 ? 0 : 1024))

 if a and $7c00 = 0 then
  value := a and 1023
 else
  value := (a and 1023) or 1024;

//#define EXPONENT(x) (((x) & 0x7C00) >> 10)

 shift := ((a and $7c00) shr 10) - 25;

 if shift > 0 then
  value := value shl shift
 else
 if shift < 0 then
  value := value shr (-shift);

 if (a and $8000) <> 0 then begin Result := -integer(value); exit end;

 Result := value;

end;


function f32Tof16(f: single): word;
(*
@description:
 https://stackoverflow.com/questions/3026441/float32-to-float16/3026505
*)
var
	fltInt32: ^cardinal;
	fltInt16, tmp: word;
	hlp: cardinal;
	sign: byte;

begin
	fltInt32 := @f;
	fltInt16 := byte((fltInt32^ shr 31) shl 5);

	tmp := (fltInt32^ shr 23) and $ff;

	hlp:=$70-tmp;

	sign:=(hlp shr 24) and $80;

	hlp := hlp shr 1;
	hlp := hlp or (sign shl 24);

	hlp := (hlp shr 1);
	hlp := hlp or (sign shl 24);

	hlp := (hlp shr 1);
	hlp := hlp or (sign shl 24);

	hlp := (hlp shr 1);
	hlp := hlp or (sign shl 24);

	hlp:=hlp shr 27;

	tmp := (tmp - $70) and hlp;

	fltInt16 := (fltInt16 or tmp) shl 10;

	tmp:=fltInt32^ shr 13;

	result := fltInt16 or (tmp and $3ff);
end;


function FloatToHalf(f: Single): word;
(*
@description:
*)
var
  Src: LongWord;
  Mantissa: LongInt;
  Exp: smallint;
  Sign: word;
begin

  Src := PLongWord(@f)^;
  // Extract sign, exponent, and mantissa from Single number
  Sign := (Src and $80000000) shr 16;
  Exp := LongInt((Src and $7F800000) shr 23) - 127 + 15;
  Mantissa := Src and $007FFFFF;

  if (Exp > 0) and (Exp < 30) then
  begin
    // Simple case - round the significand and combine it with the sign and exponent
    Result := byte(Exp);
    Result := Sign or (Result shl 10) or ((Mantissa + $00001000) shr 13);
  end
  else if Src = 0 then
  begin
    // Input float is zero - return zero
    Result := 0;
  end
  else
  begin
    // Difficult case - lengthy conversion
    if Exp <= 0 then
    begin
      if Exp < -10 then
      begin
        // Input float's value is less than HalfMin, return zero
         Result := 0;
      end
      else
      begin
        // Float is a normalized Single whose magnitude is less than HalfNormMin.
        // We convert it to denormalized half.
        Mantissa := (Mantissa or $00800000) shr (1 - Exp);
        // Round to nearest
        if (Mantissa and $00001000) > 0 then
          Mantissa := Mantissa + $00002000;
        // Assemble Sign and Mantissa (Exp is zero to get denormalized number)
	Result := Sign or (Mantissa shr 13);
      end;
    end
    else if Exp = 255 - 127 + 15 then
    begin
      if Mantissa = 0 then
      begin
        // Input float is infinity, create infinity half with original sign
        Result := Sign or $7C00;
      end
      else
      begin
        // Input float is NaN, create half NaN with original sign and mantissa
        Result := (Sign or $7C00) or (Mantissa shr 13);
      end;
    end
    else
    begin
      // Exp is > 0 so input float is normalized Single

      // Round to nearest
      if (Mantissa and $00001000) > 0 then
      begin
        Mantissa := Mantissa + $00002000;
        if (Mantissa and $00800000) > 0 then
        begin
          Mantissa := 0;
          Exp := Exp + 1;
        end;
      end;

      if Exp > 30 then
      begin
        // Exponent overflow - return infinity half
        Result := Sign or $7C00;
      end
      else
        // Assemble normalized half
	Result := byte(Exp);
        Result := Sign or (Result shl 10) or (Mantissa shr 13);
    end;
  end;
end;


function HalfToFloat(Half: float16): Single;
(*
@description:
*)
var
  Dst, Mantissa, Sign: LongWord;
  Exp: byte;
begin
  // Extract sign, exponent, and mantissa from half number
  Sign := (word(Half) and $8000) shl 16;
  Exp := (word(Half) and $7C00) shr 10;
  Mantissa := word(Half) and 1023;

  if (Exp > 0) and (Exp < 31) then
  begin
    // Common normalized number
    Exp := Exp + (127 - 15);
    Mantissa := Mantissa shl 13;
    Dst := Sign or (LongWord(Exp) shl 23) or Mantissa;
    // Result := Power(-1, Sign) * Power(2, Exp - 15) * (1 + Mantissa / 1024);
  end
  else if (Exp = 0) and (Mantissa = 0) then
  begin
    // Zero - preserve sign
    Dst := Sign;
  end
  else if (Exp = 0) and (Mantissa <> 0) then
  begin
    // Denormalized number - renormalize it
    while (Mantissa and $00000400) = 0 do
    begin
      Mantissa := Mantissa shl 1;
      Dec(Exp);
    end;
    Inc(Exp);
    Mantissa := Mantissa and not $00000400;
    // Now assemble normalized number
    Exp := Exp + (127 - 15);
    Mantissa := Mantissa shl 13;
    Dst := Sign or (LongWord(Exp) shl 23) or Mantissa;
    // Result := Power(-1, Sign) * Power(2, -14) * (Mantissa / 1024);
  end
  else if (Exp = 31) and (Mantissa = 0) then
  begin
    // +/- infinity
    Dst := Sign or $7F800000;
  end
  else //if (Exp = 31) and (Mantisa <> 0) then
  begin
    // Not a number - preserve sign and mantissa
    Dst := Sign or $7F800000 or (Mantissa shl 13);
  end;

  // Reinterpret LongWord as Single
  Result := PSingle(@Dst)^;
end;


function f16_gte(a,b: word): Boolean;
(*
@description:
*)
begin

//    if(IS_ZERO(a) && IS_ZERO(b))
//        return 1;
 if (a or b) and $7fff = 0 then
  exit(true);

//    if(IS_NAN(a) || IS_NAN(b))
//        return 0;
 if (a and $7fff > $7c00) or (b and $7fff > $7c00) then
  exit(false);

//    if((a & SIGN_MASK) == 0) {
//        if((b & SIGN_MASK) == SIGN_MASK)
//            return 1;
//        return a >= b;
//    }
 if a and $8000 = 0 then begin

  if b and $8000 = $8000 then exit(true);

  Result := (a >= b);

 end else begin
//    else {
//        if((b & SIGN_MASK) == 0)
//            return 0;
//        return (a & 0x7FFF) <= (b & 0x7FFF);
//    }
  if b and $8000 = 0 then exit(false);

  Result := (a and $7fff) <= (b and $7fff);

 end;

end;


function f16_gt(a, b: word): Boolean;
(*
@description:
*)
begin

//    if(IS_NAN(a) || IS_NAN(b))
//        return 0;
 if (a and $7fff > $7c00) or (b and $7fff > $7c00) then
  exit(false);

//    if(IS_ZERO(a) && IS_ZERO(b))
//        return 1;
 if (a or b) and $7fff = 0 then
  exit(true);

//    if((a & SIGN_MASK) == 0) {
//        if((b & SIGN_MASK) == SIGN_MASK)
//            return 1;
//        return a > b;
//    }
 if a and $8000 = 0 then begin

  if b and $8000 = $8000 then exit(true);

  Result := (a > b);

 end else begin

//    else {
//        if((b & SIGN_MASK) == 0)
//            return 0;
//        return (a & 0x7FFF) < (b & 0x7FFF);
//    }
  if b and $8000 = 0 then exit(false);

  Result := (a and $7fff) < (b and $7fff);

 end;

end;


function f16_eq(a, b: word): Boolean;
(*
@description:
*)
begin

//    if(IS_NAN(a) || IS_NAN(b))
//        return 0;
 if (a and $7fff > $7c00) or (b and $7fff > $7c00) then
  exit(false);

//    if(IS_ZERO(a) && IS_ZERO(b))
//        return 1;
 if (a or b) and $7fff = 0 then
  exit(true);

//    return a==b;
 Result := (a = b);

end;


function f16_lte(a, b: word): Boolean;
(*
@description:
*)
begin

 Result := f16_gte(b, a);

end;


function f16_lt(a, b: word): Boolean;
(*
@description:
*)
begin

 Result := f16_gt(b, a);

end;


function f16_neq(a, b: word): Boolean;
(*
@description:
*)
begin

    Result := Boolean(ord(f16_eq(a,b)) xor ord(true));

end;

end.
