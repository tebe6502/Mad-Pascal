; JAVA IEEE-32 (IEEE-754)
; David Schmenk
; https://sourceforge.net/projects/vm02/
; http://vm02.cvs.sourceforge.net/viewvc/vm02/vm02/src/

/*

  @NEGINT
  @FFRAC
  @FROUND
* @FSUB
  @FPNORM
* @FMUL
* @FDIV
  @FCMPL
  @F2I
  @I2F
  @I2F_M

*/

/*
Here's a breakdown of the floating-point math abbreviations you've listed. These are likely part of an instruction set architecture (ISA) or assembly language conventions.

**Common Abbreviations**

* **NEGINT:** Likely indicates "Negate Integer." Changes the sign of an integer value.
* **FFRAC:** Could mean "Floating-point Fraction." This might extract the fractional portion of a floating-point number.
* **FROUND:** "Floating-point Round." Rounds a floating-point number to a specified precision or rounding mode (e.g., round to nearest, round down, round up).
* **FSUB:** "Floating-point Subtract." Subtracts two floating-point values.
* **FPNORM:** "Floating-point Normalize." Adjusts the exponent of a floating-point number so the leading significant digit falls within a specific range, ensuring better precision in calculations.
* **FMUL:** "Floating-point Multiply." Multiplies two floating-point values.
* **FDIV:** "Floating-point Divide." Divides two floating-point values.
* **FCMPL:** "Floating-point Compare Less." Compares two floating-point numbers and sets flags/registers to indicate if the first operand is less than the second.  Similar instructions might exist for other comparisons (greater than, equal, etc.).
* **F2I:**  "Floating-point to Integer."  Converts a floating-point number to an integer, likely with truncation or rounding.
* **I2F:** "Integer to Floating-point."  Converts an integer value to a floating-point representation.

**Less Common/Context-Specific**

* **I2F_M:**  This might be a more specific variant of "Integer to Floating-point." The "_M" could denote a particular conversion method or rounding mode.  To be sure, we would need more context on where you encountered this abbreviation.

**Important Notes**

* The exact interpretation of some of these abbreviations might depend on the specific processor architecture or the programming language's assembly instructions.
* Floating-point instructions often have variations to handle different rounding modes, precisions (single vs. double), and to deal with special cases like NaNs (Not a Number) and infinities.

*/



/*
  org eax

FP1MAN0 .ds 1
FP1MAN1 .ds 1
FP1MAN2 .ds 1
FP1MAN3 .ds 1

  org ztmp8

FP1SGN  .ds 1
FP1EXP  .ds 1

  org edx

FP2MAN0 .ds 1
FP2MAN1 .ds 1
FP2MAN2 .ds 1
FP2MAN3 .ds 1

  org ztmp10

FP2SGN  .ds 1
FP2EXP  .ds 1

  org ecx

FPMAN0  .ds 1
FPMAN1  .ds 1
FPMAN2  .ds 1
FPMAN3  .ds 1

  org bp2

FPSGN .ds 1
FPEXP .ds 1

*/

@rx = bp+1


.proc @NEGINT

  LDA #$00
  SEC

enter SBC FPMAN0
  STA FPMAN0
  LDA #$00
  SBC FPMAN1
  STA FPMAN1
  LDA #$00
  SBC FPMAN2
  STA FPMAN2
  LDA #$00
  SBC FPMAN3
  STA FPMAN3
  RTS
.endp


.proc @FFRAC
  inx
  lda :STACKORIGIN-1,x
  sta :STACKORIGIN,x

  lda :STACKORIGIN-1+STACKWIDTH,x
  sta :STACKORIGIN+STACKWIDTH,x

  lda :STACKORIGIN-1+STACKWIDTH*2,x
  sta :STACKORIGIN+STACKWIDTH*2,x

  lda :STACKORIGIN-1+STACKWIDTH*3,x
  eor #$80
  sta :STACKORIGIN+STACKWIDTH*3,x

  dex

  jsr @F2I
  jsr @I2F

  lda :STACKORIGIN+STACKWIDTH*3,x
  eor #$80
  sta :STACKORIGIN+STACKWIDTH*3,x

  inx

  jsr @FSUB

  dex

  rts
