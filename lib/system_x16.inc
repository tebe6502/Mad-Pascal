procedure Pause; assembler; overload;
(*
@description:
Delay program execution (1/50 second).
*)
asm
w1	bit vic_cr1
	bpl w1

w2	bit vic_cr1
	bmi w2
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

w1	bit vic_cr1
	bpl w1

w2	bit vic_cr1
	bmi w2

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
	phx
	
	jsr entropy_get
	stx RndSeed
	eor RndSeed
	sty RndSeed+1
	eor RndSeed+1

	plx

end;


function Random: Real; overload;
(*
@description:
Generate random number

@returns: Real (Q24.8)
*)
begin
	asm
		phx

	// again:
	// 	jsr entropy_get
	// 	stx Result
	// 	eor Result
	// 	sty Result+1
	// 	eor Result+1
	// 	sta Result+2
	// 	lsr
	// 	lsr
	// 	lsr
	// 	lsr
	// 	eor Result+2
	// 	and #7
	// 	cmp #0
	// 	beq again	; 0 is illegal
	// 	cmp #7
	// 	beq again	; 7 is illegal

			// 	jsr entropy_get

		stx Result
		sty Result+1
		sta Result+2

		plx
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

		phx

		jsr entropy_get
		stx Result
		sty Result+1
		sta Result+2

		plx

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
		phx

		jsr entropy_get
		stx a
		sty a+1
		sta a+2

		plx
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
	phx

	jsr entropy_get
	sta Result
	tay

	lda	range
	beq	stop

	sta	:ecx
	sty	:eax

	jsr	imulCL
	tay

stop	sty	Result
	plx
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

sign	lda #0
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

