
uses crt;


var

 i: byte;
 a: byte;


 x, f: single;
 
 lx,ly: shortint;
 
 mx,my: byte;
 
 wall: array [0..255] of byte;
 
 adjw: array [0..3, 0..3] of byte;



(*
int32_t sqrt_i32(int32_t v) {
    uint32_t b = 1<<30, q = 0, r = v;
    while (b > r)
        b >>= 2;
    while( b > 0 ) {
        uint32_t t = q + b;
        q >>= 1;           
        if( r >= t ) {     
            r -= t;        
            q += b;        
        }
        b >>= 2;
    }
    return q;
}
*)


(*
function sqrt16(r: cardinal): real;
var t,q,b: cardinal;
begin

    if (r = 0) then exit(0.0);

    b := $40000000;
    q := 0;
    while( b > 0 ) do begin
   
        t := q + b;
        if( r >= t ) then begin
            r := r - t;
            q := t + b;
        end;

        r:=r shl 1;
        b:=b shr 1;
    end;
    
    if( r > q ) then inc(q);

    q:=q shr 8;
    
    Result:=PReal(@q)^;
end;



function sqrt32(r: cardinal): cardinal;
var b,q,t: cardinal;
begin

 q:=0;
 b:=1 shl 30;
 
 while b>r do b:=b shr 2;
 
 while b>0 do begin
  t:=q+b;
  
  q:=q shr 1;
  
  if r>=t then begin
   r:=r-t;
   q:=q+b;  
  end;
  
  b:=b shr 2;
 
 end;
 
 result:=q;

end;
*)


function RoundSingle(x: Single): LongInt;
var
  u: LongWord absolute x;
  sign: LongInt;
  exp: LongInt;
  mant: LongWord;
  shift: LongInt;
  intPart: LongInt;
  fracMask: LongWord;
begin
  sign := u shr 31;
  exp  := ((u shr 23) and $FF) - 127;
  mant := (u and $7FFFFF) or $800000; // ukryta "1"

  if exp < 0 then
  begin
    // |x| < 1.0
    if exp = -1 then
    begin
      // sprawdź czy ≥ 0.5
      if mant >= $C00000 then  // bo 0.5 = 1.0*2^-1
        intPart := 1
      else
        intPart := 0;
    end
    else
      intPart := 0;
  end
  else if exp > 30 then
  begin
    // za duże dla 32-bit integer
    if sign = 0 then
      intPart := High(LongInt)
    else
      intPart := Low(LongInt);
  end
  else
  begin
    // przesuwamy mantysę
    if exp >= 23 then
      intPart := mant shl (exp - 23)
    else
    begin
      shift := 23 - exp;
      fracMask := (1 shl shift) - 1;
      intPart := mant shr shift;
      // sprawdzamy ułamek do zaokrąglenia
      if (mant and fracMask) >= (1 shl (shift-1)) then
        Inc(intPart);
    end;
  end;

  if sign <> 0 then
    Result := -intPart
  else
    Result := intPart;
end;


function TruncSingle(x: Single): LongInt;
var
  u: LongWord absolute x;
  sign: LongInt;
  exp: LongInt;
  mant: LongWord;
  intPart: LongInt;
begin
  sign := u shr 31;
  exp  := ((u shr 23) and $FF) - 127;
  mant := (u and $7FFFFF) or $800000;  // ukryta jedynka (24 bity)

  if exp < 0 then
  begin
    // |x| < 1.0 → wynik 0
    intPart := 0;
  end
  else if exp > 30 then
  begin
    // Za duże dla 32-bit integer → saturacja
    if sign = 0 then
      intPart := High(LongInt)
    else
      intPart := Low(LongInt);
  end
  else
  begin
    // "przesuwamy" mantysę na właściwe miejsce
    if exp >= 23 then
      intPart := mant shl (exp - 23)
    else
      intPart := mant shr (23 - exp);
  end;

  if sign <> 0 then
    Result := -intPart
  else
    Result := intPart;
end;



function FloorSingle(x: Single): LongInt;
var
  u: LongWord absolute x;
  sign: LongInt;
  exp: LongInt;
  mant: LongWord;
  shift: LongInt;
  intPart: LongInt;
  fracMask: LongWord;