.endp


.proc @FROUND
; LDA #$00
; STA FP2SGN

  lda :STACKORIGIN,x
  STA FP2MAN0
  lda :STACKORIGIN+STACKWIDTH,x
  STA FP2MAN1
  lda :STACKORIGIN+STACKWIDTH*2,x
  CMP #$80    ; SET CARRY FROM MSB
  ORA #$80    ; SET HIDDEN BIT
  STA FP2MAN2
  lda :STACKORIGIN+STACKWIDTH*3,x
; EOR FP2SGN    ; TOGGLE SIGN FOR FSUB
  ROL
  STA FP2EXP
  LDA #$00
  STA FPSGN
  BCC @+
  SBC FP2MAN0
  STA FP2MAN0
  LDA #$00
  SBC FP2MAN1
  STA FP2MAN1
  LDA #$00
  SBC FP2MAN2
  STA FP2MAN2
  LDA #$FF
@ STA FP2MAN3
  lda #$00
  STA FP1MAN0
  STA FP1MAN1
  CMP #$80    ; SET CARRY FROM MSB
  ORA #$80    ; SET HIDDEN BIT
  STA FP1MAN2

  lda :STACKORIGIN+STACKWIDTH*3,x
  and #$80
  ora #$3f    ; 0.5 / -0.5

  inx

  jsr @FSUB.enter

  dex

  rts
.endp


.proc @FSUB
  mva #VAR_FLOAT STACK_ADDRESS
  mva :STACKORIGIN,x                VAR2_B1
  mva :STACKORIGIN+STACKWIDTH,x     VAR2_B2
  mva :STACKORIGIN+STACKWIDTH*2,x   VAR2_B3
  mva :STACKORIGIN+STACKWIDTH*3,x   VAR2_B4

  mva #VAR_FLOAT STACK_ADDRESS+1
  mva :STACKORIGIN-1,x              VAR1_B1
  mva :STACKORIGIN-1+STACKWIDTH,x   VAR1_B2
  mva :STACKORIGIN-1+STACKWIDTH*2,x VAR1_B3
  mva :STACKORIGIN-1+STACKWIDTH*3,x VAR1_B4
  mva #STACK_ADDRESS NEOMESSAGE_PAR1W
  mva #STACK_SIZE    NEOMESSAGE_PAR2W
  jsr @WaitMessage
  mva #MATH_SUB      NEOMESSAGE_FUNC
  mva #4             NEOMESSAGE_GROUP

  mva VAR1_B1 :STACKORIGIN-1,x
  mva VAR1_B2 :STACKORIGIN-1+STACKWIDTH,x
  mva VAR1_B3 :STACKORIGIN-1+STACKWIDTH*2,x
  mva VAR1_B4 :STACKORIGIN-1+STACKWIDTH*3,x
  rts

FADD
  mva #VAR_FLOAT STACK_ADDRESS
  mva :STACKORIGIN,x                VAR2_B1
  mva :STACKORIGIN+STACKWIDTH,x     VAR2_B2
  mva :STACKORIGIN+STACKWIDTH*2,x   VAR2_B3
  mva :STACKORIGIN+STACKWIDTH*3,x   VAR2_B4

  mva #VAR_FLOAT STACK_ADDRESS+1
  mva :STACKORIGIN-1,x              VAR1_B1
  mva :STACKORIGIN-1+STACKWIDTH,x   VAR1_B2
  mva :STACKORIGIN-1+STACKWIDTH*2,x VAR1_B3
  mva :STACKORIGIN-1+STACKWIDTH*3,x VAR1_B4

  mva #STACK_ADDRESS NEOMESSAGE_PAR1W
  mva #STACK_SIZE    NEOMESSAGE_PAR2W
  jsr @WaitMessage
  mva #MATH_ADD      NEOMESSAGE_FUNC
  mva #4             NEOMESSAGE_GROUP

  mva VAR1_B1 :STACKORIGIN-1,x
  mva VAR1_B2 :STACKORIGIN-1+STACKWIDTH,x
  mva VAR1_B3 :STACKORIGIN-1+STACKWIDTH*2,x
  mva VAR1_B4 :STACKORIGIN-1+STACKWIDTH*3,x
  rts

