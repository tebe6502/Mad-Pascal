unit math;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Additional mathematical routines

 @version: 1.0

 @description:
 <http://www.freepascal.org/docs-html/rtl/math/index-5.html>

 <https://github.com/graemeg/freepascal/blob/master/rtl/objpas/math.pp>

 hypot function from AMath library (C) Copyright 2009-2013 Wolfgang Ehrhardt
*)


{

ArcCos
ArcSin
ArcTan2
Ceil
CycleToRad
DegNormalize
DegToGrad
DegToRad
DivMod
EnsureRange
Floor
FMod
GradToDeg
GradToRad
InRange
IsNan
Log2
Log10
LogN
Max
Min
Power
RadToCycle
RadToDeg
RadToGrad
RandG			Return gaussian distributed random number
RandomRange
RandomRangeF
Sign
Tan

}

interface

	function ArcCos(x: real): real; overload;
	function ArcCos(x: single): single; overload;
	function ArcSin(x: real): real; overload;
	function ArcSin(x: single): single; overload;
	function DegNormalize(deg : single) : single;
	function degtorad(deg : single) : single; overload;
	function degtorad(deg : real) : real; overload;
	function radtodeg(rad : single) : single;
	function gradtorad(grad : single) : single;
	function radtograd(rad : single) : single;
	function degtograd(deg : single) : single;
	function gradtodeg(grad : single) : single;
	function cycletorad(cycle : single) : single;
	function radtocycle(rad : single) : single;
	procedure DivMod(Dividend: integer; Divisor: Word; var r, Remainder: Word); overload;
	procedure DivMod(Dividend: integer; Divisor: Word; var r, Remainder: smallint); overload;
	function InRange(const AValue, AMin, AMax: byte): Boolean; overload;
	function InRange(const AValue, AMin, AMax: Integer): Boolean; overload;
	function EnsureRange(const AValue, AMin, AMax: byte): Integer; overload;
	function EnsureRange(const AValue, AMin, AMax: Integer): Integer; overload;
	function hypot(x,y : float) : float;
	function Min(x, y: real): real; overload;
	function Min(x, y: shortreal): shortreal; overload;
	function Min(x, y: single): single; overload;
	function Min(x, y: shortint): shortint; overload;
	function Min(x, y: smallint): smallint; overload;
	function Min(x, y: integer): integer; overload;
	function Max(x, y: real): real; overload;
	function Max(x, y: shortreal): shortreal; overload;
	function Max(x, y: single): single; overload;
	function Max(x, y: shortint): shortint; overload;
	function Max(x, y: smallint): smallint; overload;
	function Max(x, y: integer): integer; overload;
	function power(base : real; const exponent : shortint) : real; overload;
	function power(base : single; const exponent : shortint) : single; overload;
	function power(base : float16; const exponent : shortint) : float16; overload;
	function power(base : integer; const exponent : shortint) : integer; overload;
	function power(x, y : real) : real; overload;
	function power(x, y : float) : float; overload;
	function arctan2(y,x : real) : real;
	function Tan(x: Real): Real;
	function Ceil(a: real): smallint;
	function Floor(a: real): smallint;
	function FMod(a, b: real): real;
	function log10(x : single): single;
	function log2(x : single): single;
	function logN(n,x : single): single;
	function IsNan(const d : Single): Boolean;
	function RandomRange(const aFrom, aTo: smallint): smallint;
	function RandomRangeF(const min, max: single): single;
	function RandG(mean, stddev : single) : single;
	function Sign(const AValue: Integer): shortint; overload;
	function Sign(const AValue: Real): Real; overload;
	function Sign(const AValue: Single): Single; overload;


implementation


function DegNormalize(deg : single) : single;
(*
@description:

*)
begin
  Result:=Deg-single(Trunc(Deg/360))*360;
  If integer(Result) < 0 then Result:=Result+360;
end;


function degtorad(deg : single) : single; overload;
(*
@description:

*)
begin
     Result:=deg*(pi/180);
end;

function degtorad(deg : real) : real; overload;
(*
@description:

*)
begin
     Result:=deg*(pi/180);
end;


function radtodeg(rad : single) : single;
(*
@description:

*)
begin
     Result:=rad*(180/pi);
end;

function gradtorad(grad : single) : single;
(*
@description:

*)
begin
     Result:=grad*(pi/200);
end;

function radtograd(rad : single) : single;
(*
@description:

*)
begin
     Result:=rad*(200/pi);
end;

function degtograd(deg : single) : single;
(*
@description:

*)
begin
     Result:=deg*(200/180);
end;

function gradtodeg(grad : single) : single;
(*
@description:

*)
begin
     Result:=grad*(180/200);
end;