begin
  sign := u shr 31;
  exp  := ((u shr 23) and $FF) - 127;
  mant := (u and $7FFFFF) or $800000; // ukryta jedynka

  if exp < 0 then
  begin
    // |x| < 1.0
    if sign = 0 then
      intPart := 0
    else
      intPart := -1;   // np. -0.3 → floor = -1
  end
  else if exp > 30 then
  begin
    // za duże dla 32-bit int
    if sign = 0 then
      intPart := High(LongInt)
    else
      intPart := Low(LongInt);
  end
  else
  begin
    if exp >= 23 then
    begin
      intPart := mant shl (exp - 23);
    end
    else
    begin
      shift := 23 - exp;
      fracMask := (1 shl shift) - 1;
      intPart := mant shr shift;

      // jeśli były jakieś bity ułamkowe i liczba ujemna → floor = trunc-1
      if (sign <> 0) and ((mant and fracMask) <> 0) then
        Inc(intPart);
    end;

    if sign <> 0 then
      intPart := -intPart;
  end;

  Result := intPart;
end;


function FastSin(x: Single): Single;
const
  PI     : Single = 3.14159265358979323846;
  INVPI  : Single = 0.31830988618379067154;  // 1/π
  TWO_PI : Single = 6.28318530717958647692;
var
  xx, y, k: Single;
begin
  // Zawijamy x do [-π, π] – szybkie przybliżenie bez podwójnej precyzji:
  // k = najbliższa liczba całkowita (x / (2π))
  k  := round(x / TWO_PI);
  xx := x - k * TWO_PI;

  // y = lin/parabola: 4/π * x - 4/π^2 * x*|x|
  y := (4.0 * INVPI) * xx - (4.0 * INVPI * INVPI) * xx * Abs(xx);

  // poprawka nieliniowa (~0.225) – znacząco zmniejsza błąd
  Result := 0.225 * (y * Abs(y) - y) + y;
end;


function FastCos(x: Single): Single; inline;
const
  HALF_PI : Single = 1.5707963267948966; // π/2
begin
  Result := FastSin(x + HALF_PI);
end;


(*
function SqrSingleSoft(x: Single): Single;
var
  u: LongWord absolute x;
  exp: LongInt;
  mant: LongWord;
  sq: QWord;
  newExp: LongInt;
  newMant: LongWord;
  res: LongWord absolute Result;
begin
  exp  := (u shr 23) and $FF;
  mant := u and $7FFFFF;

  if exp = 255 then
  begin
    // INF albo NaN → wynik też INF/NaN
    res := u and $7FFFFFFF;
    exit;
  end;

  if (exp = 0) and (mant = 0) then
  begin
    // 0 → kwadrat = 0
    res := 0;
    exit;
  end;

  // ukryta "1" dla normalnych
  if exp <> 0 then
    mant := mant or $800000
  else
    exp := 1; // denormalne traktujemy jak exponent=1

  // teraz mamy 24-bit mantysę
  // liczymy mant^2 (max 48 bitów)
  sq := QWord(mant) * QWord(mant);

  // początkowy wykładnik
  newExp := 2*exp - 127;

  // normalizacja:
  // sq jest ~ (1.0..4.0) * 2^46
  // sprawdzamy czy >= 2.0 → wtedy przesuwamy
  if (sq and (QWord(1) shl 47)) <> 0 then
  begin
    // najwyższy bit wpadł na pozycję 47 → wynik >=2
    sq := sq shr 24;  // zostawiamy 23+1 bity
    Inc(newExp);
  end
  else
    sq := sq shr 23;  // normalizacja dla [1,2)

  // sq ma teraz 24 bity: 1.xxxxxxx
  newMant := LongWord(sq) and $7FFFFF;

  // składamy wynik (znak = 0)
  res := (newExp shl 23) or newMant;
end;
*)


begin

          for lx:=-1 to 1 do
              for ly:=-1 to 1 do
                  begin
                  //mx:=max(min(xb+lx,12),0); { When referring to x, the coordinate }
                  //my:=yb+ly;                { must be between 0 and 12.           }

                  if //(shortint(xb+lx)<0 ) or
                     //(shortint(xb+lx)>12) or
                     (wall[byte(mx)+byte(my)*16]<>0) then
                        adjw[byte(lx+1),byte(ly+1)]:=$ff  { There are bricks }
                  else
                     adjw[byte(lx+1),byte(ly+1)]:=0;      { There are no bricks }

                  end;

//while true do ;

{
 while true do begin
 
 asm
  lda:rne vcount
 end;
 
 poke($d01a,$0f);

 f:=SqrSingleSoft(x);
 
 poke($d01a, 0);
 end;
 }




repeat until keypressed;

end.
