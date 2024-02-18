unit NeoMath;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: Neo6502 API library for RP2040 accelerated Math and other computations.
* @version: 0.1.0

* @description:
* Set of procedures to cover Math API functionality.
* More about Neo6502:
*
* <https://www.olimex.com/Products/Retro-Computers/Neo6502/open-source-hardware>
*
* <https://www.neo6502.com/>     

*    
* API documentation can be found here:   
*
*   <https://github.com/paulscottrobson/neo6502-firmware/wiki>

*   
* It's work in progress, so please report any bugs you will find.   
*   
*)
interface
uses neo6502;

const   
	MATHAdd = 0; 					// Add
	MATHSub = 1; 					// Subtract
	MATHMul = 2; 					// Multiply
	MATHFDiv = 3;					// Float Divide
	MATHIDiv = 4;					// Int Divide
	MATHMod = 5; 					// Int Modulus
    MATHCmp = 6; 					// Compare

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

    STACK_SIZE = 2; // binary operations stack size
    
type TMathVar = record
(*
* @description: 
* Structure used to store value for unary operations
*)
    ctrl:byte;
    val:array[0..3] of byte;
end;

type TMathStack = record
(*
* @description: 
* Structure used to store value for binary operations
*)
    ctrl:array [0..STACK_SIZE-1] of byte;
    v0:array [0..STACK_SIZE-1] of byte;
    v1:array [0..STACK_SIZE-1] of byte;
    v2:array [0..STACK_SIZE-1] of byte;
    v3:array [0..STACK_SIZE-1] of byte;
end;


var 
    mathVar: TMathVar; // unary operation register
    mathStack: TMathStack; // binary operations stack
    m_integer: integer absolute mathVar.val; // integer value returned from unary operations
    m_float: float absolute mathVar.val; // float value returned from unary operations




procedure SetMathStack(v:float;i:byte);overload;
(*
* @description: 
* Inserts float value to the Math stack at the specified position.
* 
* @param: v (float) - value to be inserted
* @param: i (byte) - stack position
* 
*)
procedure SetMathStack(v:integer;i:byte);overload;
(*
* @description: 
* Inserts integer value to the Math stack at the specified position.
* 
* @param: v (integer) - value to be inserted
* @param: i (byte) - stack position
* 
*)
function GetMathStackFloat(ptr:byte):float;
(*
* @description:
* Returns float value from Math stack at the desired position
* 
* @param: ptr (byte) - stack position
* 
* @returns: (float) - value at position ptr represented as an float
*)
function GetMathStackInt(ptr:byte):integer;
(*
* @description:
* Returns integer value from Math stack at the desired position
* 
* @param: ptr (byte) - stack position
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
procedure SetMathVar(v:integer);overload;
(*
* @description: 
* Sets integer value as the MathVar (operation register for unary)
* 
* @param: v (integer) - value to be inserted
*)
procedure SetMathVar(v:float);overload;
(*
* @description: 
* Sets float value as the MathVar (operation register for unary)
* 
* @param: v (integer) - value to be inserted
*)
procedure DoMathOnStack(cmd:byte);
(*
* @description: 
* Perform selected operation on the MathStack
* 
* @param: cmd (byte) - operation id
*)
procedure DoMathOnVar(cmd:byte);
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
implementation


procedure SetMathStack(v:float;i:byte);overload;
var src:array [0..3] of byte absolute v; // @nodoc 
begin
    mathStack.ctrl[i]:=$40;
    mathStack.v0[i]:=src[0];
    mathStack.v1[i]:=src[1];
    mathStack.v2[i]:=src[2];
    mathStack.v3[i]:=src[3];
    inc(i);
end;

procedure SetMathStack(v:integer;i:byte);overload;
var src:array [0..3] of byte absolute v; // @nodoc 
begin
    mathStack.ctrl[i]:=$40;
    mathStack.v0[i]:=src[0];
    mathStack.v1[i]:=src[1];
    mathStack.v2[i]:=src[2];
    mathStack.v3[i]:=src[3];
    inc(i);
end;

function GetMathStackFloat(ptr:byte):float;
var src:array [0..3] of byte absolute result; // @nodoc 
begin
    src[0]:=mathStack.v0[ptr];
    src[1]:=mathStack.v1[ptr];
    src[2]:=mathStack.v2[ptr];
    src[3]:=mathStack.v3[ptr];
end;

function GetMathStackInt(ptr:byte):integer;
var src:array [0..3] of byte absolute result; // @nodoc 
begin
    src[0]:=mathStack.v0[ptr];
    src[1]:=mathStack.v1[ptr];
    src[2]:=mathStack.v2[ptr];
    src[3]:=mathStack.v3[ptr];
end;

function IsFloatOnStack(i:byte):boolean;
begin
    result := mathStack.ctrl[i] and $40 <> 0;
end;

function IsFloatVal:boolean;
begin
    result := MathVar.ctrl and $40 <> 0;
end;

procedure SetMathVar(v:integer);overload;
var target:integer absolute mathVar.val; // @nodoc 
begin
    MathVar.ctrl:=0;
    target:=v;
end;

procedure SetMathVar(v:float);overload;
var target:float absolute mathVar.val; // @nodoc 
begin
    MathVar.ctrl:=$40;
    target:=v;
end;

procedure DoMathOnStack(cmd:byte);
begin
    wordParams[0] := word(@mathStack);
    NeoMessage.params[2] := STACK_SIZE;
    NeoDoMath(cmd);
end;

procedure DoMathOnVar(cmd:byte);
begin
    wordParams[0] := word(@mathVar);
    NeoMessage.params[2] := 1;
    NeoDoMath(cmd);
end;


function AddFractionalBCD(v0:float;bcd:pointer):float;
begin
    SetMathVar(v0);
    wordParams[2] := word(bcd);
    DoMathOnVar(MATHProcessDecimal);
    result:=m_float;
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