enter
  ROL
  STA FP1EXP
  LDA #$00
  BCC @+
  SBC FP1MAN0
  STA FP1MAN0
  LDA #$00
  SBC FP1MAN1
  STA FP1MAN1
  LDA #$00
  SBC FP1MAN2
  STA FP1MAN2
  LDA #$FF
@ STA FP1MAN3
  LDA FP1EXP    ; CALCULATE WHICH MANTISSA TO SHIFT
  STA FPEXP
  SEC
  SBC FP2EXP
  BEQ @FADDMAN
  BCS @+
  EOR #$FF
  TAY
  INY
  LDA FP2EXP
  STA FPEXP
  LDA FP1MAN3
  CPY #24   ; KEEP SHIFT RANGE VALID
  BCC FP1SHFT
  LDA #$00
  STA FP1MAN3
  STA FP1MAN2
  STA FP1MAN1
  STA FP1MAN0
  BEQ @FADDMAN
FP1SHFT:  CMP #$80  ; SHIFT FP1 DOWN
  ROR
  ROR FP1MAN2
  ROR FP1MAN1
  ROR FP1MAN0
  DEY
  BNE FP1SHFT
  STA FP1MAN3
  BRA @FADDMAN

@ TAY
  LDA FP2MAN3
  CPY #24   ; KEEP SHIFT RANGE VALID
  BCC FP2SHFT
  LDA #$00
  STA FP2MAN3
  STA FP2MAN2
  STA FP2MAN1
  STA FP2MAN0
  BEQ @FADDMAN
FP2SHFT:  CMP #$80  ; SHIFT FP2 DOWN
  ROR
  ROR FP2MAN2
  ROR FP2MAN1
  ROR FP2MAN0
  DEY
  BNE FP2SHFT
  STA FP2MAN3
@FADDMAN: LDA FP1MAN0
  CLC
  ADC FP2MAN0
  STA FPMAN0
  LDA FP1MAN1
  ADC FP2MAN1
  STA FPMAN1
  LDA FP1MAN2
  ADC FP2MAN2
  STA FPMAN2
  LDA FP1MAN3
  ADC FP2MAN3
  STA FPMAN3
  BPL @FPNORM

  LDA #$80
  STA FPSGN

  JSR @NEGINT

  BRA @FPNORM
.endp

.proc @FPNORM

MIN_EXPONENT  = 10
MAX_EXPONENT  = 255


  BEQ FPNORMLEFT  ; NORMALIZE FP, A = FPMANT3
FPNORMRIGHT:  INC FPEXP
  LSR
  STA FPMAN3
  ROR FPMAN2
  ROR FPMAN1
  LDA FPMAN0
  ROR
  ADC #$00
  STA FPMAN0
  LDA FPMAN1
  ADC #$00
  STA FPMAN1
  LDA FPMAN2
  ADC #$00
  STA FPMAN2
  LDA FPMAN3
  ADC #$00
  BNE FPNORMRIGHT
  LDA FPEXP
  ASL FPMAN2
  LSR
  ORA FPSGN

; ldx @rx
  sta :STACKORIGIN-1+STACKWIDTH*3,x
  LDA FPMAN2
  ROR
  sta :STACKORIGIN-1+STACKWIDTH*2,x

  lda :STACKORIGIN-1+STACKWIDTH*3,x
  asl @
  tay
  lda :STACKORIGIN-1+STACKWIDTH*2,x
  spl
  iny
  cpy #MIN_EXPONENT ; to small 6.018531E-36
  bcc zero
  cpy #MAX_EXPONENT
  beq zero    ; number is infinity (if the mantissa is zero) or a NaN (if the mantissa is non-zero)

  LDA FPMAN1
  sta :STACKORIGIN-1+STACKWIDTH,x
  LDA FPMAN0
  sta :STACKORIGIN-1,x
  rts

FPNORMLEFT: LDA FPMAN2
  BNE FPNORMLEFT1
  LDA FPMAN1
  BNE FPNORMLEFT8
  LDA FPMAN0
  BNE FPNORMLEFT16

