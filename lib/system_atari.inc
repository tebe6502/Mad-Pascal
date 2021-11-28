
procedure Pause; assembler; overload;
(*
@description:
Delay program execution (1/50 second).
*)
asm
{	lda:cmp:req :rtclok+2
};
end;


procedure Pause(n: word); assembler; overload;
(*
@description:
Delay program execution (N * 1/50 second).

@param: N - number of '1/50 second'
*)
asm
{
loop	lda n
	ora n+1
	beq stop

	lda:cmp:req :rtclok+2

	dew n

	jmp loop
stop
};
end;

procedure Randomize; assembler;
(*
@description:
Initialize random number generator
*)
asm
{ mva $d20a RndSeed
  mva #$00  RndSeed+1
};
end;


function Random: Real; overload;
(*
@description:
Generate random number

@returns: Real (Q24.8)
*)
begin

asm
{
 lda $d20a
 sta Result

 lda #$00
 sta Result+1
 sta Result+2
 sta Result+3
};

 Result:= 1 - Result;

(*
asm
{ txa:pha

_t  = edx

  LDA #$0

  sta result+1
  sta result+2
  sta result+3

  STA _T
RAN1  INC _T
  JSR POLY
  CMP #$0
  BEQ RAN1
  ORA #$10
  ldy #0
;

RAN2  INY
  JSR POLY
  ROL @
  ROL @
  ROL @
  ROL @
  AND #$F0
  STA _T+1
  JSR POLY
  ORA _T+1
  STA result-1,y
; CPY #4
; BCC RAN2
; LDA _T
; INY
; STA result,y

  pla:tax

  jmp stop

POLY  TYA
  PHA
  LDY #$0
POLY1 INY
  CLC
  ROL POLYN
  ROL POLYN+1
  ROL POLYN+2
  ROL POLYN+3
  ROL POLYN+4
  ROL POLYN+5
  ROL POLYN+6
  ROL POLYN+7
  BCC POLY3
;
  LDX #$0
POLY2 LDA POLYN,X
  EOR GEN,X
  STA POLYN,X
  INX
  CPX #8
  BCC POLY2
  SEC
;
POLY3 ROL _T+2
  CPY #4
  BCC POLY1
;
  PLA
  TAY
  LDA _T+2
  AND #$0F
  CMP #$0A
  BCS POLY
  RTS
;
;
GEN dta a($A1)
  dta $A2,$1A,$A2,$91,$C3,$93,$C0
;
POLYN dta a($63)
  dta $42,$A1,$23,$55,$09,$03,$87

stop
};
*)

end;


function RandomF: Float;
(*
@description:
Generate random number

@returns: Float (Single)
*)
begin

asm
{
 lda $d20a
 and #$7f
 sta Result+2
 mva $d20a Result+1

 lda #$00
 sta Result
 lda #$3f
 sta Result+3
};

 Result:= 1 - Result;

end;


function RandomF16: Float16;
(*
@description:
Generate random number

@returns: Float16 (Half-Single)
*)
begin

asm
{
r0 lda #0
 eor $d20a
 sta Result
 
 sta r0+1
lp
r1 adc #0
 adc $d20a
 
 sta r1+1

 
 and #$7f
 ora #$3c
 
 and #$7c
 cmp #$7c
 beq lp

 sta Result+1
 
};

 Result:= Result - 1;

end;


function Random(range: byte): byte; assembler; overload;
(*
@description:
Generate random number

@param: range (0..range-1)

@returns: byte
*)
asm
{
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
};
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

