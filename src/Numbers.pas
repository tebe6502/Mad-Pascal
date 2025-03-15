unit Numbers;

interface

{$i define.inc}
{$i Types.inc}

type
  TNumber = Int64;

// High Level
function FromInt64(const i: Int64): TNumber;
function FromSingle(const s: Single): TNumber; overload;
function CastToReal(const a: TNumber): TNumber;
function CastToSingle(const a: TNumber): TNumber;
function CastToHalfSingle(const a: TNumber): TNumber;

function Assign(const valType: Byte; const s: Single): TNumber;
function Negate(var valType: Byte; const a: TNumber): TNumber;  // valType not const!
function Add(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;
function Subtract(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;
function Multiply(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;
function Divide(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;


// High Level - Only for RealNumbers
function Frac(const valType: Byte; const a: TNumber): TNumber;
function Trunc(const valType: Byte; const a: TNumber): TNumber;



implementation

uses Common, SysUtils; // TODO Remove Common and have only Tokens


// Low-Level TFloat representation
const
  TWOPOWERFRACBITS = 256;  // Factor for 8-bit fractional part

// Fixed-point 32-bit real number storage
type
  TFloat = array [0..1] of Integer; // 2*32 bits

function Zero: TFloat;
begin
  Result := Default(TFloat);
end;

function ToTFloat(const s: Single): TFloat; overload;
begin
  Result[0] := round(s * TWOPOWERFRACBITS);
  {$IFNDEF PAS2JS}
  Result[1] := Integer(s);
  {$ENDIF}
end;

function ToSingle(const ftmp: TFloat): Single;
begin
  Result := 0;
  {$IFNDEF PAS2JS}
  move(ftmp[1], Result, sizeof(Result));
  {$ENDIF}
end;

procedure MoveTFloat(const ConstVal: TNumber; var ftmp: TFloat); overload;
begin
{$IFNDEF PAS2JS}
  move(ConstVal, ftmp, sizeof(ftmp));
{$ENDIF}
end;

procedure MoveTFloat(const ftmp: TFloat; var ConstVal: TNumber); overload;
begin
{$IFNDEF PAS2JS}
  move(ftmp, ConstVal, sizeof(ftmp));
{$ENDIF}

end;


// ----------------------------------------------------------------------------
// The https://www.freepascal.org/docs-html/rtl/system/sarlongint.html is currently
// missing from the Javascript RTL. The native arithemtic shift right works the same
// for 32-bit operands.
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Right_shift
// ----------------------------------------------------------------------------

{$IFDEF PAS2JS}
function SarLongint(const AValue: Longint; const Shift: Byte = 1): Longint;
begin
asm
  return (AValue>>Shift);
end;
{$ENDIF}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function CardToHalf32(const src: Uint32): Word; overload;
var
  Sign, Exp, Mantissa: Longint;
  s: Single;


  function f32Tof16(fltInt32: Uint32): Word;
    //https://stackoverflow.com/questions/3026441/float32-to-float16/3026505
  var
    //  fltInt32: uint32;
    fltInt16, tmp: Uint16;

  begin
    //  fltInt32 := PLongWord(@Float)^;
    fltInt16 := (fltInt32 shr 31) shl 5;
    tmp := (fltInt32 shr 23) and $ff;
    tmp := (tmp - $70) and (Longword(SarLongint(($70 - tmp), 4)) shr 27);
    fltInt16 := (fltInt16 or tmp) shl 10;
    Result := fltInt16 or ((fltInt32 shr 13) and $3ff) + 1;
  end;

begin

{$IFNDEF PAS2JS}// TODO

  s := PSingle(@Src)^;

  if (System.frac(s) <> 0) and (abs(s) >= 0.000060975552) then

    Result := f32Tof16(Src)

  else
  begin

    // Extract sign, exponent, and mantissa from Single number
    Sign := Src shr 31;
    Exp := Longint((Src and $7F800000) shr 23) - 127 + 15;
    Mantissa := Src and $007FFFFF;

    if (Exp > 0) and (Exp < 30) then
    begin
      // Simple case - round the significand and combine it with the sign and exponent
      Result := (Sign shl 15) or (Exp shl 10) or ((Mantissa + $00001000) shr 13);
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
          Result := (Sign shl 15) or (Mantissa shr 13);
        end;
      end
      else if Exp = 255 - 127 + 15 then
      begin
        if Mantissa = 0 then
        begin
          // Input float is infinity, create infinity half with original sign
          Result := (Sign shl 15) or $7C00;
        end
        else
        begin
          // Input float is NaN, create half NaN with original sign and mantissa
          Result := (Sign shl 15) or $7C00 or (Mantissa shr 13);
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
          Result := (Sign shl 15) or $7C00;
        end
        else
          // Assemble normalized half
          Result := (Sign shl 15) or (Exp shl 10) or (Mantissa shr 13);
      end;
    end;

  end;

{$ENDIF}

end;  // CardToHalf32


function CardToHalf(const ftmp: TFloat): Word; overload;
var
  Value: Uint32;
begin
  Value := ftmp[1];
  Result := CardToHalf32(Value);
end;

// ----------------------------------------------------------------------------
// High-Level
// ----------------------------------------------------------------------------

function FromInt64(const i: Int64): TNumber;
var
  fl: Single;
  ftmp: TFloat;

begin

  fl := Integer(i);
  ftmp := ToTFloat(fl);
  Result := 0;
  MoveTFloat(ftmp, Result);

end;

function FromSingle(const s: Single): TNumber; overload;
var
  ftmp: TFloat;
begin
  ftmp := ToTFloat(s);
  Result := 0;
  MoveTFloat(ftmp, Result);
end;

function CastToReal(const a: TNumber): TNumber;
var
  ftmp: TFloat;
begin
  ftmp := Zero;
  MoveTFloat(a, ftmp);
  Result := ftmp[0];
end;


function CastToSingle(const a: TNumber): TNumber;
var
  ftmp: TFloat;
begin
  ftmp := Zero;
  MoveTFloat(a, ftmp);
  Result := ftmp[1];
end;

function CastToHalfSingle(const a: TNumber): TNumber;
var
  ftmp: TFloat;
begin
  ftmp := Zero;

  MoveTFloat(a, ftmp);
  Result := CardToHalf(ftmp);
end;

function Assign(const valType: Byte; const s: Single): TNumber;
var
  ftmp: TFloat;
begin
  if valType in RealTypes then
  begin
    ftmp := ToTFloat(s);
  end
  else
  begin
    ftmp[0] := round(s);
    ftmp[1] := 0;
  end;

  Result := 0;
  MoveTFloat(ftmp, Result);
end;

function Negate(var valType: Byte; const a: TNumber): TNumber;
var
  ftmp: TFloat;
  fl: Single;
begin
  if valType in RealTypes then
  begin  // (RealTypes)

    ftmp := Zero;
    Result := 0;

    MoveTFloat(a, ftmp);
    fl := ToSingle(ftmp);

    fl := -fl;

    ftmp := ToTFloat(fl);
    MoveTFloat(ftmp, Result);

  end
  else
  begin // IntegerTypes
    Result := -a;

    if valType in IntegerTypes then
      valType := GetValueType(Result);

  end;
end;

function Add(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;
var
  ftmp, ftmp_: TFloat;
  fl, fl_: Single;
begin

  if valType in RealTypes then
  begin
    ftmp := Zero;
    ftmp_ := Zero;

    MoveTFloat(a, ftmp);
    MoveTFloat(b, ftmp_);

    fl := ToSingle(ftmp);
    fl_ := ToSingle(ftmp_);

    fl := fl + fl_;

    ftmp := ToTFloat(fl);

    Result := 0;
    MoveTFloat(ftmp, Result);
  end
  else
  begin
    Result := a + b;
  end;

end;

function Subtract(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;
var
  ftmp, ftmp_: TFloat;
  fl, fl_: Single;
begin

  if valType in RealTypes then
  begin
    ftmp := Zero;
    ftmp_ := Zero;

    MoveTFloat(a, ftmp);
    MoveTFloat(b, ftmp_);

    fl := ToSingle(ftmp);
    fl_ := ToSingle(ftmp_);

    fl := fl + fl_;

    ftmp := ToTFloat(fl);

    Result := 0;
    MoveTFloat(ftmp, Result);
  end
  else
  begin
    Result := a - b;
  end;

end;

function Multiply(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;
var
  ftmp, ftmp_: TFloat;
  fl, fl_: Single;
begin
  if valtype in RealTypes then
  begin
    ftmp := Zero;
    ftmp_ := Zero;

    MoveTFloat(a, ftmp);
    MoveTFloat(b, ftmp_);

    fl := ToSingle(ftmp);
    fl_ := ToSingle(ftmp_);

    fl := fl * fl_;

    ftmp := ToTFloat(fl);

    Result := 0;
    MoveTFloat(ftmp, Result);
  end
  else
  begin
    Result := a * b;
  end;
end;

function Divide(const valType: Byte; const a: TNumber; const b: TNumber): TNumber;
var
  ftmp, ftmp_: TFloat;
  fl, fl_: Single;
begin
  ftmp := Zero;
  ftmp_ := Zero;

  MoveTFloat(a, ftmp);
  MoveTFloat(b, ftmp_);

  fl := ToSingle(ftmp);
  fl_ := ToSingle(ftmp_);

  if fl_ = 0 then raise EDivByZero.Create('Division by Zero');

  fl := fl / fl_;

  ftmp := ToTFloat(fl);

  Result := 0;
  MoveTFloat(ftmp, Result);
end;

function Trunc(const valType: Byte; const a: TNumber): TNumber;

var
  ftmp: TFloat;
  fl: Single;
begin
  Assert(valType in RealTypes);
  if valType in [HALFSINGLETOK, SINGLETOK] then
  begin
    ftmp := Zero;

    MoveTFloat(a, ftmp);

    fl:=ToSingle(ftmp);

    fl := int(fl);

    ftmp := ToTFloat(fl);
    Result := 0;
    MoveTFloat(ftmp, Result);
  end
  else
  begin
    if a < 0 then
      Result := -(abs(a) and $ffffffffffffff00)
    else
      Result := a and $ffffffffffffff00;
  end;
end;


function Frac(const valType: Byte; const a: TNumber): TNumber;

var
  ftmp: TFloat;
  fl: Single;
begin
  Assert(valType in RealTypes);
  if valType in [HALFSINGLETOK, SINGLETOK] then
  begin
    ftmp := Zero;

    MoveTFloat(a, ftmp);

    fl:=ToSingle(ftmp);

    fl := System.frac(fl);

    ftmp := ToTFloat(fl);
    Result := 0;
    MoveTFloat(ftmp, Result);
  end
  else
  begin
    if a < 0 then
      Result := -(abs(a) and $ff)
    else
      Result := a and $ff;
  end;
end;

end.
