N6502MSG_ADDRESS              = $FF00
NEOMESSAGE_GROUP              = N6502MSG_ADDRESS+0
NEOMESSAGE_FUNC               = N6502MSG_ADDRESS+1
NEOMESSAGE_PAR1W              = N6502MSG_ADDRESS+4
NEOMESSAGE_PAR2W              = N6502MSG_ADDRESS+6
NEOMESSAGE_PAR3W              = N6502MSG_ADDRESS+8
STACK_ADDRESS                 = $F5
STACK_SIZE2                   = 2
STACK_SIZE1                   = 1


VAR_FLOAT                     = $40
VAR_INTEGER                   = 0

VAR0_TYPE                     = STACK_ADDRESS
VAR1_TYPE                     = STACK_ADDRESS
VAR2_TYPE                     = STACK_ADDRESS+1

VAR0_B0                       = STACK_ADDRESS+1
VAR0_B1                       = STACK_ADDRESS+2
VAR0_B2                       = STACK_ADDRESS+3
VAR0_B3                       = STACK_ADDRESS+4

VAR1_B0                       = STACK_ADDRESS+2
VAR1_B1                       = STACK_ADDRESS+4
VAR1_B2                       = STACK_ADDRESS+6
VAR1_B3                       = STACK_ADDRESS+8

VAR2_B0                       = STACK_ADDRESS+3
VAR2_B1                       = STACK_ADDRESS+5
VAR2_B2                       = STACK_ADDRESS+7
VAR2_B3                       = STACK_ADDRESS+9

VAR0                          = VAR0_B0
VAR1                          = VAR1_B0
VAR2                          = VAR2_B0

MATH_GROUP                    = 4

MATH_ADD                      = 0; Add
MATH_SUB                      = 1; Subtract
MATH_MUL                      = 2; Multiply
MATH_FDIV                     = 3; Float Divide
MATH_IDIV                     = 4; Int Divide
MATH_MOD                      = 5; Int Modulus
MATH_CMP                      = 6; Compare

MATH_NEG                      = 16; Unary Negate
MATH_FLR                      = 17; Floor (integer part)
MATH_SQR                      = 18; Square root
MATH_SIN                      = 19; Sine
MATH_COS                      = 20; Cosine
MATH_TAN                      = 21; Tangent
MATH_ATAN                     = 22; Arc Tangent
MATH_EXP                      = 23; Exponent
MATH_LOG                      = 24; Logarithm (e)
MATH_ABS                      = 25; Absolute value
MATH_SGN                      = 26; Sign
MATH_FRND                     = 27; Random (float)
MATH_IRND                     = 28; Random (integer)

MATH_PROCESS_DECIMAL          = 32; Append BCD encoded decimal digits, convert to float
MATH_CONVERT_STRING_TO_NUMBER = 33; String to int/float
MATH_CONVERT_NUMBER_TO_STRING = 34; int/float to string