
/*
	cmpSTRING2CHAR
	cmpCHAR2STRING
	@cmpSTRING
*/

.proc	cmpSTRING2CHAR

	lda :STACKORIGIN-1,x
	sta ztmp8
	lda :STACKORIGIN-1+STACKWIDTH,x
	sta ztmp8+1

	lda :STACKORIGIN,x
	sta ztmp10

	ldy #0

	lda (ztmp8),y		; if length <> 1
	cmp #1
	bne fail

	iny

loop	lda (ztmp8),y
	cmp ztmp10
	bne fail

	lda #0
	seq

fail	lda #$ff

	ldy #1

	cmp #0
	rts
.endp


.proc	cmpCHAR2STRING

	lda :STACKORIGIN-1,x
	sta ztmp8

	lda :STACKORIGIN,x
	sta ztmp10
	lda :STACKORIGIN+STACKWIDTH,x
	sta ztmp10+1

	ldy #0

	lda (ztmp10),y		; if length <> 1
	cmp #1
	bne fail

	iny

loop	lda (ztmp10),y
	cmp ztmp8
	bne fail

	lda #0
	seq

fail	lda #$ff

	ldy #1

	cmp #0
	rts
.endp


/*
{   CompareText compares S1 and S2, the result is the based on
    substraction of the ascii values of characters in S1 and S2
    comparison is case-insensitive
    case     result
    S1 < S2  < 0
    S1 > S2  > 0
    S1 = S2  = 0     }

function CompareText(const S1, S2: string): Integer; overload;

var
  i, count, count1, count2: sizeint;
  Chr1, Chr2: byte;
  P1, P2: PChar;
begin
  Count1 := Length(S1);
  Count2 := Length(S2);
  if (Count1>Count2) then
    Count := Count2
  else
    Count := Count1;
  i := 0;
  if count>0 then
    begin
      P1 := @S1[1];
      P2 := @S2[1];
      while i < Count do
        begin
          Chr1 := byte(p1^);
          Chr2 := byte(p2^);
          if Chr1 <> Chr2 then
            begin
              if Chr1 in [97..122] then
                dec(Chr1,32);
              if Chr2 in [97..122] then
                dec(Chr2,32);
              if Chr1 <> Chr2 then
                Break;
            end;
          Inc(P1); Inc(P2); Inc(I);
        end;
    end;
  if i < Count then
    result := Chr1-Chr2
  else
    // CAPSIZEINT is no-op if Sizeof(Sizeint)<=SizeOF(Integer)
    result:=CAPSIZEINT(Count1-Count2);
end;
*/

.proc	@cmpSTRING

A	= :TMP		; ztmp8
B	= :TMP+2	; ztmp10

	ldy #0

	lda (ztmp10),y
	sta count2

	lda (ztmp8),y
	sta count1

	cmp count2
	scc
	lda count2
	sta count

	cmp #0
	beq stop

	inw ztmp8
	inw ztmp10

loop	lda (ztmp8),y
	sub (ztmp10),y
	bne fail

	iny

	cpy #0
count	equ *-1
	bne loop
stop
	ldy #1

	lda #0
count1	equ *-1
	sub #0
count2	equ *-1
	bcc fail

	rts

fail	php

	ldy #1

	plp
	rts
.endp
