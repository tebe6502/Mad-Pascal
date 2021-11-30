
procedure Pause; assembler; overload;
(*
@description:
Delay program execution (1/50 second).
*)
asm
	lda:cmp:req :rtclok+2
end;


procedure Pause(n: word); assembler; overload;
(*
@description:
Delay program execution (N * 1/50 second).

@param: N - number of '1/50 second'
*)
asm

loop	lda n
	ora n+1
	beq stop

	lda:cmp:req :rtclok+2

	dew n

	jmp loop
stop

end;


procedure Randomize; assembler;
(*
@description:
Initialize random number generator
*)
asm

  mva $d20a RndSeed
  mva #$00  RndSeed+1

end;


function Random: Real; overload;
(*
@description:
Generate random number

@returns: Real (Q24.8)
*)
begin

 asm

 lda $d20a
 sta Result

 lda #$00
 sta Result+1
 sta Result+2
 sta Result+3

 end;

 Result:= 1 - Result;

end;


function RandomF: Float;
(*
@description:
Generate random number

@returns: Float (Single)
*)
begin

 asm

 lda $d20a
 and #$7f
 sta Result+2
 mva $d20a Result+1

 lda #$00
 sta Result
 lda #$3f
 sta Result+3

 end;

 Result:= 1 - Result;

end;


function RandomF16: Float16;
(*
@description:
Generate random number

@returns: Float16 (Half-Single)
*)
var a: word;
begin

 asm
	lda $d20a
	and #$7f
	sta a+1

	lda $d20a
	sta a
 end;

 Result:= 0.000023725 * a;

end;


function Random(range: byte): byte; assembler; overload;
(*
@description:
Generate random number

@param: range (0..range-1)

@returns: byte
*)
asm

;BYTE FUNC Rand(BYTE range)
; returns random number between 0 and
; range-1.  If range=0, then a random
; number between 0 and 255 is returned

  ldy $d20a   ; RANDOM

  lda range
  beq stop

  sta ecx
  sty eax

  jsr imulCL
  tay

stop  sty Result

end;


function Random(range: smallint): smallint; overload;
(*
@description:
Generate random number

@param: range (0..range-1), (-range..0)

@returns: smallint
*)
begin

 if range = 0 then
  Result := 0
 else begin

  RndSeed := $4595 * RndSeed;
  Result := RndSeed mod range;

asm
{ lda range+1
  bpl plus

  lda Result+1
  bmi ok
  bpl sign

plus  lda Result+1
  bpl ok

sign  lda #0
  sub Result
  sta Result

  lda #0
  sbc Result+1
  sta Result+1
ok
};

  end;

end;

