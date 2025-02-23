unit neo6502math;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Neo6502 API library for RP2040 accelerated Math and other computations.
* @version: 0.30.0

* @description:
* Set of procedures to cover Math API functionality.
*
* WARNING!
*
* This library uses 15 bytes on ZP ($F0-$FE)
*
* More about Neo6502:
*
* <https://www.olimex.com/Products/Retro-Computers/Neo6502/open-source-hardware>
*
* <https://www.neo6502.com/>

*
* API documentation can be found here:
*
* <https://github.com/paulscottrobson/neo6502-firmware/wiki>

*
* It's work in progress, so please report any bugs you will find.
*
*)
interface
uses neo6502;

const
    N6502MSG_ADDRESS = $ff00;
	MATHAdd = 0; 					// Add
	MATHSub = 1; 					// Subtract
	MATHMul = 2; 					// Multiply
	MATHFDiv = 3;					// Float Divide
	MATHIDiv = 4;					// Int Divide
	MATHMod = 5; 					// Int Modulus
    MATHCmp = 6; 					// Compare
    MATHPow = 7;                    // Power
    MATHDist = 8;                   // Distance (counter-rectangle)

    MATHNeg = 16;                   // Unary Negate
    MATHFlr = 17;                   // Floor (integer part)
    MATHSqr = 18;                   // Square root
    MATHSin = 19;                   // Sine
    MATHCos = 20;                   // Cosine
    MATHTan = 21;                   // Tangent
    MATHATan = 22;                  // Arc Tangent
    MATHExp = 23;                   // Exponent
    MATHLog = 24;                   // Logarithm (e)
    MATHAbs = 25;                   // Absolute value
    MATHSgn = 26;                   // Sign
    MATHFRnd = 27;                  // Random (float)
    MATHIRnd = 28;                  // Random (integer)

	MATHProcessDecimal = 32; 		// Append BCD encoded decimal digits, convert to float
    MATHConvertStringToNumber = 33; // String to int/float
	MATHConvertNumberToString = 34; // int/float to string
    MATHSetDegRad = 35;             // Sets the use of degrees (the default) when non zero, radians when zero.

    STACK_SIZE = 2;      // binary operations stack size
    VAR_ADDRESS = $F0;   // unary operations variable address (5 bytes)
    STACK_ADDRESS = $F5; // binary operations stack address (STACK_SIZE * 5 bytes)

var
    m_integer: integer absolute VAR_ADDRESS+1; // integer value returned from unary operations
    m_float: float absolute VAR_ADDRESS+1; // float value returned from unary operations

procedure SetMathStack(v:float;i:byte);assembler;overload;register;
(*
* @description:
* Inserts float value to the Math stack at the specified position.
*
* @param: v (float) - value to be inserted
* @param: i (byte) - stack position
*
*)
procedure SetMathStack(v:integer;i:byte);assembler;overload;register;
(*
* @description:
* Inserts integer value to the Math stack at the specified position.
*
* @param: v (integer) - value to be inserted
* @param: i (byte) - stack position
*
*)
function GetMathStackFloat:float;assembler;
(*
* @description:
* Returns float value from Math stack at position 0
*
* @returns: (float) - value at position ptr represented as an float
*)
function GetMathStackInt:integer;assembler;
(*
* @description:
* Returns integer value from Math stack at position 0
*
* @returns: (integer) - value at position ptr represented as an float
*)
function IsFloatOnStack(i:byte):boolean;
(*
* @description:
* Returns true if at desired position on the Math Stack float value is found.
*
* @param: i (byte) - stack position
*
* @returns: (boolean) - returns true if float
*)
function IsFloatVal:boolean;
(*
* @description:
* Returns true if float value is located at MathVar.
*
* @returns: (boolean) - returns true if float
*)
procedure SetMathVar(v:integer);overload;assembler;register;
(*
* @description:
* Sets integer value as the MathVar (operation register for unary)
*
* @param: v (integer) - value to be inserted
*)
procedure SetMathVar(v:float);overload;assembler;register;
(*
* @description:
* Sets float value as the MathVar (operation register for unary)
*
* @param: v (integer) - value to be inserted
*)
procedure DoMathOnStack(cmd:byte);register;
(*
* @description:
* Perform selected operation on the MathStack
*
* @param: cmd (byte) - operation id
*)
procedure DoMathOnVar(cmd:byte);register;
(*
* @description:
* Perform selected operation on the MathVar
*
* @param: cmd (byte) - operation id
*)
function AddFractionalBCD(v0:float;bcd:pointer):float;
(*
* @description:
* Adds fractional part to the float variable
*
* @param: v0 (float) - initial number
* @param: bcd (pointer) - pointer to the array containg BCD nibbles. Must be terminated with $F.
*
* @returns: (float) - returns float value
*)
function NeoIntRandom(range:integer):integer;
(*
* @description:
* Returns an random integer value in the specified range.
*
* @param: range (integer) - upper limit
*
* @returns: (integer) - random value (0..range-1)
*)
function NeoFloatRandom():float;
(*
* @description:
* Returns a random floating point value in the range 0..1
*
* @returns: (float) - random float value (0..1)
*)
procedure NeoStr(i:integer;var s:string);overload;
(*
* @description:
* Converts integer value into string variable (size is returned in the first byte)
*
* @param: i (integer) - value to be converted
* @param: s (string) - pointer to the string to be filled with the result.
*)
procedure NeoStr(i:float;var s:string);overload;
(*
* @description:
* Converts float value into string variable (size is returned in the first byte)
*
* @param: i (float) - value to be converted
* @param: s (string) - pointer to the string to be filled with the result.
*)
function NeoParseInt(var s:string):integer;
(*
* @description:
* Parses string into integer value.
*
* @param: s (string) - string to be converted.
*
* @returns: (integer) - parsed value
*)
function NeoParseFloat(var s:string):float;
(*
* @description:
* Parses string into float value.
*
* @param: s (string) - string to be converted.
*
* @returns: (float) - parsed value
*)
procedure SetDegreeMode;assembler;inline;
(*
* @description:
* Sets the use of degrees.
*)
procedure SetRadianMode;assembler;inline;
(*
* @description:
* Sets the use of radians.
*)
implementation

