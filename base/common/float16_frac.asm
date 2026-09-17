
.proc	@F16_FRAC						; FUNCTION

RESULT	= :EAX
VALUE	= :EAX

A	= :EAX+2

	lda A
	sta @F16_INT.A
	pha
	lda A+1
	sta @F16_INT.A+1
	pha
	jsr @F16_INT
	jsr @F16_I2F
	lda @F16_I2F.RESULT
	sta @F16_SUB.B
	lda @F16_I2F.RESULT+1
	sta @F16_SUB.B+1
	pla
	sta @F16_SUB.A+1
	pla
	sta @F16_SUB.A

	jmp @F16_SUB

.endp



/*
 
function FracHalfBitwise(a: float16): word;
var
  h: word absolute a;
  sign: Word;
  p: byte;
  exp: byte;
  width: byte;
  mant, fracMask, fracBits: Word;
begin
  sign := h and $8000;
  exp  := (h shr 10) and $1F;
  mant := h and $3FF;
 
  if exp = 31 then           // Inf / NaN
  begin
    Result := sign or $7E00; // qNaN
    Exit;
  end;

  if exp = 0 then             // zero lub subnormalna: już < 1
  begin
    Result := h;
    Exit;
  end;

  if exp < 15 then                // |x| < 1 -> cała wartość to ułamek
  begin
    Result := h;
    Exit;
  end;

  dec(exp, 15);                 // wykładnik nieobciążony

  if exp >= 10 then               // liczba całkowita -> ułamek = 0
  begin
    Result := sign;             // +0 lub -0
    Exit;
  end;

  // 0 <= e < 10: ułamek siedzi w dolnych (10-e) bitach mantysy
  width    := 10 - exp;
  fracMask := (Word(1) shl width) - 1;
  fracBits := mant and fracMask;

  if fracBits = 0 then
  begin
    Result := sign;              // liczba była całkowita
    Exit;
  end;

  // szukamy pozycji najwyższego ustawionego bitu (BSR na "width" bitach)
  p := width - 1;
  while (fracBits and (Word(1) shl p)) = 0 do
    Dec(p);

  exp  := exp - 10 + p + 15;                    // nowy wykładnik (obciążony)
  mant := (fracBits - (Word(1) shl p)) shl (10 - p);
  
  mant:=mant and $3FF;

  result := sign or (exp shl 10) or mant;

end;


*/