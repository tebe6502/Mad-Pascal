; JAVA IEEE-32 (IEEE-754)
; David Schmenk
; https://sourceforge.net/projects/vm02/
; http://vm02.cvs.sourceforge.net/viewvc/vm02/vm02/src/
; changes: 2024-04-06

/*

  @NEGINT
  @FFRAC
  @FROUND
  @FSUB
  @FPNORM
  @FMUL
  @FDIV
  @FCMPL
  @F2I
  @I2F

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
  SBC FPMAN0
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

RESULT  = FPMAN0

A = FPMAN0

  LDA FPMAN0
  STA FP2MAN0
  LDA FPMAN1
  STA FP2MAN1
  LDA FPMAN2
  STA FP2MAN2
  LDA FPMAN3
  EOR #$80
  STA FP2MAN3

  JSR @F2I
  JSR @I2F

  LDA FPMAN0
  STA FP1MAN0
  LDA FPMAN1
  STA FP1MAN1
  LDA FPMAN2
  STA FP1MAN2
  LDA FPMAN3
  EOR #$80
  STA FP1MAN3

  JMP @FSUB
.endp


.proc @FROUND

RESULT  = FPMAN0

A = FP2MAN0

  LDA FP2MAN2
  CMP #$80    ; SET CARRY FROM MSB
  ORA #$80    ; SET HIDDEN BIT
  STA FP2MAN2

  LDA FP2MAN3
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
  ;LDA  #$00
  STA FP1MAN0
  STA FP1MAN1
  CLC
  LDA #$80    ; SET HIDDEN BIT
  STA FP1MAN2

  LDA FP2MAN3
  AND #$80
  ORA #$3F    ; 0.5 / -0.5

  JSR @FSUB.ENTER

  JMP @F2I
.endp


.proc @FADD
  mva #MATH_ADD      NEOMESSAGE_FUNC

  lda #VAR_FLOAT
  sta VAR1_TYPE
  sta VAR2_TYPE

  mva #STACK_ADDRESS NEOMESSAGE_PAR1W
  mva #STACK_SIZE2   NEOMESSAGE_PAR2W
  stz NEOMESSAGE_PAR1W+1
  stz NEOMESSAGE_PAR2W+1
  jsr @WaitMessage
  mva #MATH_GROUP    NEOMESSAGE_GROUP

  rts
.endp


.proc @FSUB
  mva #MATH_SUB      NEOMESSAGE_FUNC

  lda #VAR_FLOAT
  sta VAR1_TYPE
  sta VAR2_TYPE

  mva #STACK_ADDRESS NEOMESSAGE_PAR1W
  mva #STACK_SIZE2   NEOMESSAGE_PAR2W
  stz NEOMESSAGE_PAR1W+1
  stz NEOMESSAGE_PAR2W+1
  jsr @WaitMessage
  mva #MATH_GROUP    NEOMESSAGE_GROUP

  rts

;workaround
ENTER ROL
  STA FP1EXP

  stx @rx

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

  LDA FP2MAN0
  STA FPMAN0
  LDA FP2MAN1
  STA FPMAN1
  LDA FP2MAN2
  STA FPMAN2
  LDA FP2MAN3
  JMP EXIT

FP1SHFT:
  CMP #$80    ; SHIFT FP1 DOWN
  ROR
  ROR FP1MAN2
  ROR FP1MAN1
  ROR FP1MAN0
  DEY
  BNE FP1SHFT
  STA FP1MAN3
  JMP @FADDMAN

@ TAY
  LDA FP2MAN3
  CPY #24   ; KEEP SHIFT RANGE VALID
  BCC FP2SHFT

  LDA FP1MAN0
  STA FPMAN0
  LDA FP1MAN1
  STA FPMAN1
  LDA FP1MAN2
  STA FPMAN2
  LDA FP1MAN3
  JMP EXIT

FP2SHFT:
  CMP #$80    ; SHIFT FP2 DOWN
  ROR
  ROR FP2MAN2
  ROR FP2MAN1
  ROR FP2MAN0
  DEY
  BNE FP2SHFT
  STA FP2MAN3
@FADDMAN:
  LDA FP1MAN0
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
EXIT:
  STA FPMAN3
  BPL @FPNORM

  LDA #$80
  STA FPSGN

  JSR @NEGINT

  JMP @FPNORM
.endp


.proc @FPNORM

RESULT  = FPMAN0

MIN_EXPONENT  = 10
MAX_EXPONENT  = 255

  BEQ FPNORMLEFT  ; NORMALIZE FP, A = FPMANT3
FPNORMRIGHT:
  INC FPEXP
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
  ASL FPMAN2

  JMP EXIT

/*
  LDA FPEXP
  LSR
  ORA FPSGN

  STA FPMAN3
  ROR FPMAN2

  ;lda FPMAN3
  asl @
  tay
  lda FPMAN2
  spl
  iny
  cpy #MIN_EXPONENT ; to small 6.018531E-36
  bcc zero
  cpy #MAX_EXPONENT
  beq zero    ; number is infinity (if the mantissa is zero) or a NaN (if the mantissa is non-zero)

  rts
*/