procedure SetDegreeMode;assembler;inline;
asm
    mva #1  N6502MSG_ADDRESS+4
    mva #35 N6502MSG_ADDRESS+1
    mva #4  N6502MSG_ADDRESS
end;

procedure SetRadianMode;assembler;inline;
asm
    stz N6502MSG_ADDRESS+4
    mva #35 N6502MSG_ADDRESS+1
    mva #4  N6502MSG_ADDRESS
end;

procedure SetMathStack(v:float;i:byte);assembler;overload;register;
asm
    lda i
    bne i1
    mva #$40 STACK_ADDRESS
    mva v    STACK_ADDRESS+2
    mva v+1  STACK_ADDRESS+4
    mva v+2  STACK_ADDRESS+6
    mva v+3  STACK_ADDRESS+8
i1
    mva #$40 STACK_ADDRESS+1
    mva v    STACK_ADDRESS+3
    mva v+1  STACK_ADDRESS+5
    mva v+2  STACK_ADDRESS+7
    mva v+3  STACK_ADDRESS+9
end;

procedure SetMathStack(v:integer;i:byte);assembler;overload;register;
asm
    lda i
    bne i1
    mva #$00 STACK_ADDRESS
    mva v    STACK_ADDRESS+2
    mva v+1  STACK_ADDRESS+4
    mva v+2  STACK_ADDRESS+6
    mva v+3  STACK_ADDRESS+8
i1
    mva #$00 STACK_ADDRESS+1
    mva v    STACK_ADDRESS+3
    mva v+1  STACK_ADDRESS+5
    mva v+2  STACK_ADDRESS+7
    mva v+3  STACK_ADDRESS+9
end;

function GetMathStackFloat:float;assembler;
//var src:array [0..3] of byte absolute result; // @nodoc
asm
    mva STACK_ADDRESS+2 result
    mva STACK_ADDRESS+4 result+1
    mva STACK_ADDRESS+6 result+2
    mva STACK_ADDRESS+8 result+3
end;

function GetMathStackInt:integer;assembler;
//var src:array [0..3] of byte absolute result; // @nodoc
asm
    mva STACK_ADDRESS+2 result
    mva STACK_ADDRESS+4 result+1
    mva STACK_ADDRESS+6 result+2
    mva STACK_ADDRESS+8 result+3
end;

function IsFloatOnStack(i:byte):boolean;
begin
    result := Peek(STACK_ADDRESS + i) and $40 <> 0;
end;

function IsFloatVal:boolean;
begin
    result := peek(VAR_ADDRESS) and $40 <> 0;
end;

procedure SetMathVar(v:integer);overload;assembler;register;
asm
    mva #$00 VAR_ADDRESS
    mva v VAR_ADDRESS+1
    mva v+1 VAR_ADDRESS+2
    mva v+2 VAR_ADDRESS+3
    mva v+3 VAR_ADDRESS+4
end;

procedure SetMathVar(v:float);overload;assembler;register;
asm
    mva #$40 VAR_ADDRESS
    mva v VAR_ADDRESS+1
    mva v+1 VAR_ADDRESS+2
    mva v+2 VAR_ADDRESS+3
    mva v+3 VAR_ADDRESS+4
end;

procedure DoMathOnStack(cmd:byte);register;
begin
    NeoMessage.func:=cmd;
    wordParams[0] := STACK_ADDRESS;
    NeoMessage.params[2] := STACK_SIZE;
    NeoWaitMessage;
    NeoMessage.group:=4;
end;

procedure DoMathOnVar(cmd:byte);register;
begin
    NeoMessage.func:=cmd;
    wordParams[0] := VAR_ADDRESS;
    NeoMessage.params[2] := 1;
    NeoWaitMessage;
    NeoMessage.group:=4;
end;

function AddFractionalBCD(v0:float;bcd:pointer):float;
begin
    SetMathVar(v0);
    wordParams[2] := word(bcd);
    DoMathOnVar(MATHProcessDecimal);
    result := m_float;
end;

function NeoIntRandom(range:integer):integer;
begin
    SetMathVar(range);
    DoMathOnVar(MATHIRnd);
    result := m_integer;
end;

function NeoFloatRandom():float;
begin
    DoMathOnVar(MATHFRnd);
    result := m_float;
end;

procedure NeoStr(i:integer;var s:string);overload;
begin
    SetMathVar(i);
    wordParams[2] := word(@s);
    DoMathOnVar(MATHConvertNumberToString);
end;

procedure NeoStr(i:float;var s:string);overload;
begin
    SetMathVar(i);
    wordParams[2] := word(@s);
    DoMathOnVar(MATHConvertNumberToString);
end;

function NeoParseInt(var s:string):integer;
begin
    wordParams[2] := word(@s);
    DoMathOnVar(MATHConvertStringToNumber);
    if IsFloatVal then DoMathOnVar(MATHFlr);
    result := m_integer;
end;

function NeoParseFloat(var s:string):float;
var b:byte;
begin
    b:=$0f;
    wordParams[2] := word(@s);
    DoMathOnVar(MATHConvertStringToNumber);
    if not IsFloatVal then begin
        wordParams[2] := word(@b);
        DoMathOnVar(MATHProcessDecimal);
    end;
    result := m_float;
end;

end.