; ldx @rx     ; RESULT IS ZERO
zero  lda #0

  sta :STACKORIGIN-1,x
  sta :STACKORIGIN-1+STACKWIDTH,x
  sta :STACKORIGIN-1+STACKWIDTH*2,x
  sta :STACKORIGIN-1+STACKWIDTH*3,x
  rts

FPNORMLEFT16: TAY
  LDA FPEXP
  SEC
  SBC #$10
  STA FPEXP
  LDA #$00
  STA FPMAN1
  STA FPMAN0
  TYA
  BNE FPNORMLEFT1
FPNORMLEFT8:  TAY
  LDA FPMAN0
  STA FPMAN1
  LDA FPEXP
  SEC
  SBC #$08
  STA FPEXP
  LDA #$00
  STA FPMAN0
  TYA
FPNORMLEFT1:  BMI FPNORMDONE
@ DEC FPEXP
  ASL FPMAN0
  ROL FPMAN1
  ROL
  BPL @-
FPNORMDONE: ASL
  TAY
  LDA FPEXP
  LSR
  ORA FPSGN

; ldx @rx
  sta :STACKORIGIN-1+STACKWIDTH*3,x
  TYA
  ROR
  sta :STACKORIGIN-1+STACKWIDTH*2,x

  lda :STACKORIGIN-1+STACKWIDTH*3,x
  asl @
  tay
  lda :STACKORIGIN-1+STACKWIDTH*2,x
  spl
  iny
  cpy #MIN_EXPONENT ; to small 6.018531E-36
  bcc zero
  cpy #MAX_EXPONENT
  beq zero    ; number is infinity (if the mantissa is zero) or a NaN (if the mantissa is non-zero)

  LDA FPMAN1
  sta :STACKORIGIN-1+STACKWIDTH,x
  LDA FPMAN0
  sta :STACKORIGIN-1,x

  rts
.endp


.proc @FMUL
  ;value eq 13
  ;0 10000010 10100000000000000000000
  ;Sign bit: 0 (positive)
  ;Exponent bits: 10000010 (130 in decimal)
  ;Mantissa bits: 10100000000000000000000
  ;01000001 #$41 => STA :STACKORIGIN-1+STACKWIDTH*3,x
  ;01010000 #$50 => STA :STACKORIGIN-1+STACKWIDTH*2,x
  ;00000000 #$00 => STA :STACKORIGIN-1+STACKWIDTH,x
  ;00000000 #$00 => STA :STACKORIGIN-1,x

  ;SetMathStack(var1,0);
  mva #VAR_FLOAT STACK_ADDRESS
  mva :STACKORIGIN,x                VAR1_B1
  mva :STACKORIGIN+STACKWIDTH,x     VAR1_B2
  mva :STACKORIGIN+STACKWIDTH*2,x   VAR1_B3
  mva :STACKORIGIN+STACKWIDTH*3,x   VAR1_B4

  ;SetMathStack(var2,1);
  mva #VAR_FLOAT STACK_ADDRESS+1
  mva :STACKORIGIN-1,x              VAR2_B1
  mva :STACKORIGIN-1+STACKWIDTH,x   VAR2_B2
  mva :STACKORIGIN-1+STACKWIDTH*2,x VAR2_B3
  mva :STACKORIGIN-1+STACKWIDTH*3,x VAR2_B4

  ;DoMathOnStack(MATHMul);
  mva #STACK_ADDRESS NEOMESSAGE_PAR1W ; wordParams[0] := STACK_ADDRESS
  mva #STACK_SIZE    NEOMESSAGE_PAR2W ; NeoMessage.params[2] := STACK_SIZE
  jsr @WaitMessage                    ; NeoWaitMessage
  mva #MATH_MUL      NEOMESSAGE_FUNC  ; NeoMessage.func := MATHMul
  mva #4             NEOMESSAGE_GROUP ; NeoMessage.group := 4

  ;GetMathStackFloat;
  mva VAR1_B1 :STACKORIGIN-1,x
  mva VAR1_B2 :STACKORIGIN-1+STACKWIDTH,x
  mva VAR1_B3 :STACKORIGIN-1+STACKWIDTH*2,x
  mva VAR1_B4 :STACKORIGIN-1+STACKWIDTH*3,x
  rts
