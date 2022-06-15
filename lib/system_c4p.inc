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

 lda ted_timer_1
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

 lda ted_timer_1
 and #$7f
 sta Result+2
 mva ted_timer_1 Result+1

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
	lda ted_timer_1
	and #$7f
	sta a+1

	lda ted_timer_1
	sta a
 end;

 Result:= a * (1/32767);

end;


function Random(range: byte): byte; assembler; overload;
(*
@description:
Generate random number

@param: range (0..range-1)

@returns: byte
*)
asm

  lda ted_timer_1   //Timer A Lo byte
  eor ted_timer_1+1 //Timer A Hi byte
  eor ted_timer_2   //Timer B Lo byte
  adc ted_hcount    //Horizontal counter
  eor ted_timer_3   //Timer C Lo byte
  eor ted_hcount    //Horizontal counter
  tay

  lda range
  beq stop

  sta :ecx
  sty :eax

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
	lda range+1
	bpl plus

	lda Result+1
	bmi ok
	bpl sign

plus	lda Result+1
	bpl ok

sign 	lda #0
	sub Result
	sta Result

	lda #0
	sbc Result+1
	sta Result+1
ok
end;

 end;

end;


function ParamCount: byte; assembler;
(*
@description:
Return number of command-line parameters passed to the program.

@returns: byte
*)
asm


end;


function ParamStr(i: byte): TString; assembler;
(*
@description:
Return value of a command-line argument.

@param: i - of a command-line argument

@returns: string[32]
*)
asm


end;

