procedure Pause; assembler; overload;
(*
@description:
Delay program execution (1/50 second).
*)
asm
{
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
};
end;

procedure Randomize; assembler;
(*
@description:
Initialize random number generator
*)
asm
{
};
end;


function Random: Real; overload;
(*
@description:
Generate random number

@returns: Real (Q24.8)
*)
begin

end;


function RandomF: Float;
(*
@description:
Generate random number

@returns: Float (Single)
*)
begin

end;


function RandomF16: Float16;
(*
@description:
Generate random number

@returns: Float (Single)
*)
begin

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

end;