.endp

; --------------------------

.proc @FDIV
  mva #VAR_FLOAT STACK_ADDRESS
  mva :STACKORIGIN,x                VAR2_B1
  mva :STACKORIGIN+STACKWIDTH,x     VAR2_B2
  mva :STACKORIGIN+STACKWIDTH*2,x   VAR2_B3
  mva :STACKORIGIN+STACKWIDTH*3,x   VAR2_B4

  mva #VAR_FLOAT STACK_ADDRESS+1
  mva :STACKORIGIN-1,x              VAR1_B1
  mva :STACKORIGIN-1+STACKWIDTH,x   VAR1_B2
  mva :STACKORIGIN-1+STACKWIDTH*2,x VAR1_B3
  mva :STACKORIGIN-1+STACKWIDTH*3,x VAR1_B4

  mva #STACK_ADDRESS NEOMESSAGE_PAR1W
  mva #STACK_SIZE    NEOMESSAGE_PAR2W
  jsr @WaitMessage
  mva #MATH_FDIV     NEOMESSAGE_FUNC
  mva #4             NEOMESSAGE_GROUP

  mva VAR1_B1 :STACKORIGIN-1,x
  mva VAR1_B2 :STACKORIGIN-1+STACKWIDTH,x
  mva VAR1_B3 :STACKORIGIN-1+STACKWIDTH*2,x
  mva VAR1_B4 :STACKORIGIN-1+STACKWIDTH*3,x
  rts
.endp


.proc @FCMPL

A = :FP1MAN0
B = :FPMAN0

FCMPG:
  CLV

  LDA :FP1MAN3      ; COMPARE SIGNS
  AND #$80
  STA FP2SGN
  LDA :FPMAN3
  AND #$80
  CMP FP2SGN
  BCC FCMPGTSGN
  BEQ @+
  BCS FCMPLTSGN
@ LDA :FPMAN3       ; COMPARE AS MAGNITUDE
  CMP :FP1MAN3
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA :FPMAN2
  CMP :FP1MAN2
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA :FPMAN1
  CMP :FP1MAN1
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA :FPMAN0
  CMP :FP1MAN0
  BCC FCMPLT
  BEQ FCMPEQ
  BCS FCMPGT
FCMPEQ: LDA #0      ; EQUAL
  RTS

FCMPGT: LDA FP2SGN    ; FLIP RESULT IF NEGATIVE #S
  BMI FCMPLTSGN
FCMPGTSGN:  LDA #$01  ; GREATER THAN
  RTS

FCMPLT: LDA FP2SGN    ; FLIP RESULT IF NEGATIVE #S
  BMI FCMPGTSGN
FCMPLTSGN:  LDA #$FF  ; LESS THAN
  RTS
.endp


/*
.proc @FCMPL
FCMPG:
  CLV

  LDA :STACKORIGIN+STACKWIDTH*3,X ; COMPARE SIGNS
  AND #$80
  STA FP2SGN
  LDA :STACKORIGIN-1+STACKWIDTH*3,X
  AND #$80
  CMP FP2SGN
  BCC FCMPGTSGN
  BEQ @+
  BCS FCMPLTSGN
@ LDA :STACKORIGIN-1+STACKWIDTH*3,X ; COMPARE AS MAGNITUDE
  CMP :STACKORIGIN+STACKWIDTH*3,X
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA :STACKORIGIN-1+STACKWIDTH*2,X
  CMP :STACKORIGIN+STACKWIDTH*2,X
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA :STACKORIGIN-1+STACKWIDTH,X
  CMP :STACKORIGIN+STACKWIDTH,X
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA :STACKORIGIN-1,X
  CMP :STACKORIGIN,X
  BCC FCMPLT
  BEQ FCMPEQ
  BCS FCMPGT
FCMPEQ: LDA #0      ; EQUAL
  RTS

FCMPGT: LDA FP2SGN    ; FLIP RESULT IF NEGATIVE #S
  BMI FCMPLTSGN
FCMPGTSGN:  LDA #$01  ; GREATER THAN
  RTS

FCMPLT: LDA FP2SGN    ; FLIP RESULT IF NEGATIVE #S
  BMI FCMPGTSGN
FCMPLTSGN:  LDA #$FF  ; LESS THAN
  RTS
.endp
*/


