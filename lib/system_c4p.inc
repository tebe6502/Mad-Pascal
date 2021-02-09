procedure Pause; assembler; overload;
(*
@description:
Delay program execution (1/50 second).
*)
asm
{ lda:cmp:req :c4p_time+2
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
loop  lda n
  ora n+1
  beq stop

  lda:cmp:req :c4p_time+2

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
{ mva ted_timer_1 RndSeed
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
 lda ted_timer_1
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
 lda ted_timer_1
 and #$7f
 sta Result+2
 mva ted_timer_1 Result+1

 lda #$00
 sta Result
 lda #$3f
 sta Result+3
};

 Result:= 1 - Result;

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
  lda ted_timer_1   //Timer A Lo byte
  eor ted_timer_1+1 //Timer A Hi byte
  eor ted_timer_2   //Timer B Lo byte
  adc ted_hcount    //Horizontal counter
  eor ted_timer_3   //Timer C Lo byte
  eor ted_hcount    //Horizontal counter
  tay

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