function cycletorad(cycle : single) : single;
(*
@description:

*)
begin
     Result:=cycle * M_PI_2;
end;

function radtocycle(rad : single) : single;
(*
@description:

*)
begin
     { avoid division }
     Result:=rad*(1 / M_PI_2);
end;


procedure DivMod(Dividend: integer; Divisor: Word; var r, Remainder: Word); overload;
(*
@description: DivMod returns Dividend DIV Divisor in Result, and Dividend MOD Divisor in Remainder

*)
begin
  if Dividend < 0 then
    begin
      { Use DivMod with >=0 dividend }
	  Dividend:=-Dividend;
      { The documented behavior of Pascal's div/mod operators and DivMod
        on negative dividends is to return Result closer to zero and
        a negative Remainder. Which means that we can just negate both
        Result and Remainder, and all it's Ok. }
      r:=-(Dividend Div Divisor);
      Remainder:=-(Dividend+(r*Divisor));
    end
  else
    begin
      r:=Dividend Div Divisor;
      Remainder:=Dividend-(r*Divisor);
    end;
end;


procedure DivMod(Dividend: integer; Divisor: Word; var r, Remainder: smallint); overload;
(*
@description: DivMod returns Dividend DIV Divisor in Result, and Dividend MOD Divisor in Remainder

*)
begin
  if Dividend < 0 then
    begin
      { Use DivMod with >=0 dividend }
	  Dividend:=-Dividend;
      { The documented behavior of Pascal's div/mod operators and DivMod
        on negative dividends is to return Result closer to zero and
        a negative Remainder. Which means that we can just negate both
        Result and Remainder, and all it's Ok. }
      r:=-(Dividend Div Divisor);
      Remainder:=-(Dividend+(r*Divisor));
    end
  else
    begin
      r:=Dividend Div Divisor;
      Remainder:=Dividend-(r*Divisor);
    end;
end;


function InRange(const AValue, AMin, AMax: byte): Boolean; overload;
(*
@description: InRange returns True if AValue is in the range AMin..AMax. It returns False if Value lies outside the specified range.

*)
begin
  Result:=(AValue>=AMin) and (AValue<=AMax);
end;


function InRange(const AValue, AMin, AMax: Integer): Boolean; overload;
(*
@description: InRange returns True if AValue is in the range AMin..AMax. It returns False if Value lies outside the specified range.

*)
begin
  Result:=(AValue>=AMin) and (AValue<=AMax);
end;


function EnsureRange(const AValue, AMin, AMax: byte): Integer; overload;
(*
@description: EnsureRange returns Value if AValue is in the range AMin..AMax. It returns AMin if the value is less than AMin, or AMax if the value is larger than AMax.

*)
begin
  Result:=AValue;
  If Result<AMin then
    Result:=AMin
  else if Result>AMax then
    Result:=AMax;
end;


function EnsureRange(const AValue, AMin, AMax: Integer): Integer; overload;
(*
@description: EnsureRange returns Value if AValue is in the range AMin..AMax. It returns AMin if the value is less than AMin, or AMax if the value is larger than AMax.

*)
begin
  Result:=AValue;
  If Result<AMin then
    Result:=AMin
  else if Result>AMax then
    Result:=AMax;
end;


function Min(x, y: real): real; overload;
(*
@description: Min returns the smallest value of X and Y.

*)
begin
if x < y then Result := x else Result := y;
end;


function Min(x, y: shortreal): shortreal; overload;
(*
@description: Min returns the smallest value of X and Y.
*)
begin
if x < y then Result := x else Result := y;
end;


function Min(x, y: single): single; overload;
(*
@description: Min returns the smallest value of X and Y.

*)
begin
if x < y then Result := x else Result := y;
end;


function Min(x, y: shortint): shortint; overload;
(*
@description: Min returns the smallest value of X and Y.

*)
begin
if x < y then Result := x else Result := y;
end;


function Min(x, y: smallint): smallint; overload;
(*
@description: Min returns the smallest value of X and Y.

*)
begin
if x < y then Result := x else Result := y;
end;


function Min(x, y: integer): integer; overload;
(*
@description: Min returns the smallest value of X and Y.

*)
begin
if x < y then Result := x else Result := y;
end;


function Max(x, y: real): real; overload;
(*
@description: Max returns the maximum of X and Y.

*)
begin
if x > y then Result := x else Result := y;
end;


function Max(x, y: shortreal): shortreal; overload;
(*
@description: Max returns the maximum of X and Y.

*)
begin
if x > y then Result := x else Result := y;
end;


function Max(x, y: single): single; overload;
(*
@description: Max returns the maximum of X and Y.

*)
begin
if x > y then Result := x else Result := y;
end;


function Max(x, y: shortint): shortint; overload;
(*
@description: Max returns the maximum of X and Y.

*)
begin
if x > y then Result := x else Result := y;
end;


function Max(x, y: smallint): smallint; overload;
(*
@description: Max returns the maximum of X and Y.

*)
begin
if x > y then Result := x else Result := y;
end;


function Max(x, y: integer): integer; overload;
(*
@description: Max returns the maximum of X and Y.

*)
begin
if x > y then Result := x else Result := y;
end;


function RandomRange(const aFrom, aTo: smallint): smallint;
(*
@description: RandomRange returns a random value in the range AFrom to ATo. AFrom and ATo do not need to be in increasing order. The upper border is not included in the generated value, but the lower border is.

*)
var a: smallint;
begin
  a := Abs(aFrom-aTo);
  Result:=Random(a)+Min(aTo,AFrom);
end;


function RandomRangeF(const min, max: single): single;
(*
@description:

*)
var
  fl : ^single;
  c: cardinal;
begin
  fl := @c;

  c:=cardinal(random) shl 16;
  c:=c or $3f000000;

  result := min + fl^* (max-min);
end;


function RandG(mean, stddev : single) : single;
(*
@description: Return gaussian distributed random number.

*)
Var U1,S2 : single;
begin
     repeat
       u1:= 2*RandomF-1;
       S2:=Sqr(U1)+sqr(single(2)*RandomF-single(1));
     until s2 < single(1);

     Result:=Sqrt(single(-2)*ln(S2)/S2)*u1*stddev+Mean;
end;


function power(base : real; const exponent : shortint) : real; overload;
(*
@description: Return real power.

*)
var
     i : shortint;
begin
     if (base = 0.0) and (exponent = 0) then
       result:=1.0
     else
       begin
         i:=abs(exponent);
         Result:=1.0;
         while i>0 do
           begin
              while (i and 1)=0 do
                begin
                   i:=i shr 1;
                   base:=sqr(base);
                end;
              i:=i-1;
              Result:=Result*base;
           end;
         if exponent < 0 then
           Result:=1.0/Result;
       end;
end;


function power(base : single; const exponent : shortint) : single; overload;
(*
@description: Return real power.

*)
var
     i : shortint;
begin
     if (base = single(0)) and (exponent = 0) then
       result:=1.0
     else
       begin
         i:=abs(exponent);
         Result:=1.0;
         while i>0 do
           begin
              while (i and 1) = 0 do
                begin
                   i:=i shr 1;
                   base:=sqr(base);
                end;
              i:=i-1;
              Result:=Result*base;
           end;
         if exponent < 0 then
           Result:=1.0/Result;
       end;
end;


function power(base : float16; const exponent : shortint) : float16; overload;
(*
@description: Return real power.

*)
var
     i : shortint;
begin
     if (base = float16(0)) and (exponent = 0) then
       result:=1.0
     else
       begin
         i:=abs(exponent);
         Result:=1.0;
         while i>0 do
           begin
              while (i and 1) = 0 do
                begin
                   i:=i shr 1;
                   base:=sqr(base);
                end;
              i:=i-1;
              Result:=Result*base;
           end;
         if exponent < 0 then
           Result:=1.0/Result;
       end;
end;


function power(base : integer; const exponent : shortint) : integer; overload;
(*
@description: Return real power.

*)
var
     i : shortint;
begin
     if (base = 0) and (exponent = 0) then
       result:=1
     else
       begin
         i:=abs(exponent);
         Result:=1;
         while i>0 do
           begin
              while (i and 1) = 0 do
                begin
                   i:=i shr 1;
                   base:=sqr(base);
                end;
              i:=i-1;
              Result:=Result*base;
           end;
         if exponent < 0 then
           Result:=0;
       end;
end;


function power(x, y : real) : real; overload;
(*
@description: Return real power.
*)
begin

  If y = 0 Then
    power := 1.0
  Else if x = 0 Then
    Power := 0.0
  Else If x > 0 Then
    Power := exp( y * ln(x))
  Else if Trunc(y) mod 2 = 0 Then
    Power := exp( y * ln(abs(x)))
  Else
    Power := -exp( y * ln(abs(x)));
    
end;


function power(x, y : float) : float; overload;
(*
@description: Return real power.
*)
begin

  If y = 0 Then
    power := 1.0
  Else if x = 0 Then
    Power := 0.0
  Else If x > 0 Then
    Power := exp( y * ln(x))
  Else if Trunc(y) mod 2 = 0 Then
    Power := exp( y * ln(abs(x)))
  Else
    Power := -exp( y * ln(abs(x)));
    
end;


function arctan2(y,x : real) : real;
(*
@description:

arctan2 calculates arctan(y/x), and returns an angle in the correct quadrant. The returned angle will be in the range $-\pi$ to $\pi$ radians.
*)
begin
    if (x = 0.0) then
      begin
        if y = 0.0 then
          Result:=0.0
        else if y>0.0 then
          Result:=D_PI_2
        else if y<0.0 then
          Result:=-D_PI_2;
      end
    else
      Result:=ArcTan(y/x);

    if x < 0.0 then
      Result:=Result+pi;

    if Result>pi then
      Result:=Result-M_PI_2;
end;


function ArcSin(x: single): single; overload;
(*
@description: Arcsin returns the inverse sine of its argument x. The argument x should lie between -1 and 1.

*)
const
 a0 : single = D_PI_2;
 a1 : single = -0.212;
 a2 : single =  0.074;
 a3 : single = -0.019;

begin

 if (x >= -1) and (x <= 1) then
  Result:= a0 - sqrt(1 - x)*(a0 + a1*x + a2*x*x + a3*x*x*x);

end;


function ArcCos(x: single): single; overload;
(*
@description: Arccos returns the inverse cosine of its argument x. The argument x should lie between -1 and 1 (borders included).

*)
begin

 if (x>=-1) and (x<=1) then
  Result:= D_PI_2 - ArcSin(x);

end;


function ArcSin(x: real): real; overload;
(*
@description: Arcsin returns the inverse sine of its argument x. The argument x should lie between -1 and 1.

*)
const
 a0 = D_PI_2;
 a1 = -0.212;
 a2 = 0.074;
 a3 = -0.019;

begin

 if (x>=-1.0) and (x<=1.0) then
  Result:= a0 - sqrt(1.0 - x)*(a0 + a1*x + a2*x*x + a3*x*x*x);

end;


function ArcCos(x: real): real; overload;
(*
@description: Arccos returns the inverse cosine of its argument x. The argument x should lie between -1 and 1 (borders included).

*)
begin

 if (x>=-1.0) and (x<=1.0) then
  Result:= D_PI_2 - ArcSin(x);

end;


function Tan(x: Real): Real;
(*
@description: Tan returns the tangent of x. The argument x must be in radians.

*)
begin

 Result := sin(x) / cos(x);

end;


function Ceil(a: real): smallint;
(*
@description: Ceil returns the lowest integer number greater than or equal to x. The absolute value of x should be less than maxint.

*)
begin

 Result := trunc(a - 32768.) + 32768;

end;


function Floor(a: real): smallint;
(*
@description: Floor returns the largest integer smaller than or equal to x. The absolute value of x should be less than maxint.

*)
begin

 Result := trunc(a + 32768.) - 32768;

end;


function FMod(a, b: real): real;
(*
@description:

*)
begin

 Result := (a - b * Real(floor(a / b)));

end;


function Log10(x: single): single;
(*
@description: Log10 returns the 10-base logarithm of X.

*)
begin
 Result := ln(x)*0.43429448190325182765;
end;


function log2(x : single) : single;
(*
@description: Log2 returns the 2-base logarithm of X.
*)
begin
 Result := ln(x)*1.4426950408889634079;    { 1/ln(2) }
end;


function logn(n,x : single) : single;
(*
@description: Logn returns the n-base logarithm of X.
*)
begin
 Result := ln(x) / ln(n);
end;


function IsNan(const d : Single): Boolean;
(*
@description:
IsNan returns True if the single d contains Not A Number (a value which cannot be represented correctly in single format).
*)
begin
 Result := (cardinal(d) and $7fffffff) > $7f800000;
end;


function Sign(const AValue: Integer): shortint; overload;
(*
@description: Return sign of argument

@param: AValue - Integer
@result: Shortint
*)
begin

 if AValue < 0 then
  Result := -1
 else
  Result := 1;

end;


function Sign(const AValue: Real): Real; overload;
(*
@description: Return sign of argument

@param: AValue - Real
@result: Real
*)
begin

 if AValue < 0.0 then
  Result := -1.0
 else
  Result := 1.0;

end;


function Sign(const AValue: Single): Single; overload;
(*
@description: Return sign of argument

@param: AValue - Single (float)
@result: Single
*)
begin

 if integer(AValue) < 0 then
  Result := -1
 else
  Result := 1;

end;


function hypot(x,y : float) : float;
(*
@description:
Hypot returns the hypotenuse of the triangle where the sides adjacent to the square angle have lengths x and y. The function uses Pythagoras' rule for this.
*)

  begin
    x:=abs(x);
    y:=abs(y);
    if (x>y) then
      hypot:=x*sqrt(1+sqr(y/x))
    else if (x>0) then
      hypot:=y*sqrt(1+sqr(x/y))
    else
      hypot:=y;
  end;


end.