.proc @F2I

  lda :STACKORIGIN,x
  STA FPMAN0
  lda :STACKORIGIN+STACKWIDTH,x
  STA FPMAN1
  lda :STACKORIGIN+STACKWIDTH*2,x
  CMP #$80    ; SET CARRY FROM MSB
  ORA #$80    ; SET HIDDEN BIT
  STA FPMAN2
  lda :STACKORIGIN+STACKWIDTH*3,x
  ROL @
  STA FPEXP
  LDA #$00
  ROR @
  STA FPSGN
  LDA FPEXP   ; CHECK FOR LESS THAN ONE
  SEC
  SBC #$7F
  BCS @+

ZERO: LDA #$00    ; RETURN ZERO
  STA :STACKORIGIN,x
  STA :STACKORIGIN+STACKWIDTH,x
  STA :STACKORIGIN+STACKWIDTH*2,x
  STA :STACKORIGIN+STACKWIDTH*3,x
  rts

@ CMP #23
  BCS F2ISHL
  STA FPEXP
  LDA #23
  SEC
  SBC FPEXP
  TAY     ; SHIFT MANTISSA RIGHT
  LDA FPMAN2
F2ISHR: LSR @
  ROR FPMAN1
  ROR FPMAN0
  DEY
  BNE F2ISHR
  STA FPMAN2
  STY FPMAN3
F2ICHKNEG:  LDA FPSGN
  BPL @+    ; CHECK FOR NEGATIVE
  ASL @   ; LDA #$00; SEC

  JSR @NEGINT.enter

@ LDA FPMAN3
  STA :STACKORIGIN+STACKWIDTH*3,x
  LDA FPMAN2
  STA :STACKORIGIN+STACKWIDTH*2,x
  LDA FPMAN1
  STA :STACKORIGIN+STACKWIDTH,x
  LDA FPMAN0
  STA :STACKORIGIN,x
  rts

F2ISHL: CMP #32
  BCC @+
  LDA #$FF    ; OVERFLOW, STORE MAXINT
  STA FPMAN0
  STA FPMAN1
  STA FPMAN2
  LSR @
  STA FPMAN3
  BNE F2ICHKNEG
@ SEC
  SBC #23
  BNE @+
  STA FPMAN3
  BEQ F2ICHKNEG
@ TAY     ; SHIFT MANTISSA LEFT
  LDA #$00
@ ASL FPMAN0
  ROL FPMAN1
  ROL FPMAN2
  ROL @
  DEY
  BNE @-
  STA FPMAN3
  BEQ F2ICHKNEG
.endp


.proc @I2F

  lda :STACKORIGIN,x
  STA FPMAN0
  lda :STACKORIGIN+STACKWIDTH,x
  STA FPMAN1
  lda :STACKORIGIN+STACKWIDTH*2,x
  STA FPMAN2
  lda :STACKORIGIN+STACKWIDTH*3,x
  STA FPMAN3
  AND #$80
  STA FPSGN
  BPL @+
; LDX #FPMAN0
  JSR @NEGINT
@ LDA #$7F+23
  STA FPEXP

  inx     ; ten zabieg zapisze pod :STACKORIGIN,x
        ; zamiast :STACKORIGIN-1,x
  LDA FPMAN3
  JSR @FPNORM

  dex
  rts
.endp


.proc @I2F_M

  lda :STACKORIGIN-1,x
  STA FPMAN0
  lda :STACKORIGIN-1+STACKWIDTH,x
  STA FPMAN1
  lda :STACKORIGIN-1+STACKWIDTH*2,x
  STA FPMAN2
  lda :STACKORIGIN-1+STACKWIDTH*3,x

  STA FPMAN3
  AND #$80
  STA FPSGN
  BPL @+
; LDX #FPMAN0
  JSR @NEGINT
@ LDA #$7F+23
  STA FPEXP

  LDA FPMAN3
  JMP @FPNORM
.endp