FPNORMLEFT:
  LDA FPMAN2
  BNE FPNORMLEFT1
  LDA FPMAN1
  BNE FPNORMLEFT8
  LDA FPMAN0
  BNE FPNORMLEFT16

zero  LDA #$00    ; RESULT IS ZERO

  STA FPMAN0
  STA FPMAN1
  STA FPMAN2
  STA FPMAN3

  ldx @rx

  RTS

FPNORMLEFT16:
  TAY
  LDA FPEXP
  SEC
  SBC #$10
  STA FPEXP
  LDA #$00
  STA FPMAN1
  STA FPMAN0
  TYA
  BNE FPNORMLEFT1
FPNORMLEFT8:
  TAY
  LDA FPMAN0
  STA FPMAN1
  LDA FPEXP
  SEC
  SBC #$08
  STA FPEXP
  LDA #$00
  STA FPMAN0
  TYA
FPNORMLEFT1:
  BMI FPNORMDONE
@ DEC FPEXP
  ASL FPMAN0
  ROL FPMAN1
  ROL
  BPL @-
FPNORMDONE:
  ASL
  STA FPMAN2
EXIT:
  LDA FPEXP
  LSR
  ORA FPSGN

  STA FPMAN3
  ROR FPMAN2

  ;lda FPMAN3
  asl @
  tay
  lda FPMAN2
  spl
  iny
  cpy #MIN_EXPONENT ; to small 6.018531E-36
  bcc zero
  cpy #MAX_EXPONENT
  beq zero    ; number is infinity (if the mantissa is zero) or a NaN (if the mantissa is non-zero)

  ldx @rx

  RTS
.endp


.proc @FMUL
  mva #MATH_MUL      NEOMESSAGE_FUNC

  lda #VAR_FLOAT
  sta VAR1_TYPE
  sta VAR2_TYPE

  mva #STACK_ADDRESS NEOMESSAGE_PAR1W
  mva #STACK_SIZE2   NEOMESSAGE_PAR2W
  stz NEOMESSAGE_PAR1W+1
  stz NEOMESSAGE_PAR2W+1
  jsr @WaitMessage
  mva #MATH_GROUP    NEOMESSAGE_GROUP

  rts
.endp


.proc @FDIV
  mva #MATH_FDIV     NEOMESSAGE_FUNC

  lda #VAR_FLOAT
  sta VAR1_TYPE
  sta VAR2_TYPE

  mva #STACK_ADDRESS NEOMESSAGE_PAR1W
  mva #STACK_SIZE2   NEOMESSAGE_PAR2W
  stz NEOMESSAGE_PAR1W+1
  stz NEOMESSAGE_PAR2W+1
  jsr @WaitMessage
  mva #MATH_GROUP    NEOMESSAGE_GROUP

  rts
.endp


.proc @FCMPL

A = eax
B = ecx

FCMPG:
  CLV

  LDA A+3   ; COMPARE SIGNS
  AND #$80
  STA FP2SGN
  LDA B+3
  AND #$80
  CMP FP2SGN
  BCC FCMPGTSGN
  BEQ @+
  BCS FCMPLTSGN
@ LDA B+3    ; COMPARE AS MAGNITUDE
  CMP A+3
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA B+2
  CMP A+2
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA B+1
  CMP A+1
  BCC FCMPLT
  BEQ @+
  BCS FCMPGT
@ LDA B+0
  CMP A+0
  BCC FCMPLT
  BEQ FCMPEQ
  BCS FCMPGT
FCMPEQ: LDA #$00    ; EQUAL
  RTS

FCMPGT: LDA FP2SGN    ; FLIP RESULT IF NEGATIVE #S
  BMI FCMPLTSGN
FCMPGTSGN:
  LDA #$01    ; GREATER THAN
  RTS

FCMPLT: LDA FP2SGN    ; FLIP RESULT IF NEGATIVE #S
  BMI FCMPGTSGN
FCMPLTSGN:
  LDA #$FF    ; LESS THAN
  RTS
.endp


.proc @F2I

RESULT  = FPMAN0

A = FPMAN0

  LDA FPMAN2
  CMP #$80    ; SET CARRY FROM MSB
  ORA #$80    ; SET HIDDEN BIT
  STA FPMAN2

  LDA FPMAN3
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
  STA RESULT
  STA RESULT+1
  STA RESULT+2
  STA RESULT+3
  RTS

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
F2ICHKNEG:
  LDA FPSGN
  BPL @+    ; CHECK FOR NEGATIVE

  JMP @NEGINT
@
  RTS

F2ISHL: CMP #32
  BCC @+

  LDA #$FF    ; OVERFLOW, STORE MAXINT
  STA FPMAN0
  STA FPMAN1
  STA FPMAN2
  LSR
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
  ROL
  DEY
  BNE @-
  STA FPMAN3
  BEQ F2ICHKNEG
.endp


.proc @I2F

RESULT  = FPMAN0

A = FPMAN0

  stx @rx

  LDA FPMAN3
  AND #$80
  STA FPSGN
  BPL @+
  JSR @NEGINT
@ LDA #$7F+23
  STA FPEXP

  LDA FPMAN3
  JMP @FPNORM
.endp
